{{
    config(
        materialized='table'
    )
}}

with tripdata as (
    select *
    from {{ ref('stg_fhv_tripdata') }}
),
dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
)
select
    tripdata.pickup_locationid, 
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    tripdata.dropoff_locationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,  
    tripdata.pickup_datetime, 
    tripdata.dropoff_datetime, 
    format_date('%Y', tripdata.pickup_datetime) as year,
    format_date('%m', tripdata.pickup_datetime) as month,
    timestamp_diff(tripdata.dropoff_datetime,
                   tripdata.pickup_datetime, SECOND)
      as trip_duration
    from tripdata
    inner join dim_zones as pickup_zone
    on tripdata.pickup_locationid = pickup_zone.locationid
    inner join dim_zones as dropoff_zone
    on tripdata.dropoff_locationid = dropoff_zone.locationid
