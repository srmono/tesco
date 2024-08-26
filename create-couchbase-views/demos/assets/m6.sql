
#############################################
############################## Filtering View Data
#############################################

-- go to views- > select travel-sample - > document name : filtering 
-- view name - > filtering_view -> edit

function(doc, meta)
{
  if(doc.name)
  {
    emit(doc.name, doc.type);
  }
}

## Click on Rest API link
## We see that by default the limit is 6, stale=false,connectiontimeout=60000 etc
## Change the limit 10
## Go to UI, click on Filter and click on 'descending' and show results
## Again click on REST API and show the result
## Go to Advanced REST client to view the result
## Now change the 'skip' to 189 


########

function(doc, meta)
{
  if(doc.type=="landmark")
  {  
    emit(doc.name, doc.city)
  }
}

## Click on Filter
## Give startkey= "Circle Bar" and endkey = "Citrus Club"
## http://127.0.0.1:8092/travel-sample/_design/dev_filtering/_view/filtering_view?full_set=true&startkey=%22Circle%20Bar%22&endkey=%22Citrus%20Club%22

## Click on Filter and uncheck the 'inclusive_end' and show results # 2 docs
## http://127.0.0.1:8092/travel-sample/_design/dev_filtering/_view/filtering_view?full_set=true&startkey=%22Circle%20Bar%22&endkey=%22Citrus%20Club%22&inclusive_end=false


####### Multiple rows emitted for a single document

function(doc, meta)
{
  if(doc.schedule)
  {   
    for (i=0; i < doc.schedule.length; i++)
    {
      emit(doc.schedule[i].flight, doc.airline);
    }
  }
}

## give key =  "BA879"
## give keys=["BA879", "BA959"]

#######

#############################################
############################## Configuring the Filters for a View
#############################################

-- go to viwes-> select student-sample -> document name : filtering 
-- view name - > filtering_view-> edit
#map ()->

function(doc, meta)
{
  emit(doc.student_name, doc.python_score);
}

#filtering

-- mention startkey as "David" 
-- click on save- > show result which names alphabetically comes after david

########

#map ()->

function(doc, meta)
{
  emit(doc.student_name, doc.python_score);
}


#filterning

# mention the keys as ["Alice","David"]

#output - > will returns python_score  of Alice and david

########

function(doc, meta)
{
  emit(doc.student_name, doc.python_score);
}

#filterning

-- mention the keys as ["Alice","David"] but give 
-- startkey_docid=id_01 and endkey_docid= id_03

## output will result only David here since there is an additional filter 
## for the document id

########

function(doc, meta)
{
  emit(doc.student_name, doc.python_score);
}

#reduce() -> select _sum

#filterning
-- mention startkey as "Alice" and endkey as "David" 
-- click on reduce function : true
#you can see the sum 

## Go back to the filter configuration
-- click on reduce function : false

#output will just result the filtering of start key and end key reduce function will not work 


#############################################
############################## Simulating Transactions in Views
#############################################

-- go to viwes-> select student-sample -> document name : transactions 
-- view name - > transact -> edit

# map() - >

function(doc, meta) 
{
  if (doc.student_name && doc.wallet_money)
  {
    emit(doc.student_name, doc.wallet_money);
  }
}

## Set the reduce() function to _sum
## Select group level of 1 in the filter congiguration

## Invoke the view. It displays the wallet balance for each student

#########

# now go to document - > add document - > id_06

{ 
  "student_name": "Andrew",
  "type": "stipend",
  "wallet_money": 2000
}


## Invoke the view again
## This time, Andrews wallet balance is much higher


########

## create one more document with an ID of id_07

{
  "fromacct" : "Alice",
  "toacct" : "Andrew",
  "type" : "transaction",
  "value" : 100
}

function(doc, meta)
{
  if(doc.type == "transaction")
  {
    emit(doc.fromacct, -doc.value);
    emit(doc.toacct, doc.value);
  }
  else
  {
    emit(doc.student_name, doc.wallet_money);
  }
}

## Invoke the view again
## This time, Andrew's wallet balance is higher by 100
## And Alice's balance is 100 lower



#############################################
############################## Publishing a Design View to Production
#############################################


## Select the most recently created "transactions" design document 
## Click on Publish
## The document and its view gets published to production

## From the Production Views section select the newly published view
## Click on Show
## If you click on Show Results, it calculates the aggregate sum of wallet_money

## Click on the filter configuration
## Set group level to 1
## Copy the URL - observe that the design document is "transactions" rather than "dev_transactions"
## Click on show results - the balance for each student is displayed

## REST API call
## http://127.0.0.1:8092/student-sample/_design/transactions/_view/transact?full_set=true&group_level=1


## Call the URL from the browser and from a REST client
