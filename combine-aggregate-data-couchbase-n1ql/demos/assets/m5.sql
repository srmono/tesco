

##################################
############### Aggregate Operations using GROUP BY, HAVING and LETTING
##################################


# GROUP BY and LETTING

SELECT DISTINCT type
FROM `travel-sample`;
 	
#######

SELECT type
FROM `travel-sample`
GROUP BY type;

SELECT type, COUNT(*) AS count
FROM `travel-sample`
GROUP BY type;

#######

SELECT city
FROM `travel-sample`
WHERE type = "hotel"
GROUP BY city;

#######

SELECT city, COUNT(DISTINCT name) landmarkCount
FROM `travel-sample`
WHERE type = "landmark"
GROUP BY city;

#######
## Assume you're looking for a city with many landmarks in the UK for your vacation
## First start off with cities with more than 10 landmarks

SELECT city, COUNT(DISTINCT name) landmarkCount
FROM `travel-sample`
WHERE type = "landmark"
GROUP BY city
HAVING COUNT(DISTINCT name) > 10;

#######
## Narrow down to cities in the UK

SELECT city, COUNT(DISTINCT name) landmarkCount
FROM `travel-sample`
WHERE type = "landmark"
AND country = "United Kingdom"
GROUP BY city
HAVING COUNT(DISTINCT name) > 10;

## You would like your city to have at least as good as 
## many landmarks as Santa Barbara
SELECT RAW COUNT(*) landmarkCount
FROM `travel-sample`
WHERE type = "landmark"
AND city = "Santa Barbara";


## Update your search for UK cities with this number
## You're down to 5 cities now
## But this value is hardcoded
SELECT city, COUNT(DISTINCT name) landmarkCount
FROM `travel-sample`
WHERE type = "landmark"
AND country = "United Kingdom"
GROUP BY city
HAVING COUNT(DISTINCT name) >= 53;

## Introduce the LETTING clause to create a variable
FROM `travel-sample`
WHERE type = "landmark"
AND country = "United Kingdom"
GROUP BY city
LETTING min_landmarkCount = 53
HAVING COUNT(DISTINCT name) >= min_landmarkCount;

#######

SELECT city, COUNT(DISTINCT name) landmarkCount
FROM `travel-sample`
WHERE type = "landmark"
AND country = "United Kingdom"
GROUP BY city
LETTING min_landmarkCount = (SELECT RAW COUNT(*)
                             FROM `travel-sample` ts
                             WHERE ts.type = "landmark"
                             AND ts.city = "Santa Barbara")[0]
HAVING COUNT(DISTINCT name) >= min_landmarkCount;



##################################
############### Aggregate Functions
##################################

SELECT name, ARRAY_LENGTH(public_likes) as num_publikes
FROM `travel-sample` 
WHERE type = "hotel"
AND city IS NOT NULL
LIMIT 10;

SELECT city, AVG(ARRAY_LENGTH(public_likes)) as avg_publikes
FROM `travel-sample` 
WHERE type = "hotel"
AND city IS NOT NULL
GROUP BY city
ORDER BY city;

SELECT city, MIN(ARRAY_LENGTH(public_likes)) as min_publikes
FROM `travel-sample` 
WHERE type = "hotel"
AND city IS NOT NULL
GROUP BY city
ORDER BY city;

SELECT city, MAX(ARRAY_LENGTH(public_likes)) as max_publikes
FROM `travel-sample` 
WHERE type = "hotel"
AND city IS NOT NULL
GROUP BY city
ORDER BY city;

SELECT city, SUM(ARRAY_LENGTH(public_likes)) as total_publikes
FROM `travel-sample` 
WHERE type = "hotel"
AND city IS NOT NULL
GROUP BY city
ORDER BY city;

## Cannot include a field in the SELECT clause which is not a group by key or aggregate
SELECT city, name, SUM(ARRAY_LENGTH(public_likes)) as total_publikes
FROM `travel-sample` 
WHERE type = "hotel"
AND city IS NOT NULL
GROUP BY city
ORDER BY city;



##################################
############### Set Operations on Query Results
##################################


# UNION 

# A list of all customer_ids from ordersbucket
SELECT customer_id AS cust_id
FROM `ordersbucket`;

# A list of all customer ids from customersbucket
SELECT META().id AS cust_id
FROM `customersbucket`;

# A UNION of the two lists produces a UNION set (no duplicates)
SELECT customer_id AS cust_id
FROM `ordersbucket` 
UNION
SELECT META().id AS cust_id
FROM `customersbucket`;

## UNION ALL also includes duplicates
SELECT customer_id AS cust_id
FROM `ordersbucket` 
UNION ALL
SELECT META().id AS cust_id
FROM `customersbucket`;

## The key names need to match for a proper UNION
## Eliminating the AS clause produces a different result
SELECT customer_id
FROM `ordersbucket` 
UNION
SELECT META().id
FROM `customersbucket`;

## This effectively produces a set of all documents in both buckets
SELECT *
FROM `ordersbucket` 
UNION 
SELECT *
FROM `customersbucket`;

#######

SELECT DISTINCT RAW city 
FROM `travel-sample` 
WHERE type = "landmark"; # 626 docs

#######

SELECT DISTINCT RAW city
FROM `travel-sample`
WHERE type = "hotel"; # 274 docs

#######

SELECT DISTINCT RAW city 
FROM `travel-sample` 
WHERE type = "landmark"
UNION
SELECT DISTINCT RAW city
FROM `travel-sample`
WHERE type = "hotel"; # 755 docs

#######

SELECT DISTINCT RAW city 
FROM `travel-sample` 
WHERE type = "landmark"
UNION ALL
SELECT DISTINCT RAW city
FROM `travel-sample`
WHERE type = "hotel"; # 900 docs

#######

# INTERSECT

SELECT customer_id AS cust_id
FROM `ordersbucket` 
INTERSECT
SELECT META().id AS cust_id
FROM `customersbucket`;

#######
## This produces 0 results as the key names are different
SELECT customer_id
FROM `ordersbucket` 
INTERSECT
SELECT META().id
FROM `customersbucket`;

#######

SELECT DISTINCT RAW city 
FROM `travel-sample` 
WHERE type = "landmark"
INTERSECT
SELECT DISTINCT RAW city
FROM `travel-sample`
WHERE type = "hotel";# 145 docs

#######
## These are hotels which are landmarks
SELECT DISTINCT name, city
FROM `travel-sample` 
WHERE type = "landmark"
INTERSECT
SELECT DISTINCT name, city
FROM `travel-sample`
WHERE type = "hotel";

#######

# EXCEPT

## IDs for customers with orders, but no customer doc
SELECT customer_id AS cust_id
FROM `ordersbucket` 
EXCEPT
SELECT META().id AS cust_id
FROM `customersbucket`;

## Flipping the order of the sets
## IDs for customers without orders
SELECT META().id AS cust_id
FROM `customersbucket`
EXCEPT
SELECT customer_id AS cust_id
FROM `ordersbucket`;


#######

SELECT DISTINCT RAW city 
FROM `travel-sample` 
WHERE type = "landmark"
EXCEPT
SELECT DISTINCT RAW city
FROM `travel-sample`
WHERE type = "hotel"; 
#481 docs


######
## 129 cities with hotels but no landmarks
SELECT DISTINCT RAW city 
FROM `travel-sample` 
WHERE type = "hotel"
EXCEPT
SELECT DISTINCT RAW city
FROM `travel-sample`
WHERE type = "landmark";

######












