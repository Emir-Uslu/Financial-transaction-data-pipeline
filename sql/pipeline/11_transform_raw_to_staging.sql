TRUNCATE staging.stg_transactions, staging.stg_customers, staging.stg_merchants;

INSERT INTO staging.stg_customers
    (customer_id, full_name, email, city, signup_date)
SELECT DISTINCT ON (customer_id::bigint)
    customer_id::bigint,
    TRIM(full_name),
    NULLIF(TRIM(email), ''),
    INITCAP(TRIM(city)),
    signup_date::date
FROM raw.customers
WHERE customer_id IS NOT NULL
  AND full_name IS NOT NULL
  AND signup_date IS NOT NULL
ORDER BY customer_id::bigint, ingested_at DESC;

INSERT INTO staging.stg_merchants
    (merchant_id, merchant_name, category, city, country)
SELECT DISTINCT ON (merchant_id::bigint)
    merchant_id::bigint,
    TRIM(merchant_name),
    INITCAP(TRIM(category)),
    INITCAP(TRIM(city)),
    INITCAP(TRIM(country))
FROM raw.merchants
WHERE merchant_id IS NOT NULL
  AND merchant_name IS NOT NULL
ORDER BY merchant_id::bigint, ingested_at DESC;

WITH ranked AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY transaction_id
            ORDER BY ingested_at DESC
        ) AS rn
    FROM raw.transactions t
)
INSERT INTO staging.stg_transactions
    (transaction_id, customer_id, merchant_id, transaction_date,
     amount, currency, transaction_type)
SELECT
    r.transaction_id::bigint,
    r.customer_id::bigint,
    r.merchant_id::bigint,
    r.transaction_date::date,
    r.amount::numeric(14,2),
    UPPER(TRIM(r.currency)),
    LOWER(TRIM(r.transaction_type))
FROM ranked r
JOIN staging.stg_customers c
  ON c.customer_id = r.customer_id::bigint
JOIN staging.stg_merchants m
  ON m.merchant_id = r.merchant_id::bigint
WHERE r.rn = 1
  AND r.amount::numeric > 0;
