{{
    config(
        materialized='table'
    )
}}

with fhv_data as (
    select *
    from {{ ref('stg_FHV') }}

),

dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)

select

fhv_data.dispatching_base_num,
fhv_data.pickup_datetime,
fhv_data.dropoff_datetime,
fhv_data.pickup_locationid,
fhv_data.dropoff_locationid,
extract(year from fhv_data.pickup_datetime) as year,
extract(month from fhv_data.pickup_datetime) as month,
pu_zones.borough as pickup_borough,
pu_zones.zone as pickup_zone,
do_zones.borough as dropoff_borough,
do_zones.zone as dropoff_zone,
sr_flag,
affiliated_base_number
from fhv_data
inner join dim_zones as pu_zones on fhv_data.pickup_locationid = pu_zones.locationid
inner join dim_zones as do_zones on fhv_data.dropoff_locationid = do_zones.locationid