import { t } from "../../trpc-client";
import type { ProcedureConfig } from "../../types";
import { createWeaveVMReferences } from "./createWeaveVMReferences";
import { getAll } from "./getAll";
import { createBlobDataByBlobIdProcedure } from "./getBlobDataByBlobId";
import { getBlobTransactions } from "./getBlobTransactions";
import { getByBlobId } from "./getByBlobId";
import { getCount } from "./getCount";

export type BlobRouterConfig = {
  blobDataProcedure: ProcedureConfig;
};

export function createBlobRouter(config?: BlobRouterConfig) {
  return t.router({
    createWeaveVMReferences,
    getAll,
    getByBlobId,
    getBlobTransactions,
    getCount,
    getBlobDataByBlobId: createBlobDataByBlobIdProcedure(
      config?.blobDataProcedure
    ),
  });
}
