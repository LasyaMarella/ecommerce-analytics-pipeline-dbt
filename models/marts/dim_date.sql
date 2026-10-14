with dates as (

    select distinct rate_date as date_day
    from {{ ref('int_finance__exchange_rates_daily') }}

),

published as (

    select distinct rate_date from {{ ref('stg_finance__exchange_rates') }}

)

select
    dates.date_day,
    year(dates.date_day)                               as year,
    quarter(dates.date_day)                            as quarter,
    month(dates.date_day)                              as month,
    monthname(dates.date_day)                          as month_name,
    to_char(dates.date_day, 'YYYY-MM')                 as year_month,
    weekiso(dates.date_day)                            as iso_week,
    dayofweekiso(dates.date_day)                       as iso_day_of_week,
    dayname(dates.date_day)                            as day_name,
    dayofweekiso(dates.date_day) in (6, 7)             as is_weekend,
    published.rate_date is not null                    as is_ecb_publication_day
from dates
left join published
    on published.rate_date = dates.date_day
