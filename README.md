# Financial Transaction Data Engineering Pipeline

An end-to-end batch data engineering project built with **Python, PostgreSQL, SQL, pandas, SQLAlchemy and psycopg**.

The pipeline ingests raw financial transaction data from CSV files, validates and cleans the records, loads them into a layered PostgreSQL architecture, builds a Kimball-style dimensional warehouse, and exposes analytics-ready views and summary tables.

## Architecture

```text
CSV Sources
    |
    v
Python Ingestion
    |
    v
raw schema
    |
    | data quality checks
    v
staging schema
    |
    | SQL transformations
    v
dwh schema
    |
    | Kimball star schema
    v
analytics schema

audit schema
    +-- pipeline run history
    +-- data quality errors
```

## Main Features

- Batch ingestion from CSV files
- Layered PostgreSQL architecture: `raw`, `staging`, `dwh`, `analytics`, `audit`
- Data quality checks for invalid amounts, missing customer references, and duplicate transaction IDs
- Kimball-style dimensional model
- Fact and dimension tables
- Range partitioning on transaction date
- SQL indexes for common access paths
- CTEs and window functions
- Analytics views
- Stored procedure for summary refresh
- Pipeline audit logging
- Python application logging
- Environment-based database configuration

## Warehouse Model

```text
                 dim_customer
                      |
dim_date ------ fact_transactions ------ dim_merchant
```

The central fact table stores transaction-level measures, while dimension tables provide customer, merchant and date context.

## Project Structure

```text
financial-data-pipeline/
├── data/
│   └── raw/
├── docs/
├── logs/
├── sql/
│   ├── analytics/
│   ├── pipeline/
│   └── setup/
├── src/
├── .env.example
├── .gitignore
├── README.md
└── requirements.txt
```

## Setup

### 1. Create and activate a virtual environment

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

```powershell
python -m pip install -r requirements.txt
```

### 3. Configure PostgreSQL connection

Copy `.env.example` to `.env`:

```powershell
Copy-Item .env.example .env
```

Update the database password in `.env`:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=financial_pipeline_db
DB_USER=postgres
DB_PASSWORD=YOUR_PASSWORD
```

### 4. Generate sample source data

```powershell
python src/generate_sample_data.py
```

### 5. Run the pipeline

```powershell
python src/pipeline.py
```

### 6. Validate the result

```powershell
python src/validate_results.py
```

## Example Pipeline Result

```text
raw transactions:        20025
clean staging rows:      20000
warehouse fact rows:     20000
data quality errors:        25
```

The invalid records are retained in the audit layer and excluded from the clean analytical layers.

## Analytics

Example queries are available in:

```text
sql/analytics/90_demo_queries.sql
```

They include:

- top merchants by transaction amount
- customer month-over-month spending
- pipeline run history
- data quality error counts
- partition row distribution
- `EXPLAIN ANALYZE` query-plan inspection

## Data Modeling

The warehouse uses a **Kimball-style dimensional model** because the primary goal is analytical querying and reporting.

See `docs/data_modeling.md` for a short comparison of Kimball and Inmon approaches.
