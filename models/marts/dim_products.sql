with products as (

    select * from {{ ref('stg_catalog__products') }}

),

vat_categories as (

    select distinct tax_category from {{ ref('stg_tax__vat_rules') }}

),

ordered_products as (

    select distinct product_id from {{ ref('stg_orders__order_items') }}

),

inferred_members as (

    select ordered_products.product_id
    from ordered_products
    left join products
        on products.product_id = ordered_products.product_id
    where products.product_id is null

),

catalog_members as (

    select
        products.product_id,
        products.brand_name,
        products.category,
        products.base_cost_eur,
        products.base_cost_eur is null                  as is_base_cost_missing,
        vat_categories.tax_category is not null         as has_vat_rules,
        false                                           as is_inferred_member,
        products.created_at,
        products.updated_at
    from products
    left join vat_categories
        on vat_categories.tax_category = products.category

),

unknown_members as (

    select
        product_id,
        'Unknown'                                       as brand_name,
        'unknown'                                       as category,
        null::number(18,4)                              as base_cost_eur,
        true                                            as is_base_cost_missing,
        false                                           as has_vat_rules,
        true                                            as is_inferred_member,
        null::timestamp_tz                              as created_at,
        null::timestamp_tz                              as updated_at
    from inferred_members

)

select * from catalog_members
union all
select * from unknown_members
