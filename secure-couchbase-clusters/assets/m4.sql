##############################
########## Audit User Activity on Couchbase
##############################


## To begin with a clean slate, make sure all users except the main admin user are deleted

## Head to Security --> Audit
## Enable the option "Audit events & write them to a log"
## Set the File Reset Interval to 15 minutes

## Expand the following Events to have an idea of the types of activities which can be audited
#	- REST API
#	- Query and Index Service
#	- Eventing Service
#	- Views 

## In the Query and Index Service section, check the box for the following query types:
#	- SELECT statement
#	- INSERT statement
## Save the changes

## From the Users & Groups section, create a new user:
#	- Username, full name, pwd = alice, Alice, bvsrao, 
#	- Assign these Roles to Alice: All Buckets --> Bucket Admin, Application Access
# Add user

## In a separate window (Firefox), login as Alice and run these queries

SELECT name, city 
FROM `beer-sample` 
WHERE type = "brewery"
AND country = "Germany";

DELETE 
FROM `beer-sample` 
WHERE meta().id = "brewery_001"
RETURNING meta().id, name;

INSERT INTO `beer-sample` (KEY, VALUE)
VALUES ("brewery_001", {"name": "Loony Brews", "city": "Bangalore"})
RETURNING meta().id, name;


## Navigate on the shell to the logs directory
cd /opt/couchbase/var/lib/couchbase/logs

## View the contents of audit.log
less -N audit.log

# From the bottom, search for "alice". 
## 	- Shift + G to to to the bottom
## 	- ?alice to search bottom-up - there are a few results
## 	- n to go to the next search result
## 	- Shift + G to to to the bottom
## Search for "SELECT" - a few results show up
## 	- Shift + G to to to the bottom
## Search for "INSERT" - a few results show up
## 	- Shift + G to to to the bottom
## Search for "DELETE" - there are no results


## From the admin UI, go to Security --> Audit --> Query and Index Service
## Check the box for DELETE statement
## Save

## Go to Alice's UI and run the delete query
DELETE 
FROM `beer-sample` 
WHERE meta().id = "brewery_001"
RETURNING meta().id, name;

## Log out from Alice's account

## Head back to the shell and view the contents of audit.log
## 	- Shift + G to to to the bottom
## Search for "DELETE" - now this is included in the results
## Search for "alice" from the bottom - her sign out is recorded






##############################
########## Redacting Sensitive Log Data
##############################

#https://docs.couchbase.com/server/6.5/clustersetup/ui-logs.html

## As the admin user in the UI, navigate to Logs --> Collect Information
## Slide the button for "Select all nodes"
## Under the Redact Logs section, choose partial redaction (click the 'i' for more info)
## Click "Start Collecting"

## Once the logs are created, navigate to the directory where the logs are stored
## Head to the shell first

#	First go to tmp directory  
cd /Users/bvsrao/Library/Application\ Support/Couchbase/var/lib/couchbase/tmp/

ls -n 

# Unzip the non-redacted file
unzip collectinfo-2020-06-08T062604-ns_1@127.0.0.1.zip

# Confirm a new directory is created
ls -n

# Rename the newly created directory
mv cbcollect_info_ns_1@192.168.1.6_20200608-062605 \
cbcollect_info_ns_1@192.168.1.6_20200608-062605-full

# Unzip the redacted logs:
unzip collectinfo-2020-06-08T062604-ns_1@127.0.0.1-redacted.zip

ls -n

# Re-name the redacted log files directory
mv cbcollect_info_ns_1@192.168.1.6_20200608-062605 \
cbcollect_info_ns_1@192.168.1.6_20200608-062605-redacted


# cd into the non-redacted log folder
cd cbcollect_info_ns_1@192.168.1.6_20200608-062605-full

ls -n

less -N ns_server.http_access.log

# From the bottom, search for "alice". 
## 	- Shift + G to to to the bottom
## 	- ?alice to search bottom-up
## 	- n to go to the next search result
# Hit n about 3-4 times. Note the line number for 2 of the search results
# Quit less by hitting q

cd ../cbcollect_info_ns_1@192.168.1.6_20200608-062605-redacted

ls -n

less -N ns_server.http_access.log

# From the bottom, search for "alice". 
## 	- Shift + G to to to the bottom
## 	- ?alice to search bottom-up - nothing is found
## 	- Shift + G to to to the bottom
# Go to both line numbers noted in the non-redacted file
# To go to line 1234, do this:
##	- 1234G

# Instead of alice, there is a hash code. 


















