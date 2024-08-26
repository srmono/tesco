####################################################
####################################### Debugging Eventing Functions
####################################################

## From the Eventing Dashboard, create a new function called CopyHighGPAStudents
## The source bucket is student-data
## The metadata bucket is stu-metadata
## Set the number of workers to 6
## Assign a bucket alias binding pointing to stu-target (read-write access)

## 

function OnUpdate(doc, meta) {

    if(doc.gpa > 3){

        log('Copying info of student', meta.id, 'to target...');
        
        target_doc = createMiniDoc(doc);
        
        target_bucket[meta.id] = target_doc;
        
        log('Student data copied to target bucket');

    }
    
    
}

function createMiniDoc(doc){

    var mini_doc = {};
    mini_doc['name'] = doc.firstName + ' ' + doc.lastName;
    mini_doc['email'] = doc.emailId;
    mini_doc['employer'] = doc.company;
    mini_doc['modified'] = new Date()

    return mini_doc;

}

## Save
## Deploy the function
## Pull up the function logs and the target bucket
## It looks like the transfer did not go through


## Enable debugging from the Eventing Settings
## Navigate to the JavaScript - there is an error
## Hit Debug and explore the Step Into feature



## Undeploy the function and make this code modification

var target_doc = {};

## Redeploy and confirm that the function works
## The date stamp is rather long though, so we can change how it's generated
## Flush the stu-target bucket
## Enable debugging again
## Make a modification to the newly inserted document

INSERT INTO `student-data` (KEY, VALUE)
VALUES ("stu_001", {
                      "id": 1,
                      "type" : "student",
                      "firstName": "Angela",
                      "lastName": "Perez",
                      "gender": "Female",
                      "emailId" : "angela@hotmail.com",
                      "degree" : "Masters",
                      "gpa" : 3.5,
                      "recruited" : true,
                      "company" : "Google",
                      "schoolName" : "Stanford University"
                  } 
        );

## Explore the breakpoints, Resume, Step Out features





## Undeploy the function and add this line to the createMiniDoc function
.toISOString().split('T')[0];

## Continue debugging, and use this query to trigger the function

INSERT INTO `student-data` (KEY, VALUE)
VALUES ("stu_004", {
                      "id": 4,
                      "type" : "student",
                      "firstName": "Lori",
                      "lastName": "Gross",
                      "gender": "Female",
                      "emailId" : "lori@hotmail.com",
                      "degree" : "BTech",
                      "gpa" : 3.8,
                      "recruited" : false,
                      "schoolName" : "Curtin University"  
                    }
       );

## In the Watch pane, add this expression
target_doc.name.toUpperCase()

## Explore Step Over

## Debug one more time, and add this document to trigger the function
## id: stu_005
{
  "id": 5,
  "type" : "student",
  "firstName": "Edwin",
  "lastName": "Brown",
  "gender": "Male",
  "emailId" : "edwin@aol.com",
  "degree" : "MS",
  "gpa" : 3.2,
  "recruited" : true,
  "company" : "itgurukul",
  "schoolName" : "Harvard University"
}

## Explore the Step Out button while debugging



####################################################
####################################### Accessing Event Logs
####################################################



cd Library/Application\ Support/Couchbase/var/lib/couchbase/data/

ls -n

cd \@eventing/

ls -n

less -N <LogFileName>


## Head over to the Couchbase logs directory
cd ../../logs

## Track the eventing.log file
tail -f eventing.log

## Undeploy and redeploy each of the 3 functions with the following System Log levels:
##      - Info (default)
##      - Error
##      - Warning

## INFO level logs are the most common
## There are fewer Warning level logs than INFO logs
## Error logs are typically the rarest



####################################################
####################################### Error-handling with try-catch blocks
####################################################


## Modify the JavaScript for HighGPAStudentTransfer


function OnUpdate(doc, meta) {

    if(doc.gpa > 3){

        log('Copying info of student', meta.id, 'to target...');
        
        try{

            target_doc['name'] = doc.firstName + ' ' + doc.lastName;
            target_doc['email'] = doc.emailId;
            target_doc['employer'] = doc.company;

            target_bucket[meta.id] = target_doc;
            
            log('Student data copied to target bucket');
        }
        
        catch(e){
            log('Exception--->', e);
        }

    }
}


