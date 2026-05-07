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
      .getOverall()
      .then((res) => res.data.map((s) => omitDBTimestampFields(s)));

    expect(overallStats).toMatchInlineSnapshot(`
      [
        {
          "dimension": {
            "name": "other",
            "type": "category",
          },
          "metrics": {
            "avgBlobGasPrice": 21.77777777777778,
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
            "totalBlobGasPrice": 196n,
            "totalBlobs": 15,
          },
        },
        {
          "dimension": {
            "name": "rollup",
            "type": "category",
          },
          "metrics": {
            "avgBlobGasPrice": 21.71428571428572,
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
            "totalBlobGasPrice": 152n,
            "totalBlobs": 14,
          },
        },
        {
          "dimension": {
            "name": "arbitrum",
            "type": "rollup",
          },
          "metrics": {
            "avgBlobGasPrice": 22,
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
            "totalBlobGasPrice": 22n,
            "totalBlobs": 1,
          },
        },
        {
          "dimension": {
            "name": "base",
            "type": "rollup",
          },
          "metrics": {
            "avgBlobGasPrice": 22,
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
            "totalBlobGasPrice": 44n,
            "totalBlobs": 4,
          },
        },
        {
          "dimension": {
            "name": "optimism",
            "type": "rollup",
          },
          "metrics": {
            "avgBlobGasPrice": 21.5,
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
            "totalBlobGasPrice": 86n,
            "totalBlobs": 9,
          },
        },
        {
          "dimension": {
            "type": "global",
          },
          "metrics": {
            "avgBlobGasPrice": 21.75,
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
            "totalBlobGasPrice": 348n,
            "totalBlobs": 29,
          },
        },
      ]
    `);
  });
});