						
##########################################
#####################   Using Built-in Functions in Analytics Queries
##########################################

## numeric functions

SELECT name, abv, ROUND(abv) AS round_abv 
FROM beers;

##

SELECT name, abv, 
       ROUND(abv) AS round_abv,
       FLOOR(abv) AS floor_abv,
       CEIL(abv) AS ceil_abv
FROM beers;


##

SELECT name, city, geo, SIGN(geo.lon) as lon_sign
FROM breweries
WHERE city IN ["Boston", "Berlin"]
ORDER BY name;


##   string functions

# concat function

SELECT name, address, phone
FROM breweries
WHERE name = concat("Alaskan"," Brewing");


#contains function

SELECT name, city, description
FROM breweries
WHERE CONTAINS (description, "outdoor");

##

#ends_with

SELECT name, abv, category
FROM beers
WHERE ends_with(category,"Ale");


# start_with

SELECT name, abv, category
FROM beers
WHERE starts_with(category,"North American");



## Date and Time

SELECT now_local() AS time;

SELECT now_local("1111-11-11") AS short_time;

SELECT weekday_str('2020-01-20') AS day;

SELECT weekday_str(now_local()) AS day;

##

SELECT name, updated
FROM beers
WHERE updated="2010-07-22 20:00:20";

SELECT name, updated
FROM beers
WHERE updated > "2010-07-23"
ORDER BY updated;

SELECT name, updated
FROM beers
WHERE updated BETWEEN "2010-07-23" AND "2011-02-10"
ORDER BY updated;

##

#  type functions

SELECT IS_ARRAY(address)
FROM breweries;

SELECT DISTINCT IS_ARRAY(address)
FROM breweries;

##

SELECT DISTINCT IS_ATOMIC(abv)
FROM beers;

SELECT DISTINCT IS_BOOLEAN(abv)
FROM beers;

SELECT DISTINCT IS_NUMBER(abv)
FROM beers;


##

SELECT DISTINCT IS_OBJECT(geo)
FROM breweries
WHERE geo IS NOT NULL;

SELECT DISTINCT IS_OBJECT(ibu)
FROM breweries
WHERE geo IS NOT NULL;

##

SELECT DISTINCT IS_STRING(name)
FROM breweries;

##

SELECT DISTINCT `type`(geo.lat)
FROM breweries;

SELECT DISTINCT `type`(geo)
FROM breweries;

SELECT DISTINCT `type`(address)
FROM breweries;

SELECT DISTINCT `type`(description)
FROM breweries;

SELECT DISTINCT typename(description)
FROM breweries;

SELECT DISTINCT `type`(ibu)
FROM beers;

SELECT DISTINCT typename(ibu)
FROM beers;


##

SELECT name, geo, IS_UNKNOWN(geo.lat) AS lat_unknown
FROM breweries;


SELECT name, geo, IS_MISSING(geo.lat) AS lat_missing
FROM breweries;


##

# type conversion

SELECT name, to_array(country)
FROM breweries;

##

SELECT name, address, ARRAY_COUNT(address)
FROM breweries
WHERE ARRAY_COUNT(address) > 1;


##

SELECT name, address, 
	   TO_ATOMIC(address) AS atomic_address 
FROM breweries
WHERE ARRAY_COUNT(address) = 1;

## TO_ATOMIC does not work for arrays with more than 1 element
SELECT name, address, 
	   TO_ATOMIC(address) AS atomic_address 
FROM breweries
WHERE ARRAY_COUNT(address) > 1;


##

SELECT name, abv, TO_BIGINT(abv) AS big_abv
FROM beers;

##

SELECT name, abv, TO_STRING(abv) AS string_abv
FROM beers;


## object functions

SELECT name, geo, 
       OBJECT_NAMES(geo) AS geo_names
FROM breweries
LIMIT 1;

SELECT name, geo, 
       OBJECT_VALUES(geo) AS geo_names
FROM breweries
LIMIT 1;

SELECT name, geo, 
       OBJECT_PAIRS(geo) AS geo_names
FROM breweries
LIMIT 1;

SELECT name, geo, 
       OBJECT_ADD(geo, "retrieved", now_local()) AS mod_geo
FROM breweries;

SELECT name, geo, 
       OBJECT_REMOVE(geo, "accuracy") AS mod_geo
FROM breweries;


## Array aggregation functions

SELECT ARRAY_AGG(abv) AS abvs_array
FROM beers;

SELECT ARRAY_MAX (abvs.abvs_array)
FROM (SELECT ARRAY_AGG(abv) AS abvs_array
      FROM beers) AS abvs;

SELECT ARRAY_MIN (abvs.abvs_array)
FROM (SELECT ARRAY_AGG(abv) AS abvs_array
      FROM beers) AS abvs;

SELECT ARRAY_AVG (abvs.abvs_array)
FROM (SELECT ARRAY_AGG(abv) AS abvs_array
      FROM beers) AS abvs;


SELECT bw.names_array
FROM (SELECT ARRAY_AGG(name) AS names_array
      FROM breweries) AS bw;

## Loony Brews is added to the end of the array
SELECT ARRAY_APPEND(bw.names_array, "Loony Brews")
FROM (SELECT ARRAY_AGG(name) AS names_array
      FROM breweries) AS bw;

## Loony Brews is added to index 2
SELECT ARRAY_INSERT(bw.names_array, 2, "Loony Brewing")
FROM (SELECT ARRAY_AGG(name) AS names_array
      FROM breweries) AS bw;
