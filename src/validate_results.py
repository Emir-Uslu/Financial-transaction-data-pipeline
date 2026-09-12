from sqlalchemy import text
from db import get_engine

CHECKS = {
    "raw_transactions": "SELECT COUNT(*) FROM raw.transactions",
    "staging_transactions": "SELECT COUNT(*) FROM staging.stg_transactions",
    "fact_transactions": "SELECT COUNT(*) FROM dwh.fact_transactions",
    "quality_errors": "SELECT COUNT(*) FROM audit.data_quality_errors",
    "analytics_rows": "SELECT COUNT(*) FROM analytics.customer_monthly_summary",
}

def main():
    engine = get_engine()
    with engine.connect() as conn:
        for name, sql in CHECKS.items():
            value = conn.execute(text(sql)).scalar_one()
            print(f"{name}: {value}")

        print("\nLatest pipeline run:")
        result = conn.execute(text("""
            SELECT run_id, started_at, finished_at, status,
                   rows_extracted, rows_loaded, invalid_rows
            FROM audit.pipeline_runs
            ORDER BY started_at DESC
            LIMIT 1
        """)).mappings().one()
        print(dict(result))

if __name__ == "__main__":
    main()
