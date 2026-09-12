CREATE OR REPLACE VIEW analytics.vw_merchant_performance AS
SELECT
    m.merchant_name,
    m.category,
    COUNT(*) AS transaction_count,
    ROUND(SUM(f.amount), 2) AS total_amount,
    ROUND(AVG(f.amount), 2) AS average_amount
FROM dwh.fact_transactions f
JOIN dwh.dim_merchant m
  ON m.merchant_key = f.merchant_key
GROUP BY m.merchant_name, m.category;

CREATE OR REPLACE VIEW analytics.vw_customer_monthly_metrics AS
WITH monthly AS (
    SELECT
        c.customer_id,
        c.full_name,
        DATE_TRUNC('month', f.transaction_date)::date AS month,
        SUM(f.amount) AS total_spending,
        COUNT(*) AS transaction_count
    FROM dwh.fact_transactions f
    JOIN dwh.dim_customer c
      ON c.customer_key = f.customer_key
    GROUP BY c.customer_id, c.full_name, DATE_TRUNC('month', f.transaction_date)
),
with_previous AS (
    SELECT
        *,
        LAG(total_spending) OVER (
            PARTITION BY customer_id
            ORDER BY month
        ) AS previous_month_spending
    FROM monthly
)
SELECT
    customer_id,
    full_name,
    month,
    ROUND(total_spending, 2) AS total_spending,
    transaction_count,
    ROUND(previous_month_spending, 2) AS previous_month_spending,
    ROUND(
        CASE
            WHEN previous_month_spending IS NULL OR previous_month_spending = 0
                THEN NULL
            ELSE ((total_spending - previous_month_spending)
                  / previous_month_spending) * 100
        END,
        2
    ) AS month_over_month_pct
FROM with_previous;

CREATE TABLE IF NOT EXISTS analytics.customer_monthly_summary (
    customer_id BIGINT NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    month DATE NOT NULL,
    total_spending NUMERIC(16,2) NOT NULL,
    transaction_count BIGINT NOT NULL,
    PRIMARY KEY (customer_id, month)
);

CREATE OR REPLACE PROCEDURE analytics.refresh_customer_monthly_summary()
LANGUAGE plpgsql
AS $$
BEGIN
    TRUNCATE analytics.customer_monthly_summary;

    INSERT INTO analytics.customer_monthly_summary
        (customer_id, full_name, month, total_spending, transaction_count)
    SELECT
        customer_id,
        full_name,
        month,
        total_spending,
        transaction_count
    FROM analytics.vw_customer_monthly_metrics;
END;
$$;
