
##########################################
#####################   Differences Between N1QL and N1QL for Analytics
##########################################

##

SELECT * 
FROM beers;

##
#it shows errors

SELECT name 
FROM `beers` 
USE KEYS[ "21st_amendment_brewery_cafe",
          "21st_amendment_brewery_cafe-21a_ipa"]; #error

##

#Right Query

SELECT name
FROM `beers`
WHERE META().id IN ["21st_amendment_brewery_cafe-amendment_pale_ale", 
                    "21st_amendment_brewery_cafe-bitter_american"];

##

SELECT DISTINCT be.name as beer_name, 
                bw.name as brewery_name
FROM beers be
JOIN breweries bw
ON be.brewery_id = meta(bw).id;

##

SELECT DISTINCT be.name as beer_name, 
                bw.name as brewery_name
FROM beers be
LEFT JOIN breweries bw
ON be.brewery_id = meta(bw).id;

##

SELECT DISTINCT be.name as beer_name, 
                bw.name as brewery_name
FROM beers be
RIGHT JOIN breweries bw
ON be.brewery_id = meta(bw).id; # error


### Nest queries in Analytics
SELECT br.name AS brewery_name, br.country,
       be[*].name AS beer_name
FROM beers be
NEST breweries br
  ON be.brewery_id = META(br).id
LIMIT 5;

## Head to the Query workbench

CREATE INDEX breweryid ON `beer-sample`(brewery_id);

SELECT br.name AS brewery_name, br.country,
       be[*].name AS beer_name
FROM `beer-sample` AS br 
NEST `beer-sample` AS be 
ON be.brewery_id = META(br).id
LIMIT 5;


## From the Analytics workbench

SELECT br.name AS brewery_name, br.country, beer_names
FROM breweries br
LET beer_names = (SELECT RAW name 
                  FROM beers be
                  WHERE be.brewery_id = META(br).id
                 )
WHERE EXISTS beer_names
LIMIT 5;


##

#it shows error because,it Doesn’t support OFFSET without LIMIT

SELECT br.name, br.abv, br.brewery_id
FROM beers br 
OFFSET 5;

##

SELECT br.name, br.abv, br.brewery_id
FROM beers br 
LIMIT 10
OFFSET 5;

##

# Only UNION ALL is supported in analytics 

SELECT name  
FROM breweries
WHERE country = "Norway"
UNION ALL
SELECT name  
FROM breweries
WHERE country = "Belgium";

##

# it shows error

SELECT name  
FROM breweries
WHERE country = "Norway"
UNION
SELECT name  
FROM breweries
WHERE country = "Belgium";
##

SELECT name  
FROM breweries
WHERE country = "Norway"
INTERSECT
SELECT name  
FROM breweries
WHERE country = "Belgium"; # error

##

SELECT name  
FROM breweries
WHERE country = "Norway"
EXCEPT
SELECT name  
FROM breweries
WHERE country = "Belgium"; # error

##
#creating index

CREATE INDEX idx_beer_breweryid ON beers(brewery_id); # error

#In analytics, we can't create index like we do in the query service

##

CREATE INDEX idx_beer_breweryid ON beers(brewery_id:string);


#Now we have to go to Datasets and click on beers Dataset 
#then you can see index is created here with index_name = "idx_brewery"



## INSERT, DELETE and UPSERT statements will not work in Analytics

##
# This results in errors

INSERT INTO beers ( KEY, VALUE )
  VALUES
  (
    "loony_stout",
    {"name": "Loony Stout", 
     "abv": 8.0, 
     "ibu": 18,
     "type": "beer", 
     "brewery_id": "Loony_brewing"
    }
  );


# we have to go query workbench and then insert update,delete documents.


#go to query workbench
# Insert new data with help of query workbench


INSERT INTO `beer-sample` ( KEY, VALUE )
  VALUES
  (
    "loony_stout",
    {"name": "Loony Stout", 
     "abv": 8.0, 
     "ibu": 18,
     "type": "beer", 
     "brewery_id": "Loony_brewing"
    }
  );

## Switch to the Analytics workbench and run this query

SELECT meta(br).id, br as beer 
FROM beers as br
WHERE br.brewery_id = "Loony_brewing"
ORDER BY meta(br).id;

## Try to delete data from the Analytics workbench. This will fail

DELETE FROM beers 
WHERE name = "Loony Stout";

## Switch to the Query workbench and run the delete agains beer-sample

DELETE FROM `beer-sample` 
WHERE name = "Loony Stout";

# Go back to Analytics and confirm that the document is gone
SELECT meta(br).id, br as beer 
FROM beers as br
WHERE br.brewery_id = "Loony_brewing"
ORDER BY meta(br).id;


## UPSERT also throws an error

UPSERT INTO beers ( KEY, VALUE )
  VALUES
  (
    "loony_stout",
    {"name": "Loony Stout", 
     "abv": 8.0, 
     "ibu": 18,
     "type": "beer", 
     "brewery_id": "Loony_brewing"
    }
  );



#Operator Expressions

# Arithmetic Operators

##

SELECT name, abv+10 
FROM beers
WHERE abv = 0;

##

SELECT abv 
FROM beers
WHERE abv*5 > 10;

##

SELECT name,brewery_id,category 
FROM beers
WHERE abv^2 > 50;

##

SELECT name, brewery_id, category 
FROM beers
WHERE name ="General" || " Pippo's" || " Porter";


##

SELECT brewery_id, category, max_ibu
FROM beers AS br
LET max_ibu =(SELECT RAW MAX(ibu)
              FROM beers)[0]
WHERE br.ibu = max_ibu;



#IN

SELECT name, address, city
FROM breweries
WHERE state IN["","Massachusetts"]
AND ARRAY_LENGTH(address) > 0;


##

SELECT name, address, city
FROM breweries
WHERE state NOT IN["","Massachusetts"]
AND ARRAY_LENGTH(address) > 0
LIMIT 10;



#IS NULL

SELECT name, ibu, category
FROM beers AS bs
WHERE bs.ibu IS NOT NULL;

## The BETWEEN operator expression

SELECT name, ibu, category
FROM beers AS bs
WHERE bs.ibu BETWEEN 20 AND 30;

#MISSING

SELECT name
FROM breweries
WHERE geo IS MISSING;


## GROUP BY, HAVING, LETTING and ORDER BY clauses are permitted

SELECT country, COUNT(*) count
FROM breweries
GROUP BY country;


SELECT country, COUNT(*) count
FROM breweries
GROUP BY country
HAVING COUNT(*) > 10;


SELECT country, COUNT(*) count
FROM breweries
GROUP BY country
LETTING min_count = 10
HAVING COUNT(*) > min_count;


SELECT country, COUNT(*) count
FROM breweries
GROUP BY country
LETTING min_count = 10
HAVING COUNT(*) > min_count
ORDER BY COUNT(*) DESC;



## Quantified Expressions

#SOME

SELECT name, address
FROM breweries bw
WHERE SOME add_line IN bw.address 
      SATISFIES add_line LIKE "%Street%" END;


## EVERY

SELECT name, address
FROM breweries bw
WHERE EVERY add_line IN bw.address 
      SATISFIES add_line LIKE "%Street%" END;

## This query fails in Analytics
SELECT name, address
FROM breweries bw
WHERE EVERY add_line IN bw.address 
      SATISFIES add_line LIKE "%Street%" END 
AND ARRAY_LENGTH(bw.address) > 0;


## Go to the Query workbench and run a similar query
## It works here
SELECT name, address
FROM `beer-sample`
WHERE type = "brewery"
AND EVERY add_line IN address SATISFIES add_line LIKE "%Street%" END
AND ARRAY_LENGTH(address) > 0;


## Case Expressions

SELECT name, category, abv,
CASE 
WHEN abv > 6 
THEN "High" 
ELSE "Low" END as alc_level
FROM beers;


##########################################
#####################   Clauses in N1QL for Analytics Queries
##########################################

# LET

SELECT raw avg(ibu) 
FROM beers 
WHERE ibu > 0;

SELECT  be.name, be.ibu, be.category
FROM beers AS be
LET avg_ibu = 40
WHERE be.ibu > avg_ibu;

SELECT  be.name, be.ibu, be.category
FROM beers AS be
LET avg_ibu = (SELECT raw avg(ibu) 
               FROM beers 
               WHERE ibu > 0)[0]
WHERE be.ibu > avg_ibu;



# WITH (available in Couchbase 6.5+)

SELECT META().id AS id, name, address, city
FROM breweries 
WHERE country = "United States";

WITH info AS
  (SELECT META().id AS id, name, address, city
   FROM breweries 
   WHERE country = "United States")
SELECT info.name, info.address 
FROM info 
WHERE info.city = "Boston";

##

WITH info AS
  (SELECT META().id AS id, name, address, city
   FROM breweries 
   WHERE country = "United States")
SELECT info.name, info.address, beer_names
FROM info
LET beer_names = (SELECT RAW name 
                  FROM beers be
                  WHERE be.brewery_id = info.id
                 )
WHERE EXISTS beer_names
AND info.city = "Boston";



##########################################
#####################   Using Indexes for Analytics Queries
##########################################

## Indexes
## Expand the beers dataset in the Datasets panel on the right of the Analytics Workbench
## This includes the indexes available for the beers dataset
## Expand the breweries dataset - there is no index yet

## This query references many attributes
SELECT br.name AS beer_name, 
       bw.name AS brewery_name,
       bw.country, bw.city
FROM beers br JOIN breweries bw
ON META(bw).id = br.brewery_id
WHERE br.ibu > 20
ORDER BY br.name;

## Click on Plan and examine the "assign" and "project" phases for one of the datasets


#index creation requires temporary suspension of the shadowing process,
#although queries on the accumulated data can continue
#to be run while shadowing is on hold and the index is being built.

##

CREATE INDEX idx_beer_multi on beers(brewery_id:STRING, 
                                     ibu:DOUBLE, 
                                     name:STRING);

CREATE INDEX idx_brewery_name on breweries(name:STRING);


## Re-running this query will show no noticeable improvement in execution time
## since the datasets are too small
SELECT br.name AS beer_name, 
       bw.name AS brewery_name,
       bw.country, bw.city
FROM beers br JOIN breweries bw
ON META(bw).id = br.brewery_id
WHERE br.ibu > 20
ORDER BY br.name;


### Dropping indexes
DROP INDEX breweries.idx_brewery_name;
DROP INDEX beers.idx_beer_multi;
DROP INDEX beers.idx_beer_breweryid;























