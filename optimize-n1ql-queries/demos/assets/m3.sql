
################################################
################################ Optimizing Query Executions with Indexes
################################################

## Re-run this query and check the execution time 
SELECT DISTINCT city
FROM `travel-sample` 
WHERE country LIKE "United%";

## Create an index on country
CREATE INDEX idx_country ON `travel-sample`(country);

## Head over to the Indexes page and view the index

## Re-run the query. It's quicker now
SELECT DISTINCT city
FROM `travel-sample` 
WHERE country LIKE "United%";

## This query references a few extra fields
SELECT name, city, country
FROM `travel-sample` 
WHERE country LIKE "United%"
AND type IN ["landmark", "hotel"];

## Check the plan - two indexes are used

## Create a composite index on type and country
CREATE INDEX idx_type_country ON `travel-sample`(type, country);

## Re-run this query. Just the new index is used
SELECT name, city, country
FROM `travel-sample` 
WHERE country LIKE "United%"
AND type IN ["landmark", "hotel"];

## This query still references the idx_country index
SELECT DISTINCT city
FROM `travel-sample` 
WHERE country LIKE "United%";



################################################
################################ The EXPLAIN Statement
################################################

## Run this query and check out the plan as well as plan text
SELECT country, city, name
FROM `travel-sample`
WHERE type IN ["landmark", "hotel"];

## Click on Explain - and check out the JSON, Plan and Plan Text

## Run this - the output is the same as hitting the Explain option
EXPLAIN SELECT country, city, name
FROM `travel-sample`
WHERE type IN ["landmark", "hotel"];

## Check the JSON, Plan and Plan Text

EXPLAIN SELECT name,
		       country,
		       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel";

## Check the JSON, Plan and Plan Text


EXPLAIN SELECT name,
		       country,
		       city
FROM `travel-sample`
WHERE city IS NOT NULL
AND type="hotel"
ORDER BY name;

## Check the Plan


SELECT *
FROM `travel-sample`
WHERE type="route"
LIMIT 1;

SELECT META().id, *
FROM `travel-sample`
WHERE type="airline"
LIMIT 1;

EXPLAIN SELECT rt.sourceairport, 
		       rt.destinationairport, 
		       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Check the Plan

EXPLAIN SELECT sourceairport, COUNT(*)
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport;

## Check the Plan

EXPLAIN SELECT sourceairport, COUNT(*)
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport
HAVING COUNT(*) > 5
ORDER BY COUNT(*) DESC;

## Check the Plan

EXPLAIN INSERT INTO `travel-sample` (KEY,VALUE) 
VALUES ("airline_09",{  "callsign":"AIRDEUTSCH",
						"country":"Germany",
						"iata":"G1",
						"icao":"MLE",
						"id":9,
						"name":"AirGermany",
						"type":"airline"
					});

## Check the Plan

EXPLAIN UPSERT INTO `travel-sample` (KEY,VALUE) 
VALUES ("airline_09",{  "callsign":"AIRDEUTSCHE",
						"country":"Germany",
						"iata":"G1",
						"icao":"MLE",
						"id":9,
						"name":"AirGermany",
						"type":"airline"
					});

## Check the Plan

EXPLAIN DELETE 
FROM `travel-sample`
WHERE iata = "G1";

## Check the Plan
