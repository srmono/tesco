#############################################
############################## ODBC Connector for Couchbase
#############################################


## Resource:- http://cdn.cdata.com/help/CKE/odbc/pg_connectionodbcmac.htm#

##	prerequisite:-
#	1. Installed couchbase
#	2. Excel


# 	In addition to the Couchbase ODBC driver, we also need the iODBC tool (if on MacOS)
#	iODBC is a tool to view data in apps such as Microsoft Excel and Tableau when on MacOS

##	- Download the ODBC driver from https://www.cdata.com/drivers/couchbase/odbc/
#	- Just double click to install 

##	Run this command to access a trial license
cd "/Applications/CData ODBC Driver for Couchbase/bin"
sudo ./install-license

#	- It will ask password for your local machine, your name and email to access trial ODBC drive

#	- Download iODBC to connect ODBC from couchbase 
#	- from http://www.iodbc.org/dataspace/doc/iodbc/wiki/iodbcWiki/Downloads#Mac%20OS%20X

##	Configuring Data Source Name(DSN's)
#	- you can configure by using GUI, opening from Launchpad or with this command
sudo /Applications/iODBC/iODBC\ Administrator64.app/Contents/MacOS/iODBC\ Administrator64

#	- Enter your sudo password
#	- A Data source name(DSN) configuration window pops up
#	- Go to System DSN tab and select database drive and then configure Server, User and password
User:- admin
password:- bvsrao
Server:- 127.0.0.1
#	- hit ok

#	- Click on test button for test the configuration
#	- Enter your Couchbase credentials where required or when prompted

## Queries to run from Excel
select * from `academic-data`;

select semester, test_score
from `academic-data`;

select semester, test_score
from `academic-data`
where absence_days = 'Under-7';



## Run this query, and load the results in an Excel sheet
select * from `academic-data`;

## Head to the Couchbase UI and make a few modifications to the academic-data bucket
insert into `academic-data` (key, value)
values('1011', {'user_id': 1011,
       'gender' : 'F',
       'nationality' : 'Nigeria',
       'parent_school_satisfaction': 'good',
       'topic': 'Physics',
       'semester' : 'First',
       'absence_days' : 'Under-7',
       'test_score': 84});

update `academic-data` 
set semester = "Second"
where meta().id = "1001";


## Head to Excel and hit Refresh - the new and updated documents should be visible here



