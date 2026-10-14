with source as (

    select * from {{ source('raw_finance', 'exchange_rates') }}

),

renamed as (

    select
        -- keys
        rate_date::date                         as rate_date,
        upper(trim(source_currency))            as source_currency_code,
        upper(trim(target_currency))            as target_currency_code,

        -- measures: 1 EUR = exchange_rate units of target currency
        exchange_rate::number(18,6)             as exchange_rate

    from source

)

select * from renamed
