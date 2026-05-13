{{ config(materialized='table') }}

with inventory_metrics as (
    select
        product_id,
        product_name,
        stock_count,
        unit_cost,
        stock_count * unit_cost as inventory_value,
        case
            when stock_count <= 10 then 'High Turnover'
            when stock_count <= 50 then 'Medium Turnover'
            else 'Low Turnover'
        end as turnover_category,
        datediff(day, updated_at_tz, current_timestamp()) as days_since_update,
        dbt_updated_at as last_updated
    from {{ ref('fact_inventory') }}
),

aggregated_metrics as (
    select
        turnover_category,
        count(*) as product_count,
        sum(inventory_value) as total_inventory_value,
        avg(stock_count) as avg_stock_level,
        sum(stock_count) as total_stock_units
    from inventory_metrics
    group by turnover_category
)

select * from aggregated_metrics
order by total_inventory_value desc