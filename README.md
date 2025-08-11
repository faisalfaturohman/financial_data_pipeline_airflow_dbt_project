# Financial Data Pipeline Solution – Analytics Engineer Technical Test

## 📌 Overview
This project implements a **complete financial data pipeline** leveraging modern data engineering tools for orchestration, transformation, and analytics.

**Key Technologies Used:**
- **Apache Airflow** – Workflow orchestration
- **dbt** – Data transformation and modeling
- **PostgreSQL** – Data storage
- **Docker** – Containerization for reproducible environments

The solution covers:
- **Data ingestion** from CSV sources
- **Layered dbt transformations** (staging → intermediate → marts)
- **Data quality checks**
- **Performance optimizations**
- **Automated testing & documentation**

---

## 📂 Project Structure
```
financial_data_pipeline/
├── airflow/
│   ├── dags/
│   │   └── financial_data_pipeline_dag.py
│   ├── logs/
│   └── plugins/
├── dbt/
│   └── financial_pipeline/
│       ├── dbt_project.yml
│       ├── profiles.yml
│       ├── models/
│       │   ├── staging/
│       │   │   ├── stg_transactions.sql
│       │   │   ├── stg_accounts.sql
│       │   │   └── stg_customers.sql
│       │   ├── intermediate/
│       │   │   ├── int_transactions_with_accounts.sql
│       │   │   └── int_daily_transaction_volumes.sql
│       │   └── marts/
│       │       └── finance_transaction_fact.sql
│       ├── macros/
│       └── tests/
├── data/
│   ├── transactions.csv
│   ├── accounts.csv
│   └── customers.csv
├── docker-compose.yml
├── Dockerfile.airflow
├── requirements.txt
└── README.md
```

---

## 📊 Data Sources
Sample CSV datasets provided in `/data/`:
- **transactions.csv** – Transaction details  
- **accounts.csv** – Account details  
- **customers.csv** – Customer demographic info  

---

## ⚙️ Setup Instructions

### 1️⃣ Prerequisites
- Docker & Docker Compose installed
- Python 3.9+ (if running locally outside Docker)

### 2️⃣ Clone Repository
```bash
git clone https://github.com/yourusername/financial_data_pipeline.git
cd financial_data_pipeline
```

### 3️⃣ Build & Start Services
```bash
docker-compose up --build
```
This will start:
- **Airflow Webserver** at `http://localhost:8080`
- **PostgreSQL** database
- **Airflow Scheduler**

---

## 🚀 Pipeline Workflow

### **Airflow DAG:** `financial_data_pipeline`
Daily scheduled pipeline with the following steps:

1. **Create Raw Tables** – `PostgresOperator` creates schemas & tables in `raw` schema.  
2. **Load CSV Data** – Python tasks ingest data into PostgreSQL.  
3. **Run dbt Models** – Transformations executed in layered structure:
   - **Staging:** Data cleaning & standardization  
   - **Intermediate:** Business logic & enrichment  
   - **Marts:** Final fact table for analytics  
4. **Run dbt Tests** – Data quality checks (unique, not null, referential integrity).  
5. **Generate Documentation** – dbt docs for lineage & model descriptions.

---

## 🏗️ dbt Architecture

### **Layers**
- **Staging:** `stg_*` models clean raw data and add quality flags.
- **Intermediate:** Join staging tables, enrich data (currency conversion, categorization).
- **Marts:** Create `finance_transaction_fact` table for reporting.

### **Materialization Strategy**
- **Staging & Intermediate:** Views for flexibility
- **Marts:** Tables for performance

---

## ✅ Data Quality & Testing
Implemented with dbt tests:
- **Uniqueness** and **not null** checks
- **Foreign key relationships**
- **Business rules** (e.g., no future transaction dates, zero amount flags)

---

## 📈 Performance Considerations
- Indexed `transaction_date`, `customer_id`, `account_id`, `transaction_type`, `amount_usd` in marts
- Early filtering in staging models
- Efficient joins with proper keys
- Fixed materialization strategies for optimized performance

---

## 📌 Key Insights
- **Data Quality Issues:** Handled with flags for anomalies
- **Currency Conversion:** Fixed-rate USD conversion
- **Customer Segmentation:** Based on age and account maturity
- **Transaction Analysis:** Daily aggregation for patterns

---

## 🧪 Running dbt Commands (Inside Airflow Container)
```bash
# Run models
cd /opt/airflow/dbt/financial_pipeline
dbt run --profiles-dir /opt/airflow/dbt

# Test models
dbt test --profiles-dir /opt/airflow/dbt

# Generate docs
dbt docs generate --profiles-dir /opt/airflow/dbt
dbt docs serve --profiles-dir /opt/airflow/dbt
```

---

## 🖥️ Accessing Services
- **Airflow Web UI:** [http://localhost:8080](http://localhost:8080) (default login: `airflow/airflow`)
- **PostgreSQL:** `localhost:5432` (user: `airflow`, pass: `airflow`)

---

## 📜 License
This project is released under the MIT License.
