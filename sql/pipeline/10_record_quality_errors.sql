DELETE FROM audit.data_quality_errors
WHERE run_id IN (
    SELECT DISTINCT ingestion_run_id
    FROM raw.transactions
);

INSERT INTO audit.data_quality_errors
    (run_id, source_table, record_id, error_type, error_message)
SELECT
    t.ingestion_run_id,
    'raw.transactions',
    t.transaction_id,
    'INVALID_AMOUNT',
    'Transaction amount must be greater than zero.'
FROM raw.transactions t
WHERE t.amount::numeric <= 0;

INSERT INTO audit.data_quality_errors
    (run_id, source_table, record_id, error_type, error_message)
SELECT
    t.ingestion_run_id,
    'raw.transactions',
    t.transaction_id,
    'MISSING_CUSTOMER',
    'customer_id does not exist in raw.customers.'
FROM raw.transactions t
LEFT JOIN raw.customers c
    ON c.customer_id = t.customer_id
WHERE c.customer_id IS NULL;

INSERT INTO audit.data_quality_errors
    (run_id, source_table, record_id, error_type, error_message)
SELECT
    t.ingestion_run_id,
    'raw.transactions',
    t.transaction_id,
    'MISSING_MERCHANT',
    'merchant_id does not exist in raw.merchants.'
FROM raw.transactions t
LEFT JOIN raw.merchants m
    ON m.merchant_id = t.merchant_id
WHERE m.merchant_id IS NULL;

INSERT INTO audit.data_quality_errors
    (run_id, source_table, record_id, error_type, error_message)
SELECT
    t.ingestion_run_id,
    'raw.transactions',
    t.transaction_id,
    'DUPLICATE_TRANSACTION',
    'Duplicate transaction_id detected.'
FROM raw.transactions t
GROUP BY t.ingestion_run_id, t.transaction_id
HAVING COUNT(*) > 1;
