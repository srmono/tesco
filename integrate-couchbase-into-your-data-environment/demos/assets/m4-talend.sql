#############################################
############################## Connecting Couchbase to Talend Open Studio
#############################################

##	To do this we need to download Talend Studio and JDBC couchbase connector

##	Download and install 

#	- Download link JDBC couchbasd connector
#	- https://www.cdata.com/kb/tech/couchbase-jdbc-talend.rst

## The steps to download and set up the JDBC driver is available in M3. 


#	- Download link for Talend Studio
#	- https://www.talend.com/download/?utm_medium=help&utm_source=help_content


##	Replicating data from Couchbase

#	- Expand metadata in the repository tree view and right click on Db Connection
#	- click create connect
#	- A new windows prompt called Database connection
#	- Fill in the required data
#	- select DB type as JDBC
#	- JDBC URL as jdbc:couchbase:User="admin";Password="bvsrao";Server="127.0.0.1";
#	- Click the plus icon to select driver path. i.e the path where .jar file is located
#	- Click on three dots option, a new windows for module will appear 
#	- Select the radio button for Artifact repository 
#	- Select radio button for Install a New Module
#	- Navigate to cdata.jdbc.couchbase.jar file 
#	- Click Detec Module
#	- Hit OK

#	- Select the driver class, clicking on select class name
#	- Set couchbase credential
#	- user ID:- admin
#	- Password:- bvsrao
#	- test connection
#	- click on finish

##	Run query to access data from couchbase to talend

#	- Right click on your created connection (in my case CouchbaseTalendConn)
#	- Click edit query, a new windows will prompt called SQL Builder
#	- Click on the refresh button in the data structure section
#	- The Couchbaase buckets will be visible


#	- Go to new Query section and execute below query.
select * from `academic-data`;
#	- it ask to some license for certicate verification

#	- Before running the query just copy the JDBC driver trial license 
#	to where Talend Open Studio has copied the driver

#	- Execute below queries

select * from `academic-data`;

select semester, test_score 
from `academic-data`
where test_score < 70;

delete from `academic-data` 
where test_score < 70;

## Scroll and view the test column to confirm that scores less than 70 have been removed
select * from `academic-data`;

## Retrieve some travel-sample data
select * from `travel-sample` 
where type='airport' 
and country = 'France';


















