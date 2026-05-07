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