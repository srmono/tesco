
##################################
############### An Intro to the NEST Clause
##################################

# understanding NEST Clause
# This query returns 3 documents

SELECT *
FROM `customersbucket` cb
JOIN `ordersbucket` ob
ON ob.customer_id = cb.customer_id;


#######
# replace join with nest. Now 2 docs are returned. The orders for customer 13 
# have been nested in an array

SELECT *
FROM `customersbucket` cb
NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id;

## View the results in a JSON formatter

SELECT *
FROM `customersbucket` cb
NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id
AND ARRAY_LENGTH(ob.order_items) > 2;

## Select only specific attributes from the customer
SELECT cb.customer_name, cb.country, ob
FROM `customersbucket` cb
NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id;


## Since the orders array is an array of objects,
## We use the [*] to extract fields
SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id;

## INNER NEST is the same as NEST
SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
INNER NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id;

# LEFT NEST includes customers without matching orders
SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
LEFT NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id;


# There's no such thing as a RIGHT nest
SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
LEFT NEST `ordersbucket` ob
ON ob.customer_id = cb.customer_id;

# Applying NEST on the travel-sample
#######

SELECT *
FROM `travel-sample`
WHERE type="hotel"
LIMIT 1; 

SELECT *
FROM `travel-sample`
WHERE type="landmark"
LIMIT 1; 

SELECT hl.name as hotel_name, hl.city, 
       lm[*].name as landmark_name
FROM `travel-sample` hl
NEST `travel-sample` lm
ON hl.city = lm.city
AND lm.type = "landmark"
WHERE hl.type = "hotel"
AND hl.country = "United States"
AND hl.free_breakfast = true
AND hl.free_internet = true
AND ARRAY_LENGTH(hl.public_likes) > 8;


## Just add another condition in the ON clause for NEST
SELECT hl.name as hotel_name, hl.city, 
       lm[*].name as landmark_name
FROM `travel-sample` hl
NEST `travel-sample` lm
ON hl.city = lm.city
AND lm.type = "landmark"
AND lm.activity = "do"
WHERE hl.type = "hotel"
AND hl.country = "United States"
AND hl.free_breakfast = true
AND hl.free_internet = true
AND ARRAY_LENGTH(hl.public_likes) > 8;


## Move the 2 conditions for the lm docs to the WHERE clause
## This does not return any results
SELECT hl.name as hotel_name, hl.city, 
       lm[*].name as landmark_name
FROM `travel-sample` hl
NEST `travel-sample` lm
ON hl.city = lm.city
WHERE hl.type = "hotel"
AND hl.country = "United States"
AND hl.free_breakfast = true
AND hl.free_internet = true
AND ARRAY_LENGTH(hl.public_likes) > 8
AND lm.type = "landmark"
AND lm.activity = "do";




##################################
############### Lookup NEST and Index NEST
##################################

SELECT rt.sourceairport, rt.destinationairport, al
FROM `travel-sample` rt
NEST `travel-sample` al
ON KEYS rt.airlineid
WHERE rt.type = "route"
AND rt.stops=1
LIMIT 5;



# INDEX NEST

# show the index is already created in the previous demo
# click on Indexes and show

#####
## Update the customer_id in the orders doc so they reference the customer doc key
UPDATE `ordersbucket`
SET customer_id = "cust_" || TO_STRING(customer_id);

#### Now the INDEX join can be performed using the key to customer from orders
SELECT *
FROM `customersbucket` cb
NEST `ordersbucket` ob
ON KEY ob.customer_id FOR cb;

#######
## Select only specific fields

SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
NEST `ordersbucket` ob
ON KEY ob.customer_id FOR cb;

#######
## The INNER NEST and LEFT NEST work as you would expect

SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
INNER NEST `ordersbucket` ob
ON KEY ob.customer_id FOR cb;
#######

SELECT cb.customer_name, cb.country, 
       ob[*].order_id, ob[*].order_items
FROM `customersbucket` cb
LEFT NEST `ordersbucket` ob
ON KEY ob.customer_id FOR cb;

#######


#######


##################################
############### The UNNEST Clause
##################################




# without unnest clause:

SELECT *
FROM `ordersbucket` ob
WHERE ob.order_id = 10312;

#######

SELECT *
FROM `ordersbucket` ob
UNNEST ob.order_items as item_ordered
WHERE ob.order_id = 10312;

## With an order having more items, the number of documents is greater
SELECT *
FROM `ordersbucket` ob
UNNEST ob.order_items as item_ordered
WHERE ob.order_id = 10311;

SELECT *
FROM `ordersbucket` ob
UNNEST ob.order_items as item_ordered
WHERE ob.order_id = 10311;

## Select specific fields from the documents
SELECT ob.customer_id, ob.order_id, item_ordered
FROM `ordersbucket` ob
UNNEST ob.order_items as item_ordered
WHERE ob.order_id = 10311;

## We can set conditions on the unnested items
SELECT ob.customer_id, ob.order_id, item_ordered
FROM `ordersbucket` ob
UNNEST ob.order_items as item_ordered
WHERE ob.order_id = 10311
AND item_ordered LIKE "s%";


## Applying UNNEST on travel-sample
# without unnest clause:

SELECT sourceairport, destinationairport,
ARRAY info FOR info IN schedule 
WHEN info.day = 0 END AS sunday_flights
FROM `travel-sample`
WHERE type="route"
LIMIT 5;

# using unnest
SELECT rt.sourceairport, rt.destinationairport,
       sch as sunday_flight
FROM `travel-sample` rt
UNNEST schedule sch
WHERE sch.day = 0
LIMIT 5;

#######

## You need an alias for travel-sample, or there is an error
SELECT sourceairport, destinationairport,
       sch as sunday_flight
FROM `travel-sample` 
UNNEST schedule sch
WHERE sch.day = 0
LIMIT 5;

#######

SELECT hl.name, r.author
FROM `travel-sample` AS hl
UNNEST reviews AS r
WHERE hl.type = "hotel"
AND r.ratings.Overall = 5
LIMIT 10;

SELECT RAW r.author
FROM `travel-sample` AS hl
UNNEST reviews AS r
WHERE hl.type = "hotel"
AND r.ratings.Overall = 5
LIMIT 10;

#######

SELECT hl.name, r.author, r.ratings.Overall
FROM `travel-sample` AS hl
UNNEST reviews AS r
WHERE hl.type = "hotel"
AND r.ratings.Overall > 3
ORDER BY hl.name
LIMIT 10;

########

# Chaining joins:

SELECT rt.sourceairport, rt.destinationairport,
       sch as sunday_flight
FROM `travel-sample` rt
UNNEST schedule sch
WHERE sch.day = 0
LIMIT 10;

SELECT rt.sourceairport, rt.destinationairport,
       t.icao, t.name, sch as sunday_flight
FROM `travel-sample` rt
UNNEST schedule sch
JOIN `travel-sample` t 
ON rt.airlineid = META(t).id
AND sch.day = 0
LIMIT 10;



























