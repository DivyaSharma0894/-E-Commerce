# Use the same version as your docker-compose
FROM apache/airflow:3.1.6

# Install astronomer-cosmos and the snowflake adapter
# We do this as the 'airflow' user so permissions remain correct
USER airflow

RUN pip install --no-cache-dir \
    astronomer-cosmos \
    dbt-snowflake \
    dbt-core