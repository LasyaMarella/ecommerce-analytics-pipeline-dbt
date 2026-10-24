FROM apache/airflow:2.10.5-python3.11

USER airflow

# dbt lives in its own virtualenv so its dependencies never clash with Airflow's
RUN python -m venv /home/airflow/dbt_venv \
 && /home/airflow/dbt_venv/bin/pip install --no-cache-dir --upgrade pip \
 && /home/airflow/dbt_venv/bin/pip install --no-cache-dir \
      "dbt-core==1.8.7" "dbt-snowflake==1.8.4"
