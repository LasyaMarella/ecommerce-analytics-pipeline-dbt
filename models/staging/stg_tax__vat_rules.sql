with source as (

    select * from {{ source('raw_tax', 'vat_rules') }}

),

renamed as (

    select
        -- keys (country + category + validity window)
        upper(trim(country_code))       as country_code,
        lower(trim(tax_category))       as tax_category,

        -- measures
        vat_rate_pct::number(8,4)       as vat_rate_pct,

        -- validity window (valid_to is NULL while the rule is active)
        valid_from::date                as valid_from,
        valid_to::date                  as valid_to

    from source

)

select * from renamed
