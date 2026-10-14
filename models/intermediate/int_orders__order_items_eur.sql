with order_items as (

    select * from {{ ref('stg_orders__order_items') }}

),

rates as (

    select
        rate_date,
        currency_code,
        exchange_rate,
        source_rate_date,
        is_carried_forward
    from {{ ref('int_finance__exchange_rates_daily') }}

),

joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        order_items.customer_country_code,
        order_items.currency_code,
        order_items.quantity,
        order_items.unit_price_paid_local,
        order_items.discount_amount_local,
        order_items.ordered_at,
        order_items.ordered_date_utc,

        rates.exchange_rate        as spine_exchange_rate,
        rates.source_rate_date     as rate_source_date,
        rates.is_carried_forward   as spine_is_carried_forward

    from order_items
    left join rates
        on rates.rate_date = order_items.ordered_date_utc
       and rates.currency_code = order_items.currency_code

),

converted as (

    select
        *,

        -- EUR has no rate row by design; any other currency without a rate stays NULL
        case
            when currency_code = 'EUR' then 1.0
            else spine_exchange_rate
        end                                                   as exchange_rate_applied,

        unit_price_paid_local * quantity                      as gross_amount_local

    from joined

)

select
    order_item_id,
    order_id,
    product_id,
    customer_country_code,
    currency_code,
    quantity,
    unit_price_paid_local,
    discount_amount_local,
    ordered_at,
    ordered_date_utc,

    exchange_rate_applied,
    rate_source_date,
    coalesce(spine_is_carried_forward, false)                 as is_rate_carried_forward,

    gross_amount_local,
    round(gross_amount_local / exchange_rate_applied, 4)      as gross_amount_eur,
    round(coalesce(discount_amount_local, 0) / exchange_rate_applied, 4)
                                                              as discount_amount_eur

from converted
