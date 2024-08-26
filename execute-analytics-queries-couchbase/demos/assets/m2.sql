##########################################
#####################   Getting Started with N1QL for Analytics
##########################################

## go to settings and install `beer-sample`
## go to Indexes and show that one index is present

## Go to the Query section to show the contents of the dataset
SELECT META().id, *
FROM `beer-sample`
LIMIT 2; 

SELECT DISTINCT type
FROM `beer-sample`;

SELECT type, COUNT(*)
FROM `beer-sample`
GROUP BY type;

## go to analytics 
## observe the Datasets

SELECT "Welcome to Couchbase!" AS Greetings;

##

SELECT ["Hello World", 99, 'abc'] AS values;

##

SELECT META().id, *
FROM `beer-sample`
LIMIT 2;  # error

##

CREATE DATASET breweries 
ON `beer-sample` 
WHERE `type` = "brewery";

##

CREATE DATASET beers 
ON `beer-sample` 
WHERE `type` = "beer";

## click on Datasets and show these 2 dataset
## two datasets are red in color

SELECT META().id, *
FROM breweries
LIMIT 1; # shows results empty

# The CONNECT LINK statement activates the connectivity between 
# Analytics and a Couchbase Server cluster instance

CONNECT LINK Local;

## obeserve the Datasets now
## click on beers and breweries

SELECT META().id, *
FROM breweries
LIMIT 1;

##

SELECT META().id, *
FROM beers
LIMIT 1;

##

SELECT RAW COUNT(*) 
FROM beers;

##

SELECT name, country, address
FROM breweries
LIMIT 10;

##

SELECT bw
FROM breweries bw
WHERE bw.name = 'Kona Brewing';

##

SELECT META(bw) AS meta, bw AS data
FROM breweries bw
WHERE META(bw).id = 'kona_brewing';

##

SELECT name, city, address, phone
FROM breweries
WHERE ARRAY_LENGTH(address) = 2;

##

SELECT bw
FROM breweries bw
WHERE bw.geo.lat > 60.0
AND bw.name LIKE '%Brewing%';

##

SELECT name, abv, category
FROM beers as bs
WHERE bs.abv BETWEEN 15 and 20 
AND bs.name LIKE "__kyo%";

##

SELECT name, address, country
FROM breweries
WHERE ARRAY_LENGTH(address) > 1
OR country LIKE '%land%';

#########

SELECT br.name AS beer_name, bw.name AS brewery_name
FROM beers br JOIN breweries bw
ON meta(bw).id = br.brewery_id
ORDER BY br.name;


##

SELECT br.name AS beer_name, brew.name AS brewery_name
FROM beers as br, 
    (SELECT bw.name
     FROM breweries bw
     WHERE meta(bw).id = br.brewery_id) AS brew
ORDER BY br.name;




##########################################
#####################   Running Analytics Queries using CBQ and the REST API
##########################################

          # Running_queries_using_command_line query tool and Rest API

#Go to bin 

cd /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/

#Go to cbq

./cbq -u loony -p runloony -e "http://127.0.0.1:8095"

SELECT name, style, abv
FROM `beers` limit 5;

##

SELECT COUNT(*) as counts 
FROM `breweries` 
WHERE geo.lat > 40;
 
##

SELECT name, style, abv
FROM beers
WHERE abv BETWEEN 15 AND 20
LIMIT 3;

##

SELECT bs.city, COUNT(city) AS counts
FROM `breweries` bs
GROUP BY bs.city
HAVING COUNT(city) > 10
ORDER BY COUNT(bs) DESC;

##

#shows all details which has highest abv(alcohol by volume) value 

SELECT bs.name, bs.abv, bs.`type`, bs.style
FROM `beers` AS bs
LET maxABV = (SELECT RAW MAX(abv)
         FROM `beers`)[0]
WHERE maxABV = bs.abv;

## Exit the CBQ shell
\exit;

## service API

#POST METHOD

curl -u loony:runloony \
--data-urlencode "statement= SELECT 'Hello World';" \
http://127.0.0.1:8095/analytics/service

##

curl -u loony:runloony \
-H "Content-Type: application/json" \
-d '{
    "statement":"SELECT name, style, abv FROM `beers` limit 5;",
    "pretty":true,
    "client_context_id":"bvsrao"
    }' \
http://127.0.0.1:8095/analytics/service

## Create a file called five_beers.json in your home directory
nano ~/five_beers.json

## Paste in this content
{
  "statement":"SELECT name, style, abv FROM `beers` limit 5;",
  "pretty":true,
  "client_context_id":"bvsrao"
}

## Run the query from the file

curl -u loony:runloony \
-H "Content-Type: application/json" \
-d @/Users/bvsrao/five_beers.json \
http://127.0.0.1:8095/analytics/service




#GET METHOD

curl -v -u loony:runloony \
http://127.0.0.1:8095/analytics/config/service

curl -v -u admin:bvsrao http://127.0.0.1:8095/analytics/config/service

#PUT METHOD

curl -v -u loony:runloony \
-X PUT \
-d jobHistorySize=15 \
http://127.0.0.1:8095/analytics/config/service

#TO SEE THE CHANGE IN 'jobHistorySize' = 15

curl -v -u loony:runloony \
http://127.0.0.1:8095/analytics/config/service

























