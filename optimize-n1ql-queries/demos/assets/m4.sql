
################################################
################################ Using Ordered Indexes
################################################


SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel";


## Adding an ORDER BY clause adds an extra Order phase to the plan
SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY name;


## Sorting by city results in an OrderedIntersectScan
SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY city;

## View the plan text and look at the contents of the OrderedIntersectScan

## Sort in the descending order of city
SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY city DESC;

## This time, there is a separate Order phase
## The index on city is in ascending order, 
## so its underlying order can't be used

CREATE INDEX idx_city_desc ON `travel-sample`(city DESC);

## Re-run the query and check the plan (and plan text)
## The new index is used
SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY city DESC;


DROP INDEX `travel-sample`.idx_city_desc;
DROP INDEX `travel-sample`.idx_country;
DROP INDEX `travel-sample`.idx_type_country;

################################################
################################ Indexes for JOIN Operations
################################################

SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## View the plan
## Click on Advise
## Click on Create & Build Index
## Head to the Indexes page - the new index has been created

## Head back to the Query interface and re-run the query
## It runs a little quicker, but still takes a while
## Check the plan
## Click on Advise - it recommends a covered index

## Re-run with the ADVISE keyword at the beginning
ADVISE SELECT rt.sourceairport, 
		      rt.destinationairport, 
		      rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Check the JSON, Plan, Plan Text and Advice
## Click on Create & Build Covered Index
## Head to the Indexes page - the new index has been created

## Head back to the Query interface and re-run the query
## It runs very quickly
SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Check the plan - the new index is used
## Click on Advise - indexes are sufficient


DROP INDEX `travel-sample`.adv_airlineid;
DROP INDEX `travel-sample`.adv_airlineid_sourceairport_destinationairport;
DROP INDEX `travel-sample`.adv_type_sourceairport;


################################################
################################ Optimizing GROUP BY Operations
################################################

SELECT sourceairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport;

## Check the plan
## Click on Advise
## Choose Create & Build Covered index (which will be on type and sourceairport)

## Re-run the query - it's really quick
## Check the plan - the new index is used
## Click on Advise - indexes are sufficient

## This groups based on two fields
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport;

## Check the plan - it uses the new index. But is still slow
## Check the Advice

## This has the destination first and then the source
CREATE INDEX idx_dest_src
ON `travel-sample`(`destinationairport`, `sourceairport`);

## Re-run the query - it's slow
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport;

## Check the plan - it uses an index with type as the lead attribute

## Remove the where type = "route" clause
## It's still slow
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
GROUP BY sourceairport, destinationairport;

## It does a PrimaryScan

## This also involves a primary scan
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
GROUP BY destinationairport, sourceairport;


CREATE INDEX idx_type_src
ON `travel-sample`(`type`, `sourceairport`);

CREATE INDEX idx_type_dest
ON `travel-sample`(`type`, `destinationairport`);

## Re-run the query 3 times - it uses the def_type and type_src index
## But never the type_dest index
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport;

CREATE INDEX idx_type_src_dest
ON `travel-sample`(`type`, `sourceairport`, `destinationairport`);

CREATE INDEX idx_type_dest_src
ON `travel-sample`(`type`, `destinationairport`, `sourceairport`);

## Re-run the query 3 times - it switches between the two newest indexes
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport;


DROP INDEX `travel-sample`.idx_dest_src;
DROP INDEX `travel-sample`.idx_type_dest;
DROP INDEX `travel-sample`.idx_type_dest_src;
DROP INDEX `travel-sample`.idx_type_src;
DROP INDEX `travel-sample`.idx_type_src_dest;


################################################
################################ Prepared Statements
################################################

SELECT name,
       country,
       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY name;

## Check plan

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

SELECT name, country, city
FROM `travel-sample`
WHERE type = "hotel"
AND country = "United Kingdom";

## Prepared statement for an update
PREPARE ucase_UK_hotel FROM
UPDATE `travel-sample`
SET country = "UK"
WHERE type = "hotel"
AND country = "United Kingdom";

EXECUTE ucase_UK_hotel;

## Confirm the changes
SELECT name, country, city
FROM `travel-sample`
WHERE type = "hotel"
AND country = "UK";

## Undoing the changes
UPDATE `travel-sample`
SET country = "United Kingdom"
WHERE type = "hotel"
AND country = "UK";


################################################
################################ Accessing Prepared Statements
################################################


## View the prepared statements
SELECT *
FROM system:prepareds;

## Navigate to Query Monitor --> Prepared
## Click on one of the PREPARE statements


#go to terminal
#go to bin
cd /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin

## Run a prepared statement using CBQ
./cbq \
-e http://127.0.0.1:8091 \
--script='EXECUTE src_dest_airline' \
-u Administrator \
-p 123456

curl -v http://localhost:8093/query/service \
-d 'statement=EXECUTE src_dest_airline' \
-u Administrator:123456


curl http://127.0.0.1:8093/admin/settings -u Administrator:123456
#checking autoprepare setting(false)

#setting auto-prepare:true
curl http://127.0.0.1:8093/admin/settings -d '{"auto-prepare":true}' -u Administrator:123456

## Now go to UI run this query
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
GROUP BY destinationairport, sourceairport;

## View the prepared statements
SELECT *
FROM system:prepareds;

## The latest query should be close to the bottom of the results
## Capture its "name"

## Substitute the correct name
EXECUTE "78c3cd4e-59a5-54e4-8cdc-5634e5fa4c97";

#setting auto-prepare:false
curl http://127.0.0.1:8093/admin/settings \
-d '{"auto-prepare":false}' \
-u Administrator:123456






