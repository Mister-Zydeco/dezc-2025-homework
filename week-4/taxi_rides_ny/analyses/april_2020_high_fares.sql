SELECT service_type, p90, p95, p97
 FROM `dataengineeringzoomcamp-dn.dn_dezc_analytics_week4.fct_taxi_trips_monthly_fare_p95`
 WHERE pickup_year = '2020' and pickup_month ='04'
