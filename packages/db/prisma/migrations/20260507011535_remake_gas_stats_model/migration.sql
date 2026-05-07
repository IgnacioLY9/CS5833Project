/*
  Warnings:

  - You are about to drop the column `max_blob_gas_price` on the `overall_stats` table. All the data in the column will be lost.
  - You are about to drop the column `median_blob_gas_price` on the `overall_stats` table. All the data in the column will be lost.
  - You are about to drop the column `min_blob_gas_price` on the `overall_stats` table. All the data in the column will be lost.
  - You are about to drop the column `q1_blob_gas_price` on the `overall_stats` table. All the data in the column will be lost.
  - You are about to drop the column `q3_blob_gas_price` on the `overall_stats` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "overall_stats" DROP COLUMN "max_blob_gas_price",
DROP COLUMN "median_blob_gas_price",
DROP COLUMN "min_blob_gas_price",
DROP COLUMN "q1_blob_gas_price",
DROP COLUMN "q3_blob_gas_price";

-- CreateTable
CREATE TABLE "gas_stats" (
    "id" SERIAL NOT NULL,
    "category" "category",
    "rollup" "rollup",
    "max_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "median_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "min_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "q1_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "q3_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "gas_stats_pkey" PRIMARY KEY ("id")
);
