TRUNCATE
    dwh.fact_transactions,
    dwh.dim_customer,
    dwh.dim_merchant,
    dwh.dim_date
RESTART IDENTITY CASCADE;

INSERT INTO dwh.dim_customer
    (customer_id, full_name, email, city, signup_date)
SELECT
    customer_id, full_name, email, city, signup_date
FROM staging.stg_customers;

INSERT INTO dwh.dim_merchant
    (merchant_id, merchant_name, category, city, country)
SELECT
    merchant_id, merchant_name, category, city, country
FROM staging.stg_merchants;

INSERT INTO dwh.dim_date
    (date_key, full_date, year, quarter, month, month_name, day, day_of_week)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::integer,
    d::date,
    EXTRACT(YEAR FROM d)::smallint,
    EXTRACT(QUARTER FROM d)::smallint,
    EXTRACT(MONTH FROM d)::smallint,
    TO_CHAR(d, 'FMMonth'),
    EXTRACT(DAY FROM d)::smallint,
    EXTRACT(ISODOW FROM d)::smallint
FROM generate_series(
    (SELECT MIN(transaction_date) FROM staging.stg_transactions),
    (SELECT MAX(transaction_date) FROM staging.stg_transactions),
    INTERVAL '1 day'
) AS d;

INSERT INTO dwh.fact_transactions
    (transaction_id, transaction_date, date_key,
     customer_key, merchant_key, amount, currency, transaction_type)
SELECT
    t.transaction_id,
    t.transaction_date,
    TO_CHAR(t.transaction_date, 'YYYYMMDD')::integer,
    c.customer_key,
    m.merchant_key,
    t.amount,
    t.currency,
    t.transaction_type
FROM staging.stg_transactions t
JOIN dwh.dim_customer c
  ON c.customer_id = t.customer_id
JOIN dwh.dim_merchant m
  ON m.merchant_id = t.merchant_id;
