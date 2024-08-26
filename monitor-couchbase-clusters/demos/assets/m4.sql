
################################################
################################ Monitoring Queries from the UI
################################################

PREPARE hotels_ordered FROM
SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY name;


EXECUTE hotels_ordered;

## Check plan

SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;


PREPARE src_dest_airline FROM
SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

EXECUTE src_dest_airline;


## Run this query - it takes a while to run
SELECT lm.name, lm.activity, lm.address, lm.city,
       ap.airportname, ap.faa
FROM `travel-sample` lm
JOIN `travel-sample` ap
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

# While the query is running...

#Head to "Dashbord"
  # open Query (statistics)
  # Head to the top and from the drop-down, select "day" instead of "minute"
  # click on 1 or 2 of the graphs
  # Expand the Index service statistics
  # click on 1 or 2 of the graphs

## Head to the Query dashboard
## Re-run this query
SELECT lm.name, lm.activity, lm.address, lm.city,
       ap.airportname, ap.faa
FROM `travel-sample` lm
JOIN `travel-sample` ap
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

# Go over to "Query Monitor"
  #view 
    # 1.active
    # 2.completed
    # 3.PREPARED

# In the Active queries section, if the query is still running, hit cancel
# Head back to the Workbench and confirm that execution has stopped


################################################
################################ Monitoring Queries from the System Catalog
################################################

## View the system catalog 

SELECT *
FROM system:datastores;

SELECT *
FROM system:namespaces;

SELECT *
FROM system:keyspaces;

SELECT *
FROM system:indexes;

SELECT *
FROM system:indexes
WHERE is_primary = true;


## Re-run this query
SELECT lm.name, lm.activity, lm.address, lm.city,
       ap.airportname, ap.faa
FROM `travel-sample` lm
JOIN `travel-sample` ap
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

## Click on plan - it's available even while the query is running




## Open a new tab for the query workbench while the above query is running
## Re-run the query if it has finished
## Check the active requests
SELECT *, meta().plan 
FROM system:active_requests;

DROP INDEX `travel-sample`.idx_country;

## Re-run the long-running query. Without the index, it takes longer to run

## Check the active requests
SELECT *, meta().plan 
FROM system:active_requests;
## Copy the requestId

## Terminate running query
DELETE FROM system:active_requests 
WHERE requestId = "c947af92-817b-4134-a97f-a75c612043f6";

## The terminated query is no longer here
SELECT *, meta().plan 
FROM system:active_requests;

## Head to the other tab - the query has stopped running

## View completed queries
SELECT *, meta().plan 
FROM system:completed_requests;

## Pick the requestId of one of the queries
## Use that request here
DELETE FROM system:completed_requests 
WHERE requestId = "b2ffa6cd-086a-48a4-b1f2-7f4dd78e7f64";

## There is one fewer query this time
SELECT *, meta().plan 
FROM system:completed_requests;


SELECT *
FROM system:prepareds;

DELETE FROM system:prepareds
WHERE name = "hotels_ordered";

SELECT *
FROM system:prepareds;



################################################
################################ Monitoring Queries using the REST API
################################################


## Re-run the query
SELECT lm.name, lm.activity, lm.address, lm.city,
       ap.airportname, ap.faa
FROM `travel-sample` lm
JOIN `travel-sample` ap
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

## Head over to the shell and view active requests
curl -u admin:bvsrao \
http://localhost:8093/admin/active_requests

## Copy the requestId and substitute in this command
curl -u admin:bvsrao \
-X DELETE \
http://localhost:8093/admin/active_requests/c9a1a0d6-4b8c-4e7b-a2d0-fd10e08a45d5

## HEad to the query workbench - the query has stopped running

## View completed requests
curl -u admin:bvsrao \
http://localhost:8093/admin/completed_requests

## Pick the requestId of a completed request and delete it
curl -u admin:bvsrao \
-X DELETE \
http://localhost:8093/admin/completed_requests/19d92873-08b3-4e13-9550-c59af067d9b4

## View prepared statements
curl -u admin:bvsrao \
http://localhost:8093/admin/prepareds

## Delete a prepared statement
curl -u admin:bvsrao \
-X DELETE http://localhost:8093/admin/prepareds/hotels_ordered

## Confirm the removal
curl -u admin:bvsrao \
http://localhost:8093/admin/prepareds


################################################
################################ Analyzing Query Statistics using N1QL
################################################


## Get all completed requests
SELECT *, meta().plan 
FROM system:completed_requests;

## View details of queries which generated large results
SELECT statement, resultSize, resultCount,
       remoteAddr, requestTime, elapsedTime
FROM system:completed_requests
WHERE resultSize > 1000;

## Queries which returned many documents
SELECT statement, resultSize, resultCount,
       remoteAddr, requestTime, elapsedTime
FROM system:completed_requests
WHERE resultCount > 10;

## View the request distribution per node
SELECT node, COUNT(*) AS request_count
FROM system:completed_requests
GROUP BY node;

## View queries which took over 2s to run
SELECT statement, resultSize, resultCount, elapsed
FROM system:completed_requests
LET elapsed = TO_NUMBER(REPLACE(elapsedTime, "s", ""))
WHERE elapsed > 2;




################################################
################################ Monitoring Indexes using the REST API
################################################

curl -X GET \
-u admin:bvsrao \
http://localhost:9102/api/v1/stats

curl -X GET \
-u admin:bvsrao \
http://localhost:9102/api/v1/stats?pretty=true

curl -X GET \
-u admin:bvsrao \
http://localhost:9102/api/v1/stats/travel-sample/def_city?pretty=true


curl -X GET \
-u admin:bvsrao \
http://localhost:9102/api/v1/stats/travel-sample/def_route_src_dst_day?pretty=true

curl -X GET \
-u admin:bvsrao \
http://localhost:9102/api/v1/stats/beer-sample/def_primary?pretty=true





curl -X GET \
-u admin:bvsrao \
http://localhost:8093/admin/settings \
| jq

cd /opt/couchbase/bin

./cbq --engine http://localhost:8091 \
--user admin --password bvsrao


DELETE 
FROM system:completed_requests; 

SELECT * FROM `beer-sample` 
WHERE abv BETWEEN 8 AND 10
and category = "German Ale"
ORDER BY name;

SELECT *, meta().plan 
FROM system:completed_requests;

\SET -profile "phases";

DELETE 
FROM system:completed_requests; 

SELECT * FROM `beer-sample` 
WHERE abv BETWEEN 8 AND 10
and category = "German Ale"
ORDER BY name;

\SET -profile "timings";

DELETE 
FROM system:completed_requests; 

SELECT * FROM `beer-sample` 
WHERE abv BETWEEN 8 AND 10
and category = "German Ale"
ORDER BY name;

curl -X GET \
-u admin:bvsrao \
http://localhost:8093/admin/settings \
| jq

curl -u admin:bvsrao \
http://localhost:8093/admin/settings  \
-H 'Content-Type: application/json' \
-d '{"profile": "phases"}' \
| jq


curl -v \
-u admin:bvsrao \
http://localhost:8093/query/service \
-d 'statement=SELECT * FROM `beer-sample` LIMIT 2;' \
| jq

curl -u admin:bvsrao \
http://localhost:8093/admin/settings  \
-H 'Content-Type: application/json' \
-d '{"profile": "timings"}' \
| jq

curl -v \
-u admin:bvsrao \
http://localhost:8093/query/service \
-d 'statement=SELECT * FROM `beer-sample` LIMIT 2;' \
| jq

curl -u admin:bvsrao \
http://localhost:8093/admin/settings  \
-H 'Content-Type: application/json' \
-d '{"profile": "off"}' \
| jq

curl -v \
-u admin:bvsrao \
http://localhost:8093/query/service \
-d 'statement=SELECT * FROM `beer-sample` LIMIT 2;' \
| jq

curl -v \
-u admin:bvsrao \
http://localhost:8093/query/service \
-d 'profile=phases&statement=SELECT * FROM `beer-sample` LIMIT 2;' \
| jq

curl -X GET \
-u admin:bvsrao \
http://localhost:8093/admin/settings \
| jq

cd /opt/couchbase/bin

./cbq --engine http://localhost:8091 \
> --user admin --password bvsrao


DELETE 
FROM system:completed_requests; 

\set -profile "timings";
cbq> SELECT * FROM `beer-sample` 
WHERE 
ORDER BY name;



