CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id TEXT,
    full_name TEXT,
    email TEXT,
    city TEXT,
    signup_date TEXT,
    ingestion_run_id UUID NOT NULL,
    ingested_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw.merchants (
    merchant_id TEXT,
    merchant_name TEXT,
    category TEXT,
    city TEXT,
    country TEXT,
    ingestion_run_id UUID NOT NULL,
    ingested_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw.transactions (
    transaction_id TEXT,
    customer_id TEXT,
    merchant_id TEXT,
    transaction_date TEXT,
    amount TEXT,
    currency TEXT,
    transaction_type TEXT,
    ingestion_run_id UUID NOT NULL,
    ingested_at TIMESTAMP NOT NULL DEFAULT NOW()
);
