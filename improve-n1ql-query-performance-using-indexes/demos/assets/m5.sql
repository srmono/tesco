###############################################
############################### Adaptive Indexes
###############################################


SELECT * 
FROM `travel-sample`
WHERE name LIKE "%Air%" 
AND type = "airline";

CREATE INDEX `travel_airlinename` 
ON `travel-sample`(`name`) 
WHERE type = "airline";

SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND name LIKE "%Air%";

SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND name LIKE "%Air%" 
AND country = "France";

## Create a composite index which uses name and country
CREATE INDEX `travel_airlinenamecountry` 
ON `travel-sample`(`name`, `country`, `type`) 
WHERE type = "airline";

## This query uses the new index
SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND name LIKE "%Air%"
AND country = "France";


## This query uses the second attribute in the travel_airlinenamecountry index
## But not the first. So that index is not used for this query
SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND country = "France";


## Create an adaptive index using the name, country and type fields
CREATE INDEX `travel_adaptive_airlinenamecountry` 
ON `travel-sample`(DISTINCT PAIRS({name, country, type}))
WHERE type = "airline";

SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND country = "France";

SELECT * 
FROM `travel-sample`
USE INDEX (travel_adaptive_airlinenamecountry)
WHERE type = "airline"
AND country = "France";


## This query uses the new index
SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND name LIKE "%Air%"
AND country = "France";

# This still uses the non-adaptive index
## For this query the index is a partial_adaptive_index
SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND name LIKE "%Air%"
AND country = "France"
AND iata LIKE "A%";

## Create a new index with iata
CREATE INDEX `travel_adaptive_airlinenamecountryiata` 
ON `travel-sample`(DISTINCT PAIRS({name, country, type, iata}))
WHERE type = "airline";

# Now the new adaptive index is used
SELECT * 
FROM `travel-sample`
WHERE type = "airline"
AND name LIKE "%Air%"
AND country = "France"
AND iata LIKE "A%";



###############################################
############################### Adaptive Index over Self
###############################################

SELECT *
FROM `travel-sample`
WHERE city IS NULL
AND `type` = "hotel";

CREATE INDEX `travel_hotel_self`
ON `travel-sample`(DISTINCT PAIRS(self))
WHERE type = "hotel";

## Navigate to indexes and check out the number of items in the travel_hotel_self index

##

SELECT *
FROM `travel-sample`
WHERE city IS NULL
AND `type` = "hotel";

## Other indexes may not get used when the USE INDEX clause is included
SELECT *
FROM `travel-sample` 
USE INDEX (travel_hotel_self)
WHERE city IS NULL
AND `type` = "hotel";

##

SELECT *
FROM `travel-sample`
USE INDEX (travel_hotel_self)
WHERE free_breakfast = true
AND pets_ok = true
AND `type` = "hotel";

#######
DROP INDEX `travel-sample`.travel_adaptive_airlinenamecountry;
DROP INDEX `travel-sample`.travel_adaptive_airlinenamecountryiata;
DROP INDEX `travel-sample`.travel_airlinename;
DROP INDEX `travel-sample`.travel_airlinenamecountry;
DROP INDEX `travel-sample`.travel_hotel_self;


###############################################
############################### Indexing Metadata
###############################################


## Indexing Metadata Information

SELECT META().*
FROM `travel-sample`
LIMIT 1;

CREATE INDEX travel_meta_id 
ON `travel-sample` (META().id);

##

SELECT name, META().id
FROM `travel-sample`
USE INDEX (travel_meta_id)
WHERE type="hotel"
ORDER BY META().id DESC
LIMIT 10;

#######

CREATE INDEX travel_meta_exp 
ON `travel-sample` (META().expiration);

##

SELECT META().id, META().expiration
FROM `travel-sample`
WHERE META().expiration = 0
AND META().id > "l"
ORDER BY META().id
LIMIT 5;

SELECT META().id
FROM `travel-sample`
USE INDEX (idx_meta_id)
WHERE META().id LIKE "air%";

#######

CREATE INDEX travel_meta_type 
ON `travel-sample` (META().type); # will throw error
# not indexable

##

SELECT META().id, META().type
FROM `travel-sample`
WHERE META().type IS VALUED
LIMIT 10;



###############################################
############################### Index Partitioning
###############################################

SELECT name, city, id
FROM `travel-sample`
WHERE city IN ["Ringway","Cumbria","Inyo County"]
ORDER BY name;

## Partition by Hash and Partition using document keys

CREATE INDEX travel_par_id
ON `travel-sample`(city, name, id)
PARTITION BY HASH (META().id);

##

SELECT name, city, id
FROM `travel-sample`
WHERE city IN ["Ringway","Cumbria","Inyo County"]
ORDER BY name;

# click on Plan
##

CREATE INDEX travel_par_id_alt
ON `travel-sample`(city, name, id)
PARTITION BY HASH (META().id);

## rerun the same query

SELECT name, city, id
FROM `travel-sample`
WHERE city IN ["Ringway","Cumbria","Inyo County"]
ORDER BY name;

# click on plan
# execute this twice so it takes 2 indexes alternatively

#######

SELECT airline, airlineid
FROM `travel-sample`
WHERE sourceairport="SFO"
AND destinationairport="PVR"
AND stops = 0;

## 

CREATE INDEX travel_par_srcdest 
ON `travel-sample` (sourceairport, destinationairport, stops)
PARTITION BY HASH (sourceairport, destinationairport);

##

SELECT airline, airlineid
FROM `travel-sample`
WHERE sourceairport="SFO"
AND destinationairport="PVR"
AND stops = 0;

# click on Plan

##
## go to indexes and show idx_par_2 , by default the num of partition is 8
## to change the partition

CREATE INDEX travel_par_srcdest_alt
ON `travel-sample` (sourceairport, destinationairport, stops)
PARTITION BY HASH (sourceairport, destinationairport) 
WITH {"num_partition":16};

## go to indexes and show the partition

SELECT airline, airlineid
FROM `travel-sample`
WHERE airline in ["AM", "AS", "DL"] 
AND sourceairport="SFO"
AND destinationairport="PVR"
AND stops = 0;

# click on Plan

###############################################
############################### Functions in Partition Indexes
###############################################

## Using functions in partition indexes

CREATE INDEX travel_par_srcdest_lcase 
ON `travel-sample` (LOWER(sourceairport), LOWER(destinationairport), stops) 
PARTITION BY HASH (LOWER(sourceairport), LOWER(destinationairport))
WITH {"nodes":["127.0.0.1:8091"]};

##

SELECT airline,airlineid
FROM `travel-sample`
WHERE airline IN ["AM", "AS", "DL"]
AND LOWER(sourceairport)="sfo"
AND LOWER(destinationairport)="pvr"
AND stops = 0;

# click on Plan

##

SELECT airline, airlineid, sourceairport
FROM `travel-sample`
WHERE sourceairport IN ["SFO", "ATL", "LAX"]
AND destinationairport="PVR"
AND stops = 0;

# click on Plan

##

SELECT airline, airlineid, sourceairport
FROM `travel-sample`
WHERE sourceairport IN ["SFO", "ATL", "LAX"]
AND stops = 0;

# click on Plan

##

SELECT airline, airlineid, sourceairport
FROM `travel-sample`
WHERE sourceairport IN ["SFO", "ATL", "LAX"]
AND destinationairport IS VALUED
AND stops = 0;

# click on Plan

##

SELECT airline, airlineid, sourceairport
FROM `travel-sample`
WHERE sourceairport IS VALUED
AND destinationairport IS VALUED
AND stops = 0;

# click on Plan

##

SELECT airline, airlineid, sourceairport
FROM `travel-sample`
WHERE sourceairport = "SFO"
AND type="route";

# click on Plan

##
# Choosing partition keys for Aggregate query

SELECT sourceairport, destinationairport, 
	   SUM(ARRAY_COUNT(schedule)) AS numFlights
FROM `travel-sample`
WHERE sourceairport = "PVR"
AND type = "route"
GROUP BY destinationairport, sourceairport;


CREATE INDEX travel_par_schedcount 
ON `travel-sample` (sourceairport, 
					destinationairport, 
					ARRAY_COUNT(schedule)) 
PARTITION BY HASH (META().id)
WHERE type="route";

##

SELECT sourceairport, destinationairport, 
	   SUM(ARRAY_COUNT(schedule)) AS numFlights
FROM `travel-sample`
WHERE sourceairport = "PVR"
AND type = "route"
GROUP BY destinationairport, sourceairport;

# click on Plan

##

CREATE INDEX travel_par_schedcount_alt
ON `travel-sample` (sourceairport, 
					destinationairport, 
					ARRAY_COUNT(schedule)) 
PARTITION BY HASH (sourceairport, destinationairport)
WHERE type="route";

## rerun the same query

SELECT sourceairport, destinationairport, 
	   SUM(ARRAY_COUNT(schedule)) AS numFlights
FROM `travel-sample`
WHERE sourceairport = "PVR"
AND type = "route"
GROUP BY destinationairport, sourceairport;

# click on Plan

#######

# creating partitioned index with specific key size and array size

CREATE INDEX travel_par_sizing
ON `travel-sample` (sourceairport, 
					destinationairport, 
					ARRAY_COUNT(schedule)) 
PARTITION BY HASH (sourceairport, destinationairport)
WHERE type="route"
WITH {"secKeySize":20, "docKeySize":20, "arrSize": 100};


## Cleaning up

DROP INDEX `travel-sample`.travel_meta_exp;
DROP INDEX `travel-sample`.travel_meta_id;
DROP INDEX `travel-sample`.travel_par_id;
DROP INDEX `travel-sample`.travel_par_id_alt;
DROP INDEX `travel-sample`.travel_par_schedcount;
DROP INDEX `travel-sample`.travel_par_schedcount_alt;
DROP INDEX `travel-sample`.travel_par_sizing;
DROP INDEX `travel-sample`.travel_par_srcdest;
DROP INDEX `travel-sample`.travel_par_srcdest_alt;
DROP INDEX `travel-sample`.travel_par_srcdest_lcase;

