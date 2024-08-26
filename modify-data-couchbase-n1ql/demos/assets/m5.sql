

##########	##########	##########	
##########		Deleting Data with N1QL
##########	##########	##########

#document has name,designation ,salary,projects,type,

#delete

select *
from `restEmployeeBucket`;

#1. deleting all doc from bucket
delete 
from `restEmployeeBucket`;

##

select * 
from `EmployeeBucket`;
#there no document found 

## Loading some documents from EmployeeBucket into the restEmployeeBucket
insert into `restEmployeeBucket` (key id, value emp)
select meta().id as id, emp
from `EmployeeBucket` emp
where emp.type = "Employee";


delete from `restEmployeeBucket` 
limit 2;

##

select * 
from `restEmployeeBucket`;

#first 2 docs are deleted..
#_____________________	


#3. deleting document using document keys 

delete 
from `restEmployeeBucket` 
use keys ["emp1005", "emp1006"]
returning * ;

##

select * 
from `restEmployeeBucket`;


#5. deleting document using WHERE with returning value in query result

delete from `restEmployeeBucket` 
where name = "Vincent Wu" 
returning meta().id as docid, name, designation;

##

select meta().id ,name 
from `restEmployeeBucket`;
	
#there is no document for Vincent Wu
#_____________________


select * 
from `restEmployeeBucket`
where salary in (select raw max(salary) 
				 from `EmployeeBucket` as eb);

#Emma Atkinson has higher salary.now lets delete document having higher salary using WHERE ,select and max functions

delete from `restEmployeeBucket` 
where salary in (select raw max(salary) from `EmployeeBucket` as eb)
returning *;
	


##########	##########	##########	
##########		Roles for delete operations
##########	##########	########### 

# delete mode

./couchbase-cli user-manage \
--cluster http://127.0.0.1:8091 \
--username Administrator --password bvsrao \
--set \
--rbac-username deleteonly \
--rbac-password bvsrao \
--rbac-name deleteonly \
--roles query_delete[*] \
--auth-domain local

## Login using the deleteonly user and run this query

## The user cannot run this query
select * 
from `restEmployeeBucket`;

## Even this won't run
delete 
from `restEmployeeBucket`
where salary < 8000
returning name, designation;

## Remove the returning clause, and the query runs
delete 
from `restEmployeeBucket`
where salary < 8000;

## Deleting from EmployeeBucket also works
delete 
from `EmployeeBucket`
where salary < 8000;


##### like insert , delete one of the docuent with use keys "emp1002"
##### delete one doc from travel-sample, with use keys "airline_10123"

./couchbase-cli user-manage \
--cluster http://127.0.0.1:8091 \
--username Administrator --password bvsrao \
--set \
--rbac-username deleteonly \
--rbac-password bvsrao \
--rbac-name deleteonly \
--roles query_delete[restEmployeeBucket] \
--auth-domain local

##### This query should run
delete 
from `restEmployeeBucket`
where salary < 9000;

## But this one will not
delete 
from `EmployeeBucket`
where salary < 9000;


##########	##########	##########	
##########		The MERGE statement
##########	##########	##########

### Login as the Administrator

#. deleting all docs from the bucket 

delete 
from `EmployeeBucket` 
returning meta().id as docid;

#there no document found

#A MERGE statement provides the ability to update, insert into, or delete

#1)UPDATE using MERGE

#step 1 : lets insert some employee document to "EmployeeBucket"
#fields #name
		#id
		#designation
		#oldSalary
		#curSalary

insert into `EmployeeBucket` (key,value)
values("emp1001",{"id":"id1001",
	"name":"Chloe Smith",
	"designation":"Web Developer",
	"oldSalary":5000,
	"curSalary":5500}),

values("emp1002",{"id":"id1002",
	"name":"Emily Armstrong",
	"oldSalary":6000,
	"curSalary":6500}),

values("emp1003",{"id":"id1003",
	"name":"Emma Atkinson",
	"designation":"Product Manager",
	"oldSalary":7000,
	"curSalary":7500})

returning meta().id,first_name,old_salary,new_salary;


## Create an index on the id property
create index idx_id on `EmployeeBucket`(id);

merge into `EmployeeBucket` eb
using [{"id":"id1001"},{"id":"id1002"}] source
on eb.id = source.id
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = 8000
returning meta(eb).id, eb.oldSalary, eb.curSalary;

select * 
from `EmployeeBucket`;

## INdex on the current salary
create index idx_cursalary on `EmployeeBucket`(curSalary);

## You can hardcode a value for the merge condition 
## This won't run as the source does not contain any documents
# The query runs but does not update anything
merge into `EmployeeBucket` eb
using [] source
on eb.curSalary = 8000
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = 8500
returning meta(eb).id, eb.oldSalary, eb.curSalary;

select * 
from `EmployeeBucket`;

## Adding an empty document will get the query to run
merge into `EmployeeBucket` eb
using [{}] source
on eb.curSalary = 8000
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = 8500
returning meta(eb).id, eb.oldSalary, eb.curSalary;

select * 
from `EmployeeBucket`;

## The merge condition need not be an equality operator
merge into `EmployeeBucket` eb
using [{}] source
on eb.curSalary < 8000
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = 9000
returning meta(eb).id, eb.oldSalary, eb.curSalary;

select * 
from `EmployeeBucket`;

## The source can include fields which are not just used for the join condition
## Here, the sal is referenced for updating the current salary
merge into `EmployeeBucket` eb
using [{"id":"id1001", "sal": 9400}, 
	   {"id":"id1002", "sal": 9900}] source
on eb.id = source.id
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = source.sal
returning meta(eb).id, eb.oldSalary, eb.curSalary;


##########	##########	##########	
##########		Merge when there is no match
##########	##########	##########

## A search for a UI developer
create index idx_designation on `EmployeeBucket`(designation);

## Since there is no UI Developer at present, a new employee is inserted
merge into `EmployeeBucket` eb
using [{"designation": "UI Developer", "sal": 7500}] source
on eb.designation = source.designation
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
when not matched then insert
	(key UUID(),
          VALUE {"id": "id1004",
				 "name": "George Miller",
				 "designation": source.designation,
				 "oldSalary": 0,
				 "curSalary": source.sal} )
returning meta(eb).id, eb.name, eb.oldSalary, eb.curSalary;


## Re-run the same query - this time a match is found and an update is performed
merge into `EmployeeBucket` eb
using [{"designation": "UI Developer", "sal": 7500}] source
on eb.designation = source.designation
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
when not matched then insert
	(key UUID(),
          VALUE {"id": "id1004",
				 "name": "George Miller",
				 "designation": source.designation,
				 "oldSalary": 0,
				 "curSalary": source.sal} )
returning meta(eb).id, eb.name, eb.oldSalary, eb.curSalary;


select meta().id, name, designation
from `EmployeeBucket`;

##########	##########	##########	
##########		Lookup merge
##########	##########	##########

merge into `EmployeeBucket` eb
using [{"id":"emp1001"},
	   {"id":"emp1002"}, 
	   {"id":"emp1003"}] source
on key source.id
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
returning meta(eb).id, eb.name, eb.oldSalary, eb.curSalary;

select meta().id, *
from `EmployeeBucket`;

merge into `EmployeeBucket` eb
using [{"id":"emp1001"},
	   {"id":"emp1002"}, 
	   {"id":"emp1003"}] source
on key source.id
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
	where eb.curSalary < 10000
returning meta(eb).id, eb.name, eb.oldSalary, eb.curSalary;



##########	##########	##########	
##########		Deleting Data with MERGE
##########	##########	##########

merge into `EmployeeBucket` eb
using [{"id":"id1001"},
	   {"id":"id1002"},
	   {"id":"id1003"}] source
on eb.id = source.id
when matched then delete 
	where eb.designation is missing
returning meta(eb).id, eb.name;

select meta().id, *
from `EmployeeBucket`;

## Multiple matches
merge into `EmployeeBucket` eb
using [{"designation": "Manager"}] source
on contains(eb.designation, source.designation)
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
	where eb.curSalary < 10000
when matched then delete 
    where eb.curSalary >= 10000
when not matched then insert
	(key UUID(),
          VALUE {"id": "id1004",
				 "name": "Darnell Williams",
				 "designation": "Engineering Manager",
				 "oldSalary": 0,
				 "curSalary": 10000} )
returning meta(eb).id, eb.name;

## The when clauses are evaluated in order
## Re-run the same query
merge into `EmployeeBucket` eb
using [{"designation": "Manager"}] source
on contains(eb.designation, source.designation)
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
	where eb.curSalary < 10000
when matched then delete 
    where eb.curSalary >= 10000
when not matched then insert
	(key UUID(),
          VALUE {"id": "id1004",
				 "name": "Darnell Williams",
				 "designation": "Engineering Manager",
				 "oldSalary": 0,
				 "curSalary": 10000} )
returning meta(eb).id, eb.name;


## Run the same query for the third time
merge into `EmployeeBucket` eb
using [{"designation": "Manager"}] source
on contains(eb.designation, source.designation)
when matched then update 
	set eb.oldSalary = eb.curSalary, eb.curSalary = eb.curSalary + 500
	where eb.curSalary < 10000
when matched then delete 
    where eb.curSalary >= 10000
when not matched then insert
	(key UUID(),
          VALUE {"id": "id1004",
				 "name": "Darnell Williams",
				 "designation": "Engineering Manager",
				 "oldSalary": 0,
				 "curSalary": 10000} )
returning meta(eb).id, eb.name;


select * from `EmployeeBucket`;



##########	##########	##########	
##########		Flushing a bucket's data
##########	##########	##########

select * from `EmployeeBucket`;


///flush the bucket `EmployeeBucket`

#go to BUCKETS>>
#click on EmployeeBucket>>
## Choose Edit --> Advanced Bucket Settings
## Enable the box next to Flush 
## Click on the bucket again in the Buckets interface
#click FLUSH button and OK 
#so that all the documents present in EmployeeBucket will erase/delete but bucket wont get deleted(EmployeeBucket with 0 documents)




##########	##########	##########	
##########		Data Compaction in Couchbase
##########	##########	##########

## Navigate in the UI to Settings --> Auto-Compaction
## For auto-compaction, set fragmentation levels to 100% for both 
## database and view fragmentation
## Then save the changes

## Navigate to the Servers section in the Couchbase Web UI
## Get the data directory for your Coucbase setup and navigate to it in your shell

cd /Users/bvsrao/Library/Application\ Support/Couchbase/var/lib/couchbase/data

## Examine the contents of the directory
ls -n

## cd into the directory for travel-sample
cd travel-sample

## View the contents of the directory
ls

## Check the disk utilization of the files in the directory
du -s

## Head to the UI and run this Query
delete 
from `travel-sample` 
where type = "route";

## Navigate to the Buckets section and click on travel-sample
## The number of documents will have dropped to about 7k

## Run this from your shell in the travel-sample directory to calculate the disk utilization
## The value is still high
du -s

## IN the UI, head to buckets and select travel-sample
## Hit the compact button. This will take a few minutes to run
## After compaction is complete, check the disk space again
## This time the number will be lower
du -s


## Click the bucket in the UI and hit Edit
## See that the auto-compaction can be configured at bucket level
## You will need to check the box to override the default compaction



####################

## In the UI, go to Settings-->Auto Compaction
## Confirm that the fragmentation levels are still 100%
## Head out of the Auto Compaction settings

## Navigate to the shell
## View the aucoCompaction settings
## syntax, curl -u [admin]:[password] http://[localhost]:8091/settings/autoCompaction
curl -u Administrator:bvsrao \
http://127.0.0.1:8091/settings/autoCompaction

## Copy the JSON output and view it in a JSON Formatter like this one:
## https://www.freeformatter.com/json-formatter.html

## Set the auto-compaction at the server level
curl -i -X POST http://127.0.0.1:8091/controller/setAutoCompaction \
-u Administrator:bvsrao \
-d databaseFragmentationThreshold[percentage]=30 \
-d databaseFragmentationThreshold[size]=1073741824 \
-d viewFragmentationThreshold[percentage]=30 \
-d viewFragmentationThreshold[size]=1073741824 \
-d parallelDBAndViewCompaction=false

## Check the settings once more. View in the JSON Formatter
curl -u Administrator:bvsrao \
http://127.0.0.1:8091/settings/autoCompaction

## View the auto-compaction settings in the web UI




