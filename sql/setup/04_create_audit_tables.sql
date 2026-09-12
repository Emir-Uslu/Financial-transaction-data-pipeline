CREATE TABLE IF NOT EXISTS audit.pipeline_runs (
    run_id UUID PRIMARY KEY,
    started_at TIMESTAMP NOT NULL,
    finished_at TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    rows_extracted INTEGER DEFAULT 0,
    rows_loaded INTEGER DEFAULT 0,
    invalid_rows INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS audit.data_quality_errors (
    error_id BIGSERIAL PRIMARY KEY,
    run_id UUID NOT NULL,
    source_table VARCHAR(100) NOT NULL,
    record_id TEXT,
    error_type VARCHAR(100) NOT NULL,
    error_message TEXT NOT NULL,
    detected_at TIMESTAMP NOT NULL DEFAULT NOW()
);
