{{ config(materialized='table') }}

with time_diff as (
    select *,
    timestamp_diff( dropoff_datetime, pickup_datetime, second) as trip_duration
    from {{ ref('dim_fhv_trips') }}
    
),

p90_calc as (
    select 
    year,
    month,
    pickup_locationid, 
    dropoff_locationid,
    pickup_zone,
    dropoff_zone,
    percentile_cont(trip_duration, 0.90) over (partition by year, month, pickup_locationid, dropoff_locationid) as p90
    from time_diff

)

select distinct
year,
month,
pickup_locationid, 
dropoff_locationid,
pickup_zone,
dropoff_zone,
p90
from p90_calc
order by year, month, pickup_locationid, dropoff_locationid