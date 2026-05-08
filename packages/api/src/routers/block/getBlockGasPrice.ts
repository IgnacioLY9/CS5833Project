import { TRPCError } from "@trpc/server";

import { parsedBlockIdSchema } from "@blobscan/db/prisma/zod-utils";
import { z } from "@blobscan/zod";

import {
  createExpandsSchema,
  withExpands,
} from "../../middlewares/withExpands";
import {
  withFilters,
  withTypeFilterSchema,
} from "../../middlewares/withFilters";
import { publicProcedure } from "../../procedures";
import { normalize } from "../../utils";
import { fetchBlock, toResponseBlock, blobGasPriceSchema } from "./helpers";

const inputSchema = z
  .object({
    id: parsedBlockIdSchema,
  })
  .merge(withTypeFilterSchema)
  .merge(createExpandsSchema(["transaction", "blob"]));

const outputSchema = blobGasPriceSchema.transform(normalize);

export const getBlockGasPrice = publicProcedure
  .meta({
    openapi: {
      method: "GET",
      path: `/blocks/{gasPrice}`,
      tags: ["blocks"],
      summary: "retrieves blob gas price of a block for given block number or hash.",
      description: "This endpoint retrieves the blob gas price of a block. If that block does not contain any blobs, an error will be returned."
    },
  })
  .input(inputSchema)
  .use(withExpands)
  .use(withFilters)
  .output(outputSchema)
  .query(async ({ ctx: { prisma, expands, filters }, input: { id } }) => {
    const res = await fetchBlock(id, {
      prisma,
      filters,
      expands,
    });

    if (!res) {
      throw new TRPCError({
        code: "NOT_FOUND",
        message: `Block with id "${id.value}" not found. It is possible this block exists, but it does not contain any blobs`,
      });
    }

    return {
        blobGasPrice: res.block.blobGasPrice,
    };
  });
