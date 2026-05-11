{{ config(materialized='incremental') }}

{%- set source_model = "stg_orders" -%}
{%- set src_pk = "link_order_customer_pk" -%}
{%- set src_fk = ["hash_order_id", "hash_customer_id"] -%}
{%- set src_ldts = "ingested_at" -%}
{%- set src_source = "source_system" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}