from airflow.decorators import dag, task_group
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook
from airflow.providers.standard.operators.python import PythonOperator
from pendulum import datetime
from datetime import timedelta

# Configuration
S3_BUCKET = "luminates-project"
S3_BASE_PATH = "divya-sharma"
AWS_CONN = "s3_default"
SNOWFLAKE_CONN = "snowflake_default"


DATASETS = {
    "customers": "ECOMMERCE_RAW.Landing.RAW_CUSTOMERS",
    "orders": "ECOMMERCE_RAW.Landing.RAW_ORDERS",
    "inventory": "ECOMMERCE_RAW.Landing.RAW_INVENTORY"
}


def run_snowflake_copy(table, folder, **context):
    """Function to satisfy PythonOperator requirement"""
    # Extract date from context to match your generator's path logic
    execution_date = context["logical_date"].strftime('%Y/%m/%d')
    
    sql = f"""
        COPY INTO {table} (json_data)
        FROM @ECOMMERCE_RAW.Landing.MY_S3_STAGE/{folder}/{execution_date}/
        FILE_FORMAT = (TYPE = 'JSON' STRIP_OUTER_ARRAY = TRUE)
        ON_ERROR = 'CONTINUE';
    """
    hook = SnowflakeHook(snowflake_conn_id=SNOWFLAKE_CONN)
    hook.run(sql)

@dag(
    dag_id="s3_to_snowflake_multi_table_ingest",
    start_date=datetime(2026, 4, 15),
    schedule="0 * * * *",  # AC Requirement: RUNS HOURLY
    catchup=True,
    default_args={
        "owner": "divya_sharma",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
    },
    tags=["ingestion", "snowflake", "variant"]
)
def s3_ingestion_logic():

    for folder, table in DATASETS.items():
        
        @task_group(group_id=f"process_{folder}")
        def dataset_group():
            
            # AC Requirement: S3KeySensor implemented
            # Fix: wildcard_match replaces the failing wildcard parameter
            wait_for_data = S3KeySensor(
                task_id=f"wait_for_{folder}",
                bucket_name=S3_BUCKET,
                bucket_key=f"{S3_BASE_PATH}/{folder}/" + "{{ logical_date.strftime('%Y/%m/%d') }}/*.json",
                wildcard_match=True, 
                aws_conn_id=AWS_CONN,
                timeout=timedelta(hours=1).total_seconds(),
                mode="reschedule"
            )

            # AC Requirement: PythonOperator triggers Snowflake COPY INTO
            load_data = PythonOperator(
                task_id=f"copy_{folder}_to_snowflake",
                python_callable=run_snowflake_copy,
                op_kwargs={'table': table, 'folder': folder}
            )

            wait_for_data >> load_data

        dataset_group()

s3_ingestion_logic()