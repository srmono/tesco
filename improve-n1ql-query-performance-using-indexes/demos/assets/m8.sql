

###############################################
############################### Covering Indexes
###############################################


CREATE INDEX idx_type_city 
ON `travel-sample`(type, city);

##

SELECT COUNT(city)
FROM `travel-sample`
WHERE type = "hotel";

##

SELECT COUNT(DISTINCT city)
FROM `travel-sample`
WHERE type = "hotel";

##

SELECT DISTINCT city 
FROM `travel-sample` 
WHERE type = "hotel"
INTERSECT 
SELECT DISTINCT city 
FROM `travel-sample` 
WHERE type = "landmark";

##

SELECT *
FROM (
      SELECT DISTINCT city 
      FROM `travel-sample`
      WHERE type = "hotel" 
      UNION 
      SELECT DISTINCT city 
      FROM `travel-sample`
      WHERE type = "landmark"
     ) AS info
WHERE info.city LIKE "%A%" ;


###############################################
############################### The Advise Feature for Indexes
###############################################


SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Click on Plan and then on Advise
## It recommends a covered and non-covered index

## Prepend the ADVISE keyword before the query
ADVISE SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Use one of the recommendations
CREATE INDEX idx_airlineid 
ON `travel-sample`(`airlineid`);

## Re-run the query
SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Click on Plan and then on Advise
## Now there is just a recommendation for a covered index

## Create a covered index for this query
CREATE INDEX idx_airlineid_dest_src
ON `travel-sample`(`airlineid`,
                   `destinationairport`,
                   `sourceairport`);

## Re-run the query
SELECT rt.sourceairport, 
       rt.destinationairport, 
       rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id;

## Click on Plan and then on Advise
## We are told that "Existing indexes are sufficient."

# join

## RUn this join and check the execution time and the 
SELECT DISTINCT l.city
FROM `travel-sample` l
JOIN `travel-sample` h 
ON h.city=l.city
WHERE l.type ="landmark"
AND h.type="hotel";

## Check Advise
## We are told that "Existing indexes are sufficient."

ADVICE SELECT DISTINCT l.city, l.name
FROM `travel-sample` l
JOIN `travel-sample` h 
ON h.city=l.city
WHERE l.type ="landmark"
AND h.type="hotel";

## More index recommendations show up

ADVISE SELECT *
FROM `travel-sample`
WHERE type="route"
AND ANY departure IN schedule SATISFIES departure.day = 0 END
AND stops=1;

## click on JSON

## Cleaning up
DROP INDEX `travel-sample`.idx_airlineid;
DROP INDEX `travel-sample`.idx_airlineid_dest_src;
DROP INDEX `travel-sample`.idx_type_city;





###############################################
############################### Performance Tuning with Analytics for N1QL
###############################################


## go to Analytics
## show data insights

SELECT "Hello World!";

##

SELECT *
FROM `travel-sample`
LIMIT 1; # error

## create a dataset

CREATE DATASET hotels 
ON `travel-sample` 
WHERE `type` = "hotel";

##

CREATE DATASET airports 
ON `travel-sample` 
WHERE `type` = "airport";

##

CREATE DATASET landmarks 
ON `travel-sample` 
WHERE `type` = "landmark";

CREATE DATASET routes 
ON `travel-sample` 
WHERE `type` = "route";

CREATE DATASET airlines 
ON `travel-sample` 
WHERE `type` = "airline";

##

CONNECT LINK Local;

##

SELECT *
FROM hotels
LIMIT 1;

##

SELECT name, reviews
FROM hotels
WHERE hotels.`name` LIKE "M%";

##

SELECT *
FROM routes
LIMIT 1;

##

## go to query and run this join

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id; # 18s 

## go back to analytics and run the same operation on same condition

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM routes rt
JOIN airlines al 
ON rt.airlineid = META(al).id; # 500ms


##
# Parallelism Parameter

SET `compiler.parallelism` "1";

SELECT airline.name, route.sourceairport, route.destinationairport
FROM airlines airline
JOIN routes route
ON route.airlineid = META(airline).id; # 450ms

##

SET `compiler.parallelism` "4";

SELECT airline.name, route.sourceairport, route.destinationairport
FROM airlines airline
JOIN routes route
ON route.airlineid = META(airline).id; # 250-350 ms

##
# Memory Parameters

SET `compiler.groupmemory` "64MB";

SELECT rt.sourceairport, COUNT(*)
FROM routes rt
GROUP BY rt.sourceairport;

##

SET `compiler.sortmemory` "67108864";

SELECT DISTINCT VALUE airlineid
FROM routes AS rt
ORDER BY ARRAY_LENGTH(rt.schedules) DESC;

##

SET `compiler.joinmemory` "132000KB";

SELECT airline.name, route.sourceairport, route.destinationairport 
FROM airlines airline
JOIN routes route
ON route.airlineid = META(airline).id
WHERE route.`type`="route"
AND airline.`type`="airline"
and route.distance > 1500;

##
# Parallel sort parameter

SET `compiler.sort.parallel` "true";

SELECT DISTINCT VALUE airlineid
FROM routes AS rt
ORDER BY ARRAY_LENGTH(rt.schedules) DESC;



###############################################
############################### Memory-optimized Indexes
###############################################


## Go to Settings and click on Memory-Optimized , it throws error
## create a new cluster
## Click on Configure Disk, Memory, Service
## give minimum index space (256 MB)
## In Index Storage Settings opt 'Memory-Optimized'
## Install travel-sample
## go to indexs and show that the RAM used even now is greater than 70%

SELECT rt.sourceairport, rt.destinationairport, rt.airlineid
FROM `travel-sample` rt
JOIN `travel-sample` al 
ON rt.airlineid = META(al).id; # 3s and # 477ms
 
## click on Advise and create the index suggested
## go to indexes and show it

SELECT *
FROM `travel-sample`
WHERE type="route"
AND ANY departure IN schedule SATISFIES departure.utc < "01:00" END
AND stops = 0
AND distance > 4000; #600 ms

## click on Advise and create the index suggested
## go to indexes and show the index and remaining RAM

SELECT *
FROM `travel-sample`
WHERE ANY v IN schedule SATISFIES v.flight LIKE 'BA%' END;

## click on advise and create the index suggested
## go to indexes and we see all the indexes is paused

# now try to create another index , it throws error

CREATE INDEX travel_type ON `travel-sample`(type);

## run the previous queries, we see there is not much difference in execution time
## it means 

## go to Indexes and drop index we see the mutation's remaining on the previous indexes reduces
## after dropping 2 ndexes the last index is created




















