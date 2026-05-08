import { TRPCError } from "@trpc/server";

import { z } from "@blobscan/zod";

import {
  createExpandsSchema,
  withExpands,
} from "../../middlewares/withExpands";
import { publicProcedure } from "../../procedures";
import { normalize } from "../../utils";
import type { CompletedPrismaBlob } from "./helpers";
import {
  responseBlobSchema,
  createBlobSelect,
} from "./helpers";

const inputSchema = z
  .object({
    id: z.string(),
  })
  .merge(createExpandsSchema(["transaction", "block"]));

const outputSchema = responseBlobSchema.omit({
    "versionedHash": true,
    "commitment": true,
    "proof": true,
    "usageSize": true,
    "size": true,
    "dataStorageReferences": true
}).transform(normalize);

export const getBlobTransactions = publicProcedure
  .meta({
    openapi: {
      method: "GET",
      path: "/blobs/transactions/{id}",
      tags: ["blobs"],
      summary:
        "retrieves blob transactions for given versioned hash or kzg commitment.",
    },
  })
  .input(inputSchema)
  .use(withExpands)
  .output(outputSchema)
  .query(async ({ ctx: { prisma, expands }, input }) => {
    const { id } = input;
    const isExpandEnabled = !!expands.block || !!expands.transaction;

    const [prismaBlob, _] = await Promise.all([
      prisma.blob.findFirst({
        select: createBlobSelect(expands),
        where: {
          OR: [{ versionedHash: id }, { commitment: id }],
        },
      }) as unknown as Promise<CompletedPrismaBlob | null>,
      isExpandEnabled ? prisma.blob.findEthUsdPrices(id) : Promise.resolve([]),
    ]);

    if (!prismaBlob) {
      throw new TRPCError({
        code: "NOT_FOUND",
        message: `No blob with versioned hash or kzg commitment '${id}'.`,
      });
    }

    return {
        transactions: prismaBlob.transactions
    }
  });
