-- @param {Int} $1:from The block number from which to start aggregating the data.
-- @param {Int} $2:to The block number until which to aggregate the data.
INSERT INTO gas_stats as curr_stats (

  category,
  rollup,

  total_blobs,
  updated_at
)
SELECT
  CASE WHEN f.rollup IS NOT NULL THEN 'rollup'::category ELSE 'other'::category END AS category,
  f.rollup,

  COALESCE(COUNT(bl_txs.blob_hash)::INT, 0) AS total_blobs,

  NOW() AS updated_at
FROM blob bl
  JOIN blobs_on_transactions bl_txs ON bl_txs.blob_hash = bl.versioned_hash
  JOIN transaction tx ON tx.hash = bl_txs.tx_hash
  JOIN address f ON f.address = tx.from_id
  LEFT JOIN transaction_fork tx_f ON tx_f.block_hash = tx.block_hash AND tx_f.hash = tx.hash
WHERE tx_f.hash IS NULL AND tx.block_number BETWEEN $1 AND $2
GROUP BY GROUPING SETS (
  (category),
  (f.rollup),
  ()
)
--  Exclude NULL rollup aggregates from the second grouping set, as they’re already included in the first when the category is OTHER
HAVING NOT (
  GROUPING(f.rollup) = 0 AND
  f.rollup IS NULL
)
ON CONFLICT (category, rollup) DO UPDATE SET

  total_blobs = curr_stats.total_blobs + EXCLUDED.total_blobs,

  updated_at = EXCLUDED.updated_at

;

INSERT INTO overall_stats AS curr_stats (
    category,
    rollup,
    avg_blob_gas_price,
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
    COALESCE(AVG(b.blob_gas_price)::FLOAT, 0) AS avg_blob_gas_price,
    COALESCE(MIN(b.blob_gas_price)::FLOAT, 0) AS min_blob_gas_price,
    COALESCE(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY b.blob_gas_price)::FLOAT, 0) AS q1_blob_gas_price,
    COALESCE(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY b.blob_gas_price)::FLOAT, 0) AS median_blob_gas_price,
    COALESCE(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY b.blob_gas_price)::FLOAT, 0) AS q3_blob_gas_price,
    COALESCE(MAX(b.blob_gas_price)::FLOAT, 0) AS max_blob_gas_price,
    NOW() AS updated_at
FROM transaction tx
JOIN block b ON b.hash = tx.block_hash
JOIN address from_addr ON from_addr.address = tx.from_id
JOIN address to_addr ON to_addr.address = tx.to_id
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
ON CONFLICT (category, rollup)
DO UPDATE SET
    total_transactions = curr_stats.total_transactions + EXCLUDED.total_transactions,
    total_blob_gas_price = curr_stats.total_blob_gas_price + EXCLUDED.total_blob_gas_price,

    avg_blob_gas_price =
        CASE
            WHEN curr_stats.total_transactions + EXCLUDED.total_transactions = 0 THEN 0
            ELSE (curr_stats.total_blob_gas_price + EXCLUDED.total_blob_gas_price)
                 / (curr_stats.total_transactions + EXCLUDED.total_transactions)
        END,

    min_blob_gas_price = LEAST(curr_stats.min_blob_gas_price, EXCLUDED.min_blob_gas_price),
    max_blob_gas_price = GREATEST(curr_stats.max_blob_gas_price, EXCLUDED.max_blob_gas_price),

    q1_blob_gas_price = EXCLUDED.q1_blob_gas_price,
    median_blob_gas_price = EXCLUDED.median_blob_gas_price,
    q3_blob_gas_price = EXCLUDED.q3_blob_gas_price,

    updated_at = EXCLUDED.updated_at;