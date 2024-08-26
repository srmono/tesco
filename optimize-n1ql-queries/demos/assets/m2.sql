################################################
################################ The Query Execution Plan
################################################


# Getting to know the data

SELECT *
FROM `travel-sample`
LIMIT 5;

SELECT DISTINCT RAW type
FROM `travel-sample`;

SELECT type, COUNT(*) as count
FROM `travel-sample`
GROUP BY type;

SELECT *
FROM `travel-sample`
WHERE type="hotel"
LIMIT 1;

SELECT *
FROM `travel-sample`
WHERE type="landmark"
LIMIT 1; 

SELECT *
FROM `travel-sample`
WHERE type="route"
LIMIT 1;

## Navigate to the indexes page and view all the indexes
## Expand the primary index and one of the secondary indexes

## Get name and type from all documents
SELECT name, type
FROM `travel-sample` ;

## Click on the Plan and view the various phases
## Click on each phase to view the details
## Click on the Plan Text and view the contents

## Retrieve all document IDs
SELECT META().id
FROM `travel-sample`;

## Click on the plan and view the various phases
## Click on the IndexScan phase and take a look
## Click on the Plan Text and view the contents

# This query involves a key scan
SELECT country, city, name
FROM `travel-sample`
USE KEYS ["hotel_10025", "landmark_27774"];

## Click on the plan and view the various phases
## Click on the KeyScan phase and take a look
## Click on the Plan Text and view the contents

## This query will reference the def_type index
SELECT DISTINCT city
FROM `travel-sample` 
WHERE type = "hotel";

## Click on the plan and view the various phases

## This query will reference the def_type and def_city indexes
SELECT DISTINCT city
FROM `travel-sample` 
WHERE type = "hotel"
AND city LIKE "San%";

## Click on the plan 

## There is no index on country, so this involves a primary scan
SELECT DISTINCT city
FROM `travel-sample` 
WHERE country LIKE "United%";

## Click on the plan