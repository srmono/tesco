#############################################
############################## MapReduce Best Practices
#############################################


## To the Design document _design/dev_MapReduce, add a new view
## Call the view best_practices


# 1) Modifying existing views and Don’t include document IDs

function (doc, meta)
{ 
  emit(meta.id, doc.wallet_money);
}

## 

function (doc, meta)
{ 
  emit(doc.student_name, doc.wallet_money);
}

########

# 2) Check document fields


function (doc, meta)
{ 
  emit(doc.student_name, doc.sports_medals.gold);
}

## give _count as reduce function and run 
## We see it shows count=5
## remove the -count function 
## Now change the reduce fun to _stats and Show Results
## It throws error so change the code to:

function (doc, meta)
{ 
  if(doc.sports_medals.gold)
  {
    emit(doc.student_name, doc.sports_medals.gold);
  }
}

## We see now it shows only 4 doc

########

# 3) Include value data in views


# not recommended:

function (doc, meta) 
{
  emit(doc.student_id, doc.student_name);
}

##
# say we want to count the number of documents in the bucket, giving doc.student_name as value is unnessary

## give reduce function as _count
## it will show count 5
## replace the func as 

function (doc, meta) 
{
  emit(doc.student_id, null);
}

## this will also give count=5 -> best view

#########

# 4) Don’t include entire documents in view output


function (doc, meta) 
{
  emit(doc.student_name, doc);
}
 
 #so above query output will show entire bucket details, which is not a good practice

##

function (doc, meta) 
{
  emit(doc.student_id, [doc.js_score, doc.python_score]);
}


# 5) Use built-in Reduce functions

-- select _stats from the reduce function 

function (doc, meta) 
{ 
  emit(meta.id, doc.python_score);
}




#############################################
############################## Translating SQL to MapReduce
#############################################

## Add a new view for the travel-sample bucket
## To the Design document _design/travel_view, add a new view
## Call the view sql_to_mapreduce

# IN SQL

SELECT type, name FROM travel-table

# IN COUCHBASE

function (doc, meta) 
{
  emit(doc.type, doc.name);
}

#########

function (doc, meta) 
{
  emit([doc.type, doc.name], meta.id);
}


######################

# IN SQL

SELECT name, state FROM travel-table
WHERE type="hotel" 
AND state IS NOT NULL

# IN COUCHBASE

function (doc, meta) 
{
  if((doc.state != null) && (doc.type == "hotel"))           
  {
    emit(doc.name, doc.state);
  }
}


## launch Advanced REST client in chrome (install the app)
## paste the above link in the app and view it


##########

# IN SQL

SELECT type, city, count(city) 
FROM travel-table 
GROUP BY type, city


# IN COUCHBASE

function (doc, meta) 
{
  if (doc.city)
  {
    emit([doc.type, doc.city], null);
  }
}

# put _count as the reduc function

# REST API :
# http://127.0.0.1:8092/travel-sample/_design/dev_travel_view/_view/sql_to_mapreduce?full_set=true&group_level=2

## go to Advanced REST client and paste the REST api link


#######


# IN SQL

SELECT name FROM travel-table 
WHERE name IS NOT NULL
ORDER BY name DESC
 
# IN Couchbase

function (doc, meta) 
{
  if(doc.name)
  {
    emit(doc.name, null);
  }
}

# in the filter form-> click on the descending-> click on save 

# http://127.0.0.1:8092/travel-sample/_design/dev_travel_view/_view/sql_to_mapreduce?full_set=true&group_level=2

#returns all the document name filed, wherever name is present and it will display the document in descending order 
#
########

## Apply filters

# keep descending on and then give startkey and endkey
# filter we are giving start key as "Zenbu" and end key as "Yuet Lee"
# http://127.0.0.1:8092/travel-sample/_design/dev_travel_view/_view/sql_to_mapreduce?inclusive_end=true&full_set=true&descending=true&startkey="Zenbu"&endkey="Yuet Lee"
# ###############


