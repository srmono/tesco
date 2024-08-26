##############################
########## Modifying Security Setting with the CLI 
##############################

Case:-I Roles for Cluster as Administration & Global

Note:- Before setting Roles to the users we have to check current user role and create another users as your required

### First go to bin directory

cd /opt/couchbase/bin 

./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--my-roles


Case:-1 Set roles for full access as full Admin
link:- https://docs.couchbase.com/server/5.5/security/security-roles.html#full-admin


### Since, current user has admin role then it manage all things. It can create another 
#	user as admin role or cluster admin role or security admin role or analytics reader
#	or combine of two or more roles

### So, by using below command, I want to create a user with role admin  

./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--set \
--rbac-username cluster_admin \
--rbac-password bvsrao \
--roles cluster_admin  \
--auth-domain local

## From the alternate browser, login with the credentials 



## Create a new user using the security_admin credentials

./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--set \
--rbac-username query_select_all \
--rbac-password bvsrao \
--roles query_select[*]  \
--auth-domain local

## Try to login to the UI using the new query_select_all credentials
## Navigate to buckets and expand both buckets - they cannot be edited
## Navigate to Servers and Settings - data can be seen but not edited

## Navigate to Query and run this

SELECT name, city 
FROM `beer-sample` 
WHERE type = "brewery"
AND country = "Germany";

## This query cannot be run
INSERT INTO `beer-sample` (KEY, VALUE)
VALUES ("brewery_001", {"name": "Loony Brews", "city": "Bangalore"});


## Back to the shell and create a user
./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--set \
--rbac-username query_user_01 \
--rbac-password bvsrao \
--roles query_insert[beer-sample],query_delete[gamesim-sample]  \
--auth-domain local


## Login as query_user_01
## Navigate to Query and run these. Only the insert works

SELECT name, city 
FROM `beer-sample` 
WHERE type = "brewery"
AND country = "Germany";

INSERT INTO `beer-sample` (KEY, VALUE)
VALUES ("brewery_001", {"name": "Loony Brews", "city": "Bangalore"});




## Against gamesim-sample, only the delete works
SELECT *
FROM `gamesim-sample` 
WHERE jsonType = "player"
AND experience > 10000;

INSERT INTO `gamesim-sample` (KEY, VALUE)
VALUES ("player_001", {"name": "Loony", "city": "Bangalore"});

DELETE
FROM `gamesim-sample` 
WHERE jsonType = "player";




#### Creating a group and assigning a user to it

## Back to the shell and create a group
./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--set-group \
--group-name select_users \
--roles query_select[*]  \
--auth-domain local

./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--set \
--rbac-username query_user_02 \
--rbac-password bvsrao \
--user-groups select_users \
--auth-domain local


## Sign in as query_user_02
## Run these queries - only the select queries work


SELECT name, city 
FROM `beer-sample` 
WHERE type = "brewery"
AND country = "Germany";

SELECT *
FROM `gamesim-sample` 
WHERE jsonType = "monster";



./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--delete \
--rbac-username query_user_01 \
--auth-domain local

./couchbase-cli user-manage -c 127.0.0.1:8091 \
-u security_admin -p bvsrao \
--delete \
--rbac-username query_user_02 \
--auth-domain local








##############################
########## Modifying SecuritySetting with the REST API 
##############################


### We can also manage all things using of REST API's instead of CLI
#	Here, we are going to list all existing users and their roles 

## To view JSON output in a formatted manner, install JQ
## This is the command on Linux, different for MacOS (brew install jq)
sudo apt-get install jq

curl -v -X GET -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/users \
| jq


Case:-1 set Roles for full access as full Admin
https://docs.couchbase.com/server/5.5/security/security-roles.html#full-admin

###	Create a user with a Views admin role 

curl -v -X PUT -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/users/local/views_admin \
-d "name=Views Admin" \
-d password=bvsrao \
-d roles=views_admin[*],query_select[*]

curl -v -X GET -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/users/local/views_admin \
| jq


## Navigate to the UI and sign in as views_admin
## Head to the Views menu - the button to add a view is available
## Head to the Query menu and run this query

SELECT name, city 
FROM `beer-sample` 
WHERE type = "brewery"
AND country = "Germany";


## Creating groups

curl -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/groups \
| jq

curl -v -X PUT -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/groups/view_viewer \
-d roles=views_reader[*],query_select[*]

curl -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/groups \
| jq


## Add a user to the group

curl -v -X PUT -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/users/local/view_user_01 \
-d "name=Views Admin" \
-d password=bvsrao \
-d groups=view_viewer

curl -v -X GET -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/users/local/view_user_01 \
| jq


## Navigate to the UI and sign in as view_user_01
## Head to the Views menu - Views can be seen, but the add button is not available
## Head to the Query menu and run this query

SELECT name, city 
FROM `beer-sample` 
WHERE type = "brewery"
AND country = "Germany";


## Delete the user
curl -v -X DELETE -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/users/local/view_user_01

## Delete the group
curl -v -X DELETE -u admin:bvsrao \
http://127.0.0.1:8091/settings/rbac/groups/view_viewer







