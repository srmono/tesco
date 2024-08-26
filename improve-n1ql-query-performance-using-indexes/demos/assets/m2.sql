 
###############################################
############################### Getting Started with Indexes
###############################################

# setup a new cluster
# default settings

# load a sample bucket, `travel-sample`
# go to indexes and show that it has a few indexes


# Primary Index:

SELECT *
FROM system:indexes;

#######

SELECT *
FROM system:indexes
WHERE is_primary=true;

#######

### Introducing the travel-sample bucket
SELECT *
FROM `travel-sample`
LIMIT 1;

SELECT DISTINCT type
FROM `travel-sample`;

SELECT type, COUNT(*) AS typeCount
FROM `travel-sample`
GROUP BY type;


SELECT *
FROM `travel-sample`
WHERE META().id = "hotel_10158";

# click on Plan 

#######

SELECT *
FROM `travel-sample`
WHERE META().id = "hotel_10159"
AND city = "Padfield";

# click on Plan

#######

### There is no index on free_internet, so the plan will be identical with this query
SELECT *
FROM `travel-sample`
WHERE META().id = "hotel_10159"
AND city = "Padfield"
AND free_internet = true;

# we already have a primary index , 
# create another primary index 

CREATE PRIMARY INDEX ON `travel-sample`;

##

SELECT *
FROM system:indexes
WHERE name = "#primary";

##

SELECT *
FROM system:indexes
WHERE is_primary=true;

#######

CREATE PRIMARY INDEX `travel-sample-primary-index` 
ON `travel-sample` USING GSI;

##

SELECT *
FROM system:indexes
WHERE is_primary=true;

#######

CREATE PRIMARY INDEX `travel-sample-primary-index_2` 
ON `travel-sample`
USING GSI WITH {"defer_build":TRUE};

##

SELECT *
FROM system:indexes
WHERE is_primary=true;

# we can see the status is deferred  for `travel-sample-primary-index_2`
# go to Indexes and show that the status of `travel-sample-primary-index_2` is 'created' and not 'ready'

SELECT *
FROM system:indexes
WHERE is_primary=true
AND state = "online";

########

# as we have many primary index now, if you run this query again multiple times 
# and observe the plan every time
# we can see the indexes are used in a round-robin fashion during every execution

SELECT *
FROM `travel-sample`
WHERE META().id = "hotel_10158";

# click on Plan . Do it at least 3 times, i.e. at least 3 executions
# The different primary indexes will be used

#######

BUILD INDEX ON `travel-sample`("travel-sample-primary-index_2") 
USING GSI; 

# status is changed to online 

SELECT *
FROM system:indexes
WHERE name="travel-sample-primary-index_2";

#######

# creating an index with same name will build the old index 

CREATE PRIMARY INDEX `travel-sample-primary-index` ON `travel-sample` 
WITH {"defer_build":TRUE};

# go to Indexes and show that now its in deffered state















