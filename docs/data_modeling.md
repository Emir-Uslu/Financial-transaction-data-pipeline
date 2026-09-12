# Data Modeling Decision

## Project choice: Kimball dimensional model

The analytical warehouse uses a star schema:

- `dwh.fact_transactions`
- `dwh.dim_customer`
- `dwh.dim_merchant`
- `dwh.dim_date`

This is a Kimball-style dimensional model because the project is analytics-oriented and
optimizes for simple reporting queries and understandable business dimensions.

## Kimball vs Inmon

**Kimball**
- Bottom-up / business-process-oriented.
- Dimensional models and data marts are central.
- Strong fit for analytics, BI, and fast delivery.

**Inmon**
- Top-down enterprise data warehouse approach.
- Central warehouse is typically normalized first.
- Data marts are derived from the enterprise warehouse.
- Strong fit when enterprise-wide integration and normalized governance are the priority.

For this portfolio project, Kimball is the more appropriate design because transaction
analytics is the primary goal and the dimensional model is easy to query and demonstrate.
