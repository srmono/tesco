###############################################
############################### Understanding Pushdowns
###############################################


## go to indexes and show `def_route_src_dst_day` index
## go to query and execute

# index projection

EXPLAIN SELECT sourceairport, destinationairport 
FROM `travel-sample`
USE INDEX (def_route_src_dst_day)
WHERE sourceairport IN ["PVR","SFO"]
AND type = "route";

# click on Plan Text
# observe "index_projection" and "spans"

#######

EXPLAIN SELECT destinationairport, sourceairport
FROM `travel-sample` 
USE INDEX (idx_dist_src_dst)
WHERE type = "route"
AND distance BETWEEN 1000 AND 2000
AND sourceairport = "SFO";

## Click on the IndexScan3 box and observe that the "span" includes
## the sourceairport filter, but not the distance

# create a composite index on sourceairport, destinationairport and distance

CREATE INDEX `idx_dist_src_dst`
ON `travel-sample`(`distance`,`sourceairport`,`destinationairport`)
WHERE (`type` = "route");

##

EXPLAIN SELECT destinationairport, sourceairport
FROM `travel-sample` 
USE INDEX (idx_dist_src_dst)
WHERE type = "route"
AND distance BETWEEN 1000 AND 2000
AND sourceairport = "SFO";

## Click on the IndexScan3 box and observe that the "span" includes
## the sourceairport filter and also the distance

EXPLAIN SELECT destinationairport, sourceairport
FROM `travel-sample` 
USE INDEX (idx_dist_src_dst)
WHERE type = "route"
AND distance > 1000
AND sourceairport = "SFO";

## Click on the IndexScan3 box and observe that the "span"
## has an inclusion of 0 for the distance attribute
## In the JSON output, you can observe the "spans" section
## This time, the "spans" in the JSON shows that the inclusion is 1
## for the distance attribute with only a low

EXPLAIN SELECT destinationairport, sourceairport
FROM `travel-sample` 
USE INDEX (idx_dist_src_dst)
WHERE type = "route"
AND sourceairport = "SFO"
AND distance >= 1000
AND distance < 2000;

## The "spans" in the JSON has a single range for the distance has
## an inclusion of 1 but both a high and a low


EXPLAIN SELECT destinationairport, sourceairport
FROM `travel-sample` 
USE INDEX (idx_dist_src_dst)
WHERE type = "route"
AND sourceairport = "SFO"
AND distance > 1000
AND distance <= 2000;

## The "spans" in the JSON has a single range for the distance has
## an inclusion of 2 with both a high and a low

###############################################
############################### Pagination Pushdown
###############################################

CREATE PRIMARY INDEX `idx_primary` ON `travel-sample`;

##

EXPLAIN SELECT *
FROM `travel-sample`
OFFSET 500
LIMIT 100;

##

EXPLAIN SELECT *
FROM `travel-sample`
WHERE name LIKE "S%"
OFFSET 500
LIMIT 100;

##

CREATE INDEX idx_name ON `travel-sample`(name ASC);

## Re-run the same query and examine the IndexScan3 step
## The offset is applied at the index level
EXPLAIN SELECT *
FROM `travel-sample`
WHERE name LIKE "S%"
OFFSET 500
LIMIT 100;

##

## With the inclusion of ORDER BY, the offset cannot be done at the index
EXPLAIN SELECT *
FROM `travel-sample` 
USE INDEX(idx_name)
WHERE name LIKE "S%"
ORDER BY city
OFFSET 500
LIMIT 100;

##

EXPLAIN SELECT *
FROM `travel-sample` 
USE INDEX(idx_name)
WHERE name LIKE "S%"
ORDER BY city;

##

EXPLAIN SELECT *
FROM `travel-sample` 
USE INDEX(idx_name)
WHERE name LIKE "S%"
ORDER BY META().id;


###############################################
############################### Ordering and Aggregation Pushdowns
###############################################

EXPLAIN SELECT *
FROM `travel-sample` 
USE INDEX(idx_name)
WHERE name LIKE "S%"
ORDER BY name DESC;

CREATE INDEX idx_name_desc ON `travel-sample`(name DESC);

##
## This query does not require a separate order step
EXPLAIN SELECT *
FROM `travel-sample` 
USE INDEX(idx_name_desc)
WHERE name LIKE "S%"
ORDER BY name DESC;

EXPLAIN SELECT *
FROM `travel-sample` 
USE INDEX(idx_name_desc)
WHERE name LIKE "S%"
ORDER BY city DESC;

# Operator Pushdowns

# max() pushdowns

EXPLAIN SELECT MAX(name)
FROM `travel-sample` 
USE INDEX (idx_name)
WHERE name IS NOT MISSING;

##

EXPLAIN SELECT MAX(name)
FROM `travel-sample` 
USE INDEX (idx_name)
WHERE name IS NOT MISSING
AND city LIKE "San%";

# min() pushdowns

EXPLAIN SELECT MIN(name)
FROM `travel-sample` 
USE INDEX (idx_name)
WHERE name IS NOT MISSING;

##

EXPLAIN SELECT MIN(name)
FROM `travel-sample` 
USE INDEX (idx_name)
WHERE name IS NOT MISSING
AND city LIKE "San%";

# count() pushdowns

EXPLAIN SELECT COUNT(name) AS nameCount
FROM `travel-sample` 
USE INDEX (idx_name)
WHERE name IS NOT MISSING;

# click on Plan Text

##

SELECT COUNT(DISTINCT name) AS nameCount
FROM `travel-sample` 
USE INDEX (idx_name)
WHERE name IS NOT MISSING;

# click on Plan Text

## Clean up
DROP INDEX `travel-sample`.idx_dist_src_dst;
DROP INDEX `travel-sample`.idx_name;
DROP INDEX `travel-sample`.idx_name_desc;



