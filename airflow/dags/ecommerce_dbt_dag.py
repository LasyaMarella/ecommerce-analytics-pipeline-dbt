from __future__ import annotations

import logging
from datetime import timedelta

import pendulum
from airflow import DAG
from airflow.operators.bash import BashOperator

log = logging.getLogger(__name__)

DBT = "/home/airflow/dbt_venv/bin/dbt"
PROJECT_DIR = "/opt/airflow/dbt_project"
PROFILES_DIR = "/opt/airflow/dbt_profiles"


def notify_failure(context):
    """Failure alert stub. Replace the log line with email or Slack later."""
    task_instance = context["task_instance"]
    log.error(
        "dbt pipeline failure | dag=%s task=%s run=%s attempt=%s | log: %s",
        context["dag"].dag_id,
        task_instance.task_id,
        context["run_id"],
        task_instance.try_number,
        task_instance.log_url,
    )


default_args = {
    "owner": "analytics-engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "on_failure_callback": notify_failure,
}


def dbt_task(task_id: str, command: str) -> BashOperator:
    return BashOperator(
        task_id=task_id,
        bash_command=(
            f"cd {PROJECT_DIR} && "
            f"{DBT} {command} --project-dir {PROJECT_DIR} --profiles-dir {PROFILES_DIR}"
        ),
    )


with DAG(
    dag_id="ecommerce_dbt_daily",
    description="Daily dbt build of the multi-region e-commerce financial pipeline.",
    # ECB publishes reference rates around 16:00 CET, so run after that.
    start_date=pendulum.datetime(2024, 3, 1, tz="Europe/Berlin"),
    schedule="30 17 * * *",
    catchup=False,
    max_active_runs=1,
    default_args=default_args,
    tags=["dbt", "ecommerce"],
) as dag:

    dbt_deps = dbt_task("dbt_deps", "deps")
    dbt_run_staging = dbt_task("dbt_run_staging", "run --select staging")
    # The snapshot reads a staging view and feeds the pricing model,
    dbt_snapshot = dbt_task("dbt_snapshot", "snapshot")
    dbt_run_intermediate = dbt_task("dbt_run_intermediate", "run --select intermediate")
    dbt_run_marts = dbt_task("dbt_run_marts", "run --select marts")
    dbt_test = dbt_task("dbt_test", "test")

    (
        dbt_deps
        >> dbt_run_staging
        >> dbt_snapshot
        >> dbt_run_intermediate
        >> dbt_run_marts
        >> dbt_test
    )

