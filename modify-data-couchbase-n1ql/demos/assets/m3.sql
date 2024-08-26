
##########	##########	##########	
##########		Insert roles in Couchbase
##########	##########	########## 

# USING ROLES

#####

# in the terminal

./couchbase-cli user-manage \
--cluster http://127.0.0.1:8091 \
--username Administrator --password bvsrao \
--set \
--rbac-username viewonly \
--rbac-password bvsrao \
--rbac-name viewonly \
--roles ro_admin \
--auth-domain local

##### log out of the current user from server and log in with viewonly details

##### Go to buckets and show that we have those 2 buckets
##### show that we can't view or insert docs

## Even this simple query doesn't work
select * 
from `EmployeeBucket`;

## Hover over the yellow warning sign and it confirms that the user does not 
## have the required permissions

# read only

##### create a read only user

./couchbase-cli user-manage \
--cluster http://127.0.0.1:8091 \
--username Administrator --password bvsrao \
--set \
--rbac-username readonly \
--rbac-password bvsrao \
--rbac-name readonly \
--roles ro_admin,data_reader[*] \
--auth-domain local

##### log out of the current user from server and log in with readOnlyUser details

##### Go to buckets and show that we have those 2 buckets
##### we can see that those buckets doesnot have a Edit option
##### go to query and try to insert a doc

insert into `EmployeeBucket` (key,value)
values("emp1005",{"id":"id1005",
					   "name":"GeORge MiLLer",
					   "salary":9000,
					   "type":"Employee",
					   "projects":["UITest"]})
returning *,meta().id as docid; # not possible

## The user can't even run a select query
select * 
from `EmployeeBucket`;

# insert mode

./couchbase-cli user-manage \
--cluster http://127.0.0.1:8091 \
--username Administrator --password bvsrao \
--set \
--rbac-username insertonly \
--rbac-password bvsrao \
--rbac-name insertonly \
--roles query_insert[*] \
--auth-domain local

##### insert a document in EmployeeBucket
## This does not work due to the returning clause
insert into `EmployeeBucket` (key,value)
values("emp1005",{"id":"id1005",
					   "name":"GeORge MiLLer",
					   "salary":9000,
					   "type":"Employee",
					   "projects":["UITest"]})
returning *,meta().id as docid;

## Re-run but without the returning clause - now it works!
insert into `EmployeeBucket` (key,value)
values("emp1005",{"id":"id1005",
					   "name":"GeORge MiLLer",
					   "salary":9000,
					   "type":"Employee",
					   "projects":["UITest"]});

#### 

##### insert a document in travel-sample

insert into `travel-sample` (key,value)
values("airline_11",{"callsign":"FLYSTAR",
					 "country":"Montenegro",
					 "iata":"B1",
					 "id":"11",
					 "name":"FlyStar",
					 "type":"airline"
					});

##### try using a select clause

select * from `travel-sample`
limit 1;

##### it throws error

# insert mode for specified bucket

./couchbase-cli user-manage \
--cluster http://127.0.0.1:8091 \
--username Administrator --password bvsrao \
--set \
--rbac-username insertonly \
--rbac-password bvsrao \
--rbac-name insertonly \
--roles query_insert[EmployeeBucket] \
--auth-domain local

##### go to buckets, we see that there is an edit option only for the EmployeeBucket 

##### insert a document in EmployeeBucket

insert into `EmployeeBucket` (key,value)
values("emp1006",{"id":"id1006",
					   "name":"Sam",
					   "designation":"UX Engineer",
					   "type":"Employee",
					   "projects":["HomePage","Search"]
				  });

##### insert a document in travel-sample

insert into `travel-sample` (key,value)
values("airline_12",{"callsign":"REUNION",
					 "country":"France",
					 "iata":"B1",
					 "icao":"MLE",
					 "id":"11",
					 "name":"AirAustral",
					 "type":"airline"
					});

##### throws error

##### log out of this user and login with Admin user


##########	##########	##########	
##########		The ARRAY_INSERT function
##########	##########	##########

#now multiple project is in array and each project has its own value

select projects 
from `EmployeeBucket`;

##
# >>documents(left hand side)>>choose your bucket 'EmployeeBucket'>>limit==10>>offset,docid,where let it be null>>on spreadsheet mode>>retrieve docs
# >>now in projects column, each field contain single projects 


select name, 
array v for v in projects 
when v = "HomePage" end as project_details 
from `EmployeeBucket`;

-----------
#4.) array_insert keyword

select name, projects
from `EmployeeBucket` 
use keys "emp1005";


select name, array_insert(projects, 1, "Build") AS updated_projects
from `EmployeeBucket`
use keys "emp1005";

## array_insert merely affects what is projected in the results
## The underlying data is not modified
select name, projects
from `EmployeeBucket` 
use keys "emp1005";

## Inserting the project at the start of the array
select name, array_insert(projects, 0, "Build") AS updated_projects
from `EmployeeBucket`
use keys ["emp1005", "emp1006"];

#-------------
#array_insert on travel-sample

select name, city, public_likes
from `travel-sample`
where type="hotel"
and pets_ok=true 
and free_parking= true
order by city, name;

#array element inserted in pos 2

select name, city, 
	   array_insert(public_likes, 2, "John Walker") AS new_publikes
from `travel-sample`
where type="hotel"
and pets_ok=true 
and free_parking= true
order by city, name;

------------------
##########	##########	##########	
##########		Adding multiple related documents
##########	##########	##########

insert into `EmployeeBucket` (key,value)
values("per1001",{"id":"id001",
				  "first_name":"Chloe",
				  "last_name":"Smith",
				  "type":"Personal",
				  "city":"Los Angeles",
				  "passport_no":"ABC191919"});

#adding other personal 5 documents

insert into `EmployeeBucket` (key,value)
values("per1002",{"id":"id1002",
				  "first_name":"Emily",
				  "last_name":"Armstrong",
				  "type":"Personal",
				  "city":"Chicago",
				  "passport_no":"MNO654321"}),

values("per1003",{"id":"id1003",
				  "first_name":"Emma",
				  "last_name":"Atkinson",
				  "type":"Personal",
				  "city":"New York",
				  "passport_no":"XYZ654322"}),

values("per1004",{"id":"id1004",
				  "first_name":"Ivo",
				  "last_name":"Buletov",
				  "type":"Personal",
				  "city":"Chicago",
				  "passport_no":"MNO655555"}),

values("per1005",{"id":"id1005",
				  "first_name":"George",
				  "last_name":"Miller",
				  "type":"Personal",
				  "city":"San Jose",
				  "passport_no":"XYZ777777"}),

values("per1006",{"id":"id1006",
				  "first_name":"Sam",
				  "type":"Personal",
				  "city":"San Jose"})

returning first_name, type, meta().id as docid;



select * 
from `EmployeeBucket` 
where id="id1002";

#shows both personal and employee document with the id1002,in which both are linked

# displays its docid which holds id="1002"

select meta().id,* 
from `EmployeeBucket` 
where id= "id1002";





















