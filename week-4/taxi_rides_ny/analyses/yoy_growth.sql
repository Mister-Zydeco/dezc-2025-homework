WITH yoy_growth_table AS (
SELECT service_type, pickup_quarter, pickup_year,
100.0 * (total_revenue - (LAG(total_revenue) OVER qtrw))/(LAG(total_revenue) OVER qtrw) AS yoy_growth
FROM dataengineeringzoomcamp-dn.dn_dezc_analytics_week4.fct_taxi_trips_quarterly_revenue
WINDOW
  qtrw AS (PARTITION BY service_type, pickup_quarter ORDER BY pickup_year)
)
SELECT * FROM yoy_growth_table
WHERE yoy_growth IS NOT NULL
ORDER BY service_type, yoy_growth

