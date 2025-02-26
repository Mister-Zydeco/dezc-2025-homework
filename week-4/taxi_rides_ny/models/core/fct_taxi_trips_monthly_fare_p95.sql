with fact_trips_filtered as (
    select service_type, pickup_year,
    format_date('%m', pickup_datetime) as pickup_month,
    fare_amount
    from {{ ref('fact_trips') }}
    where trip_distance > 0 and fare_amount > 0 and
    payment_type_description in ('Cash', 'Credit card')
    and pickup_year in ('2019', '2020')
), 
fact_trips_ranked as (
select 
  service_type,
  pickup_year,
  pickup_month, 
  percentile_cont(fare_amount, 0.9)
    over w as p90, 
  percentile_cont(fare_amount, 0.95)
    over w as p95,
  percentile_cont(fare_amount, 0.97)
    over w as p97,
  row_number() over w as rn 
from fact_trips_filtered
window w as (partition by service_type, pickup_year, pickup_month)
)
select * from fact_trips_ranked where rn = 1
