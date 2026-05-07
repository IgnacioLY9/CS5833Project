import { beforeAll, beforeEach, describe, expect, it } from "vitest";

import { omitDBTimestampFields } from "@blobscan/test";

import type { TRPCContext } from "../../src";
import { createTestContext } from "../helpers";
import { createStatsCaller } from "./caller";
import type { StatsCaller } from "./caller";

describe("getOverall", () => {
  let caller: StatsCaller;
  let ctx: TRPCContext;

  beforeAll(async () => {
    ctx = await createTestContext();

    caller = createStatsCaller(ctx);
  });

  beforeEach(async () => {
    await ctx.prisma.overallStats.aggregate();
  });

  it("should return the correct overall stats", async () => {
    const overallStats = await caller
      .getGasSummary()
      .then((res) => res.data.map((s) => omitDBTimestampFields(s)));

    expect(overallStats).toMatchInlineSnapshot(`
      [
        {
          "dimension": {
            "name": "other",
            "type": "category",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 22,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
          },
        },
        {
          "dimension": {
            "name": "rollup",
            "type": "category",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 22,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
          },
        },
        {
          "dimension": {
            "name": "arbitrum",
            "type": "rollup",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 22,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
          },
        },
        {
          "dimension": {
            "name": "base",
            "type": "rollup",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 22,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
          },
        },
        {
          "dimension": {
            "name": "optimism",
            "type": "rollup",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 20,
            "q1BlobGasPrice": 21.5,
            "q3BlobGasPrice": 22,
          },
        },
        {
          "dimension": {
            "type": "global",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 22,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
          },
        },
      ]
    `);
  });
});