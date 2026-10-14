{% snapshot snap_listing_prices %}

{{
    config(
        target_schema='snapshots',
        unique_key='listing_id',
        strategy='timestamp',
        updated_at='last_modified_at'
    )
}}

select * from {{ ref('stg_pricing__listing_prices') }}

{% endsnapshot %}
