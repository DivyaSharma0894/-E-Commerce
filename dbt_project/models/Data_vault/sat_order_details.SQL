{{ config(materialized='incremental') }}

{%- set source_model = "stg_orders" -%}
{%- set src_pk = "hash_order_id" -%}
{%- set src_hashdiff = "order_hashdiff" -%}
{%- set src_payload = ["order_amount", "order_status", "ordered_at_tz"] -%}
{%- set src_ldts = "ingested_at" -%}
{%- set src_source = "source_system" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}