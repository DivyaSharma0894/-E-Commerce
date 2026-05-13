{{ config(materialized='incremental') }}

{%- set source_model = "stg_inventory" -%}
{%- set src_pk = "hash_product_id" -%}
{%- set src_nk = "product_id" -%}
{%- set src_ldts = "ingested_at" -%}
{%- set src_source = "source_system" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}