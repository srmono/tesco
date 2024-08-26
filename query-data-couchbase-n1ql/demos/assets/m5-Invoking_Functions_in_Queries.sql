
##							MODULE-4
               
##					Invoking_Functions_in_Queries

        
###########  Working_with_operators


# arithmetic operator

SELECT 10 + 5   

SELECT 10 + 5  
FROM system:dual

SELECT 10 - 5   

SELECT 10 * 5  

SELECT 10 % 4   

SELECT 10 / 3   

SELECT -(10)    

########

SELECT name.first_name,
       marks[0] AS math_scores,
       marks[1] AS eng_scores,
       marks[2] AS chemistry_scores,
       marks[3] AS physics_scores
FROM `student-sample`;

########

SELECT name.first_name, marks[1]*2 AS new_eng_score
FROM `student-sample`;

########

SELECT name.first_name, marks[0] + marks[1] + marks[2] + marks[3] AS total_score
FROM `student-sample`
WHERE name.first_name= "Louis";

########

SELECT name,
       hitpoints AS old_hitpoints,
       hitpoints*2 AS boosted_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
AND hitpoints BETWEEN 10 AND 50;

SELECT name,
       hitpoints AS old_hitpoints,
       hitpoints*2 AS boosted_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
AND hitpoints BETWEEN 10 AND 50
ORDER BY boosted_hitpoints DESC;

########

########

# COUNT 

SELECT COUNT(*) AS total_count
FROM `gamesim-sample`;


SELECT COUNT(*) AS total_count
FROM `gamesim-sample`
WHERE jsonType="player";

SELECT COUNT(*) AS total_count
FROM `gamesim-sample`
WHERE jsonType="item";

SELECT COUNT(*) AS total_count
FROM `gamesim-sample`
WHERE jsonType="monster";

########
SELECT COUNT(jsonType) AS num_jsonType 
FROM `gamesim-sample`;

SELECT COUNT(DISTINCT jsonType) AS distinct_jsonType 
FROM `gamesim-sample`;

SELECT COUNT(level) AS num_level
FROM `gamesim-sample`;

SELECT COUNT(DISTINCT level) AS distinct_level
FROM `gamesim-sample`;

########
SELECT jsonType,
       COUNT(*)
FROM `gamesim-sample`; ## Error

SELECT jsonType,
       COUNT(*)
FROM `gamesim-sample`
GROUP BY jsonType;

SELECT jsonType,
       COUNT(name)
FROM `gamesim-sample`
GROUP BY jsonType;

SELECT jsonType,
       COUNT(level)
FROM `gamesim-sample`
GROUP BY jsonType;



#########

SELECT COUNT(jsonType) AS type_count,
       COUNT(level) AS level_count
FROM `gamesim-sample`
## Such queries are confusing


SELECT COUNT(DISTINCT jsonType) AS type_count,
       COUNT(DISTINCT level) AS level_count
FROM `gamesim-sample`

# AVG and SUM
SELECT SUM(hitpoints) AS total_hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster";
## Does not make that much sense

SELECT AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster";   

########
## Lowercase also works

SELECT avg(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster";   

SELECT level, AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player";   ## Error

SELECT level, AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY level;

SELECT level, AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY level
ORDER BY level;

##########

#max

#Returns the maximum non-NULL, non-MISSING value 

SELECT MAX(hitpoints) 
FROM `gamesim-sample`
WHERE jsonType="player";

SELECT MAX(hitpoints) 
FROM `gamesim-sample`
WHERE jsonType="monster";


#######

SELECT MAX(name) 
FROM `gamesim-sample`
WHERE jsonType="item";

########

SELECT level, MAX(hitpoints) AS max_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY level;

SELECT level, MAX(hitpoints) AS max_hitpoints, COUNT(hitpoints) AS count_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY level;

#########

#5.  MIN

SELECT MIN(hitpoints) 
FROM `gamesim-sample`
WHERE jsonType="monster";

########

SELECT MIN(name) 
FROM `gamesim-sample`
WHERE jsonType="player";

########

SELECT level, MIN(hitpoints) AS min_hitpoints, 
       MAX(hitpoints) AS max_hitpoints, COUNT(hitpoints) AS count_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player" 
GROUP BY level;


#Aggregate functions

#ARRAY_AGG


SELECT DISTINCT level
FROM `gamesim-sample`; # there are null values

#######

SELECT ARRAY_AGG(level) 
FROM `gamesim-sample`; 

#######

SELECT ARRAY_AGG(DISTINCT level) 
FROM `gamesim-sample`; 

#######

SELECT ARRAY_AGG(jsonType)
FROM `gamesim-sample`; 
  
SELECT ARRAY_AGG(DISTINCT jsonType)
FROM `gamesim-sample`;

SELECT ARRAY_AGG(DISTINCT jsonType) AS types
FROM `gamesim-sample`;

#######

SELECT RAW ARRAY_AGG(DISTINCT jsonType)
FROM `gamesim-sample`;

########

SELECT ARRAY_AGG(DISTINCT ownerId) players_with_item
FROM `gamesim-sample`
WHERE jsonType="item";

########







#NUMBER FUNCTIONS

#1. ROUND

SELECT ROUND(4.4); #4

SELECT ROUND(4.6); #5



#########

SELECT ROUND(itemProbability) AS probability, name
from `gamesim-sample`
WHERE itemProbability IS NOT MISSING

#########

SELECT ROUND((itemProbability), 2) AS probability,
       name
FROM `gamesim-sample`
WHERE itemProbability IS NOT MISSING
LIMIT 10;



#########

#CEIL

select CEIL(6.3) #7

select CEIL(5.4) #6


#########

SELECT CEIL(itemProbability) 
from `gamesim-sample`
WHERE itemProbability IS NOT MISSING
LIMIT 10;

#FLOOR(expression)
#Largest integer not greater than the number.

select FLOOR(6.3) #6

select FLOOR(8.6) #8


SELECT FLOOR(itemProbability) 
from `gamesim-sample`
WHERE itemProbability IS NOT MISSING
LIMIT 10;

#######


#SQRT
#Returns square root

SELECT SQRT(9)

########

SELECT SQRT(625)

# String functions
######## 

SELECT name, level
FROM `gamesim-sample`
WHERE CONTAINS(name, "Br");

SELECT name
FROM `gamesim-sample`
WHERE jsonType="monster" AND CONTAINS(name, "u");

SELECT DISTINCT UPPER(name)
FROM `gamesim-sample`
WHERE jsonType="monster";

SELECT DISTINCT LOWER(name) AS lowercase_monster_name
FROM `gamesim-sample`
WHERE jsonType="monster";

SELECT REPLACE(name, "B", "ZZ")
FROM `gamesim-sample`
WHERE jsonType="monster";

# Type functions
##############



###########  Understanding_GROUP_BY_and_HAVING_clauses

SELECT DISTINCT jsonType
FROM `gamesim-sample`;

SELECT jsonType
FROM `gamesim-sample`
GROUP BY jsonType;

#######

SELECT DISTINCT experience
FROM `gamesim-sample`; # 592 docs

########

SELECT experience
FROM `gamesim-sample`
GROUP BY experience ;

SELECT experience
FROM `gamesim-sample`
GROUP BY experience
ORDER BY experience;

########

SELECT ownerId
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId;

#######

SELECT *
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId; # error


SELECT ownerId, name
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId; # error

SELECT ownerId, COUNT(*) records_count
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId
ORDER BY ownerId;

SELECT ownerId, COUNT(name) items_count
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId
ORDER BY ownerId; ## happens to be the same as number of records here

########

SELECT jsonType, COUNT(name) AS name_count
FROM `gamesim-sample`
WHERE jsonType="player"; ## Error


SELECT jsonType, COUNT(name) AS name_count
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY jsonType;

SELECT jsonType, COUNT(name) AS name_count
FROM `gamesim-sample`
GROUP BY jsonType;

#######

SELECT ownerId AS player, COUNT(name) AS number_of_items
FROM `gamesim-sample`
WHERE jsonType="item" AND CONTAINS(ownerId, "A")
GROUP BY ownerId;

SELECT ownerId AS player, COUNT(name) AS number_of_items
FROM `gamesim-sample`
WHERE jsonType="item" AND CONTAINS(ownerId, "A")
GROUP BY ownerId
ORDER BY number_of_items DESC;


#######
#HAVING clauses

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
GROUP BY level;

SELECT jsonType, level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
GROUP BY level; #Error

SELECT jsonType, level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
GROUP BY jsonType, level; ## Only players have these fields so add in the WHERE clause

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player" 
GROUP BY level
ORDER BY level;

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player" and level > 100
GROUP BY level
ORDER BY level;


SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY level
ORDER BY level
HAVING level > 100; # Error

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player"
GROUP BY level
HAVING level > 100 
ORDER BY level; # Seems to do the same thing as what is in the WHERE clause

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player" AND avg_experience > 12000
GROUP BY level
ORDER BY level; # Warning does not do what we expect, hover over the warning

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player" AND AVG(experience) > 12000
GROUP BY level
ORDER BY level; # This is an error

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player" 
GROUP BY level
HAVING avg_experience > 12000 # This does not work
ORDER BY level;

SELECT level, AVG(experience) AS avg_experience
FROM `gamesim-sample`
WHERE jsonType="player" 
GROUP BY level
HAVING AVG(experience) > 12000 # Works!
ORDER BY level;

SELECT level, AVG(experience) AS avg_experience, AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player" and level > 100
GROUP BY level
ORDER BY level;

SELECT level, AVG(experience) AS avg_experience, AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player" and level > 100
GROUP BY level
HAVING AVG(experience) > 18000
ORDER BY level;

SELECT level, AVG(experience) AS avg_experience, AVG(hitpoints) AS avg_hitpoints
FROM `gamesim-sample`
WHERE jsonType="player" and level > 100
GROUP BY level
HAVING AVG(experience) > 18000 and AVG(hitpoints) > 25000
ORDER BY level;

######
SELECT ownerId AS player, count(name) AS number_of_items
FROM `gamesim-sample`
GROUP BY ownerId;

SELECT ownerId AS player, count(name) AS number_of_items
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId
ORDER BY number_of_items DESC;


SELECT ownerId AS player, count(name) AS number_of_items
FROM `gamesim-sample`
WHERE jsonType="item"
GROUP BY ownerId
HAVING count(name) < 12
ORDER BY number_of_items DESC;






