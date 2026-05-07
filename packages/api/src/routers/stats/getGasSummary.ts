import { GasStatsModel } from "@blobscan/db/prisma/zod";
import { z } from "@blobscan/zod";

import { publicProcedure } from "../../procedures";
import { normalize } from "../../utils";
import { dimensionSchema, getDimension } from "../../zod-schemas";
import { buildStatsPath } from "./helpers";

const metricsSchema = GasStatsModel.omit({
  id: true,
  category: true,
  rollup: true,
  updatedAt: true,
});

const outputSchema = z
  .object({
    data: z
      .object({
        dimension: dimensionSchema,
        metrics: metricsSchema,
        updatedAt: GasStatsModel.shape.updatedAt,
      })
      .array(),
  })
   .transform(normalize);

export const getGasSummary = publicProcedure
  .meta({
    openapi: {
      method: "GET",
      path: buildStatsPath("gassummary"),
      tags: ["stats"],
      summary: "retrieves statistics of gas prices.",
    },
  })
  .input(z.void())
  .output(outputSchema)
  .query(async ({ ctx: { prisma } }) => {
    const latestGasStats = await prisma.gasStats.findFirst({
      orderBy: { updatedAt: "desc" },
    });

    if (!latestGasStats) {
      return { data: [] };
    }

    const { updatedAt, ...metrics } = latestGasStats;

    return {
      data: [
        {
          dimension: getDimension(null),
          metrics,
          updatedAt,
        },
      ],
    };
  });
