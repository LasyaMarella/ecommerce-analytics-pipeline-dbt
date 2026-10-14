with rates as (

    select
        rate_date,
        target_currency_code as currency_code,
        exchange_rate
    from {{ ref('stg_finance__exchange_rates') }}

),

bounds as (

    select
        (select min(rate_date) from rates) as start_date,
        greatest(
            (select max(rate_date) from rates),
            (select max(ordered_date_utc) from {{ ref('stg_orders__order_items') }})
        ) as end_date

),

calendar as (

    select
        dateadd(day, row_number() over (order by seq4()) - 1, bounds.start_date) as rate_date,
        bounds.end_date
    from bounds,
         table(generator(rowcount => 3660))

),

date_spine as (

    select rate_date
    from calendar
    where rate_date <= end_date

),

currencies as (

    select distinct currency_code from rates

),

grid as (

    select
        date_spine.rate_date,
        currencies.currency_code
    from date_spine
    cross join currencies

),

joined as (

    select
        grid.rate_date,
        grid.currency_code,
        rates.exchange_rate,
        rates.rate_date as published_date
    from grid
    left join rates
        on rates.rate_date = grid.rate_date
       and rates.currency_code = grid.currency_code

),

filled as (

    select
        rate_date,
        currency_code,

        last_value(exchange_rate) ignore nulls over (
            partition by currency_code
            order by rate_date
            rows between unbounded preceding and current row
        ) as exchange_rate,

        last_value(published_date) ignore nulls over (
            partition by currency_code
            order by rate_date
            rows between unbounded preceding and current row
        ) as source_rate_date

    from joined

)

select
    rate_date,
    currency_code,
    exchange_rate,
    source_rate_date,
    rate_date <> source_rate_date                      as is_carried_forward,
    datediff(day, source_rate_date, rate_date)         as days_since_source_rate
from filled
