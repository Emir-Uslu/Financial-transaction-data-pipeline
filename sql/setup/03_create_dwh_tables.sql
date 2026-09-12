CREATE TABLE IF NOT EXISTS dwh.dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id BIGINT UNIQUE NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(200),
    city VARCHAR(100),
    signup_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.dim_merchant (
    merchant_key BIGSERIAL PRIMARY KEY,
    merchant_id BIGINT UNIQUE NOT NULL,
    merchant_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dwh.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    year SMALLINT NOT NULL,
    quarter SMALLINT NOT NULL,
    month SMALLINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day SMALLINT NOT NULL,
    day_of_week SMALLINT NOT NULL
);

CREATE TABLE IF NOT EXISTS dwh.fact_transactions (
    transaction_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    date_key INTEGER NOT NULL REFERENCES dwh.dim_date(date_key),
    customer_key BIGINT NOT NULL REFERENCES dwh.dim_customer(customer_key),
    merchant_key BIGINT NOT NULL REFERENCES dwh.dim_merchant(merchant_key),
    amount NUMERIC(14,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    PRIMARY KEY (transaction_id, transaction_date)
) PARTITION BY RANGE (transaction_date);

CREATE TABLE IF NOT EXISTS dwh.fact_transactions_2025
PARTITION OF dwh.fact_transactions
FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE IF NOT EXISTS dwh.fact_transactions_2026
PARTITION OF dwh.fact_transactions
FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

CREATE TABLE IF NOT EXISTS dwh.fact_transactions_default
PARTITION OF dwh.fact_transactions DEFAULT;
