#############################################
############################## Load Data into a Bucket
#############################################

##	To create a view

#	Create a new bucket called academic-data

## From the Query workbench, create a primary index
CREATE PRIMARY INDEX ON `academic-data`;

## Load data into the bucket
insert into `academic-data` (key, value)
values('1001', {'user_id': 1001,
       'gender' : 'M',
       'nationality' : 'Jordan',
       'parent_school_satisfaction': 'good',
       'topic': 'IT',
       'semester' : 'First',
       'absence_days' : 'Under-7',
       'test_score': 80});

insert into `academic-data`(key, value)
values('1002', {'user_id': 1002,
                'gender': 'F',
                'nationality': 'Mexico',
                'parent_school_satisfaction': 'good',
                'topic': 'History',
                'semester': 'First',
                'absence_days': 'Above-7',
                'test_score': 65}),
values('1003', {'user_id': 1003,
                'gender': 'M',
                'nationality': 'Canada',
                'parent_school_satisfaction': 'bad',
                'topic': 'History',
                'semester': 'First',
                'absence_days': 'Above-7',
                'test_score': 74}),
values('1004', {'user_id': 1004,
                'gender': 'M',
                'nationality': 'Lebanon',
                'parent_school_satisfaction': 'good',
                'topic': 'Math',
                'semester': 'First',
                'absence_days': 'Under-7',
                'test_score': 82}),
values('1005', {'user_id': 1005,
                'gender': 'M',
                'nationality': 'Egypt',
                'parent_school_satisfaction': 'good',
                'topic': 'IT',
                'semester': 'First',
                'absence_days': 'Under-7',
                'test_score': 91}),
values('1006', {'user_id': 1006,
                'gender': 'M',
                'nationality': 'US',
                'parent_school_satisfaction': 'bad',
                'topic': 'Math',
                'semester': 'First',
                'absence_days': 'above-7',
                'test_score': 78}),
values('1007', {'user_id': 1007,
                'gender': 'F',
                'nationality': 'US',
                'parent_school_satisfaction': 'good',
                'topic': 'Math',
                'semester': 'Second',
                'absence_days': 'Under-7',
                'test_score': 69}),
values('1008', {'user_id': 1008,
                'gender': 'M',
                'nationality': 'Venezuela',
                'parent_school_satisfaction': 'good',
                'topic': 'IT',
                'semester': 'Second',
                'absence_days': 'Above-7',
                'test_score': 64}),
values('1009', {'user_id': 1009,
                'gender': 'F',
                'nationality': 'Tunisia',
                'parent_school_satisfaction': 'bad',
                'topic': 'IT',
                'semester': 'First',
                'absence_days': 'Under-7',
                'test_score': 81}),
values('1010', {'user_id': 1010,
                'gender': 'M',
                'nationality': 'US',
                'parent_school_satisfaction': 'good',
                'topic': 'Physics',
                'semester': 'First',
                'absence_days': 'Under-7',
                'test_score': 83});

#	- Now show the documents

SELECT * FROM `academic-data`;

SELECT COUNT(*) FROM `academic-data`;


#############################################
############################## Creating and Invoking a View
#############################################

##  Create views in Couchbase

#	- Now go to views section of dashboard select academic-data bucket of dropdwon section
#	- and make sure you are on Development Views section and now click on ADD VIEW
#	- set your design document(ddoc) and view name (in my case ddoc name is academic_ddoc
#	- and view name is student_view) and click on save button.
#	- Now click on edit section of view.
#	- Here, we can see a sample document of academic-data and meta data as well.

##	Run Map fucntion
#   :-https://docs.couchbase.com/server/6.5/learn/views/views-writing-map.html

#	- First time without any changes click save and run map-reduce function.
#	- It gives key with id and value with null


#	- make some changes of View Index Code and then save and run

function (doc, meta) {
  emit(meta.id, doc.topic);
}


function (doc, meta) {
  emit(meta.id, [doc.semester, doc.topic]);
}

function (doc, meta) {
  emit(meta.id, [doc.semester, doc.topic, doc.nationality]);
}


## Bring up the shell and run this command to invoke the view
curl -X GET -u admin:bvsrao \
http://127.0.0.1:8092/academic-data/_design/dev_academic_ddoc/_view/student_view

## Set a limit argument
curl -X GET -u admin:bvsrao \
http://127.0.0.1:8092/academic-data/_design/dev_academic_ddoc/_view/student_view?limit=3


## Back to the map() function, set an if condition
function(doc, meta) {
    if (doc.absence_days == "Above-7") {
        emit(doc.user_id, [doc.semester, doc.topic]);
    }
}

function(doc, meta) {
    if (doc.absence_days == "Above-7" && doc.semester == "Second") {
        emit(doc.user_id, [doc.nationality, doc.topic]);
    }
}


#############################################
############################## The Reduce Function
#############################################

##  Write Map-Reduce function
#   :-https://docs.couchbase.com/server/6.5/learn/views/views-writing-reduce.html
#   :-https://docs.couchbase.com/server/6.5/learn/views/views-writing-count.html



#   Map function 
function(doc, meta) {
    emit(doc.topic);
}

#   Reduce function
_count


#   Map function
function(doc, meta) {
    if(doc.semester == 'First'){
    emit(doc.topic, doc.test_score);
    }
}

#   Reduce function

function(key, values, rereduce){
  return values;
}



## Modify the reduce to return the max of the test scores
function(key, values, rereduce){
  var max = 0;

    for (var i = 0; i < values.length; i++) 
    {
      max = max > values[i] ? max : values[i]
    } 

    return max;
}


## Make another modification to reduce() to return the average test score
function(key, values, rereduce) 
{
    return sum(values) / values.length;
}


## Invoke the view from the shell
curl -X GET -u admin:bvsrao \
http://127.0.0.1:8092/academic-data/_design/dev_academic_ddoc/_view/student_view


