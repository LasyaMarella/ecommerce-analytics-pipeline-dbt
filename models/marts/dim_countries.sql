with countries as (

    select * from {{ ref('ref_countries') }}

),

vat_countries as (

    select distinct country_code from {{ ref('stg_tax__vat_rules') }}

)

select
    countries.country_code,
    countries.country_name,
    countries.currency_code,
    countries.is_eurozone,
    vat_countries.country_code is not null as has_vat_rules
from countries
left join vat_countries
    on vat_countries.country_code = countries.country_code
