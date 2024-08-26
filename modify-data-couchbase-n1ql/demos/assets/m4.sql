
##########	##########	##########	
##########		Understanding_UPSERT_statements_in_N1QL 
##########	##########	##########

#difference between the UPSERT and INSERT

		#INSERT statement to insert one or more new documents into an existing Bucket
		#UPSERT statement helps to overwrite a document with the same key, in case it already exists.
		   # (if document is not present in bucket it create new document with mentioned id)


#////UPSERT STATEMENT///////]

## Behaves similarly to insert here
upsert into `EmployeeBucket` (key,value)
values("emp1007",{"id": "id1007",
				  "name": "Harry Morus",
				  "designation": "UI Designer",
				  "salary": 6500,
				  "type": "Employee",
				  "projects": ["UI Grid"]});


## The returning statement also applies here
upsert into `EmployeeBucket` (key,value)
values("emp1008",{"id": "id1008",
				  "name": "Vincent",
				  "designation": "Network Engineer",
				  "salary": 7500,
				  "type": "Employee"})
returning meta().id as docid, name, salary;

## Try to insert modified data
insert into `EmployeeBucket` (key,value)
values("emp1008",{"id": "id1008",
				  "name": "Vincent Wu",
				  "designation": "Network Engineer",
				  "salary": 8000,
				  "type": "Employee"})
returning meta().id as docid, name, salary;

## Just change the statement to use upsert rather than insert
upsert into `EmployeeBucket` (key,value)
values("emp1008",{"id": "id1008",
				  "name": "Vincent Wu",
				  "designation": "Network Engineer",
				  "salary": 8000,
				  "type": "Employee"})
returning meta().id as docid, name, salary;

select * 
from `EmployeeBucket` 
use keys "emp1008";


## Multiple values being upserted
upsert into `EmployeeBucket` (key,value)
values("emp1007",{"id": "id1007",
				  "name": "Harry Morus",
				  "salary": 7500,
				  "type": "Employee"
				 }),

values("emp1009",{"id" :"id1009",
				  "name": "Chris Gale",
				  "designation": "Content Developer",
				  "salary": 6300,
				  "type": "Employee"}),

values("per1009",{"id": "id1009",
				  "first_name": "Chris",
				  "last_name": "Gale",
				  "city": "Chicago",
				  "passport_no": "MNO567870",
				  "type": "Personal"})

returning meta().id;


select * 
from `EmployeeBucket` 
use keys ["emp1007", "emp1009", "per1009"];



##########	##########	##########	
##########		The UPDATE statement
##########	##########	##########


#introduction code

select * 
from `EmployeeBucket` 
use keys "emp1007";

## Update an existing field
update `EmployeeBucket` 
use keys "emp1007"
set name = "Henry Morus";

select * 
from `EmployeeBucket` 
use keys "emp1007";

## Add a new field
update `EmployeeBucket` 
use keys "emp1007"
set designation = "UI Designer";

select * 
from `EmployeeBucket` 
use keys "emp1007";

## The returning clause
update `EmployeeBucket` 
use keys "emp1007"
set salary = 8000
returning meta().id as docid, name, id;

## Using the where clause in an update statement
## First retrieve documents using the where clause
select * 
from `EmployeeBucket` 
where salary > 8000;

# Update those documents
update `EmployeeBucket` 
set grade = "A"
where salary > 8000
returning meta().id as id, name;

select * 
from `EmployeeBucket` 
where salary > 8000;

## Perform an update without any condition
update `EmployeeBucket` 
set workLocation = "USA";

## All documents are updated
select * 
from `EmployeeBucket`;

## Multiple conditions in the where clause
select * 
from `EmployeeBucket`
where grade = "A"
and ARRAY_LENGTH(projects) > 1;

## We can also reference the field itself while updating its value
update `EmployeeBucket` 
set salary = salary + 1000
where grade = "A"
and ARRAY_LENGTH(projects) > 1
returning meta().id as id, name, salary;


##########	##########	##########	
##########		Updates using N1QL functions
##########	##########	##########

# updating document with the help of functions
select INITCAP(name)  
from `EmployeeBucket` 
where name = "GeORge MiLLer";

update `EmployeeBucket` 
set name = INITCAP(name)  
where name = "GeORge MiLLer" 
returning meta().id as docid, id, name;

#IS MISSING
select * 
from `EmployeeBucket` 
where designation is missing 
and type="Employee";

#GEORGE MILLER is missing a designation field

update `EmployeeBucket` 
set designation = "Android Developer" 
where designation is missing 
and type = "Employee"
returning name, designation;

# without position

## Use of the REPLACE function
select name, designation
from `EmployeeBucket` 
where type = "Employee"
and designation like "%Engineer";

## Apply it to the designation
select name, 
       replace(designation, "Engineer", "Analyst") as modTitle
from `EmployeeBucket` 
where type = "Employee"
and designation like "%Engineer";

## The replace function only modifies the query results
## The underlying data is unaffected
select name, designation
from `EmployeeBucket` 
where type = "Employee"
and designation like "%Engineer";

update `EmployeeBucket` 
set designation = replace(designation, "Engineer", "Analyst")
where type = "Employee"
returning name, designation;

select name, designation
from `EmployeeBucket` 
where type = "Employee"
and designation like "%Engineer";



# >>array update 

# adding a value to the project (array) at the end

select * 
from `EmployeeBucket` 
where type = "Employee"
and ARRAY_LENGTH(projects) < 2;

select name, ARRAY_APPEND(projects, "StressTest")
from `EmployeeBucket` 
where type = "Employee"
and ARRAY_LENGTH(projects) < 2;

update `EmployeeBucket` 
set projects = ARRAY_APPEND(projects, "StressTest")
where type = "Employee"
and ARRAY_LENGTH(projects) < 2
returning name, projects;


##########	##########	##########	
##########		The LIMIT clause in an update query
##########	##########	##########

## 

## Find employees who don't have a project
select name, projects 
from `EmployeeBucket` 
where type = "Employee"
and projects is missing;

## Assign two more employees to the StressTest project
## Use the limit clause to get this to apply to exactly two documents
update `EmployeeBucket`
set projects = ["StressTest"]
where type = "Employee"
and projects is missing
limit 2
returning name, projects;

## Confirm that there are still folks who are missing a project
select name, projects 
from `EmployeeBucket` 
where type = "Employee"
and projects is missing;


------------------
## update for

select meta().id, name
from `EmployeeBucket`
where grade = "A"
and ARRAY_LENGTH(projects) > 1;

update `EmployeeBucket`
use keys "emp1003"
set workAddresses = [{"street": "401 5th Ave", "city": "New York"},
				     {"street": "20 Broad St", "city": "New York"}];

select *
from `EmployeeBucket`
use keys "emp1003";

update `EmployeeBucket`
use keys "emp1003"
set add.country = "USA" for add in workAddresses end
returning name, workAddresses;

select *
from `EmployeeBucket`
use keys "emp1003";


##########	##########	##########	
##########		Updating multiple fields
##########	##########	##########

select * 
from `EmployeeBucket`
use keys ["emp1003", "emp1004"];

update `EmployeeBucket`
use keys ["emp1003", "emp1004"]
set salary = salary + 500, bonus = 10000
returning name, salary, bonus;

select * 
from `EmployeeBucket`
use keys ["emp1003", "emp1004"];


##########	##########	##########	
##########		The UNSET clause in an update query
##########	##########	##########

#>>unset

 #unseting field and its value within particular doc 

select meta().id, name, salary, grade
from `EmployeeBucket`
where grade is not missing;

select *
from `EmployeeBucket` 
use keys "emp1005";

update `EmployeeBucket` 
unset grade
where grade is not missing
returning *;

select first_name, workLocation
from `EmployeeBucket` 
where type = "Personal";

update `EmployeeBucket` 
unset workLocation
where type = "Personal"
returning *;









