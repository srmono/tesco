##############################
########## Security settings with the UI
##############################

## Setting up Couchbase on Linux

wget https://packages.couchbase.com/releases/6.5.0/couchbase-server-enterprise_6.5.0-ubuntu18.04_amd64.deb

sudo dpkg -i couchbase-server-enterprise_6.5.0-ubuntu18.04_amd64.deb


## Assume the admin user is admin and the password is bvsrao

## Bucket setup

## Log in to Couchbase as admin
## Head to Security --> Sample Buckets
## Load two of the sample buckets - beer-sample and gamesim-sample
## Navigate to the buckets page and make sure they show up


#### Admin users

## Head to Security and then Add User
# Create the following users with the following Full names and permissions
# Set the password to bvsrao for all of them
#	- cluster_admin , Cluster Admin, Cluster Admin
#	- security_admin , Security Admin, Security Admin
#	- ro_admin , Readonly Admin, Read-Only Admin
#	- bucket_admin , Bucket Admin, All Buckets --> Bucket Admin
#	- beer_admin , Beer Admin, beer-sample --> Bucket Admin

## From a separate browser window (Firefox/Safari private window), login as each user above

## Cluster Admin
#	- cluster_admin - the left menu does not include Security, Eventing, Views, Indexes
#	- head to the Query section and run this query (the user does not have permissions for this):
SELECT *
FROM system:indexes;

#	- even this query cannot be run
SELECT *
FROM `beer-sample`;

#	- the Cluster admin can change settings though. Go to Settings
#	- Change the memory allocation for the index service (if it's 512MB, change to 256) and save
#	- this works without issues
#	- Go to Buckets and expand one of the buckets - there is the option to edit/delete
#	- Log out

## Security Admin
#	- security_admin - similar to Cluster admin, but left menu has Security, does not include Analytics
#	- Go to Security - all users are visible
#	- Select Cluster Admin user and delete
#	- Go to Buckets and expand one of the buckets - there is no Edit/Delete option
#	- Log out


## Bucket Admin
#	- Go to Settings - options are visible, but cannot be edited
#	- Go to Buckets and expand one of the buckets - there is the option to edit/delete
#	- Go to Indexes - the indexes on the two tables can be viewed
#	- Go to Query and run these queries. Both cannot be run

CREATE INDEX city ON `beer-sample`(city);

SELECT *
FROM `beer-sample`;

#	- From the Query page, click on Query Monitor. The user is able to view that.
#	- Log out


## Beer Admin
#	- Go to Buckets and expand both buckets - only beer-sample can be edited/deleted


## From the admin user console, go to Security --> Add Group
#	- Create a group called gamesim_select_insert
#	- with the Role from Roles--> gamesim-sample --> Query and Index Services --> Query Select, Query Insert
#	- From the Security menu, go to the groups tab and confirm the group creation

## Add 2 users to the newly created group with the password "bvsrao"
#	- gamesim_user_01, GameSim 01, Group --> gamesim_select_insert
#	- gamesim_user_02, GameSim 02, Group --> gamesim_select_insert

## Sign in as both gamesim_user_01 and gamesim_user_01 and run these queries

SELECT *
FROM `gamesim-sample` 
WHERE jsonType = "player"
AND experience > 10000;

INSERT INTO `gamesim-sample` (KEY, VALUE)
VALUES ("player_001", {"name": "Loony", "city": "Bangalore"});

DELETE
FROM `gamesim-sample` 
WHERE jsonType = "player";

SELECT *
FROM `beer-sample`;


## Select the gamesim_user_01 and gamesim_user_02 and delete from the console








