with fct as (

    select * from {{ ref('fct_order_items') }}

),

products as (

    select
        product_id,
        brand_name,
        category,
        is_inferred_member
    from {{ ref('dim_products') }}

),

countries as (

    select
        country_code,
        country_name,
        is_eurozone
    from {{ ref('dim_countries') }}

),

dates as (

    select
        date_day,
        year,
        quarter,
        month,
        month_name,
        year_month,
        iso_week,
        day_name,
        is_weekend,
        is_ecb_publication_day
    from {{ ref('dim_date') }}

)

select
    -- keys
    fct.order_item_id,
    fct.order_id,

    -- date
    fct.order_date,
    dates.year                      as order_year,
    dates.quarter                   as order_quarter,
    dates.month                     as order_month,
    dates.month_name                as order_month_name,
    dates.year_month                as order_year_month,
    dates.iso_week                  as order_iso_week,
    dates.day_name                  as order_day_name,
    dates.is_weekend                as is_weekend_order,
    dates.is_ecb_publication_day,

    -- market
    fct.country_code,
    countries.country_name,
    countries.is_eurozone,
    fct.currency_code,

    -- product
    fct.product_id,
    products.brand_name,
    products.category               as product_category,
    products.is_inferred_member     as is_unknown_product,

    -- local-currency measures
    fct.quantity,
    fct.unit_price_paid_local,
    fct.discount_amount_local,
    fct.gross_amount_local,

    -- FX and VAT applied
    fct.exchange_rate_applied,
    fct.is_rate_carried_forward,
    fct.vat_rate_applied,
    fct.is_vat_rate_missing,

    -- EUR measures
    fct.gross_amount_eur,
    fct.discount_amount_eur,
    fct.discounted_gross_amount_eur,
    fct.vat_amount_eur,
    fct.net_amount_eur,
    fct.list_price_net_line_eur,
    fct.discount_depth_eur,
    fct.total_discount_given_eur,
    fct.margin_eur,

    -- margin restricted to lines with a known cost (same rule as the margin_pct metric)
    case when fct.is_base_cost_missing then null else fct.margin_eur end       as margin_eur_known_cost,
    case when fct.is_base_cost_missing then null else fct.net_amount_eur end   as net_amount_eur_known_cost,

    -- pricing context and data-quality flags
    fct.price_type_flag,
    fct.is_listing_missing,
    fct.is_price_history_gap,
    fct.is_base_cost_missing

from fct
left join products
    on products.product_id = fct.product_id
left join countries
    on countries.country_code = fct.country_code
left join dates
    on dates.date_day = fct.order_date
