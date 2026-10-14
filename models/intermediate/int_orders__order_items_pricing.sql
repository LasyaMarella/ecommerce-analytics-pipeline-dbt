with order_items as (

    select
        order_item_id,
        product_id,
        customer_country_code,
        ordered_at,
        quantity,
        unit_price_paid_local,
        discount_amount_local,
        exchange_rate_applied,
        vat_rate_applied,
        net_amount_eur
    from {{ ref('int_orders__order_items_net') }}

),

products as (

    select
        product_id,
        base_cost_eur
    from {{ ref('stg_catalog__products') }}

),

price_versions as (

    select
        listing_id,
        product_id,
        country_code,
        recommended_retail_price_local,
        current_listing_price_local,
        dbt_valid_from,
        dbt_valid_to,
        dbt_valid_from = min(dbt_valid_from) over (partition by listing_id) as is_first_version
    from {{ ref('snap_listing_prices') }}

),

with_price as (

    -- Window match, plus fallback to the earliest version for orders placed before it.
    -- The two conditions are mutually exclusive, so at most one version matches per line.
    select
        order_items.*,
        price_versions.listing_id,
        price_versions.recommended_retail_price_local,
        price_versions.current_listing_price_local,
        price_versions.dbt_valid_from                                         as price_valid_from,
        price_versions.dbt_valid_to                                           as price_valid_to,
        price_versions.listing_id is null                                     as is_listing_missing,
        coalesce(order_items.ordered_at < price_versions.dbt_valid_from, false) as is_price_history_gap
    from order_items
    left join price_versions
        on price_versions.product_id = order_items.product_id
       and price_versions.country_code = order_items.customer_country_code
       and (
            (order_items.ordered_at >= price_versions.dbt_valid_from
             and order_items.ordered_at < coalesce(price_versions.dbt_valid_to, '9999-12-31'::timestamp_tz))
            or (price_versions.is_first_version
                and order_items.ordered_at < price_versions.dbt_valid_from)
       )

),

with_cost as (

    select
        with_price.*,
        products.base_cost_eur
    from with_price
    left join products
        on products.product_id = with_price.product_id

)

select
    order_item_id,

    -- price version used
    listing_id,
    price_valid_from,
    price_valid_to,
    is_listing_missing,
    is_price_history_gap,

    -- list prices in EUR (per unit, tax-inclusive); NULL when no listing exists
    round(recommended_retail_price_local / exchange_rate_applied, 4)           as recommended_retail_price_eur,
    round(current_listing_price_local / exchange_rate_applied, 4)              as list_price_eur,

    -- Req 3: discount depth, line level, ex-VAT on both sides
    round(current_listing_price_local * quantity / exchange_rate_applied
          / (1 + vat_rate_applied), 4)                                         as list_price_net_line_eur,
    round(current_listing_price_local * quantity / exchange_rate_applied
          / (1 + vat_rate_applied) - net_amount_eur, 4)                        as discount_depth_eur,

    -- Req 3: margin
    base_cost_eur is null                                                      as is_base_cost_missing,
    round(net_amount_eur - quantity * coalesce(base_cost_eur, 0), 4)           as margin_eur,

    -- Req 4: markdown vs RRP (tax-inclusive, EUR); NULL when no listing exists
    round((recommended_retail_price_local - coalesce(unit_price_paid_local, 0))
          / exchange_rate_applied, 4)                                          as markdown_per_unit_eur,
    round((recommended_retail_price_local - coalesce(unit_price_paid_local, 0))
          * quantity / exchange_rate_applied, 4)                               as total_discount_given_eur,

    case
        when coalesce(discount_amount_local, 0) > 0 then 'Basket Discount'
        when is_listing_missing then 'Unknown'
        when coalesce(current_listing_price_local, 0)
             < coalesce(recommended_retail_price_local, 0) then 'Promo Price'
        else 'Full Price'
    end                                                                        as price_type_flag

from with_cost
