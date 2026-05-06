-- @name aggregateGasPrices

-- @param {Int} $1:from block number
-- @param {Int} $2:to block number

WITH valid_txs AS (
  SELECT
    tx.*,
    b.blob_gas_price,
    b.number AS block_number
  FROM transaction tx
  JOIN block b
    ON b.hash = tx.block_hash
  LEFT JOIN transaction_fork tx_f
    ON tx_f.block_hash = tx.block_hash
   AND tx_f.hash = tx.hash
  WHERE tx_f.hash IS NULL
    AND b.number BETWEEN $1 AND $2
),

valid_blobs AS (
  SELECT DISTINCT
    bl.versioned_hash
  FROM blob bl
  JOIN blobs_on_transactions bl_txs
    ON bl_txs.blob_hash = bl.versioned_hash
  JOIN valid_txs tx
    ON tx.hash = bl_txs.tx_hash
),

valid_blocks AS (
  SELECT DISTINCT
    b.number,
    b.blob_gas_price
  FROM block b
  WHERE b.number BETWEEN $1 AND $2
)

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
  COALESCE(AVG(vb.blob_gas_price)::FLOAT, 0) AS avg_blob_gas_price,
  COALESCE(MAX(vb.blob_gas_price)::FLOAT, 0) AS max_blob_gas_price,
  COALESCE(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vb.blob_gas_price), 0),
  COALESCE(MIN(vb.blob_gas_price)::FLOAT, 0),
  COALESCE(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY vb.blob_gas_price), 0),
  COALESCE(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY vb.blob_gas_price), 0),

  COALESCE(SUM(vb.blob_gas_price)::DECIMAL, 0) AS total_blob_gas_price,
  COALESCE(COUNT(vb.number)::INT, 0) AS total_blobs,

  NOW()
FROM valid_blocks vb;