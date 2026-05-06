import { GasStatsModel } from "@blobscan/db/prisma/zod";
import { z } from "@blobscan/zod";

import { publicProcedure } from "../../procedures";
import { normalize } from "../../utils";
import { dimensionSchema, getDimension } from "../../zod-schemas";
import { buildStatsPath } from "./helpers";

const metricsSchema = GasStatsModel.omit({
  id: true,
  updatedAt: true,
});

console.log("getGasSummary loaded");

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
    const allOverallStats = await prisma.gasStats.findMany({
      orderBy: { updatedAt: "desc" },
    });

    return {
      data: allOverallStats.map(
        ({
          updatedAt,
          ...metrics
        }) => ({
          dimension: getDimension(null), // maybe?
          metrics,
          updatedAt,
        })
      ),
    };
  });