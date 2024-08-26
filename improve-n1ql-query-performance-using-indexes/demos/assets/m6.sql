
###############################################
############################### Factors Affecting Index Selection
###############################################

SELECT count(city)
FROM `travel-sample`
WHERE type = "hotel"
AND city = "Bishop";

##

CREATE INDEX idx_all_city 
ON `travel-sample` (city, type);

## 

SELECT count(city)
FROM `travel-sample`
WHERE type = "hotel"
AND city = "Bishop";

##

SELECT name, city, country
FROM `travel-sample`
WHERE type = "hotel"
AND city = "Bishop";

# click on Plan and then on Explain

##

CREATE INDEX idx_hotel 
ON `travel-sample`(name, city, country) 
WHERE (`type` = "hotel");

## rerun the same query
## The WHERE clause does not reference the leading index attribute (name) of idx_hotel
## So that index is not selected
SELECT name, city, country
FROM `travel-sample`
WHERE type = "hotel"
AND city = "Bishop";

##

CREATE INDEX idx_main_atts 
ON `travel-sample` (name, country, city, type);

##

SELECT city, name, country
FROM `travel-sample`
USE INDEX (idx_main_atts)
WHERE type = "hotel"
AND city = "Bishop"; # it does not use the idx_main_atts index 

## When the lead index attribute is referenced, the idx_main_atts gets used
## For this query, it becomes a covering index
SELECT city, name, country
FROM `travel-sample`
WHERE type = "hotel"
AND city = "Bishop"
AND name IS VALUED;

SELECT city, name, country
FROM `travel-sample`
WHERE type = "hotel"
AND name IS VALUED;


##

CREATE INDEX idx_freeinternet 
ON `travel-sample`(free_internet)
WHERE type="hotel" ;

##

SELECT name, city
FROM `travel-sample`
WHERE type="hotel"
AND free_internet IS MISSING;

# click on Plan and then on Explain 
# The index cannot be used for details of missing authors

##

SELECT name, city
FROM `travel-sample`
WHERE type="hotel"
AND free_internet IS NOT MISSING;

# click on Plan and then on Explain


###############################################
############################### The EXPLAIN statement
###############################################

## The EXPLAIN statement

EXPLAIN SELECT name, city
FROM `travel-sample`
WHERE type="hotel"
AND free_internet IS NOT MISSING;

EXPLAIN SELECT name, city
FROM `travel-sample`
WHERE type="hotel"
AND free_internet IS MISSING;

EXPLAIN SELECT city, name, country
FROM `travel-sample`
WHERE type = "hotel"
AND city = "Bishop"
AND name IS VALUED;

## Cleaning up
DROP INDEX `travel-sample`.idx_all_city;
DROP INDEX `travel-sample`.idx_hotel;
DROP INDEX `travel-sample`.idx_main_atts;
DROP INDEX `travel-sample`.idx_freeinternet;


###############################################
############################### Use of Indexes
###############################################


# create 2 indexes
# create index on id of type="hotel"

CREATE INDEX idx_hotel_id 
ON `travel-sample`(id)
WHERE type = "hotel";

# create index on hotel name 

CREATE INDEX idx_hotel_name 
ON `travel-sample`(name)
WHERE type = "hotel";

##
# Equality Predicate

EXPLAIN SELECT META().id, name
FROM `travel-sample`
WHERE type = "hotel"
AND id = 65;

# click on Plan text

##

EXPLAIN SELECT META().id, name
FROM `travel-sample`
WHERE type = "hotel"
AND id <= 65;
##


##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type="hotel"
AND id > 65;

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type="hotel"
AND id >= 65 AND id <= 1000 ;

##

SELECT META().id,name
FROM `travel-sample`
WHERE type="hotel"
AND id >= 65 AND id < 1000 ;

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type = "hotel"
AND (id >= 100 OR id <= 500);

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type = "hotel"
AND id >= 100 OR id <= 500; # primary index is used

# click on Plan Text, there is no span 

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type = "hotel"
AND id IN [590, 591, 592, 593, 594];

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type = "hotel"
AND id IN (SELECT RAW ts.id
            FROM `travel-sample` AS ts
            WHERE type= 'hotel'
            AND id <= 100);
            
##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type= "hotel"
AND ((id BETWEEN 100 AND 2500) 
    OR (id > 50 AND id <= 1000));

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type= "hotel"
AND ((id BETWEEN 100 AND 2500) 
    AND (id > 50 AND id <= 1000));

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type= "hotel"
AND id <> 65;

##
  
EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type= "hotel"
AND id NOT IN [593, 594, 595, 596, 597];

##

EXPLAIN SELECT META().id,name
FROM `travel-sample`
WHERE type= "hotel"
AND NOT (id >= 1000 AND id < 30000);

##

EXPLAIN SELECT META().id, name, city
FROM `travel-sample`
WHERE type= "hotel"
AND name = "Balinoe Campsite";

##

EXPLAIN SELECT META().id,name,city
FROM `travel-sample`
WHERE type= "hotel"
AND name >= "Balinoe Campsite"
AND name <= "Club Med";

##

EXPLAIN SELECT META().id,name,city
FROM `travel-sample`
WHERE type= "hotel"
AND name LIKE "%hotel%";

##

EXPLAIN SELECT META().id,name,city
FROM `travel-sample`
WHERE type= "hotel"
AND name NOT LIKE "%hotel%";

## Cleaning up
DROP INDEX `travel-sample`.idx_hotel_id;
DROP INDEX `travel-sample`.idx_hotel_name;






###############################################
############################### Indexes and GROUP BY
###############################################


#######

SELECT sourceairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport;

## Click on plan. It uses the primary index

CREATE INDEX idx_route_src 
ON `travel-sample` (sourceairport) 
WHERE type = "route";

## Re-run the query
SELECT sourceairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport;

CREATE INDEX idx_route_src_type
ON `travel-sample` (sourceairport, type) 
WHERE type = "route";

## Re-run the query. It doesn't use the new index
SELECT sourceairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport;

CREATE INDEX idx_route_type_src 
ON `travel-sample` (type, sourceairport) 
WHERE type = "route";

## Re-run the query. The newest index gets used (and is a covered index)
SELECT sourceairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport;

## When the destinationairport is included, the query still needs to fetch from disk
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport;

CREATE INDEX idx_route_type_dest_src 
ON `travel-sample` (type, destinationairport, sourceairport) 
WHERE type = "route";

## Re-run the query. The new index is used despite the different order or src and dest
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport;

## The index is still used with the introduction of the HAVING clause
SELECT sourceairport, destinationairport,
       COUNT(*) AS routeCount
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport, destinationairport
HAVING COUNT(*) > 5;

## This query requires a disk fetch due to the distance field being included
SELECT sourceairport,
       COUNT(*) AS routeCount,
       AVG(distance) as avgDistance
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport
HAVING COUNT(*) > 5
AND AVG(distance) > 1000;

## A fetch is still performed when the distance is only in the select clause
SELECT sourceairport,
       COUNT(*) AS routeCount,
       AVG(distance) as avgDistance
FROM `travel-sample`
WHERE type = "route"
GROUP BY sourceairport
HAVING COUNT(*) > 5;



###############################################
############################### GROUP BY on Expressions
###############################################

CREATE INDEX idx_expr
ON `travel-sample`(ROUND(distance, -2), sourceairport)
WHERE type="route";

##
## This query does not get used as the ROUND is not in the where clause
SELECT ROUND(distance, -2) AS distance,
       COUNT(sourceairport) numAirports
FROM `travel-sample`
WHERE type = "route"
GROUP BY ROUND(distance, -2);

## Even in this case, the index is not used
SELECT ROUND(distance, -2) AS distance,
       COUNT(sourceairport) numAirports
FROM `travel-sample`
WHERE ROUND(distance) IS NOT MISSING
AND type = "route"
GROUP BY ROUND(distance, -2);

## The index is used when there is a match with the lead attribute of the index
SELECT ROUND(distance, -2) AS distance,
       COUNT(sourceairport) numAirports
FROM `travel-sample`
WHERE ROUND(distance, -2) IS NOT MISSING
AND type = "route"
GROUP BY ROUND(distance, -2);

##

SELECT sourceairport,
       MAX(ROUND(distance)) AS total_distance
FROM `travel-sample` 
USE INDEX (idx_expr)
WHERE sourceairport IS NOT MISSING
AND type = "route"
GROUP BY sourceairport; # wont use idx_expr

## create index by exchanging the field

CREATE INDEX idx_expr_2
ON `travel-sample`(sourceairport,ROUND(distance))
WHERE type="route";

## rerun the query

SELECT sourceairport,
       MAX(ROUND(distance)) AS total_distance
FROM `travel-sample` 
USE INDEX (idx_expr)
WHERE sourceairport IS NOT MISSING
AND type = "route"
GROUP BY sourceairport; # it uses idx_expr_2 index

## Clean up
DROP INDEX `travel-sample`.idx_expr;
DROP INDEX `travel-sample`.idx_route_src;
DROP INDEX `travel-sample`.idx_route_src_type;
DROP INDEX `travel-sample`.idx_route_type_dest_src;
DROP INDEX `travel-sample`.idx_route_type_src;




