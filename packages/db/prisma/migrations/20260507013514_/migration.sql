/*
  Warnings:

  - A unique constraint covering the columns `[category,rollup]` on the table `gas_stats` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "gas_stats_category_rollup_key" ON "gas_stats"("category", "rollup");
