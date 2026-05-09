import { t } from "../../trpc-client";
import { getGasSummary } from "./getGasSummary";
import { getOverall } from "./getOverall";
import { getTimeseries } from "./getTimeseries";
import { getGasTime } from "./getGasTime";

export const statsRouter = t.router({
  getTimeseries,
  getOverall,
  getGasSummary,
  getGasTime,
});
