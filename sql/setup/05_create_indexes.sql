CREATE INDEX IF NOT EXISTS idx_stg_transactions_customer
    ON staging.stg_transactions(customer_id);

CREATE INDEX IF NOT EXISTS idx_stg_transactions_merchant
    ON staging.stg_transactions(merchant_id);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_customer
    ON dwh.fact_transactions(customer_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_merchant
    ON dwh.fact_transactions(merchant_key);

CREATE INDEX IF NOT EXISTS idx_fact_transactions_date
    ON dwh.fact_transactions(date_key);
