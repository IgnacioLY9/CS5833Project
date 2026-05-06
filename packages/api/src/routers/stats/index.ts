import { t } from "../../trpc-client";
import { getGasSummary } from "./getGasSummary";
import { getOverall } from "./getOverall";
import { getTimeseries } from "./getTimeseries";

export const statsRouter = t.router({
  getTimeseries,
  getOverall,
  getGasSummary,
});
