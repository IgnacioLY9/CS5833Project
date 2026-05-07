-- @param {Int} $1:from
-- @param {Int} $2:to

INSERT INTO gas_stats AS curr_stats (
  category,
  rollup,
  min_blob_gas_price,
  q1_blob_gas_price,
  median_blob_gas_price,
  q3_blob_gas_price,
  max_blob_gas_price,
  updated_at
)
SELECT
  CASE
    WHEN from_addr.rollup IS NOT NULL THEN 'rollup'::category
    ELSE 'other'::category
  END AS category,
  from_addr.rollup,

  MIN(b.blob_gas_price) AS min_blob_gas_price,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY b.blob_gas_price) AS q1_blob_gas_price,
  PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY b.blob_gas_price) AS median_blob_gas_price,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY b.blob_gas_price) AS q3_blob_gas_price,
  MAX(b.blob_gas_price) AS max_blob_gas_price,

  NOW() AS updated_at

FROM transaction tx
JOIN block b ON b.hash = tx.block_hash
JOIN address from_addr ON from_addr.address = tx.from_id
LEFT JOIN transaction_fork tx_f
  ON tx_f.block_hash = b.hash
 AND tx_f.hash = tx.hash

WHERE tx_f.hash IS NULL
  AND b.number BETWEEN $1 AND $2

GROUP BY GROUPING SETS (
  (category),
  (from_addr.rollup),
  ()
)

HAVING NOT (
  GROUPING(from_addr.rollup) = 0
  AND from_addr.rollup IS NULL
)

ON CONFLICT (category, rollup) DO UPDATE SET
  min_blob_gas_price = EXCLUDED.min_blob_gas_price,
  q1_blob_gas_price = EXCLUDED.q1_blob_gas_price,
  median_blob_gas_price = EXCLUDED.median_blob_gas_price,
  q3_blob_gas_price = EXCLUDED.q3_blob_gas_price,
  max_blob_gas_price = EXCLUDED.max_blob_gas_price,
  updated_at = EXCLUDED.updated_at;