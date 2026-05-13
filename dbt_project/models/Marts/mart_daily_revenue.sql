{{ config(materialized='table') }}

with daily_orders as (
    select
        date(ordered_at_tz) as order_date,
        sum(order_amount) as total_revenue,
        count(distinct order_id) as order_count,
        avg(order_amount) as avg_order_value,
        max(dbt_updated_at) as last_updated
    from {{ ref('fact_orders') }}
    where order_status = 'completed'
    group by date(ordered_at_tz)
)

select * from daily_orders
order by order_date desc