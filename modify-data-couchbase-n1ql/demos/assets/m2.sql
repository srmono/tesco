

##	Creating and Manipulating Data with N1QL

##########	##########	##########	
##########		Creating Documents using the INSERT Statement
##########	##########	##########	

# showing creation of bucket in CLI,Rest Api,couchbase web

# 1) CLI

#step 1: go to terminal
#step 2: couchbase bin

cd /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/

#step 3: using couchbase-cli and syntax creating bucket

$ ./couchbase-cli bucket-create \
-c 127.0.0.1 -u Administrator -p 123456 \
--bucket cliEmployeeBucket \
--bucket-type couchbase \
--bucket-ramsize 100

------------------------------------------------------------------------------------------

# (2) REST API

		
cd /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/

$ curl -X POST \
-u Administrator:123456 http://127.0.0.1:8091/pools/default/buckets \
-d name=restEmployeeBucket \
-d conflictResolutionType=lww  \
-d ramQuotaMB=100   \
-d bucketType=couchbase


-------------------------------------------------------------------------------------------

# (3) COUCHBASE WEB

# Go to couchbase web> choose "Buckets"(left handside) 
# add sample bucket - `travel-sample`

# top corner of right handside choose ADD "BUCKET">> "Add Data Bucket" dialog box will popup
#1) createing a bucket called 'EmployeeBucket'
#2) 100MB memory quota
#3) Choose 'Couchbase' Bucket type (normally couchbase type)
#4) in ADVANCE SETTING enable FLUSH (give option to erase all document in particular bucket)
#5) click ADD bucket

##### click on the bucket and open Documents and show no docs are present 

## Confirm that a query cannot be executed without a primary index

select * 
from `EmployeeBucket`;

#6) creating primary index for bucket  
#* in query > query editor

create primary index `EmployeeBucket-primary` on `EmployeeBucket`;

#8) after successfull execution of this statement

##### on the right hand side, within Bucket Insights 
## click on EmployeeBucket and show that the index is created 

select * 
from `EmployeeBucket`;


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


# INSERT ATOMIC AND BUlK VALUE

#1) atomic value
		#1. insert statement (inserting document 1 by one)
			#document id(emp1001)
			#employee id id1001
			#name,designation,salary,projects
			#"type":"Employee",
			
#1.

insert into `EmployeeBucket` (key,value)
values("emp1001",{"id":"id1001", 
				  "name":"Chloe Smith",
				  "designation":"Web Developer",
				  "salary":7500,
				  "projects":"Dashboard, HomePage",
				  "type":"Employee"
				});


select * 
from `EmployeeBucket`;

## Familiarize yourself with the travel-sample bucket

select * 
from `travel-sample`
limit 1;

select type, count(*) 
from `travel-sample`
group by type;

#inserting into travel-sample


insert into `travel-sample` (key,value)
values("airline_09",{"callsign":"REBORN",
					 "country":"Germany",
					 "iata":"B1",
					 "icao":"MLE",
					 "id":"09",
					 "name":"AirGermany",
					 "type":"airline"
					});


select * from `travel-sample` 
use keys"airline_09";

#2.

#document will insert and shows document id as result

insert into `EmployeeBucket` (key,value)
values("emp1002",{"id":"id1002",
				  "name":"Emily Armstrong",
				  "designation":"",
				  "salary":7000,
				  "type":"Employe"
				 })
returning meta().id as docid;

#3.
#document will insert and shows document fields and its docid as result

insert into `EmployeeBucket` (key,value)
values("emp1003",{"id":"id1003",
				  "name":"Emma Atkinson",
				  "designation":"Product Manager",
				  "salary":9000,
				  "projects":"Search, Index",
				  "type":"Employee"
       			 })
returning meta().id as docid, *;


insert into `EmployeeBucket` (key,value)
values("emp1004",{"id":"id1004",
				  "name":"Ivo Buletov",
				  "designation":"Release Engineer",
				  "salary":8500,
				  "projects":"FastDeploy",
				  "type":"Employee"
    			 })
returning meta().id as docid, name, designation;


## Inserting data for an already present key will throw an error
insert into `EmployeeBucket` (key,value)
values("emp1004",{"id":"id1004",
				  "name":"Ivo Buletov",
				  "designation":"Release Engineer",
				  "salary":9500,
				  "projects":"FastDeploy",
				  "type":"Employee"
    			 })
returning meta().id as docid, name, designation;

##########	##########	##########	
##########		Inserting using a SELECT statement
##########	##########	##########


select meta().id, name, designation
from `EmployeeBucket`
where name like "E%";

select "dup_" || meta().id as id, 
{"name": name, "designation": designation} as data
from `EmployeeBucket`
where name like "E%";

insert into `EmployeeBucket` (key id, value data)
select "dup_" || meta().id as id, 
{"name": name, "designation": designation} as data
from `EmployeeBucket`
where name like "E%";


insert into `EmployeeBucket` (key id, value data)
select uuid() as id, 
{"name": name, "designation": designation} as data
from `EmployeeBucket`
where designation like "%Engineer";





##########	##########	##########	
##########		Bulk Insert Queries
##########	##########	##########

create primary index `restEmployeeBucketIndex` on restEmployeeBucket;

##		

select * from `restEmployeeBucket`;
#no document in restEmployeeBucketIndex

insert into `restEmployeeBucket` (key,value)
values("emp1005",{"id":"id1005",
					   "name":"George Miller",
					   "salary":9000,
					   "type":"Employee",
					   "projects":["UITest"]})
returning meta().id as docid;


## Adding multiple documents in one query
insert into `restEmployeeBucket` (key,value)
values("emp1007",{"id": "id1007",
				  "name": "Harry Morus",
				  "designation": "UI Designer",
				  "salary": 6500,
				  "type": "Employee",
				  "projects": ["UI Grid"]}),

values("emp1008",{"id": "id1008",
				  "name": "Vincent",
				  "designation": "Network Engineer",
				  "salary": 7500,
				  "type": "Employee"})

returning meta().id as docid;

##

select * from `restEmployeeBucket`;

#step5: lets insert document from BenchEmployeeBucket to EmployeeBucket

insert into `restEmployeeBucket` (key id, value emp)
select meta().id as id, emp
from `EmployeeBucket` emp
where salary > 8000;


select * from `restEmployeeBucket`;


#array implementation (projects)

#showing multiple projects as single value

select projects 
from `EmployeeBucket`
where projects is valued;


delete from `EmployeeBucket`;

#delete all documents

#as you seen some employee worked on multiple projects but when inserted it all will take as single value, 
#to overcome this problem array is used 

# "EXPLAIN"provides information about the execution plan for the statement.
explain
insert into `EmployeeBucket` (key,value)
values("emp1001",{"id":"id1001", 
				  "name":"Chloe Smith",
				  "designation":"Web Developer",
				  "salary":7500,
				  "projects": ["Dashboard", "HomePage"],
				  "type":"Employee"
				 });

## explain doesn't insert data into the database
select * 
from `EmployeeBucket`;

## Insert the data now
insert into `EmployeeBucket` (key,value)
values("emp1001",{"id":"id1001", 
				  "name":"Chloe Smith",
				  "designation":"Web Developer",
				  "salary":7500,
				  "projects": ["Dashboard", "HomePage"],
				  "type":"Employee"
				 });

##### click on PLAN and show the plan and click on Plan Text

#using bulk insert


insert into `EmployeeBucket` (key,value)
values("emp1002",{"id":"id1002",
				  "name":"Emily Armstrong",
				  "designation":"",
				  "salary":7000,
				  "type":"Employee"
				 });

insert into `EmployeeBucket` (key,value)
values("emp1003",{"id":"id1003",
				  "name":"Emma Atkinson",
				  "designation":"Product Manager",
				  "salary":9000,
				  "projects":["Search", "Index"],
				  "type":"Employee"
       			 });


insert into `EmployeeBucket` (key,value)
values("emp1004",{"id":"id1004",
				  "name":"Ivo Buletov",
				  "designation":"Release Engineer",
				  "salary":8500,
				  "projects":["FastDeploy"],
				  "type":"Employee"
    			 });

