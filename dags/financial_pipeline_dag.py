from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator
import pandas as pd
import psycopg2
from sqlalchemy import create_engine

default_args = {
    'owner': 'analytics_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'financial_data_pipeline',
    default_args=default_args,
    description='Financial transaction data pipeline',
    schedule_interval='@daily',
    catchup=False,
    tags=['finance', 'etl', 'dbt']
)

# Task 1: Create raw tables
create_raw_tables = PostgresOperator(
    task_id='create_raw_tables',
    postgres_conn_id='postgres_default',
    sql='''
    CREATE SCHEMA IF NOT EXISTS raw;
    
    CREATE TABLE IF NOT EXISTS raw.transactions (
        transaction_id VARCHAR(50) PRIMARY KEY,
        account_id VARCHAR(50),
        transaction_date DATE,
        amount DECIMAL(15,2),
        currency VARCHAR(3),
        transaction_type VARCHAR(50),
        merchant_id VARCHAR(50),
        loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS raw.accounts (
        account_id VARCHAR(50) PRIMARY KEY,
        customer_id VARCHAR(50),
        opening_date DATE,
        account_type VARCHAR(50),
        balance DECIMAL(15,2),
        loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS raw.customers (
        customer_id VARCHAR(50) PRIMARY KEY,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        date_of_birth DATE,
        address VARCHAR(200),
        city VARCHAR(100),
        province VARCHAR(50),
        loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    ''',
    dag=dag,
)

# Task 2: Load transaction data
def load_transactions():
    """Load transaction data from CSV to PostgreSQL"""
    engine = create_engine('postgresql://airflow:airflow@postgres:5432/airflow')
    df = pd.read_csv('/opt/airflow/data/transactions.csv')
    df['transaction_date'] = pd.to_datetime(df['transaction_date'])
    df.to_sql('transactions', engine, schema='raw', if_exists='append', index=False)

load_transactions_task = PythonOperator(
    task_id='load_transactions',
    python_callable=load_transactions,
    dag=dag,
)

# Task 3: Load customer data
def load_customers():
    """Load customer data from CSV to PostgreSQL"""
    engine = create_engine('postgresql://airflow:airflow@postgres:5432/airflow')
    df = pd.read_csv('/opt/airflow/data/customers.csv')
    df['date_of_birth'] = pd.to_datetime(df['date_of_birth'])
    df.to_sql('customers', engine, schema='raw', if_exists='append', index=False)

load_customers_task = PythonOperator(
    task_id='load_customers',
    python_callable=load_customers,
    dag=dag,
)

# Task 4: Load accounts data
def load_accounts():
    """Load accounts data from CSV to PostgreSQL"""
    engine = create_engine('postgresql://airflow:airflow@postgres:5432/airflow')
    df = pd.read_csv('/opt/airflow/data/accounts.csv')
    df['opening_date'] = pd.to_datetime(df['opening_date'])
    df.to_sql('accounts', engine, schema='raw', if_exists='append', index=False)

load_accounts_task = PythonOperator(
    task_id='load_accounts',
    python_callable=load_accounts,
    dag=dag,
)

# Task 5: Run dbt models
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command='cd /opt/airflow/dbt/financial_pipeline && dbt run --profiles-dir /opt/airflow/dbt',
    dag=dag,
)

# Task 6: Run dbt tests
dbt_test = BashOperator(
    task_id='dbt_test',
    bash_command='cd /opt/airflow/dbt/financial_pipeline && dbt test --profiles-dir /opt/airflow/dbt',
    dag=dag,
)

# Task 7: Generate dbt documentation
dbt_docs = BashOperator(
    task_id='dbt_docs_generate',
    bash_command='cd /opt/airflow/dbt/financial_pipeline && dbt docs generate --profiles-dir /opt/airflow/dbt',
    dag=dag,
)

# Define task dependencies
create_raw_tables >> [load_transactions_task, load_customers_task, load_accounts_task]
[load_transactions_task, load_customers_task, load_accounts_task] >> dbt_run
dbt_run >> dbt_test >> dbt_docs