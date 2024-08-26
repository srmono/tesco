



####################################################
####################################### Tracking Event Activity with Audit Logs
####################################################


## Create a new user who can access events
## Head to Security --> Users & Groups --> ADD USER
## Create a new user who has Admin privileges
## Go to the Audit section and enable auditing for the Eventing Service

## Sign in as the newly created user from a different browser
## Play around with one of the functions

## From the shell, head over to the logs directory and view the audit log:
cd Library/Application\ Support/Couchbase/var/lib/couchbase/logs

less -N audit.log

## Search for the newly created user's ID
## Also search for the function which was accessed by the new user
##      - HighGPAStudentTransfer
##      - CopyHighGPAStudents
##      - CascadeStudentDelete

## From the admin session, modify the audit setting so that list operations
## are not audited
## From the new user session, perform more operations on the functions
## Once again, check the audit log (search from the bottom)



####################################################
####################################### Log Redaction
####################################################

## Disable audit logs
## Head over to the Log section of the Web UI and then to Collect Information
## Select the node for which you want log data to be collected
## Make sure Partial Redaction has been enabled
## Hit "Start Collecting"
## This operation will take several minutes


## Navigate to the directory where the log files have been saved e.g.
cd /Users/kishan/Library/Application\ Support/Couchbase/var/lib/couchbase/tmp/

## Unzip the redacted and non-redacted logs in separate folders
## Compare the contents of the file ns_server.http_access.log



####################################################
####################################### Function Statistics
####################################################



==>Analyze event statistics in the Couchbase Web UI

https://docs.couchbase.com/server/6.5/eventing/eventing-statistics.html

-->Case-I (Using console web)

--> Go to server section of web console on this windows of right hand side you will get statistic
-- link click on it and select one by one your created bucket and analysis the statistics of uses
-- resources, analysis the resources uses by Query, Analystics, Event function, index and Incoming XDCR


### Expand the one for Eventing Stats: EventFunction
## Click on the "per server" link. The chart pops up
## Adjust the duration for the chart, from minute, hour, day, week

--> Case-II (Using Rest API)
## Bring up your shell

curl http://admin:bvsrao@127.0.0.1:8096/api/v1/functions/CopyHighGPAStudents

curl http://admin:bvsrao@127.0.0.1:8096/api/v1/functions/CascadeStudentDelete

curl http://admin:bvsrao@127.0.0.1:8096/api/v1/stats?type=full

-->Case-I (undeploy)

curl http://admin:bvsrao@127.0.0.1:8096/getExecutionStats?name=CopyHighGPAStudents
curl http://admin:bvsrao@127.0.0.1:8096/getExecutionStats?name=CascadeStudentDelete

curl http://admin:bvsrao@127.0.0.1:8096/getLatencyStats?name=CopyHighGPAStudents

curl http://admin:bvsrao@127.0.0.1:8096/getFailureStats?name=CopyHighGPAStudents

