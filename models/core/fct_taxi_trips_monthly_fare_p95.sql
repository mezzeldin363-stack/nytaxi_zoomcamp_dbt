{{ config(materialized='table') }}

with filtered as (
    select *
    from {{ ref('fact_trips') }}
    where fare_amount > 0 
    and trip_distance > 0 
    and payment_type_description in ('Cash', 'Credit card')
),

p95_calc as (
    select 
    service_type,
    year,
    month,
    percentile_cont(fare_amount, 0.95) over (partition by service_type, year, month) AS p95,
    percentile_cont(fare_amount, 0.97) over (partition by service_type, year, month) as p97,
    percentile_cont(fare_amount, 0.90) over (partition by service_type, year, month) as p90
    from filtered

)

select 
service_type,
year,
month,
p95,
p97,
p90
from p95_calc
order by service_type, year, month