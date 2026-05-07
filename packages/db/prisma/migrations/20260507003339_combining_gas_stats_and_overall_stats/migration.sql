/*
  Warnings:

  - You are about to drop the `gas_stats` table. If the table is not empty, all the data it contains will be lost.

*/
-- AlterTable
ALTER TABLE "overall_stats" ADD COLUMN     "max_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "median_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "min_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "q1_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0,
ADD COLUMN     "q3_blob_gas_price" DOUBLE PRECISION NOT NULL DEFAULT 0;

-- DropTable
DROP TABLE "gas_stats";
