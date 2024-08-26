## Before running any of the queries, 
## delete the FTS index so that there are no search indexes

## Run a query without the search service
SELECT META(t1).id, t1.country, t1.name, t1.type
FROM `travel-sample` AS t1
WHERE t1.country = "United States";

## Employ the search service
## The results include documents where the country is United Kingdom
## The query execution takes a while
SELECT META(t1).id, t1.country, t1.name, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1.country, "United States");

## Head to the Search tab and re-create an FTS index 
## Re-run the SEARCH query - execution is much faster now
SELECT META(t1).id, t1.country, t1.name, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1.country, "United States");

## This is written in the key-value syntax, but does an exact match
SELECT META(t1).id, t1.country, t1.name, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, "country:\"United States\"");

## Searching for "outdoor" in the description using both syntaxes
SELECT META(t1).id, t1.country, t1.name, t1.type, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1.description, "outdoor");

SELECT META(t1).id, t1.country, t1.name, t1.type, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, "description:\"outdoor\"");

## Exclude results which do not contain "pool"
SELECT META(t1).id, t1.country, t1.name, t1.type, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1.description, "outdoor -pool");


### This query is the same as the second query, just written in the syntax of the previous query

SELECT META(t1).id, t1.country, t1.name, t1.type, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "match": "outdoor",
  "field": "description",
  "analyzer": "standard"
});

SELECT META(t1).id, t1.country, t1.name, t1.type, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, { 
    "query": {
      "match": "outdoor",
      "field": "description",
      "analyzer": "standard"
     }
});


## Search for "swimming pool"
SELECT t1.country, t1.name, t1.type, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, { 
    "query": {
       "match_phrase": "\"swimming pool\""
     }
});


## Search for occurrences of "exhibit" in the content field
SELECT t1.name, t1.country, t1.content, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "exhibit",
    "field": "content",
    "analyzer": "standard"
  }});

## When the prefix "exhibit" is being searched, words such as exhibition are 
## included in the search result
SELECT t1.name, t1.country, t1.content, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "prefix": "exhibit",
    "field": "content",
    "analyzer": "standard"
  }});

### This search returns documents which have any word beginning with "exhibit" in the content field 

## The results in the prefix query which did not exist in the match query
SELECT t1.name, t1.country, t1.content, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "prefix": "exhibit",
    "field": "content",
    "analyzer": "standard"
  }})
EXCEPT
SELECT t1.name, t1.country, t1.content, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "exhibit",
    "field": "content",
    "analyzer": "standard"
  }});

## Use a regular expression in the search
## The results contain at least one character after "exhibit" in the content field
SELECT t1.name, t1.country, t1.content, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "regexp": "exhibit.+",
    "field": "content",
    "analyzer": "standard"
  }});

## The results contain 0 or more characters after "exhibit" in the content field
## i.e. it also includes results which contain "exhibit" without anything else
SELECT t1.name, t1.country, t1.content, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "regexp": "exhibit.*",
    "field": "content",
    "analyzer": "standard"
  }});


## The results only include descriptions where the word "exhibit" exists
SELECT t1.name, t1.country, t1.content, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "exhibit",
    "field": "content",
    "analyzer": "standard"
  }})
EXCEPT
SELECT t1.name, t1.country, t1.content, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "regexp": "exhibit.+",
    "field": "content",
    "analyzer": "standard"
  }});


## This returns nothing 
SELECT t1.name, t1.country, t1.content, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "exhibit",
    "field": "content",
    "analyzer": "standard"
  }})
EXCEPT
SELECT t1.name, t1.country, t1.content, t1.description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "regexp": "exhibit.*",
    "field": "content",
    "analyzer": "standard"
  }});

## This returns documents where the name contains a number followed by something
SELECT t1.name, t1.country, t1.type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "regexp": "[0-9].+",
    "field": "name",
    "analyzer": "standard"
  }});


## Documents containing "ocean" in the description
SELECT name, country, city, description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "ocean",
    "field": "description",
    "analyzer": "standard"
  }
});

## This returns the same info as above, plus details on where the match was found
SELECT SEARCH_META() as meta, 
       name, country, city, description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "ocean",
    "field": "description",
    "analyzer": "standard"
  },
   "includeLocations": true 
});

## The locations of each word in the query are returned
SELECT SEARCH_META() as meta, 
       name, country, city, description
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "match": "eiffel tower",
    "field": "description",
    "analyzer": "standard"
  },
   "includeLocations": true 
});


## Search within boolean fields
## In this case, we look for pets_ok = true (hotels which allow pets)
SELECT name, country, city, description, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "bool": true,
    "field": "pets_ok",
    "analyzer": "standard"
  }});

## Here, we look for hotels with free parking
SELECT name, country, city, description, free_parking
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "bool": true,
    "field": "free_parking",
    "analyzer": "standard"
  }});


## We carry out 2 searches and combine the results
## for hotels which allow pets AND allow free parking
SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "bool": true,
    "field": "free_parking",
    "analyzer": "standard"
  }}) 
AND SEARCH (t1, {
  "query": {
    "bool": true,
    "field": "pets_ok",
    "analyzer": "standard"
  }});

## The same results (though in a different order) also show up
## if we use the conjuncts operator to combine the two conditions
SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "conjuncts": [{
      "bool": true,
      "field": "free_parking",
      "analyzer": "standard"
    },
    {
      "bool": true,
      "field": "pets_ok",
      "analyzer": "standard"
    }]
  }});

## Hotels with free parking, pets and the ocean
SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "conjuncts": [{
      "bool": true,
      "field": "free_parking",
      "analyzer": "standard"
    },
    {
      "bool": true,
      "field": "pets_ok",
      "analyzer": "standard"
    },
    {
      "match": "ocean",
      "field": "description",
      "analyzer": "standard"
    }]
  }});

## Just replace "conjuncts" with "disjuncts"
## This returns hotels with free parking OR pets
SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "disjuncts": [{
      "bool": true,
      "field": "free_parking",
      "analyzer": "standard"
    },
    {
      "bool": true,
      "field": "pets_ok",
      "analyzer": "standard"
    }]
  }});

## The same results as above, but with two searches and the N1QL OR clause
SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "bool": true,
    "field": "free_parking",
    "analyzer": "standard"
  }}) 
OR SEARCH (t1, {
  "query": {
    "bool": true,
    "field": "pets_ok",
    "analyzer": "standard"
  }});


SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "must": {
      "conjuncts": [{
        "bool": true,
        "field": "free_parking",
        "analyzer": "standard"
      },
      {
        "bool": true,
        "field": "pets_ok",
        "analyzer": "standard"
      }]
    }
  }});

SELECT name, country, city, description, free_parking, pets_ok
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "must_not": {
      "disjuncts": [{
        "bool": true,
        "field": "free_parking",
        "analyzer": "standard"
      },
      {
        "bool": true,
        "field": "pets_ok",
        "analyzer": "standard"
      }]
    }
  }});


SELECT id, name, type
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "min" : 1000, 
    "max" : 2000, 
    "field" : "id"
  }});

--------------

## This only returns two results
SELECT name, country, city, content
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "conjuncts": [{
      "match": "exhibit",
      "field": "content",
      "analyzer": "standard"
    },
    {
      "match": "France",
      "field": "country",
      "analyzer": "standard"
    }]
  }});

## Add a single line for the first query condition - "fuzziness": 0
## This returns the same - the default fuzziness level is 0
SELECT name, country, city, content
FROM `travel-sample` AS t1
WHERE SEARCH(t1, {
  "query": {
    "conjuncts": [{
      "match": "exhibit",
      "field": "content",
      "analyzer": "standard",
      "fuzziness": 0
    },
    {
      "match": "France",
      "field": "country",
      "analyzer": "standard"
    }]
  }});

## Increase the fuzziness to 1 and run - 5 docs show up in the results

## Increase fuzziness to 2 and re-run - 6 docs now appear