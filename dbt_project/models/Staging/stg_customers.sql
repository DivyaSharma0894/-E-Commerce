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
        
        -- Metadata column
        ingestion_time as ingested_at

    from raw_source
)

select * from final