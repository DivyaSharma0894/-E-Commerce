{{ config(materialized='incremental') }}

{%- set source_model = "stg_inventory" -%}
{%- set src_pk = "hash_product_id" -%}
{%- set src_hashdiff = "inventory_hashdiff" -%}
{%- set src_payload = ["product_name", "stock_count", "unit_cost", "updated_at_tz"] -%}
{%- set src_ldts = "ingested_at" -%}
{%- set src_source = "source_system" -%}

{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff,
                   src_payload=src_payload, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}