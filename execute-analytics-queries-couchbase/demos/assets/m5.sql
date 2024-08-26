						
##########################################
#####################   Advanced Operations using Built-in Functions
##########################################

##bit operation functions

# Bitand

SELECT BITAND(7, 3) AS result;

SELECT BITAND(6, 3) AS result;

SELECT BITAND(7, 6, 5) AS result;

## BITOR

SELECT BITOR(4, 6, 5) AS result;

## BITCLEAR

SELECT BITCLEAR(7, 3) AS result;

SELECT BITCLEAR(7, 1) AS result;





#comparison functions

SELECT GREATEST(5,6,3,1) as greatest_value;

SELECT LEAST(5,6,3,1) as least_value;

SELECT name, style, abv, ibu, srm,
       GREATEST(abv, ibu, srm) AS greatest_num
FROM beers
WHERE ibu > 0;

SELECT name, style, abv, ibu, srm,
       LEAST(abv, ibu, srm) AS least_num
FROM beers
WHERE ibu > 0;


## Conditional Functions

# if_null

SELECT {
	    "a": if_null(),
	    "b": if_null(1),
	    "c": if_null(null, null),
	    "d": if_null(null, null, "Couchbase"),
	    "e": if_null(null, "", null, "Couchbase")
	   };

##

SELECT if_null (geo) AS geo
FROM breweries
LIMIT 5;

##

SELECT {
	    "a": if_missing(),
	    "b": if_missing(10),
	    "c": if_missing(missing, missing),
	    "d": if_missing(missing, missing, "Couchbase"),
	    "e": if_missing(null, missing, "Couchbase")
	   };


SELECT {
	    "a": if_missing_or_null(),
	    "b": if_missing_or_null(10),
	    "c": if_missing_or_null(missing, missing),
	    "d": if_missing_or_null(missing, missing, "Couchbase"),
	    "e": if_missing_or_null(null, missing, "Couchbase")
	   };

##

SELECT name,
       IF_MISSING(geo, address, website) AS data
FROM breweries;

SELECT name,
       IF_MISSING_OR_NULL(geo, address, website) AS data
FROM breweries;




##Environment and Identifier Functions

# meta function-->Return a metadata object for a stored document 
# like object containing fields id, vbid, seq, cas, and flags.

SELECT META(bw) AS meta, bw AS data
FROM breweries bw
WHERE META(bw).id = 'kona_brewing';

## The UUID function
## Run this 2-3 times - a new UUID is generated each time
SELECT UUID() AS uuid, 
       bw.name, bw.country, bw.city
FROM breweries bw
WHERE meta(bw).id = 'kona_brewing';




##JSON functions 

# decode_json

decode_json("{\"overall_rating\":4.5,\"on_time_rating\":4.9}");

##
# encode_json

SELECT ENCODE_JSON(geo) AS encoded_geo
FROM breweries
LIMIT 10;

##

SELECT ENCODE_JSON(address) AS encoded_add
FROM breweries
LIMIT 10;


SELECT geo,
       ENCODED_SIZE(geo) AS geo_enc_size
FROM breweries;

##



## Window Functions

#cume_dist

SELECT brewery_id,
       array_agg(abv) AS abvs
FROM beers
GROUP BY brewery_id;


## The RANK function
SELECT name, brewery_id, abv,
       RANK() OVER ( PARTITION BY brewery_id
                     ORDER BY abv) AS rank
FROM beers
ORDER BY brewery_id, abv;

## The DENSE_RANK (there are no gaps in the ranking)
SELECT name, brewery_id, abv,
       DENSE_RANK() OVER ( PARTITION BY brewery_id
                           ORDER BY abv) AS rank
FROM beers
ORDER BY brewery_id, abv;

## Order window contents in descending order
SELECT name, brewery_id, abv,
       DENSE_RANK() OVER ( PARTITION BY brewery_id
                           ORDER BY abv DESC) AS rank
FROM beers
ORDER BY brewery_id, abv;


### Get the first value in the window based the rank
SELECT name, brewery_id, abv,
       FIRST_VALUE(abv) OVER ( PARTITION BY brewery_id
                               ORDER BY abv DESC) AS highest_abv
FROM beers
ORDER BY brewery_id, abv;

## Get the last value
SELECT name, brewery_id, abv,
       LAST_VALUE(abv) OVER ( PARTITION BY brewery_id
                              ORDER BY abv DESC) AS lowest_abv
FROM beers
ORDER BY brewery_id, abv;


SELECT name, brewery_id, abv,
       CUME_DIST() OVER ( PARTITION BY brewery_id
                          ORDER BY abv DESC) AS cume_dist
FROM beers
ORDER BY brewery_id, abv;






