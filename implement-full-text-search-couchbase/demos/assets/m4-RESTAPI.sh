### Install the jq tool from the shell
brew install jq


## Run a query identical to what we did previously from N1QL
curl -XPOST -H "Content-Type: application/json" \
-u admin:bvsrao http://127.0.0.1:8094/api/index/travel-sample-fts-index/query \
-d '{ 
    "query": {
      "match": "outdoor",
      "field": "description",
      "analyzer": "standard"
     }}' | jq

## The highlights property points to where the match is found
curl -XPOST -H "Content-Type: application/json" \
-u admin:bvsrao http://127.0.0.1:8094/api/index/travel-sample-fts-index/query \
-d '{ 
    "highlight": {"fields": ["description"]},
    "query": {
      "match": "outdoor",
      "field": "description",
      "analyzer": "standard"
     }}' | jq

## This is the conjuncts query which contains 124 matches, 
## but only 10 are displayed by default
curl -XPOST -H "Content-Type: application/json" \
-u admin:bvsrao http://127.0.0.1:8094/api/index/travel-sample-fts-index/query \
-d '{
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
  }}' | jq


## We re-run the same request with size = 20. More hits show up
curl -XPOST -H "Content-Type: application/json" \
-u admin:bvsrao http://127.0.0.1:8094/api/index/travel-sample-fts-index/query \
-d '{
  "size": 20,
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
  }}' | jq


## Head to the UI and use the index to search for this:
## name: church -content: church
## Check the box "show advanced query settings"
## This includes a field "JSON for Query Request" were the REST API data is shown
## Check the box "show command-line curl example" and show the full request

## This is what the request was. Run it from the shell
## The output is very large - we'll fix it in the next run
curl -XPOST -H "Content-Type: application/json" \
-u admin:bvsrao http://127.0.0.1:8094/api/index/travel-sample-fts-index/query \
-d '{
  "explain": true,
  "fields": [
    "*"
  ],
  "highlight": {},
  "query": {
    "query": "name: church -content: church"
  }
}' | jq

## Re-run the same command, but with explain set to false, and no fields or highlights
curl -XPOST -H "Content-Type: application/json" \
-u admin:bvsrao http://127.0.0.1:8094/api/index/travel-sample-fts-index/query \
-d '{
  "explain": false,
  "query": {
    "query": "name: church -content: church"
  }
}' | jq
 
