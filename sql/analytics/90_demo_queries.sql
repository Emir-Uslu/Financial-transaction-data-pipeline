-- 1) Top merchants by total transaction amount
SELECT *
FROM analytics.vw_merchant_performance
ORDER BY total_amount DESC
LIMIT 10;

-- 2) Customer monthly metrics (CTE + window function inside the view)
SELECT *
FROM analytics.vw_customer_monthly_metrics
ORDER BY customer_id, month
LIMIT 50;

-- 3) Pipeline audit history
SELECT *
FROM audit.pipeline_runs
ORDER BY started_at DESC;

-- 4) Data-quality errors by type
SELECT error_type, COUNT(*) AS error_count
FROM audit.data_quality_errors
GROUP BY error_type
ORDER BY error_count DESC;

-- 5) Partition inspection
SELECT
    tableoid::regclass AS partition_name,
    COUNT(*) AS row_count
FROM dwh.fact_transactions
GROUP BY tableoid::regclass
ORDER BY partition_name;

-- 6) Index/query-plan demonstration
EXPLAIN ANALYZE
SELECT *
FROM dwh.fact_transactions
WHERE customer_key = 100;
