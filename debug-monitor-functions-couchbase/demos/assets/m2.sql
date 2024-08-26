####################################################
####################################### Setting up the Cluster
####################################################

## create 3 buckets 'student-data'(source bucket),
##                  'stu-metadata'(metadata bucket)
##                  'stu-target'(target bucket, enable flushing)
##                        
 
##create primary index

CREATE PRIMARY INDEX idx_st on `student-data`;

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
        ),
VALUES ("stu_002", {
                      "id": 2,
                      "type" : "student",
                      "firstName": "Uli",
                      "lastName": "Schneider",
                      "gender": "Male",
                      "emailId" : "kevin@yahoo.com",
                      "degree" : "Masters",
                      "gpa" : 3.2,
                      "recruited" : true,
                      "company" : "Facebook",
                      "schoolName" : "Technische University Berlin" 
                  } 
        ),
VALUES ("stu_003", {
                      "id": 3,
                      "type" : "student",
                      "firstName": "Sandra",
                      "lastName": "Schmidt",
                      "gender": "Female",
                      "emailId" : "sandra@aol.com",
                      "degree" : "Bachelors",
                      "gpa" : 2.8,
                      "recruited" : true,
                      "company" : "SAP",
                      "schoolName" : "Technische University Berlin"
                    }
        );


SELECT meta().id, * FROM `student-data`;



####################################################
####################################### Defining Functions
####################################################


## From the Eventing Dashboard, create a new function called HighGPAStudentTransfer
## The source bucket is student-data
## The metadata bucket is stu-metadata
## Assign a bucket alias binding pointing to stu-target (read-write access)

## Enter this code for the function

function OnUpdate(doc, meta) {

    if(doc.gpa > 3){

        log('Copying info of student', meta.id, 'to target...');
        
        var target_doc = {};
        target_doc['name'] = doc.firstName + ' ' + doc.lastName;
        target_doc['email'] = doc.emailId;
        target_doc['employer'] = doc.company;

        target_bucket[meta.id] = target_doc;
        
        log('Student data copied to target bucket');

    }
}

## Save down the function
## Deploy it, and set the boundary to "Everything"
## Confirm from the function log and stu-target bucket that the transfer works

## From the Eventing Dashboard, create a new function called CascadeStudentDelete
## The source bucket is student-data
## The metadata bucket is stu-metadata
## Assign a bucket alias binding pointing to stu-target (read-write access)

function OnDelete(meta) {

    var id = meta.id;
    
    if (id) {

        DELETE FROM `stu-target` WHERE META().id = $id;

        log('Deleted student with id', meta.id, 'from the target.');
    }
}

## Once the function is deployed, test it out by deleting one record

## To run a delete query on the target though, a primary index is needed
CREATE PRIMARY INDEX idx_st_target on `stu-target`;

DELETE FROM `student-data`
WHERE id = 1;

## Confirm from the eventing log and stu-target bucket that the function
## has done its job