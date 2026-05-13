with raw_source as (
    select * from {{ source('raw', 'customers') }}
),

final as (
    select
        -- Accessing JSON_DATA directly using colon syntax
        -- We use double quotes inside the colon to handle lowercase keys
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"customer_id"::string']) }} as hash_customer_id,
        
        try_cast(JSON_DATA:"customer_id"::string as varchar) as customer_id,
        try_cast(JSON_DATA:"name"::string as varchar) as customer_name,
        try_cast(JSON_DATA:"email"::string as varchar) as email,
        try_cast(JSON_DATA:"created_at"::string as timestamp_tz) as created_at_tz,
        
        -- NEW: HashDiff (Required for sat_customer_details CDC)
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"name"::string', 'JSON_DATA:"email"::string', 'JSON_DATA:"created_at"::string']) }} as customer_hashdiff,
        
        -- Metadata column
        ingestion_time as ingested_at,
        
        -- NEW: Record Source (Required for all Vault models)
        'SNOWFLAKE_ECOM' as source_system

    from raw_source
)

select * from final