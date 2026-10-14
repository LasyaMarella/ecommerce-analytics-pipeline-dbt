with source as (

    select * from {{ source('raw_orders', 'order_items') }}
),

renamed as (

    select
        -- keys
        trim(order_item_id)                      as order_item_id,
        trim(order_id)                           as order_id,
        trim(product_id)                         as product_id,

        -- dimensions
        upper(trim(customer_country_code))       as customer_country_code,
        upper(trim(currency))                    as currency_code,

        -- measures (local currency, gross of tax)
        quantity::integer                        as quantity,
        unit_price_paid::number(18,4)            as unit_price_paid_local,
        discount_amount::number(18,4)            as discount_amount_local,

        -- timestamps
        ordered_at::timestamp_tz                 as ordered_at,
        convert_timezone('UTC', ordered_at)::date as ordered_date_utc

    from source

)

select * from renamed
