################################################
################################ Cluster Statistics from the UI
################################################



			** Access Bucket Statistics

			-- Access the Buckets screen, by left-clicking on the Buckets tab
			-- Left-click on the Statistics tab
			-- Show Bucket Selection, Server Selection, Interval Selection, Ops Per Sec


			** Statistics Groups

			-- Below the general controls, information is aggregated and displayed according to the following statistics groups.
			-- All groups provide information that relates either to a specific server, or to the whole cluster,
			-- depending on the Server Selection that has been made.


			** Bucket Monitoring — Summary Statistics

			-- The summary section provides an overview of bucket-related activity.
			-- Each chart shows information based on the currently selected bucket.


			** Monitoring Server Resources

			-- The Server Resources statistics group displays general resource information for either the selected server, or for the whole cluster; 
			-- including swap usage, free RAM, CPU utilization percentage, connections, port requests, streaming requests, index RAM used,
			-- remaining index RAM, and FTS RAM used.

			*** Viewing Statistics Per Server

			-- Each chart features a per server option, which allows the data to be displayed in detail for each server in the cluster.
			-- left-click on the per server option for the Management Port Reqs/Sec chart, 
			-- located in the Server Resources statistics group

			** Monitoring vBucket Resources

			-- The vBucket Resources statistics group provides information for all vBucket types within the cluster, 
			-- across three different states; which are Active, Replica, and Pending.

			** Monitoring Disk Queues

			-- The Disk Queues statistics group displays information for data being placed into disk queues.
			-- Information is displayed for each of the disk-queue states, which are Active, Replica, and Pending.

			** Monitoring DCP Queues

			-- The DCP Queues statistics group shows information about DCP connections for the selected bucket.

			** Monitoring View Statistics

			-- The View Stats statistics group shows information on individual design documents within the selected bucket. 
			-- One block of stats is shown for each production-level design document.

			** Monitoring Index Statistics

			-- The Index Statistics statistics group provides per index information on GSI Indexes.

			** Monitoring Analytics Statistics

			-- The Analytics Stats statistics group shows information on the Analytics Service. 
			-- Note that if the Analytics Service is not running, the charts are blank, and the statistic is given as N/A .

			** Monitoring Outgoing XDCR (Not now)

			-- The Outgoing XDCR statistics group provides information on XDCR operations that are supporting cross datacenter replication,
			-- from the current cluster to a destination cluster.

			** Monitoring Query Statistics

			-- The Query statistics group provides information on the Query Service.
			-- Note that these statistics are aggregated across the entire cluster, rather than per bucket or per server.

			** Monitoring Incoming XDCR

			-- The Incoming XDCR Operations statistics group provides information on
			--  the XDCR operations that are coming into to the current cluster from a remote cluster.



################################################
################################ Cluster Statistics using cbstats
################################################

## Using cbstats

-- The cbstats tool queries differently depending on the port
-- When using the Couchbase data port 11210, 
-- it will give you operations per node per bucket:

/opt/couchbase/bin/cbstats host-01:11210 \
-u admin -p bvsrao \
-b beer-sample \
all


/opt/couchbase/bin/cbstats host-01:11210 \
-u admin -p bvsrao \
-b beer-sample \
all | grep \ curr_items

/opt/couchbase/bin/cbstats host-02:11210 \
-u admin -p bvsrao \
-b beer-sample \
all | grep \ curr_items

/opt/couchbase/bin/cbstats host-02:11210 \
-u admin -p bvsrao \
-b travel-sample \
all | grep \ curr_items

/opt/couchbase/bin/cbstats host-01:11210 \
-u admin -p bvsrao \
-b travel-sample \
all | grep \ curr_items

/opt/couchbase/bin/cbstats host-02:11210 \
-u admin -p bvsrao \
-b travel-sample \
items

/opt/couchbase/bin/cbstats host-01:11210 \
-u admin -p bvsrao \
-b travel-sample \
memory

/opt/couchbase/bin/cbstats host-01:11210 \
-u admin -p bvsrao \
-b travel-sample \
workload



/opt/couchbase/bin/couchbase-cli host-list \
-c host-01 \
--username admin \
--password bvsrao

/opt/couchbase/bin/couchbase-cli server-list \
-c host-01 \
--username admin \
--password bvsrao


/opt/couchbase/bin/couchbase-cli server-info \
-c host-01 \
--username admin \
--password bvsrao

/opt/couchbase/bin/couchbase-cli server-info \
-c host-02 \
--username admin \
--password bvsrao


sudo apt-get install jq -y

/opt/couchbase/bin/couchbase-cli server-info \
-c host-02 \
--username admin \
--password bvsrao | jq '.memoryFree'



################################################
################################ Cluster Statistics using the REST API
################################################


curl -X GET \
-u admin:bvsrao \
http://52.172.36.8:8091/pools/default


## Alternatively, paste this as a URL in the browser
## Copy the JSON response and render in some editor which can format it
http://52.172.36.8:8091/pools/default

curl -X GET \
-u admin:bvsrao \
http://host-01:8091/pools/default \
| jq '.nodes[0].systemStats.cpu_utilization_rate'

curl -X GET \
-u admin:bvsrao \
http://host-01:8091/pools/default \
| jq '.nodes[1].systemStats.cpu_utilization_rate'

## Bucket level data
curl -X GET \
-u admin:bvsrao \
http://host-01:8091/pools/default/buckets/beer-sample/stats













