## Homework for Week 3 Data Talks Club Data Engineering Zoomcamp

I had to figure out that the google-cloud-storage package, not the obosolete omnibus google-cloud package, needed to be installed in my python environemnt.Once that was done, the provided fetch-and-upload script for the parquet files worked without incident.

I have a micro-nitpick with the studio _Create table_ UI. We obviously wnst to load all six parquet files in one go, and so we want to use a URI pattern. But if you start you URI pattern with "gs://" as the clickable help for _use a URI pattern_ suggests, you are immediately scolded with red erro messages. You actuallky have to leave of the "gs://" bit for it to work.

Otherwise, creating the external table was striaghtforward. My dataset name is _dn_dezc_week3_. I named the external table _yellow_tripdata_2024h1_. I picked _table _yellow_tripdata_2024h1_mat_ for the name of the materialized table, and created it with 
```
CREATE OR REPLACE TABLE dn_dezc_week3.table _yellow_tripdata_2024h1_mat
AS
SELECT * FROM yellow_tripdata_2024h_;
```

Question 1. Answer: 20,332,093
Query used:
```
SELECT COUNT(1) FROM dn_dezc_week3.yellow_trip_data_2024h1;
```

Please note my (unintentional) quirk that the name of external table has no
"ext" suffix or prefix, and that the name of may materialized table end with
"_mat".

Question 2. Answer: 0 MB for the External Table and 155.12 MB for the Materialized Table
Query used:
```
SELECT COUNT(1) FROM (SELECT DISTINCT PULocationID FROM <tablename>)
```
where <tablename> varies over the names of the
external and materialized tables as noted above.
The estimates come from the "This query will process x megabaytes when run"
messages near the right edge and just above the top edge of the query box.

Question 3. Answer: BigQuery is a columnar database, and it only scans the specific columns requested in the query. Querying two columns (PULocationID, DOLocationID) requires reading more data than querying one column (PULocationID), leading to a higher estimated number of bytes processed. 

Question 4. Answer: 8,333
Query used:
```
SELECT COUNT(1) FROM
 (SELECT 1 FROM dn_dezc_week3.yellow_trip_data_2024h1_mat
  WHERE fare_amount = 0
 );
 ```

Question 5. Answer: Partition by tpep_dropoff_datetime and Cluster on VendorID

DDL used to create table:

```
CREATE TABLE dn_dezc_week3.yellow_trip_data_2024h1_pc
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID
AS (
  SELECT * FROM dn_dezc_week3.yellow_trip_data_2024h1_pc
);
```

Question 6. Answer: 310.24 MB for non-partitioned table and 26.84 MB for the partitioned table and 26.84 MB for the partitioned table

Queries used:
SELECT DISTINCT VendorID FROM `dn_dezc_week3.<tablename>`
  WHERE DATE(tpep_dropoff_datetime) BETWEEN DATE('2024-03-01')
  AND DATE('2024-03-15')

where <tablename> is first dn_dezc_week3.yellow_trip_data_2024h1_mat (unpartioned materialized table) and then dn_dezc_week3.yellow_trip_data_2024h1_pc (partitoned and clustered table)

Question 7. Answer: GCP Bucket
The data for our external table is, more specifically, in the parquet files uploaded to our GCP Bucket.

Question 8. Answer: False
If you have a table that you write to frequently and a field that you rarely filter on in queries, maintaining the sort order on that field can cost you more overall than the time you save on those rare queries.

Question 9. Answer: I'm not sure why...

Presumably the reason that bigquery doesn't have to
process data in "SELECT COUNT(*) FROM <some_table>" is that it just gets
the number of rows from some metadata. [It is so written in a stack overflow
answer](https://stackoverflow.com/questions/50302724/bigquery-this-query-will-process-0-b-when-run). But [this explanation from Google Cloud's own knowledgebase](https://cloud.google.com/knowledge/kb/bigquery-count-query-slot-utilization-and-rows-scanned-000004360) says that "All of the table rows will get scanned for a COUNT(*) statement".

It seems to me that the latter source is more authoritative, but my materialized table contains 12 million rows. I'd think that you'd have to read at least 12 million bytes to scan 12 million rows. The only explanation I have to square these two facts is how the word "processed" is interpreted: maybe "processing" means "doing something with some data within the rows of the table". This query does not have to do that. It's just counting the rows themselves.
