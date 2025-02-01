
## Homework for Week 2 Data Talks Club Data Engineering Zoomcamp

I used the docker-config.yml in this directory, which on afterhought was
wasteful because pgadmin and postgres are irrelvant here. But the important
thing is that it brough up Kestra.

I first set up my GCP key-value pairs by running the flow 04_gcp_kv.yml
in this directory. To follow the videos before this homework, I loaded all
of 2019 by running the flow 06_gcp_taxi.yml for December 2019, one for green
and one for yellow. I then ran backfills using 06_gcp_scheduled that started
at Jan 1 2019 00:00:00 and ended on Dec 31 2019 23:00:00.

To get 2020 and 2021, I ran one backfill each for green and red taxis that started on Jan 1 2020 00:00:00 and ended on July 2 2021 00:00:00.

#### Question 1: Answer: 128.3 MB
From this [screenshot of the contents of my GCP bucket](my-gcp-bucket.png)

Question 2: Answer: green_tripdata_2020-04.csv

Question 3: Answer: 24,648,499\
To find the number of rows for all the Yellow Taxi CSV files for 2020, I tried to be careful. I first executed 

SELECT DISTINCT filename
FROM \`dataengineeringzoomcamp-dn.dn_dezc_kestra_dataset.yellow_tripdata\`
ORDER BY filename;

to make sure there were no unexpected values for the filename field in yellow_trip. There are indeed only the expected 31 monthly filenames for Jan 2019 through July 2021 inclusive. It follows that the records from 2020 files are exactly those whose filename field contains the substring '2020':

SELECT COUNT(1)
FROM \`dataengineeringzoomcamp-dn.dn_dezc_kestra_dataset.yellow_tripdata\`
WHERE CONTAINS_SUBSTR(filename, '2020');

Question 4: Answer: 1,734,051
Just by repeating the process for question 3, but with the green_tripdata table instead of the yellow.

Question 5: Answer: 1,925,152
From the query 
SELECT COUNT(1) 
FROM \`dataengineeringzoomcamp-dn.dn_dezc_kestra_dataset.yellow_tripdata\`
WHERE filename = 'yellow_tripdata_2021-03.csv'

Question 6: Answer: add a timezone propery set to America/New_York
I get this answer straight from the [Kestra page on Schedule Triggers](https://kestra.io/docs/workflow-components/triggers/schedule-trigger)
