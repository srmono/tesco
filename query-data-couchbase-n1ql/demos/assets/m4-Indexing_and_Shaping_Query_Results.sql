						

##						MODULE-4
##			Indexing_and_Shaping_Query_Results


###########  System Information And Document Metadata

## https://docs.couchbase.com/server/current/n1ql/n1ql-intro/sysinfo.html

SELECT * 
FROM system:datastores

SELECT * 
FROM system:namespaces

SELECT * 
FROM system:keyspaces;

#######

SELECT *
FROM system:keyspaces
WHERE id= "gamesim-sample";

#######

SELECT *
FROM system:keyspaces
WHERE id= "student-sample";

SELECT *
FROM system:indexes;

#######

SELECT *
FROM system:indexes
WHERE name="#primary";

#######

SELECT *
FROM system:indexes
WHERE is_primary=true;

#######

SELECT *
FROM system:indexes
WHERE keyspace_id="gamesim-sample";

#######

SELECT *
FROM system:active_requests;



#######

SELECT 10 * 3 FROM system:dual

SELECT 10 * 3, "Simple multiplication" FROM system:dual

#######
## https://docs.couchbase.com/server/current/n1ql/n1ql-language-reference/indexing-meta-info.html

SELECT META().id
FROM `gamesim-sample`

SELECT META().id, META().cas, META().expiration, META().type
FROM `gamesim-sample`

SELECT META().id, META().expiration
FROM `gamesim-sample`
WHERE META().expiration != 0

SELECT META().id, META().expiration
FROM `gamesim-sample`
WHERE META().expiration == 0




###########  Creating Indexes Using the With Clause


CREATE INDEX `gamesim-sample-index1` ON `gamesim-sample`(jsonType);

#######

SELECT *
FROM system:indexes
WHERE name="gamesim-sample-index1";

#######

CREATE INDEX `gamesim-sample-index2` ON `gamesim-sample`(jsonType) USING GSI;

######


SELECT *
FROM system:indexes
WHERE keyspace_id="gamesim-sample";

######

CREATE INDEX idx_gamesim1 ON `gamesim-sample`(name)
WHERE jsonType="player";

######

CREATE INDEX idx_gamesim2
ON `gamesim-sample`(name, itemProbability)
WHERE jsonType="monster"

#######

CREATE INDEX idx_gamesim3
ON `gamesim-sample`(name, uuid, ownerId)
WHERE jsonType="item"
AND hitpoints > 1000;

#######

SELECT RAW name
FROM system:indexes
WHERE keyspace_id = 'gamesim-sample';

#######

CREATE INDEX `gamesim-sample-index3` ON `gamesim-sample`(jsonType) USING GSI 
WITH {"defer_build":TRUE};

######

SELECT *
FROM system:indexes
WHERE name="gamesim-sample-index3"; # we can see the status is deferred

# go to Indexes and show that the status of "gamesim-sample-index3" is 'deferred' and not 'ready'

CREATE INDEX `gamesim-sample-index4` ON `gamesim-sample`(jsonType) USING GSI 
WITH {"defer_build":FALSE};

######

SELECT *
FROM system:indexes
WHERE name="gamesim-sample-index4"; 

######
# status can be changed to online:

BUILD INDEX ON `gamesim-sample`("gamesim-sample-index3") USING GSI; 

######

SELECT *
FROM system:indexes
WHERE name="gamesim-sample-index3"; # now the status is online

######

CREATE INDEX `gamesim-sample-index5` ON `gamesim-sample`(uuid)
WHERE experience > 1000 USING GSI 
WITH {"nodes": ["127.0.0.1:8091"]};

# Deleting index:

DROP INDEX`gamesim-sample` .idx_gamesim1

# go to Indexes show that idx_gamesim1 is gone and click on idx_gamesim2 and drop it



###########  Shaping_Query_results

# DISTINCT and RAW 


######

SELECT ownerId 
FROM `gamesim-sample`
WHERE jsonType="item"; # 405 docs

######

SELECT DISTINCT ownerId 
FROM `gamesim-sample`
WHERE jsonType="item"; # 47 docs

######
SELECT AVG(hitpoints)
FROM `gamesim-sample` 
WHERE jsonType = "player";

## Just add RAW

SELECT RAW AVG(hitpoints)
FROM `gamesim-sample` 
WHERE jsonType = "player";

######

SELECT DISTINCT RAW ownerId 
FROM `gamesim-sample`
WHERE jsonType="item";

######

SELECT RAW DISTINCT ownerId 
FROM `gamesim-sample`
WHERE jsonType="item"; # error

######

SELECT level, hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
AND hitpoints < 15000; # 38 docs

######

SELECT DISTINCT level, hitpoints
FROM `gamesim-sample`
WHERE jsonType="player"
AND hitpoints < 15000; # 13 doc

######

SELECT ownerId, name, jsonType
FROM `gamesim-sample`
WHERE ownerId IS NOT NULL

######

SELECT DISTINCT RAW ownerId 
FROM (SELECT ownerId, name, jsonType
		FROM `gamesim-sample`
		WHERE ownerId IS NOT NULL) as g;

#######

# using ORDER BY 


SELECT name
FROM `gamesim-sample`
WHERE jsonType="player" ;

######
# same result as above

SELECT name 
FROM `gamesim-sample`
WHERE jsonType="player"
ORDER BY name ;

###### 
# same result as above

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
ORDER BY name ASC ;

######

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player" 
ORDER BY name DESC ;

SELECT name AS player_name
FROM `gamesim-sample`
WHERE jsonType="player" 
ORDER BY name DESC ;

SELECT name AS player_name
FROM `gamesim-sample`
WHERE jsonType="player" 
ORDER BY player_name DESC;

######

SELECT name, level, jsonType
FROM `gamesim-sample`
WHERE jsonType="player"
ORDER BY level ;

######

SELECT name,level,jsonType
FROM `gamesim-sample`
WHERE jsonType="player"
AND level>=50
ORDER BY level ;

## Show multiple players at level 156, their names are in any order
## Then add in the name below and scroll to level 156 again

SELECT name,level,jsonType
FROM `gamesim-sample`
WHERE jsonType="player"
AND level>=50
ORDER BY level, name;

## Then add in ASC and DESC and show level 156 again

SELECT name,level,jsonType
FROM `gamesim-sample`
WHERE jsonType="player"
AND level>=50
ORDER BY level ASC, name DESC;


## 

######
# priority order: MISSING, NULL (including JSON NULL), FALSE, TRUE, number, string, array, object
## Please scroll to the bottom to show loggedIn=false and loggedIn=true

SELECT name,jsonType,loggedIn
FROM `gamesim-sample`
ORDER BY loggedIn;

#######

SELECT name, level, jsonType, loggedIn
FROM `gamesim-sample`
WHERE jsonType="player"
AND loggedIn=TRUE
ORDER BY level ASC, name DESC;

#######

SELECT name,level,jsonType,loggedIn
FROM `gamesim-sample`
WHERE jsonType="player"
AND loggedIn=TRUE
ORDER BY name DESC, level ASC;




###########  Paginating_results_with_limit_and_offset_keywords


# LIMIT 
SELECT name
FROM `gamesim-sample`
WHERE jsonType="player";

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
LIMIT 5;

#######

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
LIMIT (20/5);

#######

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
OFFSET 5;

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
OFFSET 76;

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
LIMIT 7;

SELECT name
FROM `gamesim-sample`
WHERE jsonType="player"
LIMIT 2
OFFSET 5;

#######

SELECT name, hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster"
LIMIT 5
ORDER BY hitpoints; #syntax error

########

SELECT name, hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster"
ORDER BY hitpoints
LIMIT 5;

#########

SELECT name, hitpoints
FROM `gamesim-sample`
WHERE jsonType="monster"
ORDER BY hitpoints DESC
LIMIT 10;

########

SELECT name, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY hitpoints DESC
LIMIT 10
OFFSET 10;

#########
SELECT name, experienceWhenKilled, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY experienceWhenKilled, name DESC;

SELECT name, experienceWhenKilled, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY experienceWhenKilled, name DESC
OFFSET 98;

SELECT name, experienceWhenKilled, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY experienceWhenKilled, name DESC
LIMIT 7
OFFSET 95;

##### Pagination

SELECT name, experienceWhenKilled, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY name
OFFSET 0
LIMIT 5

SELECT name, experienceWhenKilled, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY name
OFFSET 5
LIMIT 5

SELECT name, experienceWhenKilled, hitpoints
FROM `gamesim-sample`
WHERE jsonType = "monster"
ORDER BY name
OFFSET 10
LIMIT 5


















