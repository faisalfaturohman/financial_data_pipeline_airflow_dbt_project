#!/usr/bin/env bash
set -e

# Migrasi / inisialisasi metadata DB
airflow db migrate

# Buat user admin kalau belum ada
airflow users create \
  --username "${_AIRFLOW_WWW_USER_USERNAME:-airflow}" \
  --password "${_AIRFLOW_WWW_USER_PASSWORD:-airflow}" \
  --firstname "${_AIRFLOW_WWW_USER_FIRSTNAME:-Admin}" \
  --lastname "${_AIRFLOW_WWW_USER_LASTNAME:-User}" \
  --role Admin \
  --email "${_AIRFLOW_WWW_USER_EMAIL:-admin@example.com}" || true

# Jalankan scheduler (background)
airflow scheduler &

# Jalankan webserver (foreground)
exec airflow webserver