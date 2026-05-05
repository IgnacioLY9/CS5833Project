import { OverallStatsModel } from "@blobscan/db/prisma/zod";
import { z } from "@blobscan/zod";

import { publicProcedure } from "../../procedures";
import { normalize } from "../../utils";
import { dimensionSchema, getDimension } from "../../zod-schemas";
import { buildStatsPath } from "./helpers";

const metricsSchema = OverallStatsModel.omit({
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
        metrics: ,
        updatedAt: OverallStatsModel.shape.updatedAt,
      })
      .array(),
  })
  .transform(normalize);