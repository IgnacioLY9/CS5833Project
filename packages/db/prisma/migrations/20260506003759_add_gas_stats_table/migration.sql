-- CreateTable
CREATE TABLE "gas_stats" (
    "id" SERIAL NOT NULL,
    "avg_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "max_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "median_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "min_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "q1_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "q3_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "total_blob_gas_price" DECIMAL(100,0) NOT NULL DEFAULT 0,
    "total_blobs" INTEGER NOT NULL DEFAULT 0,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gas_stats_pkey" PRIMARY KEY ("id")
);
