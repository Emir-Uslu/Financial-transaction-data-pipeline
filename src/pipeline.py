from uuid import uuid4
from datetime import datetime
import pandas as pd
from sqlalchemy import text

from config import BASE_DIR
from db import get_engine, execute_sql_file
from logging_config import setup_logger

logger = setup_logger()

SETUP_SCRIPTS = [
    "sql/setup/00_create_schemas.sql",
    "sql/setup/01_create_raw_tables.sql",
    "sql/setup/02_create_staging_tables.sql",
    "sql/setup/03_create_dwh_tables.sql",
    "sql/setup/04_create_audit_tables.sql",
    "sql/setup/05_create_indexes.sql",
    "sql/setup/06_create_analytics_objects.sql",
]

PIPELINE_SCRIPTS = [
    "sql/pipeline/10_record_quality_errors.sql",
    "sql/pipeline/11_transform_raw_to_staging.sql",
    "sql/pipeline/12_load_dwh.sql",
    "sql/pipeline/13_refresh_analytics.sql",
]

RAW_COLUMNS = {
    "customers": ["customer_id", "full_name", "email", "city", "signup_date"],
    "merchants": ["merchant_id", "merchant_name", "category", "city", "country"],
    "transactions": [
        "transaction_id", "customer_id", "merchant_id",
        "transaction_date", "amount", "currency", "transaction_type"
    ],
}

def run_sql_scripts(engine, scripts):
    for rel_path in scripts:
        path = BASE_DIR / rel_path
        logger.info("Running SQL: %s", rel_path)
        execute_sql_file(engine, path)

def load_raw_tables(engine, run_id):
    data_dir = BASE_DIR / "data" / "raw"

    with engine.begin() as conn:
        conn.execute(text(
            "TRUNCATE raw.customers, raw.merchants, raw.transactions;"
        ))

    counts = {}

    for table, source_columns in RAW_COLUMNS.items():
        path = data_dir / f"{table}.csv"
        df = pd.read_csv(path, dtype=str)
        df = df.where(pd.notna(df), None)

        df["ingestion_run_id"] = str(run_id)
        df["ingested_at"] = datetime.now()

        insert_columns = source_columns + ["ingestion_run_id", "ingested_at"]

        values_sql = [
            "CAST(:ingestion_run_id AS uuid)" if col == "ingestion_run_id"
            else f":{col}"
            for col in insert_columns
        ]

        insert_sql = text(
            f'''
            INSERT INTO raw.{table} ({", ".join(insert_columns)})
            VALUES ({", ".join(values_sql)})
            '''
        )

        records = df[insert_columns].to_dict(orient="records")

        with engine.begin() as conn:
            for start in range(0, len(records), 1000):
                conn.execute(insert_sql, records[start:start + 1000])

        counts[table] = len(df)
        logger.info("Loaded %s rows into raw.%s", len(df), table)

    return counts

def main():
    run_id = uuid4()
    engine = get_engine()
    started_at = datetime.now()

    logger.info("Pipeline started. run_id=%s", run_id)

    try:
        run_sql_scripts(engine, SETUP_SCRIPTS)

        with engine.begin() as conn:
            conn.execute(
                text(
                    '''
                    INSERT INTO audit.pipeline_runs
                        (run_id, started_at, status)
                    VALUES
                        (:run_id, :started_at, 'RUNNING')
                    '''
                ),
                {"run_id": run_id, "started_at": started_at},
            )

        counts = load_raw_tables(engine, run_id)
        run_sql_scripts(engine, PIPELINE_SCRIPTS)

        with engine.begin() as conn:
            invalid_count = conn.execute(
                text(
                    '''
                    SELECT COUNT(*)
                    FROM audit.data_quality_errors
                    WHERE run_id = :run_id
                    '''
                ),
                {"run_id": run_id},
            ).scalar_one()

            fact_count = conn.execute(
                text("SELECT COUNT(*) FROM dwh.fact_transactions")
            ).scalar_one()

            conn.execute(
                text(
                    '''
                    UPDATE audit.pipeline_runs
                    SET finished_at = NOW(),
                        status = 'SUCCESS',
                        rows_extracted = :rows_extracted,
                        rows_loaded = :rows_loaded,
                        invalid_rows = :invalid_rows
                    WHERE run_id = :run_id
                    '''
                ),
                {
                    "rows_extracted": counts["transactions"],
                    "rows_loaded": fact_count,
                    "invalid_rows": invalid_count,
                    "run_id": run_id,
                },
            )

        logger.info(
            "Pipeline completed. extracted=%s loaded=%s invalid=%s",
            counts["transactions"],
            fact_count,
            invalid_count,
        )

    except Exception:
        logger.exception("Pipeline failed. run_id=%s", run_id)
        try:
            with engine.begin() as conn:
                conn.execute(
                    text(
                        '''
                        UPDATE audit.pipeline_runs
                        SET finished_at = NOW(), status = 'FAILED'
                        WHERE run_id = :run_id
                        '''
                    ),
                    {"run_id": run_id},
                )
        except Exception:
            logger.exception("Could not update audit.pipeline_runs after failure.")
        raise

if __name__ == "__main__":
    main()
