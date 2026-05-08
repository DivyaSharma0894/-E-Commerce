with raw_source as (
    select * from {{ source('raw', 'orders') }}
),

final as (
    select
        -- Existing Hashes
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"order_id"::string']) }} as hash_order_id,
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"customer_id"::string']) }} as hash_customer_id,

        -- NEW: Link Hash (Required for link_order_customer)
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"order_id"::string', 'JSON_DATA:"customer_id"::string']) }} as link_order_customer_pk,

        -- NEW: HashDiff (Required for sat_order_details CDC)
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"amount"::string', 'JSON_DATA:"status"::string']) }} as order_hashdiff,
        
        -- Scalar Columns
        try_cast(JSON_DATA:"order_id"::string as varchar) as order_id,
        try_cast(JSON_DATA:"customer_id"::string as varchar) as customer_id,
        try_cast(JSON_DATA:"status"::string as varchar) as order_status,
        try_cast(JSON_DATA:"amount"::string as float) as order_amount,
        try_cast(JSON_DATA:"order_time"::string as timestamp_tz) as ordered_at_tz,
        
        -- Metadata
        ingestion_time as ingested_at,
        
        -- NEW: Record Source (Required for all Vault models)
        'SNOWFLAKE_ECOM' as source_system 

    from raw_source
)

select * from final