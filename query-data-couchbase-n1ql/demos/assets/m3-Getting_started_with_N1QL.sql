
##            
##				MODULE 3
##    Getting_started_with_N1QL



###########  Quering_data_using_SELECT_FROM_and_WHERE_statments

# go to query
# Under Data Insights we get to know the details of each bucket
# Under gamesim-sample, show that it has 3 different jsonTypes and click on Indexes (only one present) 


SELECT 5 ;

SELECT "Hello World" ;

#####

SELECT ["Hello World", 1, 5.5, 'abc']



#####

SELECT "Welcome to Couchbase" AS Greeting

#####

SELECT * 
FROM `gamesim-sample`;

######

SELECT * 
FROM "gamesim-sample"; # error

SELECT * 
FROM gamesim-sample; # error


######

SELECT * 
FROM `gamesim-sample`
LIMIT 5;

######
# instead of writing query everytime just replace all, distinct, raw and element

SELECT jsonType 
FROM `gamesim-sample`; # note the execution time

######

SELECT ALL jsonType 
FROM `gamesim-sample`;

######

SELECT DISTINCT jsonType 
FROM `gamesim-sample`;

######

SELECT ELEMENT jsonType 
FROM `gamesim-sample`;

######

SELECT RAW jsonType 
FROM `gamesim-sample`;

######

SELECT DISTINCT RAW jsonType 
FROM `gamesim-sample`;

######

SELECT name, jsonType 
FROM `gamesim-sample`
LIMIT 10;

######

SELECT name, jsonType, uuid
FROM `gamesim-sample`
LIMIT 10;

######

SELECT name, jsonType, uuid as unique_id
FROM `gamesim-sample`
LIMIT 10;

######

SELECT gss.name, gss.jsonType, gss.uuid as unique_id
FROM `gamesim-sample` AS gss
LIMIT 10;

######

SELECT gss.name, gss.jsonType, gss.uuid as unique_id
FROM `gamesim-sample` AS gss
LIMIT 10;

######

SELECT META().id, *
FROM `gamesim-sample`;

######

SELECT META().id as docid, name, uuid
FROM `gamesim-sample`
LIMIT 5;

######

SELECT * 
FROM `gamesim-sample`
USE KEYS "Aaron0";


######

SELECT name, jsonType
FROM `gamesim-sample`
USE KEYS ["Aaron0", "Infinityblade_ed7da450-f6b2-41cd-a52f-2e3effca020c", "Joint-eater2"];

#######

SELECT * 
FROM `gamesim-sample`
WHERE name = "Aaron1";

#######

SELECT gss.name, gss.jsonType
FROM `gamesim-sample` gss
WHERE name = "Aaron1";

#######

SELECT DISTINCT name, jsonType 
FROM `gamesim-sample`
WHERE jsonType="player";

#######

SELECT ownerId, jsonType 
FROM `gamesim-sample`
WHERE jsonType="item"
ORDER BY ownerId;

######

SELECT name AS items_owned
FROM `gamesim-sample`
WHERE ownerId="Aaron0";


#######

SELECT * 
FROM `gamesim-sample`
WHERE jsonType="player" 
AND loggedIn=true;

######

SELECT name, experience, loggedIn 
FROM `gamesim-sample`
WHERE jsonType="player" 
AND loggedIn=false;

######

SELECT name, jsonType, hitpoints 
FROM `gamesim-sample`
WHERE jsonType="monster" 
AND hitpoints > 1000;

######

SELECT name, jsonType, hitpoints 
FROM `gamesim-sample`
WHERE jsonType="monster" 
AND (hitpoints > 4500 OR hitpoints < 100);

# click on Table, Tree, Plan, Plan Text and Advice just under the query editor
# Finally go back to JSON



###########   The CBQ Shell

# open up a shell window

# accessing bucket from command line
# https://docs.couchbase.com/server/current/tools/cbq-shell.html#cbq-shell-cmd-echo

# in the terminal navigate to 

$ cd /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin

$ ./cbq -h

$ ./cbq --script="select \* from \`gamesim-sample\` LIMIT 1"
## This will be an error 

$ ./cbq -u Administrator -p bvsrao -engine=http://127.0.0.1:8091/ 

# you can disconnect the server using:

cbq> \DISCONNECT ;

# and connect back using:

cbq> \CONNECT http://127.0.0.1:8091/ ;

cbq>
SELECT *
FROM `gamesim-sample`
LIMIT 3;

# press cmd+k to clear the screen

SELECT name, jsonType, hitpoints 
# Choose from the gamesim-sample bucket
FROM `gamesim-sample`
WHERE jsonType="monster" /* only interested 
in the monsters */
-- Filter based on this where clause
AND (hitpoints > 4900 OR hitpoints < 100);

## To understand the difference between the different kinds of commments
## https://docs.couchbase.com/server/current/tools/cbq-shell.html#cbq-shell-cmd-echo

cbq> \HELP;

cbq> \ALIAS;

cbq> \ALIAS gamesim-limit3 SELECT * FROM `gamesim-sample` LIMIT 3;

cbq> \ALIAS; # to show all the alias

cbq> \ECHO \\gamesim-limit3; # will display the query

cbq> \\gamesim-limit3; # to run that query

cbq> \ALIAS gamesim-monsters SELECT * FROM `gamesim-sample` WHERE jsonType="monster" ;

cbq> \ALIAS; # to show all the alias

cbq> \\gamesim-monsters;

cbq> \UNALIAS gamesim-monsters;

cbq> \ALIAS;

cbq> 
SELECT name, jsonType
FROM `gamesim-sample`
WHERE jsonType="monster"
LIMIT 1;

cbq> SELECT DISTINCT name, jsonType, hitpoints, experienceWhenKilled
> FROM `gamesim-sample`
> WHERE jsonType="monster" AND experienceWhenKilled >= 99;

cbq> \EXIT ; 

#or press Ctrl+D to exit

## Run this on the terminal (replace bvsrao with your user name)
cat  /Users/bvsrao/.cbq_history



###########  Inserting_Updating_and_Removing_documents 

# go to couchbase server > Query

SELECT * 
FROM `student-sample`; #Error

# go to Indexes and show that there is no index for student-sample

CREATE PRIMARY INDEX ON `student-sample`;

# go to Indexes show that index (#primary)

SELECT * 
FROM `student-sample`;

#######

# INSERT

INSERT INTO `student-sample` (KEY, VALUE) 
VALUES("id_02", { "name" : "Angela",
                  "location" : "Canada", 
                  "zip" : "P8N2Y6" } );

#######

SELECT * 
FROM `student-sample`;

####### will throw error as id_02 is already taken

INSERT INTO `student-sample` (KEY, VALUE) 
VALUES("id_02", { "name": {"first_name" : "Bill", "last_name" : "King" }, 
                  "address": {"street" :"Bunway Lane", 
                              "city" :"New York", 
                              "country" : "US", 
                              "zip":"10012"} } ) 
RETURNING *;

####### changing the id

INSERT INTO `student-sample` (KEY, VALUE) 
VALUES("id_03", { "name": {"first_name" : "Bill", "last_name" : "King" }, 
                  "address": {"street" :"Bunway Lane", 
                              "city" :"New York", 
                              "country" : "US", 
                              "zip":"10011"} } ) 
RETURNING *;

#######

INSERT INTO `student-sample` AS s (KEY, VALUE) 
VALUES("id_04", { "name" : { "first_name" : "Louis", "last_name" : "Seva" }, 
                  "grade" : "8", 
                  "marks" : [100, 40, 33, 45], 
                  "address": {"street" : "University Avenue",  
                              "city" : "Palo Alto", 
                              "country" : "US", 
                              "zip":"94305"} } ) 
RETURNING s.name, s.grade;


INSERT INTO `student-sample` AS s (KEY, VALUE) 
VALUES("id_05", { "name" : { "first_name" : "Charles", "last_name" : "Babbage" }, 
                  "grade" : "8", 
                  "marks" : [87, 45, 57, 99], 
                  "address": {"street" : "14th Street",  
                              "city" : "San Jose", 
                              "country" : "US", 
                              "zip":"95129"} } ) 
RETURNING s.name, s.grade, s.marks;


#######

SELECT * FROM `student-sample` # to display all the inserted values 

SELECT name.first_name, name.last_name
FROM `student-sample`

# Hover over the warning icon and show what it is, we will explain it

SELECT name.first_name, name.last_name, marks[0] AS math_scores
FROM `student-sample`

SELECT name.first_name, address.city, marks[1] AS english_scores
FROM `student-sample`


#######
# UPDATE

UPDATE `student-sample` 
SET grade = 10; 

# go to Documents and enable field editing mode and show that now all doc has grade field and it is set to 10
# click on Enable field editing to show this, makes things very clear

UPDATE `student-sample` 
SET location ="United States"
WHERE name = "Angela"
RETURNING name, location, META().id AS docid ;

#######

UPDATE `student-sample`
SET name.last_name ="Baker"
WHERE name.first_name = "Bill" 
RETURNING *, META().id AS docid;



#######

# DELETE

DELETE
FROM `student-sample`
USE KEYS "id_02";

######

SELECT META().id 
FROM `student-sample`;












