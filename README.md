# Financial Data Pipeline (Docker + Airflow + dbt + Postgres) — with optional GitHub ingest

## What you get
- **Postgres** data warehouse
- **Airflow** (LocalExecutor) + **dbt** inside the same container image
- **DAG** that can:
  1) Create raw tables
  2) Optionally **download CSVs from GitHub** (public or private repo) using env vars
  3) Load CSVs into `raw_*` tables
  4) Run `dbt seed` (demo currency rates), `dbt run`, `dbt test`
- **dbt project** with staging, intermediate, marts layers + tests

## Run (Windows/macOS/Linux)
```bash
docker compose up --build
# Airflow UI: http://localhost:8080  (user: admin, pass: admin)
docker compose exec airflow airflow dags trigger financial_pipeline
```

## CSV source options
### A) Local files
Put `customers.csv`, `accounts.csv`, `transactions.csv` in `./data/` (already in this zip if you provided them).

### B) Download from GitHub (public/private)
Set at least one of these env vars in `docker-compose.yml` (service `airflow`):
- `GITHUB_RAW_URL_CUSTOMERS`
- `GITHUB_RAW_URL_ACCOUNTS`
- `GITHUB_RAW_URL_TRANSACTIONS`

Example (public raw URLs):
```
GITHUB_RAW_URL_CUSTOMERS: "https://raw.githubusercontent.com/yourorg/yourrepo/main/data/customers.csv"
GITHUB_RAW_URL_ACCOUNTS: "https://raw.githubusercontent.com/yourorg/yourrepo/main/data/accounts.csv"
GITHUB_RAW_URL_TRANSACTIONS: "https://raw.githubusercontent.com/yourorg/yourrepo/main/data/transactions.csv"
```

If the repo is **private**, also set:
```
GITHUB_TOKEN: "ghp_your_personal_access_token"
```
> The DAG checks env vars; if a URL is provided, it downloads to `/opt/airflow/data/*.csv`. If not, it uses local `/data/*.csv`.

## dbt connection
`dbt/profiles.yml` points to `postgres:5432`, db `warehouse`, user `warehouse`, password `warehouse`, schema `public`.

## Notes
- The CSV loader uses `if_exists="replace"` for simplicity. For production, implement staging + UPSERT/MERGE.
- You can modify schedule in the DAG (`@daily` by default).
- Currency conversion comes from `dbt/seeds/currency_rates.csv`; adjust as needed and re-run `dbt seed`.
