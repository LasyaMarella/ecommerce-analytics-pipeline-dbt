with order_items as (

    select * from {{ ref('int_orders__order_items_eur') }}

),

products as (

    select
        product_id,
        category
    from {{ ref('stg_catalog__products') }}

),

vat_rules as (

    select
        country_code,
        tax_category,
        vat_rate_pct,
        valid_from,
        valid_to
    from {{ ref('stg_tax__vat_rules') }}

),

with_category as (

    select
        order_items.*,
        products.category
    from order_items
    left join products
        on products.product_id = order_items.product_id

),

with_vat as (

    select
        with_category.*,
        vat_rules.vat_rate_pct
    from with_category
    left join vat_rules
        on vat_rules.country_code = with_category.customer_country_code
       and vat_rules.tax_category = with_category.category
       and with_category.ordered_date_utc >= vat_rules.valid_from
       and with_category.ordered_date_utc <= coalesce(vat_rules.valid_to, '9999-12-31'::date)

),

final as (

    select
        *,
        vat_rate_pct is null                               as is_vat_rate_missing,
        coalesce(vat_rate_pct, 0)                          as vat_rate_applied,
        gross_amount_eur - discount_amount_eur             as discounted_gross_amount_eur
    from with_vat

)

select
    *,
    round(discounted_gross_amount_eur / (1 + vat_rate_applied), 4)         as net_amount_eur,
    round(discounted_gross_amount_eur
          - discounted_gross_amount_eur / (1 + vat_rate_applied), 4)       as vat_amount_eur
from final
