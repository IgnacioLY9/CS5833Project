-- @param {Int} $1:from block number
-- @param {Int} $2:to block number

INSERT INTO gas_stats AS curr_stats (
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
  COALESCE(AVG(b.blob_gas_price)::FLOAT, 0) AS avg_blob_gas_price,
  COALESCE(MAX(b.blob_gas_price)::FLOAT, 0) AS max_blob_gas_price,
  COALESCE(
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY b.blob_gas_price),
    0
  ) AS median_blob_gas_price,
  COALESCE(MIN(b.blob_gas_price)::FLOAT, 0) AS min_blob_gas_price,
  COALESCE(
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY b.blob_gas_price),
    0
  ) AS q1_blob_gas_price,
  COALESCE(
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY b.blob_gas_price),
    0
  ) AS q3_blob_gas_price,

  COALESCE(SUM(b.blob_gas_price)::DECIMAL, 0) AS total_blob_gas_price,

  COALESCE(COUNT(bl_txs.blob_hash)::INT, 0) AS total_blobs,

  NOW() AS updated_at

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
  AND b.number BETWEEN $1 AND $2

ON CONFLICT DO UPDATE SET
  avg_blob_gas_price = EXCLUDED.avg_blob_gas_price,
  max_blob_gas_price = EXCLUDED.max_blob_gas_price,
  median_blob_gas_price = EXCLUDED.median_blob_gas_price,
  min_blob_gas_price = EXCLUDED.min_blob_gas_price,
  q1_blob_gas_price = EXCLUDED.q1_blob_gas_price,
  q3_blob_gas_price = EXCLUDED.q3_blob_gas_price,

  total_blob_gas_price =
    gas_stats.total_blob_gas_price + EXCLUDED.total_blob_gas_price,

  total_blobs =
    gas_stats.total_blobs + EXCLUDED.total_blobs,

  updated_at = EXCLUDED.updated_at;