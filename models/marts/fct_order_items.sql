with net as (

    select * from {{ ref('int_orders__order_items_net') }}

),

pricing as (

    select * from {{ ref('int_orders__order_items_pricing') }}

)

select
    -- keys
    net.order_item_id,
    net.order_id,
    net.product_id,
    net.customer_country_code                  as country_code,
    net.currency_code,
    net.ordered_date_utc                       as order_date,
    net.ordered_at,

    -- local-currency measures (gross, tax-inclusive)
    net.quantity,
    net.unit_price_paid_local,
    net.discount_amount_local,
    net.gross_amount_local,

    -- FX and VAT applied
    net.exchange_rate_applied,
    net.rate_source_date,
    net.is_rate_carried_forward,
    net.vat_rate_applied,
    net.is_vat_rate_missing,

    -- EUR measures: revenue
    net.gross_amount_eur,
    net.discount_amount_eur,
    net.discounted_gross_amount_eur,
    net.vat_amount_eur,
    net.net_amount_eur,

    -- EUR measures: pricing and margin
    pricing.recommended_retail_price_eur,
    pricing.list_price_eur,
    pricing.list_price_net_line_eur,
    pricing.discount_depth_eur,
    pricing.markdown_per_unit_eur,
    pricing.total_discount_given_eur,
    pricing.margin_eur,

    -- price version and quality flags
    pricing.listing_id,
    pricing.price_valid_from,
    pricing.is_listing_missing,
    pricing.is_price_history_gap,
    pricing.is_base_cost_missing,
    pricing.price_type_flag

from net
left join pricing
    on pricing.order_item_id = net.order_item_id
