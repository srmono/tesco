################################################
################################ Monitoring Queries from the UI
################################################

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

## Copy the requestId

## Terminate running query
DELETE FROM system:active_requests 
WHERE requestId = "ba669297-d48d-45ef-a28c-f0ac26998c34";

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
WHERE requestId = "a7b683fb-98e8-4423-93be-85c0ccffa0f7";

## There is one fewer query this time
SELECT *, meta().plan 
FROM system:completed_requests;


SELECT *
FROM system:prepareds;

DELETE FROM system:prepareds
WHERE name = "ucase_UK_hotel";

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
curl -u Administrator:123456 \
http://localhost:8093/admin/active_requests

## Copy the requestId and substitute in this command
curl -u Administrator:123456 \
-X DELETE http://localhost:8093/admin/active_requests/09c70d74-4901-4860-883a-921d20bfc62c

## HEad to the query workbench - the query has stopped running

## View completed requests
curl -u Administrator:123456 \
http://localhost:8093/admin/completed_requests

## Pick the requestId of a completed request and delete it
curl -u Administrator:123456 \
-X DELETE http://localhost:8093/admin/completed_requests/85b0e218-f66a-400a-ba8a-a4554cb15b09

## View prepared statements
curl -u Administrator:123456 \
http://localhost:8093/admin/prepareds

## Delete a prepared statement
curl -u Administrator:123456 \
-X DELETE http://localhost:8093/admin/prepareds/hotels_ordered

## Confirm the removal
curl -u Administrator:123456 \
http://localhost:8093/admin/prepareds




################################################
################################ Request Profiling
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
WHERE resultCount > 1000;

## View the request distribution per node
SELECT node, COUNT(*) AS request_count
FROM system:completed_requests
GROUP BY node;

## View queries which took over 2s to run
SELECT statement, resultSize, resultCount, elapsed
FROM system:completed_requests
LET elapsed = TO_NUMBER(REPLACE(elapsedTime, "s", ""))
WHERE elapsed > 2;


## HEad to the shell
curl -u Administrator:123456 \
http://localhost:8093/admin/vitals

curl -u admin:bvsrao \
http://localhost:8093/admin/vitals



