{% snapshot inventory_snapshot %}

{{
    config(
      target_schema='snapshots',
      strategy='check',
      unique_key='product_id',
      check_cols=['stock_count', 'unit_cost'],
    )
}}

-- Pointing to your existing staging model or raw source
-- Since you already have stg_inventory, we use that for clean data
select 
    product_id,
    stock_count,
    unit_cost,
    ingested_at
from {{ ref('stg_inventory') }}

{% endsnapshot %}