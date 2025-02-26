ITH fhv_trips AS (
  SELECT pickup_zone, dropoff_zone, year, month,
  percentile_cont(trip_duration, 0.9) OVER (PARTITION BY pickup_locationid, dropoff_locationid, year, month)
  as trip_duration_p90
  FROM `dataengineeringzoomcamp-dn.dn_dezc_analytics_week4.fct_fhv_monthly_zone_traveltime_p90`
  WHERE year = '2019' and month = '11' AND pickup_zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
),
fhv_trips_prededuped AS (
  SELECT *,
  ROW_NUMBER() OVER (PARTITION BY pickup_zone, dropoff_zone) AS rn
  FROM fhv_trips
),
fhv_trips_deduped AS (
  SELECT *,
  FROM fhv_trips_prededuped WHERE rn = 1
),
fhv_trips_grouped AS (
  SELECT pickup_zone, dropoff_zone, year, month, trip_duration_p90,
  ROW_NUMBER() OVER (
    PARTITION BY pickup_zone
    ORDER BY trip_duration_p90 DESC
  ) AS rn2
  FROM fhv_trips_deduped
)
SELECT * from fhv_trips_grouped WHERE rn2 < 3
