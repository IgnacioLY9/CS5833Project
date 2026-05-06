import { beforeAll, beforeEach, describe, expect, it } from "vitest";

import { omitDBTimestampFields } from "@blobscan/test";

import type { TRPCContext } from "../../src";
import { createTestContext } from "../helpers";
import { createStatsCaller } from "./caller";
import type { StatsCaller } from "./caller";

describe("getGasSummary", () => {
  let caller: StatsCaller;
  let ctx: TRPCContext;

  beforeAll(async () => {
    ctx = await createTestContext();

    caller = createStatsCaller(ctx);
  });

  beforeEach(async () => {
    await ctx.prisma.overallStats.aggregate();
  });

  it("should return only global stats", async () => {
    const gasStats = await caller.getGasSummary().then((res) =>
      res.data
        .map((s) => omitDBTimestampFields(s))
        .filter((s) => s.dimension.type === "global")
    );

    expect(gasStats).toMatchInlineSnapshot(`
      [
        {
          "dimension": {
            "type": "global",
          },
          "metrics": {
            "avgBlobGasPrice": 21.75,
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 20,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
            "totalBlobGasPrice": 348n,
            "totalBlobs": 29,
          },
        },
      ]
    `);
  });
});