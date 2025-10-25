{{ config(materialized='table') }}

with quarterly_rev as (
    select
        service_type,
        year,
        quarter,
        year_quarter,
        sum(total_amount) as quarterly_revenue
    from {{ ref('fact_trips') }}
    group by service_type, year, quarter, year_quarter
),

with_yoy as (
    select
        service_type,
        year,
        quarter,
        year_quarter,
        quarterly_revenue,
        lag(quarterly_revenue) over (
            partition by service_type, quarter 
            order by year
        ) as prev_year_revenue
    from quarterly_rev
)

select
    service_type,
    year,
    quarter,
    year_quarter,
    quarterly_revenue,
    prev_year_revenue,
    round(safe_divide((quarterly_revenue - prev_year_revenue), prev_year_revenue) * 100, 2)
        as yoy_growth_percentage
from with_yoy
order by service_type, year, quarter
