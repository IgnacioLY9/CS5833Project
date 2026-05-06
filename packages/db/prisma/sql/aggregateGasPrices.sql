-- @name aggregateGasPrices

-- @param {Int} $1:from block number
-- @param {Int} $2:to block number

INSERT INTO gas_stats (
  avg_blob_gas_price,
  max_blob_gas_price,
  median_blob_gas_price,
  min_blob_gas_price,
  q1_blob_gas_price,
  q3_blob_gas_price,
  total_blob_gas_price,
  total_blobs,
  updated_at
)
SELECT
  COALESCE(AVG(b.blob_gas_price)::FLOAT, 0),
  COALESCE(MAX(b.blob_gas_price)::FLOAT, 0),
  COALESCE(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.blob_gas_price), 0),
  COALESCE(MIN(b.blob_gas_price)::FLOAT, 0),
  COALESCE(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY b.blob_gas_price), 0),
  COALESCE(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY b.blob_gas_price), 0),
  COALESCE(SUM(b.blob_gas_price)::DECIMAL, 0),
  COALESCE(COUNT(bl_txs.blob_hash)::INT, 0),
  NOW()
FROM blob bl
JOIN blobs_on_transactions bl_txs
  ON bl_txs.blob_hash = bl.versioned_hash
JOIN transaction tx
  ON tx.hash = bl_txs.tx_hash
JOIN block b
  ON b.hash = tx.block_hash
LEFT JOIN transaction_fork tx_f
  ON tx_f.block_hash = tx.block_hash
 AND tx_f.hash = tx.hash
WHERE
  tx_f.hash IS NULL
  AND b.number BETWEEN $1 AND $2;