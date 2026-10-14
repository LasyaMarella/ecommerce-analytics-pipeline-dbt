with source as (

    select * from {{ source('raw_pricing', 'listing_prices') }}

),

renamed as (

    select
        -- keys
        trim(listing_id)                          as listing_id,
        trim(product_id)                          as product_id,

        -- dimensions
        upper(trim(country_code))                 as country_code,
        upper(trim(currency))                     as currency_code,

        -- measures (local currency, gross of tax)
        recommended_retail_price::number(18,4)    as recommended_retail_price_local,
        current_listing_price::number(18,4)       as current_listing_price_local,

        -- status
        is_active::boolean                        as is_active,

        -- timestamps
        last_modified_at::timestamp_tz            as last_modified_at

    from source

)

select * from renamed
