CREATE TABLE IF NOT EXISTS staging.stg_customers (
    customer_id BIGINT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(200),
    city VARCHAR(100),
    signup_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS staging.stg_merchants (
    merchant_id BIGINT PRIMARY KEY,
    merchant_name VARCHAR(150) NOT NULL,
    category VARCHAR(100),
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS staging.stg_transactions (
    transaction_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    merchant_id BIGINT NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL
);
