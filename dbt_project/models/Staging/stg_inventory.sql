with raw_source as (
    select * from {{ source('raw', 'inventory') }}
),

final as (
    select
        -- 1. Generate hash-based business key for the product
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"product_id"::string']) }} as hash_product_id,

        -- 2. Extract and cast JSON keys into typed scalar columns
        try_cast(JSON_DATA:"product_id"::string as varchar) as product_id,
        try_cast(JSON_DATA:"product_name"::string as varchar) as product_name,
        
        -- Use integer for stock levels
        try_cast(JSON_DATA:"stock"::string as integer) as stock_count,
        try_cast(JSON_DATA:"unit_cost"::string as numeric(10, 2)) as unit_cost,
        
        -- Convert ISO timestamp to timestamp with timezone
        try_cast(JSON_DATA:"updated_at"::string as timestamp_tz) as updated_at_tz,
        
        -- NEW: HashDiff (Required for sat_inventory_details CDC)
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"product_name"::string', 'JSON_DATA:"stock"::string', 'JSON_DATA:"unit_cost"::string', 'JSON_DATA:"updated_at"::string']) }} as inventory_hashdiff,
        
        -- 3. Capture metadata column (Snowflake TIMESTAMP_NTZ)
        ingestion_time as ingested_at,
        
        -- NEW: Record Source (Required for all Vault models)
        'SNOWFLAKE_ECOM' as source_system

    from raw_source
)

select * from final