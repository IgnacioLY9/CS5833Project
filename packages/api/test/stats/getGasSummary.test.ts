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
            "type": "global",
          },
          "metrics": {
            "maxBlobGasPrice": 22,
            "medianBlobGasPrice": 22,
            "minBlobGasPrice": 20,
            "q1BlobGasPrice": 22,
            "q3BlobGasPrice": 22,
          },
        },
      ]
    `);
  });
});