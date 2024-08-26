###############################################
############################### Secondary Indexes
###############################################

# Secondary Index

# Within Indexes we can see "def_name_type" and has 0 items
# this index is on type="User" which do not exist, so drop this index
# create another index for name 

CREATE INDEX travel_name ON `travel-sample`(name);

##

SELECT name
FROM `travel-sample`
WHERE type="airline"; # note the execution time

# click on Plan

##

SELECT *
FROM `travel-sample`
WHERE type="airline"
AND name = "40-Mile Air";

# click on Plan

########

# drop the index in type and run the query again

SELECT name
FROM `travel-sample`
WHERE type="airline"; # takes around 3s

##

CREATE INDEX `travel_type` 
ON `travel-sample`(`type`) 
WITH { "defer_build":true };

BUILD INDEX ON `travel-sample`("travel_type") 
USING GSI; # to make it online

## Re-run the query to confirm the execution time improves
SELECT name
FROM `travel-sample`
WHERE type="airline";

########

SELECT *
FROM `travel-sample`
WHERE type="airport"
LIMIT 1; # to show the data

##

SELECT *
FROM `travel-sample`
WHERE geo.alt > 389; # around 3s

# click on plan

##

CREATE INDEX travel_geo ON `travel-sample`(geo);

## run the same query

SELECT *
FROM `travel-sample`
WHERE geo.alt > 389; # milli seconds

# click on plan

#######

CREATE INDEX travel_geo_alt ON `travel-sample`(geo.alt);

## again run the same query 

SELECT *
FROM `travel-sample`
WHERE geo.alt > 389
AND type="airport"; # execution time further decreases

## Check the plan and confirm that the new index has been used

#######

SELECT *
FROM `travel-sample`
WHERE type="hotel"
AND reviews[*].author IS NOT NULL;

# click on Plan

##

CREATE INDEX travel_reviews ON `travel-sample`(reviews);

##

SELECT *
FROM `travel-sample`
WHERE type="hotel"
AND reviews[*].author IS NOT NULL;

# click on Plan

#######

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

##

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` al
JOIN `travel-sample` rt 
ON META(al).id = rt.airlineid; # error

##

CREATE INDEX travel_airlineid ON `travel-sample`(airlineid);

## run the join again

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` al
JOIN `travel-sample` rt 
ON META(al).id = rt.airlineid;

#######

###############################################
############################### Composite Secondary Index
###############################################

# Composite Secondary Index

# to find all hotel which gives free breakfast and free internet

SELECT name,city
FROM `travel-sample`
WHERE type= "hotel"
AND free_breakfast = TRUE
AND free_internet = TRUE;

# click on Plan
##

CREATE INDEX travel_idx_b ON `travel-sample`(free_breakfast);

## run the same query

SELECT name,city
FROM `travel-sample`
WHERE type= "hotel"
AND free_breakfast = TRUE
AND free_internet = TRUE; 

# click on Plan

##

CREATE INDEX travel_idx_i ON `travel-sample`(free_internet);

## run the query

SELECT name,city
FROM `travel-sample`
WHERE type= "hotel"
AND free_breakfast = TRUE
AND free_internet = TRUE; 

# click on plan

## create a composite index 

CREATE INDEX travel_idx_bi 
ON `travel-sample`(free_breakfast, free_internet);

##

SELECT name,city
FROM `travel-sample`
WHERE type = "hotel"
AND free_breakfast = TRUE
AND free_internet = TRUE; # click on plan

##

CREATE INDEX travel_idx_tbi 
ON `travel-sample`(type, free_breakfast, free_internet);

##

SELECT name,city
FROM `travel-sample`
WHERE type= "hotel"
AND free_breakfast = TRUE
AND free_internet = TRUE; # click on plan

##

SELECT name,city
FROM `travel-sample`
WHERE free_breakfast = TRUE
AND free_internet = TRUE;

# run this query twice, we see it will use travel_idx_bi index only
## order of the index matters

CREATE INDEX travel_idx_bit 
ON `travel-sample`(free_breakfast, free_internet, type);

##

SELECT name,city
FROM `travel-sample`
WHERE free_breakfast = TRUE
AND free_internet = TRUE;

# run this twice and we see it uses 2 indexes alternatively (travel_idx_bit and travel_idx_bi)

















