################################################
################################ Cluster and Bucket Setup
################################################

## On a Linux host, v6.5.0 of Couchbase Server Enterprise can be installed with these commands:
wget https://packages.couchbase.com/releases/6.5.0/couchbase-server-enterprise_6.5.0-ubuntu18.04_amd64.deb

sudo dpkg -i couchbase-server-enterprise_6.5.0-ubuntu18.04_amd64.deb

## Load a sample bucket
## Go to Settings and load the travel-sample and beer-sample buckets

## Head to the query workbench and run these queries
SELECT *
FROM `travel-sample`
LIMIT 5;

SELECT DISTINCT RAW type
FROM `travel-sample`;

SELECT type, COUNT(*) as count
FROM `travel-sample`
GROUP BY type;



SELECT * 
FROM `beer-sample`;



## Add a new node to the cluster using the UI
## Rebalance the cluster data


################################################
################################ Exploring the Couchbase Log Files
################################################

## In the UI, first head to the Logs menu
## This contains a limited set of logs
## More details are available in the log files on disk 

-- - By default logfiles are saved to given below location in couchbase

$ cd /opt/couchbase/var/lib/couchbase

$ ls -n

$ cd logs

$ ls -n

## This will result in a permissions error
less -N query.log 

## Run as the root user
sudo -i

cd /opt/couchbase/var/lib/couchbase/logs

## Create an index from the UI
CREATE INDEX idx_country ON `travel-sample`(country);

## Back to the shell, take a look at the updated logs
ls -ltr

## Examine the contents of these log files
## Do a bottom-up search for idx_c
less -N query.log
less -N indexer.log
less -N debug.log


## Connect to the second host and effectively repeat the steps. The log files are different



################################################
################################ Configuring Couchbase Log Settings
################################################ 


# Changing the default location

## By default the system logs are saved to this ($ /opt/couchbase/var/lib/couchbase/logs) location in linux
## Let's say we want the logs to be written to the /logs directory

cd /
mkdir logs

## The couchbase user and group need permissions to write to this folder
l

ls -l

## Navigate to the dir with the Couchbase config
cd /opt/couchbase/etc/couchbase

## Edit the static_config file
vim static_config 

## Modify the following property
## {error_logger_mf_dir, "/logs"} #(we can change path fully)

## Stop and restart Couchbase Server.

systemctl status couchbase-server

systemctl stop couchbase-server

systemctl status couchbase-server

systemctl start couchbase-server

systemctl status couchbase-server

-- - Then cd in to the /logs location



################################################
################################ Collecting Log Data
################################################

##
### Gathering data using the UI
##

## From the UI, head to Logs --> Collect Information
## Pick "Select all Nodes" and opt for "No redaction"
## Hit "Start Collecting"

## This generates log files on each node, and the location is published to the screen
## Navigate to the location on the main node
cd /opt/couchbase/var/lib/couchbase/tmp

ls -n

## Unzip won't work as it's not installed by default
unzip collectinfo-2020-04-14T051534-ns_1@10.0.0.4.zip 

## 
sudo apt-get update -y
apt-get install -y unzip

unzip collectinfo-2020-04-14T051534-ns_1@10.0.0.4.zip 

cd cbcollect_info_ns_1@10.0.0.5_20200414-051535/

less -N ns_server.indexer.log

cd ../

## Remove the unpacked directory as well as the zip file
## We'll create them using the shell
rm -rf cbcollect_info_ns_1@10.0.0.5_20200414-051535/
rm collectinfo-2020-04-14T051534-ns_1@10.0.0.4.zip 




##
### Gathering data using the shell
##

## Collecting logs using cbcollect_info
## The cbcollect_info command gathers statistics from an individual node in the cluster
	
$ cd /opt/couchbase/bin
$ ls -n

## Back to the tmp directory
cd -

/opt/couchbase/bin/cbcollect_info \
collect_info.zip

$ ls

$ unzip collect_info.zip

$ ls

## cd into the unzipped directory
$ cd cbcollect_info_ns_1@cb.local_20200303-115430 

$ ls -n



## Collecting log status using collect-logs-start, 
## collect-logs-stop, and collect-logs-status


$ cd /opt/couchbase/bin

$ ls

$ /opt/couchbase/bin/couchbase-cli \
collect-logs-start \
-c http://host-01:8091 \
--username admin --password bvsrao \
--all-nodes

-- ** collect-logs-status: This command is used to check the status 
-- of the log collection task that is either currently running or last completed.

$ /opt/couchbase/bin/couchbase-cli \
collect-logs-status \
-c http://host-01:8091 \
--username admin --password bvsrao

/opt/couchbase/bin/couchbase-cli \
collect-logs-stop \
-c http://host-01:8091 \
--username admin --password bvsrao

/opt/couchbase/bin/couchbase-cli \
collect-logs-status \
-c http://host-01:8091 \
--username admin --password bvsrao


##
### Gathering data using the REST API
##

-- - Returning Diagnostic Information
-- - The GET /diag http method and URI returns general Couchbase Server diagnostic information.

curl -v -X GET \
-u admin:bvsrao \
http://host-01:8091/diag

-- - Returning Log-File Content
-- - The GET /sasl_logs http method and URI returns information in a Couchbase Server log file
-- - The following example uses GET /sasl_logs with the stats endpoint, to return the contents of the stats.log log file:

curl -v -X GET \
-u admin:bvsrao \
http://host-01:8091/sasl_logs/indexer

curl -v -X GET \
-u admin:bvsrao \
http://host-01:8091/sasl_logs/query


curl -v -X GET \
-u admin:bvsrao \
http://host-02:8091/sasl_logs/query

