-- @param {Int} $1:from The block number from which to start aggregating the data.
-- @param {Int} $2:to The block number until which to aggregate the data.

INSERT INTO gas_stats AS curr_stats (
  category,
  rollup,
  max_blob_gas_price,
  median_blob_gas_price,
  min_blob_gas_price,
  q1_blob_gas_price,
  q3_blob_gas_price,
  updated_at
)

WITH base AS (
  SELECT
    tx.gas_price::float AS gas_price,
    from_addr.rollup AS rollup
  FROM transaction tx
  JOIN block b ON b.hash = tx.block_hash
  JOIN address from_addr ON from_addr.address = tx.from_id
  LEFT JOIN transaction_fork tf
    ON tf.block_hash = b.hash AND tf.hash = tx.hash
  WHERE tf.hash IS NULL
    AND b.number BETWEEN $1 AND $2
),

aggregated AS (
  SELECT
    CASE
      WHEN GROUPING(rollup) = 1 THEN 'other'::category
      WHEN rollup IS NULL THEN 'other'::category
      ELSE 'rollup'::category
    END AS category,

    rollup,

    COALESCE(MAX(gas_price), 0)::float AS max_blob_gas_price,
    COALESCE(MIN(gas_price), 0)::float AS min_blob_gas_price,

    COALESCE(
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gas_price),
      0
    )::float AS median_blob_gas_price,

    COALESCE(
      PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY gas_price),
      0
    )::float AS q1_blob_gas_price,

    COALESCE(
      PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY gas_price),
      0
    )::float AS q3_blob_gas_price

  FROM base
  GROUP BY GROUPING SETS (
    (rollup),
    ()
  )
)

SELECT
  category,
  rollup,
  max_blob_gas_price,
  median_blob_gas_price,
  min_blob_gas_price,
  q1_blob_gas_price,
  q3_blob_gas_price,
  NOW() AS updated_at
FROM aggregated

ON CONFLICT (category, rollup) DO UPDATE SET
  max_blob_gas_price = EXCLUDED.max_blob_gas_price,
  min_blob_gas_price = EXCLUDED.min_blob_gas_price,
  median_blob_gas_price = EXCLUDED.median_blob_gas_price,
  q1_blob_gas_price = EXCLUDED.q1_blob_gas_price,
  q3_blob_gas_price = EXCLUDED.q3_blob_gas_price,
  updated_at = NOW();