##################################
############### Understanding ANSI JOIN, LOOKUP JOIN and INDEX JOIN
##################################

SELECT *
FROM `travel-sample`
WHERE type="route"
LIMIT 1; 
# to show the data

## There are more than 24K routes

SELECT COUNT(*)
FROM `travel-sample`
WHERE type="route";

#####

SELECT *
FROM `travel-sample`
WHERE type="airline"
LIMIT 1;

SELECT *
FROM `travel-sample`
WHERE type="airport"
LIMIT 1; # to show the data

#####

## There are a total of 187 airlines

SELECT DISTINCT META().id
FROM `travel-sample`
WHERE type="airline";

## And a total of 214 airlines in the routes
## So some routes reference airlines which are not present

SELECT DISTINCT airlineid
FROM `travel-sample`
WHERE type="route";

#####

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

# click on table to view the data 
# click on Plan Text, we see join operation
# click on Plan 

#####

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id
WHERE al.country = "United Kingdom";

#####

SELECT ap.faa AS departure,
       rt.destinationairport AS destination
FROM `travel-sample` ap
JOIN `travel-sample` rt 
ON ap.faa = rt.sourceairport
WHERE ap.type = "airport"
AND ap.country="United States";

# click on table
# click on Plan (for explanation)

SELECT DISTINCT ap.faa AS departure,
       rt.destinationairport AS destination
FROM `travel-sample` ap
JOIN `travel-sample` rt 
ON ap.faa = rt.sourceairport
WHERE ap.type = "airport"
AND ap.country="United States";

# click on Plan once again

###### Multiple joins

SELECT DISTINCT ap.faa AS departure,
                rt.destinationairport AS destination,
                al.name AS airlinename
FROM `travel-sample` ap
JOIN `travel-sample` rt 
ON ap.faa = rt.sourceairport
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id
WHERE ap.type = "airport"
AND ap.country="United States";


## Ordering the results

SELECT DISTINCT ap.faa AS departure,
                rt.destinationairport AS destination,
                al.name AS airlinename
FROM `travel-sample` ap
JOIN `travel-sample` rt 
ON ap.faa = rt.sourceairport
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id
WHERE ap.type = "airport"
AND ap.country="United States"
ORDER BY airlinename, departure, destination;



##################################
############### INNER, LEFT and RIGHT joins
##################################


SELECT ob.order_id, ob.customer_id, cb.customer_name
FROM `ordersbucket` ob
JOIN `customersbucket` cb
ON ob.customer_id = cb.customer_id;


SELECT ob.order_id, ob.customer_id, cb.customer_name
FROM `ordersbucket` ob
INNER JOIN `customersbucket` cb
ON ob.customer_id = cb.customer_id;


SELECT ob.order_id, ob.customer_id, cb.customer_name
FROM `ordersbucket` ob
LEFT JOIN `customersbucket` cb
ON ob.customer_id = cb.customer_id;

SELECT ob.order_id, ob.customer_id, cb.customer_name
FROM `ordersbucket` ob
LEFT OUTER JOIN `customersbucket` cb
ON ob.customer_id = cb.customer_id;


SELECT ob.order_id, ob.customer_id, cb.customer_name
FROM `ordersbucket` ob
RIGHT JOIN `customersbucket` cb
ON ob.customer_id = cb.customer_id;

SELECT ob.order_id, ob.customer_id, cb.customer_name
FROM `ordersbucket` ob
RIGHT OUTER JOIN `customersbucket` cb
ON ob.customer_id = cb.customer_id;


## Applying this on the travel-sample bucket
SELECT rt.sourceairport, rt.destinationairport, rt.airlineid,
	   al.name
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## The empty objects here are those without an airlineid field (non-routes)
## There are some documents in the results with just the route fields (no matching airlines)
## Some with all 4 fields (routes with matching airlines)
SELECT rt.sourceairport, rt.destinationairport, rt.airlineid,
       al.name
FROM `travel-sample` rt
LEFT JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Syntax error. We'll address this with index joins later
SELECT rt.sourceairport, rt.destinationairport, rt.airlineid,
       al.name
FROM `travel-sample` rt
RIGHT JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

######



##################################
############### Understanding ANSI JOIN, LOOKUP JOIN and INDEX JOIN
##################################


## Run this query again and note the number of docs and result size

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

# LOOKUP JOIN
# Lookup joins allow only left-to-right joins, 
# which means the ON KEYS expression must produce a document key 
# which is then used to retrieve documents from the right-hand side keyspace.
# The output is the same as the previous query

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` 
ON KEYS rt.airlineid;

########

## With a hardcoded key, the document with that key is paired with every 
## document on the left of the join 
SELECT airline.id as airlineId, airline.name as airlineName, 
	   airport.airportname, airport.city
FROM `travel-sample` as airline 
JOIN `travel-sample` airport 
ON KEYS "airport_471"
WHERE airline.type = "airline"
AND airport.type = "airport";


## This yields twice as many documents as the previous query
## as it effectively pairs every airline with the two airports
## whether or not there is a flight from the airport by that airline
SELECT airline.id as airlineId, airline.name as airlineName, 
	   airport.airportname, airport.city
FROM `travel-sample` as airline 
JOIN `travel-sample` airport 
ON KEYS ["airport_471", "airport_465"]
WHERE airline.type = "airline"
AND airport.type = "airport";

########

## Re-running this query to illustrate that the regular index join works

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` 
ON KEYS rt.airlineid;

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
RIGHT JOIN `travel-sample` 
ON KEYS rt.airlineid; 
# syntax error

########

## The left join produces an entry for every document in the bucket
SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt 
LEFT JOIN `travel-sample` 
ON KEYS rt.airlineid;

########

SELECT airline.id, airline.name, 
	   airport.airportname, airport.city
FROM `travel-sample` as airline 
INNER JOIN `travel-sample` airport 
ON KEYS "airport_471"
WHERE airline.type = "airline"
AND airport.type = "airport";

#######
# INDEX JOIN
#######

### At the start, navigate to the indexes section in the dashboard and show the following indexes:
## def_city and def_type

SELECT DISTINCT airline.name, route.schedule, 
				route.sourceairport, route.destinationairport
FROM `travel-sample` route
JOIN `travel-sample` airline
ON KEYS route.airlineid
WHERE route.type = "route"
AND airline.type = "airline"
AND airline.callsign = "HEX AIRLINE";


# without index 
# The ordering of the buckets in the from clause has changed
# Note the singular ON KEY rather than ON KEYS
# The FOR keyword

SELECT DISTINCT airline.name, route.schedule, 
				route.sourceairport, route.destinationairport
FROM `travel-sample` airline
JOIN `travel-sample` route
ON KEY route.airlineid FOR airline
WHERE route.type="route"
AND airline.type="airline"
AND airline.callsign = "HEX AIRLINE"; # error

# create an index

CREATE INDEX idx_airlineid 
ON `travel-sample`(airlineid) 
WHERE type="route";

###### using index

SELECT DISTINCT airline.name, route.schedule, 
				route.sourceairport, route.destinationairport
FROM `travel-sample` airline
JOIN `travel-sample` route
ON KEY route.airlineid FOR airline
WHERE route.type="route"
AND airline.type="airline"
AND airline.callsign = "HEX AIRLINE";

#######

SELECT DISTINCT airline.name, route.schedule, 
				route.sourceairport, route.destinationairport
FROM `travel-sample` airline
LEFT JOIN `travel-sample` route
ON KEY route.airlineid FOR airline
WHERE route.type="route"
AND airline.type="airline"
AND airline.callsign = "HEX AIRLINE";

#######

SELECT DISTINCT airline.name, route.schedule, 
				route.sourceairport, route.destinationairport
FROM `travel-sample` airline
RIGHT JOIN `travel-sample` route
ON KEY route.airlineid FOR airline
WHERE route.type="route"
AND airline.type="airline"
AND airline.callsign = "HEX AIRLINE"; # error

#######

SELECT * 
FROM `travel-sample` airline
JOIN `travel-sample` route
ON KEY route.airlineid FOR airline
WHERE route.type="route"
AND airline.type="airline"
AND route.sourceairport="ABQ" 
AND route.destinationairport="ATL"
AND ANY departure IN route.schedule SATISFIES departure.utc < "05:17" END;



##################################
############### ANSI JOIN Hints and the HASH JOIN
################################## 

# Show what a landmark document looks like
SELECT *
FROM `travel-sample` lm
WHERE lm.type = "landmark"
AND lm.country = "France"
LIMIT 1;

SELECT *
FROM `travel-sample` ap
WHERE ap.type = "airport"
AND ap.country = "France"
LIMIT 1;

SELECT DISTINCT RAW lm.activity
FROM `travel-sample` lm
WHERE lm.type = "landmark"
AND lm.country = "France";

# 1968 documents in all
SELECT ap.airportname, ap.faa
FROM `travel-sample` ap
WHERE ap.type = "airport";

# 45 documents in all
SELECT lm.name, lm.activity, lm.address, lm.city
FROM `travel-sample` lm
WHERE lm.type = "landmark"
AND lm.country = "France"
and lm.activity = "do";

# This query runs in about 30 seconds
# View the query plan. 
SELECT lm.name, lm.activity, lm.address, lm.city, 
       ap.airportname, ap.faa
FROM `travel-sample` ap
JOIN `travel-sample` lm
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

# Just change the order of the sources in the JOIN clause
# Now this query runs in about 9 mins
# View the query plan
# The lm documents need to be fetched from disk
# and this is what slows down the query
SELECT lm.name, lm.activity, lm.address, lm.city, 
       ap.airportname, ap.faa
FROM `travel-sample` lm
JOIN `travel-sample` ap
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";



## Add the USE HASH(PROBE) clause
## The RHS of the join will become the probe side while the LHS is the build side
## You typically want the build side to use the smaller of the two sets
## View the plan
SELECT lm.name, lm.activity, lm.address, lm.city, 
       ap.airportname, ap.faa
FROM `travel-sample` ap
JOIN `travel-sample` lm
USE HASH(PROBE)
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

## Add the USE HASH(BUILD) clause
## The RHS of the join will become the build side while the LHS is now the probe side
## View the plan
SELECT lm.name, lm.activity, lm.address, lm.city, 
       ap.airportname, ap.faa
FROM `travel-sample` ap
JOIN `travel-sample` lm
USE HASH(BUILD)
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";

## Add the USE NL clause
## This explicitly tells Couchbase to use a nested loop join
## View the plan
SELECT lm.name, lm.activity, lm.address, lm.city, 
       ap.airportname, ap.faa
FROM `travel-sample` ap
JOIN `travel-sample` lm
USE NL
ON ap.city = lm.city
WHERE lm.type = "landmark"
AND ap.type = "airport"
AND lm.country = "France"
AND lm.activity = "do";


##################################
############### ANSI JOIN on Arrays
##################################

# ANSI Joins and Arrays

# ANSI Join with No arrays:

SELECT cb.contact_name, ob.order_items, ob.payment_method
FROM ordersbucket ob
JOIN customersbucket cb
ON ob.customer_id = cb.customer_id;


#######

SELECT cb.contact_name, ob.order_items, ob.payment_method
FROM ordersbucket ob
JOIN customersbucket cb
ON ob.customer_id = cb.customer_id
AND ANY p IN cb.payment_methods SATISFIES p = ob.payment_method END;

#######

# ANSI Join with entire erray as Index Key

SELECT cb.contact_name, ob.order_items, ob.payment_method
FROM ordersbucket ob
JOIN customersbucket cb
ON ob.customer_id = cb.customer_id
AND cb.frequent_order = ob.order_items;

#######

# ANSI Join involving right hand side arrays



