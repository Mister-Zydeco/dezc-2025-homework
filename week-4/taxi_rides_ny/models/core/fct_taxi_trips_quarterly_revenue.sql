with fact_trips as (
    select * from {{ ref('fact_trips') }}
    where pickup_year in ('2019', '2020')
),
fact_trips_quarterly_agg as (
select fact_trips.service_type,
    fact_trips.pickup_quarter,
    fact_trips.pickup_year,
    sum(fact_trips.total_amount) as total_revenue,
    row_number() over (
       partition by service_type, pickup_year, pickup_quarter
    ) as row_num
    from fact_trips
    group by service_type, pickup_year, pickup_quarter
    
)
select * from fact_trips_quarterly_agg 
where row_num = 1   
