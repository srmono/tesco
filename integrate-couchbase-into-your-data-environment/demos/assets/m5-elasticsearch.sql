#############################################
############################## Elasticsearch Connector for Couchbase
#############################################

## At the start, make sure at least 20% of your hard disk is free

## Load the travel-sample bucket into your Couchbase cluster

##	Resources:- https://docs.couchbase.com/elasticsearch-connector/4.2/getting-started.html

##	prerequisite:-
#	1. Installed couchbase
#	2. Installed java

##	Downloads:-
#	- To do this we have to download both Elasticsearch and the Couchbase elasticsearch connector.
#	- Download Elasticsearch :- https://elastic.co/downloads/elasticsearch/
#	- Download couchbase elasticsearch connector:- https://docs.couchbase.com/elasticsearch-connector/4.2/release-notes.html

## Unpack both elasticsearch and the couchbase-elasticsearch-connector in a directory (e.g. ~/tools)

##	PATH configuration
#	- Open your .bash_profile and set path configurations

subl ~/.bash_profile

##Add these lines to the file. Then save and close
export CBES_HOME=~/tools/couchbase-elasticsearch-connector-4.2.3
export PATH=$PATH:$CBES_HOME/bin

## Load the changes in your shell (or open a new shell)
source .bash_profile

##	Set credential and connection config for couchbase
#	    - Go to the config sub-folder of couchbase-elasticsearch-connector-4.2.3 
#	    - copy example-conector.toml to default-connector.toml in the same directory
cp $CBES_HOME/config/example-connector.toml $CBES_HOME/config/default-connector.toml

## View the contents of default-connector.toml with a text editor (format as bash file)
## Note the username and pathToPassword properties
## Make sure the username matches your Couchbase user
subl $CBES_HOME/config/default-connector.toml

## Open you couchbase-password.toml file with sublime text or any editor and then
## Set the password to that of the username specified in default-connector.toml
## Save and close the file
subl $CBES_HOME/secrets/couchbase-password.toml



## Run elasticsearch
~/tools/elasticsearch-7.8.1/bin/elasticsearch

## From a new tab check that Couchbase and Elasticsearch are both running
curl localhost:8092

curl localhost:9200

## From a new shell, run the couchbase elasticsearch connector
$CBES_HOME/bin/cbes


## Check the health of the elastic cluster
curl -X GET 'localhost:9200/_cluster/health?pretty'

##	List of elastic indexes
curl -v -GET localhost:9200/_cat/indices?v

## View the contents of the airports index
curl -X GET 'http://localhost:9200/airports/_search?pretty=true' \
-H 'Content-Type: application/json' \
-d '{
   "query" : {
       "match_all" : {}                                
   }
}'

## Select doc with the id airport_3554
curl -XGET 'http://localhost:9200/airports/_search?pretty=true' \
-H 'Content-Type: application/json' \
-d '{
   "query" : {
       "match" : {"_id" : "airport_6456"}
   }
}'

## View the contents of the airlines index
curl -X GET 'http://localhost:9200/airlines/_search?pretty=true' \
-H 'Content-Type: application/json' \
-d '{
    "query" : {
        "match_all" : {}
    }
}'


## Stop the Couchbase Elasticsearch connector process

## From the Couchbase UI, add these documents:
insert into `academic-data` (key, value)
values('stu_1013', {'user_id': 1013,
       'gender' : 'M',
       'nationality' : 'Canada',
       'topic': 'Chemistry',
       'semester' : 'First',
       'test_score': 82}),
values('stu_1014', {'user_id': 1014,
       'gender' : 'M',
       'nationality' : 'USA',
       'topic': 'Biotech',
       'semester' : 'Third',
       'test_score': 90});


## Make these changes to the config so that it indexes the academic-data documents
## The original value of bucket will be travel-sample
[couchbase]
  hosts = ['localhost']
  network = 'auto'
  bucket = 'academic-data'

## In place of the airlines and airports index, index student documents
## Delete these two elasticsearch.type entries
[[elasticsearch.type]]
  prefix = 'airline_'
  index = 'airlines'
  pipeline = ''

[[elasticsearch.type]]
  # Regex just for example. Matches prefixes "airport_", "seaport_", etc.
  regex = '.*port_.*'
  index = 'airports'

## Also delete this entry 
[[elasticsearch.type]]
  prefix = 'route_'
  index = 'airlines'
  routing = '/airlineid' # JSON pointer to the parent ID field.
  ignoreDeletes = true # Must always be true if `routing` is specified.

## Add this entry for students in academic-data
[[elasticsearch.type]]
  prefix = 'stu_'
  index = 'students'
  pipeline = ''

## Restart the Couchbase Elasticsearch conncector
$CBES_HOME/bin/cbes


## From another shell, check the indexes - the students index should show up
## This could take 1-2 minutes
curl -v -GET localhost:9200/_cat/indices?v

## query the students index - the new ones with Doc ids starting with "stu_" show up

curl -XGET 'http://localhost:9200/students/_search?pretty=true' \
-H 'Content-Type: application/json' \
-d '{
   "query" : {
       "match_all" : {}                                
   }
}'

## From the Couchbase UI, run this query to update one of the new students
update `academic-data`
set semester = "Second"
where meta().id = 'stu_1013';

## After a few seconds, from the terminal, re-run the search - the update should have propagated

curl -XGET 'http://localhost:9200/students/_search?pretty=true' \
-H 'Content-Type: application/json' \
-d '{
   "query" : {
       "match_all" : {}                                
   }
}'


