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
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
          },
        },
        {
          "dimension": {
            "name": "rollup",
            "type": "category",
          },
          "metrics": {
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
          },
        },
        {
          "dimension": {
            "name": "arbitrum",
            "type": "rollup",
          },
          "metrics": {
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
          },
        },
        {
          "dimension": {
            "name": "base",
            "type": "rollup",
          },
          "metrics": {
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
          },
        },
        {
          "dimension": {
            "name": "optimism",
            "type": "rollup",
          },
          "metrics": {
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
          },
        },
        {
          "dimension": {
            "type": "global",
          },
          "metrics": {
            "maxBlobGasPrice": null,
            "medianBlobGasPrice": null,
            "minBlobGasPrice": null,
            "q1BlobGasPrice": null,
            "q3BlobGasPrice": null,
          },
        },
      ]
    `);
  });
});