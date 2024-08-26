

#############################################
############################## Creating a Simple View
#############################################

## Download and install the latest version of Couchbase (6.5 Enterprise version) 

# Go to buckets and Add `travel-sample`
# create a new bucket `student-sample`

id_01

{
  "student_id": 101,
  "student_name": "Andrew",
  "java_score": 40,
  "python_score": 50,
  "js_score": 60,
  "fee_collected": 2200,
  "wallet_money": 780,
  "date_of_pay": "2012-07-30T23:58:22.193Z",
  "other_scores": [
                    {"arts": 10},
                    {"history": 12},
                    {"economics": 10}
                   ],
  "sports_medals": {
                    "gold": 2,
                    "bronze": 1
  },
  "dorm_fee":[300, 360, 380, 400, 350, 330]
}

id_02

{
  "student_id": 102,
  "student_name": "David",
  "java_score": 40,
  "python_score": 60,
  "js_score": 60,
  "fee_collected": 2200,
  "wallet_money": 820,
  "date_of_pay": "2012-07-20T20:58:22.193Z",
  "other_scores": [
                   {"arts": 10},
                   {"finance": 13},
                   {"economics": 13}
                  ],
  "sports_medals": {
                    "gold": 1,
                    "silver": 1,
                    "bronze": 1
                    },
  "dorm_fee":[340, 350, 300, 400, 300, 350]
}

id_03

{
  "student_id": 103,
  "student_name": "Amy",
  "java_score": 40,
  "python_score": 80,
  "js_score": 80,
  "fee_collected": 2200,
  "wallet_money": 805,
  "date_of_pay": "2012-07-30T23:58:22.193Z",
  "other_scores": [
                   {"arts": 15},
                   {"finance": 13},
                   {"psychology": 10}
                   ],
  "sports_medals": {
                   "bronze": 1
                  },
 "dorm_fee":[400, 350, 390, 400, 370, 350]
}

id_04

{
  "student_id": 104,
  "student_name": "Sarah",
  "java_score": 60,
  "python_score": 80,
  "js_score": 90,
  "fee_collected": 2200,
  "wallet_money": 770,
  "date_of_pay": "2012-07-25T03:58:22.193Z",
  "other_scores": [
                    {"arts": 12},
                    {"history": 13},
                    {"economics": 15}
                  ],
  "sports_medals": {
                   "gold": 1,
                   "silver": 3
                  },
  "dorm_fee":[300, 350, 350, 370, 300, 310]
}

id_05

{
  "student_id": 105,
  "student_name": "Alice",
  "java_score": 60,
  "python_score": 80,
  "js_score": 90,
  "fee_collected": 2200,
  "wallet_money": 800,
  "date_of_pay": "2012-07-28T16:58:22.193Z",
  "other_scores": [
                    {"arts": 15},
                    {"history": 12},
                    {"economics": 10}
                  ],
  "sports_medals": {
                    "gold": 3,
                    "bronze": 2
                 },
  "dorm_fee":[390, 350, 370, 400, 380, 350]
}

# Creating Views in UI

# how to start creating view:
# -> go back to views again 
# -> select the bucket on which you want to work (student-sample)
# -> click on Development views (from right-top most menu bar)
# -> click on "Add view"
# -> name Design_Document_Name as "first_couchbase_view" 
# -> an View name as "first_view" ->click on Save
# -> click on edit to write a function and to run

### Scroll up and down the Sample Document
### Click on Show Results
### Click on the Rest api link and show the results there also


# then change the function:
# just replace the null with doc
# avoid copying the whole code and try to replace the fields wherever possible
# always click on Save Changes before running the code


function (doc, meta) 
{
  emit(meta.id,doc);
}

#######

function (doc, meta) 
{
  emit(meta.id, doc.student_name);
}

#######

function (doc, meta) 
{
  emit(doc.student_name, doc.java_score);
}

#######

#############################################
############################## Using the REST API to invoke a View
#############################################

## Copy the URL generted for the view (right-click --> Copy Link Address)
## Paste it in a browser's address bar 
## You may be prompted for user credentials - enter those of your Couchbase user
## The output of the map view should be visible


#can view the views result using rest API 

curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_first_couchbase_view/_view/first_view

# go to UI and change the map()->

function (doc, meta) 
{
  emit(doc.student_name, doc.python_score);
}


# save changes and show results

curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_couchbase_view/_view/first_view


##

curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_first_couchbase_view/_view/first_view?limit=2

##

curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_first_couchbase_view/_view/first_view?limit=4





#############################################
############################## Managing Views using the REST API
#############################################

# Creating Design Docs via Rest API

# creating a new doc

curl -X PUT \
-H "Content-Type: application/json" http://Administrator:bvsrao@127.0.0.1:8092/student-sample/_design/dev_rest_view \
-d '{"views" : {"restapi_view" : {"map" : "function (doc, meta) {emit(meta.id, doc);}"}}}'

# go to UI and show that view is created 
# click on Edit and click on Show Results 

# Invoke the view using the REST API
curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_rest_view/_view/restapi_view

##

# viewing a Design Doc

curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_first_couchbase_view

##

curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_rest_view


# updating a view
# In this case, a different name is assigned to the view
curl -X PUT \
-H "Content-Type: application/json" http://Administrator:bvsrao@127.0.0.1:8092/student-sample/_design/dev_rest_view \
-d '{"views" : {"restapi_updated_view" : {"map" : "function (doc, meta) {emit(doc.student_name, doc.wallet_money);}"}}}'

# Invoke the view using the REST API
curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_rest_view/_view/restapi_updated_view

## Modify the full view, using the same view name
## In this case, just the value returned is modified 
curl -X PUT \
-H "Content-Type: application/json" http://Administrator:bvsrao@127.0.0.1:8092/student-sample/_design/dev_rest_view \
-d '{"views" : {"restapi_updated_view" : {"map" : "function (doc, meta) {emit(doc.student_name, doc.fee_collected);}"}}}'

## Invoke the view and confirm the modificatoin has taken effect
curl -X GET \
-u Administrator:bvsrao \
http://127.0.0.1:8092/student-sample/_design/dev_rest_view/_view/restapi_updated_view

# go to UI and show that view is created 
# click on Edit and click on Show Results 


# Deleting Design Docs via Rest API

curl -v -X DELETE \
http://Administrator:bvsrao@127.0.0.1:8092/student-sample/_design/dev_rest_view

# go to UI and show that view is deleted 











