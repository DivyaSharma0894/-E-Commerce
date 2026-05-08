with raw_source as (
    select * from {{ source('raw', 'orders') }}
),

final as (
    select
        -- 1. Generate hash-based business key for the order
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"order_id"::string']) }} as hash_order_id,

        -- 2. Generate hash-based key for the customer (to join with stg_customers later)
        {{ dbt_utils.generate_surrogate_key(['JSON_DATA:"customer_id"::string']) }} as hash_customer_id,
        
        -- 3. Use TRY_CAST to convert JSON data into typed scalar columns
        try_cast(JSON_DATA:"order_id"::string as varchar) as order_id,
        try_cast(JSON_DATA:"customer_id"::string as varchar) as customer_id,
        try_cast(JSON_DATA:"amount"::string as float) as order_amount,
        try_cast(JSON_DATA:"status"::string as varchar) as order_status,
        
        -- 4. Parse the timestamp
        try_cast(JSON_DATA:"order_time"::string as timestamp_tz) as ordered_at_tz,
        
        -- 5. Metadata column from Snowflake
        ingestion_time as ingested_at

    from raw_source
)

select * from final