
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

#### Question 2: Answer: green_tripdata_2020-04.csv

#### Question 3: Answer: 24,648,499

Between my first commit of this README and now, I went down a rabbit hole not trusting the filename field. I think that this question would get surprisingly tricky (1) if the filename field were untrustowrthy because it was provided in the raw data and (2) one were to take into account the remote possibility that our \"unique_row_identifier\" might not be unique. Struggling with this, I then fell upon the useful expedient of reading what is actually done in the flow. The filename field does not come form the raw data; it is, rather, added by us, and so it _is_ trustworthy.

And then a moment's reflection shows that the rows in yellow_tripdata that come from 2020 files are exactly those whose filename field contains '2020' as a substring.

```
SELECT COUNT(1)
FROM `dataengineeringzoomcamp-dn.dn_dezc_kestra_dataset.yellow_tripdata`
WHERE CONTAINS_SUBSTR(filename, '2020');
```

 I hope to publish in public learning my journey down the rabbit hole I mention above. I learned quite a bit about bigquery sql in the process. 

#### Question 4: Answer: 1,734,051
Just by repeating the process for question 3, but with the green_tripdata table instead of the yellow.

#### Question 5: Answer: 1,925,152
From the query 
```
SELECT COUNT(1) 
FROM `dataengineeringzoomcamp-dn.dn_dezc_kestra_dataset.yellow_tripdata`
WHERE filename = 'yellow_tripdata_2021-03.csv'
```

#### Question 6: Answer: add a timezone propery set to America/New_York
I get this answer straight from the [Kestra page on Schedule Triggers](https://kestra.io/docs/workflow-components/triggers/schedule-trigger)
