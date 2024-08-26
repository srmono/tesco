###############################################
############################### Partial and Functional Indexes
###############################################


# Partial index

### Run this query before any index is created
SELECT airportname,city
FROM `travel-sample`
WHERE type="airport"
AND airportname LIKE "%B%";


# applying a where condition for an index
CREATE INDEX `travel_info_airport` 
ON `travel-sample`(airportname,id,city) 
WHERE (type = "airport");

##

SELECT airportname,city
FROM `travel-sample`
WHERE type="airport"
AND airportname LIKE "%B%";

# now this index also acts as a covering index 

#######

SELECT *
FROM `travel-sample`
WHERE geo.alt > 1000; # note the execution time

##

CREATE INDEX `travel_alt_over1000` ON `travel-sample`(geo.alt) 
WHERE geo.alt > 1000 
USING GSI;

## run the query again

SELECT *
FROM `travel-sample`
WHERE geo.alt > 1000;

#######



# create another node within the same cluster
# create index for a specific node


CREATE INDEX travel_hotel_city_node 
ON `travel-sample`(city)
WHERE type="hotel" 
USING GSI
WITH {"nodes":"127.0.0.1:8091"};

# go to index and show the index



###############################################
############################### Functional Indexes
###############################################

SELECT *
FROM `travel-sample`
WHERE ARRAY_LENGTH(reviews[*].author) >= 3;

# click on Plan

##

CREATE INDEX travel_auth 
ON `travel-sample`(ARRAY_LENGTH(reviews[*].author) >= 3);

##

# rerun the same query and replace the numbers

SELECT *
FROM `travel-sample`
WHERE ARRAY_LENGTH(reviews[*].author) >= 3;

# click on Plan

##

SELECT *
FROM `travel-sample`
WHERE ARRAY_LENGTH(reviews[*].author) >= 5;

# click on Plan

##

SELECT *
FROM `travel-sample`
WHERE ARRAY_LENGTH(reviews[*].author) >= 2;

# click on Plan

#######

SELECT name, reviews[*].ratings[*].Overall, city
FROM `travel-sample`
WHERE type = "hotel"
AND EVERY Overall IN (reviews[*].ratings[*].Overall) 
    SATISFIES Overall= 5 END;

##

CREATE INDEX travel_cx1 
ON `travel-sample`(EVERY Overall IN (reviews[*].ratings[*].Overall) 
				   SATISFIES Overall= 5 END, type);

##

SELECT name,reviews[*].ratings[*].Overall,city
FROM `travel-sample`
WHERE type="hotel"
AND EVERY Overall IN (reviews[*].ratings[*].Overall) 
    SATISFIES Overall= 5 END;

# click on Plan

#######

# Drop all the index created in this module 
# All indexes have the prefix "travel" in the name
# There is also a #primary index



###############################################
############################### Array Indexing
###############################################


SELECT *
FROM `travel-sample`
WHERE type="route"
AND ANY departure IN schedule SATISFIES departure.utc < "01:00" END
AND stops=1;

# click on Plan
# go to indexes and show that you have a default index `def_schedule_utc` but we are not using it 
# drop that index 

##

CREATE INDEX travel_sched_utc 
ON `travel-sample`(ALL DISTINCT ARRAY v.utc FOR v IN schedule END);

## rerun the same query

SELECT *
FROM `travel-sample`
WHERE type="route"
AND ANY departure IN schedule SATISFIES departure.utc < "01:00" END
AND stops=1; 

########

SELECT *
FROM `travel-sample`
WHERE ANY v IN schedule SATISFIES v.flight LIKE 'BA%' END; # 5s

##

CREATE INDEX travel_sched_flight
ON `travel-sample` ( DISTINCT ARRAY v.flight FOR v IN schedule END );

##

SELECT *
FROM `travel-sample`
WHERE ANY v IN schedule SATISFIES v.flight LIKE 'BA%' END; # ms

# click on Plan 

#######

CREATE INDEX travel_flight_utc
ON `travel-sample` ( ALL ARRAY v.flight FOR v IN schedule WHEN v.utc < "01:00" END )
WHERE type = "route" ;

##

SELECT sourceairport, destinationairport, stops
FROM `travel-sample`
WHERE type="route"
AND ANY v IN schedule SATISFIES v.flight LIKE 'BA%' and v.utc < "01:00" END ;

# click on Plan

#######

# drop travel_sched
DROP INDEX `travel-sample`.travel_sched_utc;

CREATE INDEX travel_sched_utc_stops
ON `travel-sample`( DISTINCT ARRAY v.utc FOR v IN schedule END, stops )
WHERE type = "route" ;

##

SELECT *
FROM `travel-sample`
WHERE type="route"
AND ANY departure IN schedule SATISFIES departure.utc < "01:00" END
AND stops=1;

# click on Plan

#######

###############################################
############################### Covering Indexes with Arrays
###############################################


# covering index

CREATE INDEX travel_review_author 
ON `travel-sample`( DISTINCT ARRAY v.author FOR v IN reviews END, reviews)
WHERE type = "hotel";

CREATE INDEX travel_review 
ON `travel-sample`(reviews)
WHERE type = "hotel";

##

SELECT META().id, name, city
FROM `travel-sample` 
WHERE type = "hotel"
AND ANY v IN reviews SATISFIES v.author LIKE 'A%' END;

## 

SELECT META().id, name, city
FROM `travel-sample` 
USE INDEX (travel_review)
WHERE type = "hotel"
AND ANY v IN reviews SATISFIES v.author LIKE 'A%' END;

#######
## For this query, the index becomes a covering index
SELECT reviews[*].author, reviews[*].ratings[*].Overall
FROM `travel-sample` 
WHERE type = "hotel"
AND ANY v IN reviews SATISFIES v.author LIKE 'A%' END;

SELECT reviews[*].author, reviews[*].ratings[*].Overall
FROM `travel-sample` 
USE INDEX (travel_review)
WHERE type = "hotel"
AND ANY v IN reviews SATISFIES v.author LIKE 'A%' END;

## After replacing ANY with EVERY, the index is no longer used
SELECT reviews[*].author, reviews[*].ratings[*].Overall
FROM `travel-sample` 
USE INDEX (travel_review)
WHERE type = "hotel"
AND EVERY v IN reviews SATISFIES v.author LIKE 'A%' END;

## Check the plan to confirm that the review index is not used

#######
### Drop all indexes created so far in this module
DROP INDEX `travel-sample`.travel_flight_utc;
DROP INDEX `travel-sample`.travel_hotelreview_nested;
DROP INDEX `travel-sample`.travel_review;
DROP INDEX `travel-sample`.travel_review_author;
DROP INDEX `travel-sample`.travel_sched_flight;
DROP INDEX `travel-sample`.travel_sched_utc_stops;

