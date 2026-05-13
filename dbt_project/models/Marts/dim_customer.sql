{{ config(materialized='table') }}

with customer_history as (
    select
        h.hash_customer_id,
        h.customer_id,
        s.customer_name,
        s.email,
        s.created_at_tz,
        s.ingested_at as load_dts,
        s.source_system,
        row_number() over(
            partition by h.hash_customer_id
            order by s.ingested_at asc, s.customer_hashdiff
        ) as version_number
    from {{ ref('hub_customer') }} h
    join {{ ref('sat_customer_details') }} s
        using (hash_customer_id)
),

scd_customer as (
    select
        hash_customer_id,
        customer_id,
        customer_name,
        email,
        created_at_tz,
        load_dts,
        source_system,
        version_number,
        load_dts as valid_from,
        coalesce(
            lead(load_dts) over(
                partition by hash_customer_id
                order by load_dts asc
            ),
            to_timestamp_ntz('9999-12-31 23:59:59')
        ) as valid_to,
        case
            when lead(load_dts) over(
                partition by hash_customer_id
                order by load_dts asc
            ) is null then true
            else false
        end as is_current
    from customer_history
)

select * from scd_customer
order by hash_customer_id, valid_from desc
