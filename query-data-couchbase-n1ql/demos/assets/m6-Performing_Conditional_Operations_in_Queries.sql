                              
##                              MODULE-5

##              Performing_Conditional_Operations_in_Queries



###########  Construct_objects_and_arrays_using_construction_operators

#Objects Construct 
#Objects contain name value members

SELECT { "bvsrao" : 1} AS info 

#######

SELECT  {
            "first_name" : "Bob",
            "last_name" : "Parker"
        }

SELECT  { 
          "name" : {
            "first_name" : "Bob",
            "last_name" : "Parker"
           }
        }
######

SELECT { "full_name": UPPER("Bob") ||" "|| UPPER("Parker") }

#######

SELECT  {
         "name" : {
              "first_name" : "Barry",
              "last_name" : "Flores"
              },
         "grade" : "8",
         "marks": {
               "Math" : 50,
               "Science" : 60,
               "History" : 78
              }
        }

SELECT  {
         "name" : {
              "first_name" : "Barry",
              "last_name" : "Flores"
              },
         "grade" : "8",
         "marks": [50, 60, 78]
        }

#######

SELECT  {

         "name" : {
              "first_name" : "Louis",
              "last_name" : "Seva"
              },
         "grade" : "9",
         "marks" : {
               "Math" : {"Internal" : 40, "External" : 10},
               "Science" : {"Internal" : 40, "External" : 10},
               "History" : {"Internal" : 40, "External" : 10}
            }
        }

# inserting

SELECT * FROM `student-sample`;


INSERT INTO `student-sample` (key, value)
 VALUES("id_10",
        {
         "name": {
              "first_name": "Barry",
              "last_name": "Flores"
             },
         "grade" : "8",
         "marks": [50, 60, 78]
        })

RETURNING grade, name ;

INSERT INTO `student-sample` (key, value)
 VALUES("id_11",
        {
         "name": {
              "first_name": "Ava",
              "last_name": "Lovelace"
             },
         "grade" : "8",
         "marks": [87, 23, 93]
        })

RETURNING name.first_name, name.last_name;

#Array construction


SELECT  {
           "name": {
                "first_name": "Steve",
                "last_name": "Parks"
                },
           "grade" : "8",
           "hobbies": ["Dance", "Music", "Sports"]
         }

########


SELECT  {
         "name": {
              "first_name": "Tony",
              "last_name": "Pearson"
              },
         "std" : "7",
         "marks": {
               "Math": [30, 40 , 50],
               "Science": [45, 75, 67]
          }    
        }

########

SELECT  {
         "name": {
                  "first_name": "Jack",
                  "last_name": "Gates"
                  },
         "grade" : "9",
         "hobbies": [
                      {"Dance": {"Experience": 2, "Level": 2}},
                      {"Music": {"Experience": 3, "Level": 1}},
                      {"Sports": {"Experience": 1, "Level": 2}}
                    ]     
        } 

# inserting


INSERT INTO `student-sample` (key, value)
VALUES("id_12",  {
          "name": {
            "first_name": "Steve",
            "last_name": "Parks"
          },
          "grade" : "8",
          "hobbies": ["Dance", "Music", "Sports"]
          }
      )

RETURNING name.first_name, hobbies[0];

INSERT INTO `student-sample` (key, value)
VALUES("id_13",  {
          "name": {
            "first_name": "Lauren",
            "last_name": "Dimon"
          },
          "grade" : "8",
          "hobbies": ["Dance"]
          }
      )

RETURNING name.first_name, hobbies[0];

INSERT INTO `student-sample` (key, value)
VALUES("id_14",  {
          "name": {
            "first_name": "Nina",
            "last_name": "Chen"
          },
          "grade" : "8",
          "hobbies": ["Music"]
          }
      )

RETURNING name.first_name, hobbies[0];

########

INSERT INTO `student-sample` (key, value)
 VALUES("id_15", {
           "name": {
                "first_name": "Emily",
                "last_name": "Wharton"
                  },
           "grade" : "7",
           "hobbies": [
                       {"Dance": {"Experience": 2, "Level":2}},           
                       {"Music": {"Experience": 3, "Level":1}},
                       {"Sports": {"Experience": 1, "Level":2}}
                      ]     
                  }
                 )

RETURNING name.first_name, hobbies[1];


# Selecting fields in objects and arrays

SELECT * FROM `student-sample`;

########

SELECT first_name 
FROM `student-sample`;

########

SELECT name.first_name 
FROM `student-sample`;

SELECT name.first_name AS fname, name.last_name AS lname 
FROM `student-sample`;

########

SELECT marks 
FROM `student-sample`;

SELECT marks[0], marks[1]
FROM `student-sample`;

SELECT marks[0] as math, marks[1] as english
FROM `student-sample`;

SELECT RAW marks 
FROM `student-sample`;

#########

SELECT name, hobbies[1].Music.Experience, hobbies[1].Music.Level
FROM `student-sample`;

## Using array functions:

SELECT ARRAY_INSERT(hobbies, 2, "Gardening") AS new_hobbies
FROM `student-sample`
USE KEYS "id_12";

SELECT *
FROM `student-sample`
WHERE META().id = "id_12";

SELECT name, ARRAY_AVG(marks) AS avg_marks
FROM `student-sample`

SELECT name, hobbies
FROM `student-sample`
WHERE ARRAY_CONTAINS(hobbies, "Music")

SELECT name, hobbies
FROM `student-sample`
WHERE ARRAY_CONTAINS(hobbies, "Dance")

SELECT name, ARRAY_LENGTH(hobbies) AS num_hobbies
FROM `student-sample`

######## Using object functions

########
SELECT name, OBJECT_LENGTH(address), address
FROM `student-sample`;

SELECT name, OBJECT_LENGTH(address), address
FROM `student-sample`
WHERE OBJECT_LENGTH(address) > 0;

SELECT name, OBJECT_NAMES(address) AS address_fields, address
FROM `student-sample`
WHERE OBJECT_LENGTH(address) > 0;

SELECT name, OBJECT_VALUES(address) AS address_values, address
FROM `student-sample`
WHERE OBJECT_LENGTH(address) > 0;

SELECT name, OBJECT_PAIRS(address) AS address_pairs, address
FROM `student-sample`
WHERE OBJECT_LENGTH(address) > 0;

SELECT name, OBJECT_RENAME(address, "street", "lane") AS address_renamed, address
FROM `student-sample`
WHERE OBJECT_LENGTH(address) > 0;

#########

      
###########  Working_with_conditional_operators


# simple case expression

SELECT CASE (1 < 4) 
WHEN TRUE 
THEN "yes" END # yes

SELECT CASE (1 < 4) 
WHEN TRUE 
THEN "yes" END as one_less_than_four;

######

SELECT CASE (6 < 4) 
WHEN TRUE 
THEN "yes" END # null

SELECT CASE (6 < 4) 
WHEN TRUE 
THEN "yes" END as six_less_than_four;

######

SELECT CASE (2 < 3) 
WHEN TRUE 
THEN "yes" 
ELSE "no" END AS condition_satisfied

######
## This is a little confusing look at docs here: 
## https://docs.couchbase.com/server/current/n1ql/n1ql-language-reference/conditionalops.html


## Simple case expression

SELECT level,
       name, CASE (level >= 100) WHEN TRUE THEN "pro-player" ELSE "beginner" END AS tag
FROM `gamesim-sample`

SELECT level,
       name, CASE level 
             WHEN 2 THEN "two" 
             WHEN 3 THEN "three" 
             WHEN 150 THEN "one-fifty"
             ELSE "some other level"
             END AS tag
FROM `gamesim-sample`;

SELECT level,
       name,
       loggedIn,
       CASE TRUE WHEN loggedIn=TRUE THEN "active_player" ELSE "inactive_player" END AS tag
FROM `gamesim-sample`
WHERE jsonType="player";

SELECT level,
       name,
       loggedIn,
       CASE FALSE WHEN loggedIn THEN "active_player" ELSE "inactive_player" END AS tag
FROM `gamesim-sample`
WHERE jsonType="player";

######

SELECT name,
       jsonType,
       CASE TRUE WHEN experience IS NOT MISSING THEN "jsonType = Player" 
       ELSE "jsonType is either item or monster" END AS type_info
FROM `gamesim-sample`;

# searched case expression

SELECT CASE WHEN `experience` IS NOT MISSING THEN `experience` ELSE "no-experience" END AS experience
FROM `gamesim-sample`;


SELECT name,
       experience,
       loggedIn,
       CASE WHEN loggedIn=TRUE THEN "Logged In" ELSE "Not Logged In" END AS status
FROM `gamesim-sample`
WHERE jsonType="player";


SELECT name,
       jsonType,
       CASE WHEN `hitpoints` > 1000 THEN `hitpoints` ELSE "hitpoints below 1000" END AS hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster";

SELECT level,
       name, CASE WHEN (level>=150) THEN "pro-player" 
                  WHEN (level >= 100) THEN "intermediate"
                  ELSE "beginner" END AS tag
FROM `gamesim-sample`
WHERE jsonType = "player";


#######

SELECT name,
       level,
       CASE WHEN `level` > 100 AND `experience` > 10000 THEN "reached_higer_level" 
            WHEN `level` BETWEEN 50 AND 100 THEN "reached_medium_level" 
            ELSE "keep_playing" END AS level_status
FROM `gamesim-sample`
WHERE jsonType="player";



#######

# Conditional Functions 
#Conditional Functions for Unknowns

# IFMISSING

SELECT IFMISSING(missing, "Couchbase", 100); 

SELECT IFMISSING(null, "Couchbase", 100); #returns null

######


######

SELECT IFMISSING("Couchbase", missing),
       IFMISSING(missing, "Couchbase", 123),
       IFMISSING(null, "Couchbase", missing), 
       IFMISSING(missing, missing, missing) ;
      
######

SELECT name, IFMISSING(marks, null) AS marks
FROM `student-sample`;

SELECT IFMISSING(name, "No name given"), IFMISSING(marks, null) AS marks
FROM `student-sample`;

#######


# IFNULL

SELECT IFNULL(null, "Couchbase");

#######

 SELECT IFNULL(null, null), #returns output as null
        IFNULL(missing, missing, null),    # it will not give any output
        IFNULL("Couchbase", missing, null); #returns output as couchbase

#######

# IFMISSINGORNULL

SELECT IFMISSINGORNULL(null, missing, "Couchbase", 123)

#######

SELECT IFMISSINGORNULL(null, null, null),
       IFMISSINGORNULL(missing, null),
       IFMISSINGORNULL("Couchbase", missing, null);

#######

SELECT IFMISSINGORNULL(null, null, null),
       IFMISSINGORNULL(missing, null),
       IFMISSINGORNULL(missing, null, "Couchbase"),
       IFMISSINGORNULL("Couchbase", missing, null);

SELECT IFMISSINGORNULL(uuid, name) AS playerId
FROM `gamesim-sample`;



# Conditional Functions for Numbers
# IFNAN
## https://docs.couchbase.com/server/current/n1ql/n1ql-language-reference/condfunnum.html

SELECT IFNAN(9, "Couchbase")


########

SELECT IFNAN("Couchbase", 1),   #returns null because 1st number is not a number
       IFNAN(null, Missing, 2), #returns null because 1st number is not a number
       IFNAN(Missing, 3);    #1st digit is missing so it will display the 2nd digit
 
########

SELECT IFNAN(level, "no_level")
FROM `gamesim-sample`
WHERE jsonType="player";
## All levels are numbers
 
######## 


########

# IFINF

SELECT IFINF(1/0, 9);   #result is null

#######

SELECT IFINF(1, 1/0),  #returns output as 1  
       IFINF(null, 1/0, 2), #returns output as null
       IFINF(missing, 9); #output will not display anything

#######

# IFNANORINF

SELECT IFNANORINF(1, 1/0, "Couchbase"),  #returns output as 1
       IFNANORINF(null, 1/0, 2), #returns output as null
       IFNANORINF(missing,  9); #returns output as 9
