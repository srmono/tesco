#############################################
############################## Introducing Reduce Functions
#############################################


## create another view (named 'reduce_view') within travel_view (for travel-sample) 

# _count

function (doc, meta) 
{
  emit(meta.id);
}

# Click on Full Cluster Data Set to get the correct count

########

function (doc, meta) 
{
  if (doc.name)
  {
    emit(meta.id);
  }
}

# Click on Full Cluster Data Set to get the correct count

########

function (doc, meta) 
{
  if(doc.name==null)
  {
    emit(meta.id);
  }
}

#######


function (doc, meta) 
{
  if ((doc.airportname)||(doc.name))
  {
    emit(meta.id);
  }
} 

# Click on Full Cluster Data Set to get the correct count

########

function (doc, meta) 
{
  emit(doc.type, meta.id);
}

# click on Filter and give grouplevel = 1

# Rest APi --> 

########

function (doc, meta) 
{
  if (doc.city)
  {
    emit(doc.type, meta.id);
  }
}

########         

function (doc, meta) 
{
  if (doc.city)
  {
     emit([doc.type, doc.city], meta.id);
  }
}

# click on Filter and give grouplevel = 2

# Rest APi --> http://127.0.0.1:8092/travel-sample/_design/dev_dev_travel_view/_view/reduce_view?full_set=true&group_level=2

#reset the filter
#######



#######

#############################################
############################## Exploring the SUM function
#############################################

# go to views and select student-sample -> document MapReduce -> first_view
# Reduce function : _count

function(doc, meta) 
{
  if(doc.sports_medals.gold)
  {   
    emit(meta.id);
  }
}

#######

function(doc, meta) 
{
  if(doc.sports_medals.silver)
  {   
    emit(meta.id);
  }
}

#######

function(doc, meta) 
{
  if((doc.sports_medals.gold) || (doc.sports_medals.silver))
  {
    emit(meta.id);
  }
}

#######


# Reduce function : _sum
# select _sum from Reduce (right side of the domain)

function (doc, meta) 
{
  emit(meta.id, null);
}

# error    

# http://127.0.0.1:8092/student-sample/_design/dev_Reduce/_view/View_1?full_set=true
# output - > will returns error because _sum perform only on integer number

#######

function (doc, meta) 
{
  emit(meta.id, doc.fee_collected);
}

#######

function (doc, meta) 
{
  if(doc.sports_medals.gold)
  {
    emit(meta.id, doc.sports_medals.gold);
  }
}

#######

function (doc, meta) 
{ 
  if((doc.sports_medals.gold) && (doc.sports_medals.silver))
  {
    emit(meta.id, doc.sports_medals.gold);
  }
}

#######

function (doc, meta) 
{
  if(doc.other_scores)
  {
    emit(meta.id, doc.other_scores[0].arts);
  }
}

#######


#############################################
############################## Built-in Utility and Stats Functions
#############################################

# Stick with the student-sample bucket
# go to view -> click on add view under 
# design document MapReduce-> utility_function-> edit

# dateToArray(date)

# map() - >

function(doc, meta)
{
  emit(meta.id, dateToArray(doc.date_of_pay));
}

# http://127.0.0.1:8092/student-sample/_design/dev_MapReduce/_view/utility_function?full_set=true

#########

# sum(array)

function(doc, meta)
{
  emit(meta.id, sum(doc.dorm_fee));
}

##

# now put _sum in reduce function to see total fee collected for 6 students

function(doc, meta)
{
  emit(meta.id, sum(doc.dorm_fee));
}

########

function(doc, meta)
{
  if(doc.wallet_money >= 800) 
    {
      emit(meta.id, sum(doc.dorm_fee));
    }
}

########

# Reduce function : _stats

# select _stats from Reduce (right side of the domain)
# without _stats

function (doc, meta) 
{
  emit(meta.id, doc.python_score);
}

##
# put _status in the reduce

function (doc, meta) 
{
  emit(meta.id, doc.python_score);
}

########

function (doc, meta) 
{
  emit(meta.id, doc.fee_collected);
}

########



########

#############################################
############################## Re-writing the Built-in Reduce Functions
#############################################

### The reduce functions here may be better viewed in SublimeText or some IDE

## To the Design document _design/dev_MapReduce, add a new view
## Call the view redefine_reduce

# count () 

# map() function:

function(doc, meta)
{
  emit(meta.id, null);
}

# Reduce() function:

function(key, values, rereduce) 
{
  if (rereduce) 
  {
    var result = 0;

    for (var i = 0; i < values.length; i++) 
    {
      result += 1;
    } 

    return result;
  } 

  else 
  {
    return values.length;
  }
}

## This returns the count of 5

## Modify the reduce() function so that the "else" returns 2*values.length
function(key, values, rereduce) 
{
  if (rereduce) 
  {
    var result = 0;

    for (var i = 0; i < values.length; i++) 
    {
      result += 1;
    } 

    return result;
  } 

  else 
  {
    return 2 * values.length;
  }
}

## Now the count returned is 10 (with such a small data set, rereduce is false)



### Modify the map() function to emit the wallet_money
function(doc, meta)
{
  emit(meta.id, doc.wallet_money);
}

## The reduce() function
## Can re-define the _count function by limiting the count 
## to docs where the wallet_money is less than 800
function(key, values, rereduce) 
{
  var result = 0;

    for (var i = 0; i < values.length; i++) 
    {
      if(values[i] < 800)
      {
        result += 1;
      }
    } 

    return result;
}

## This returns a count of 2

## Redefine the function to compute the sum instead of the count
## result += 1 become result += values[i]
function(key, values, rereduce) 
{
  var result = 0;

    for (var i = 0; i < values.length; i++) 
    {
      if(values[i] < 800)
      {
        result += values[i];
      }
    } 

    return result;
}

## This returns the sum of wallet_money where the balance is less than 800

## Remove the if condition so that the full sum is calculated
function(key, values, rereduce) 
{
  var result = 0;

    for (var i = 0; i < values.length; i++) 
    {
      result += values[i];
    } 

    return result;
}

## Invoke the function from the browser
# http://127.0.0.1:8092/student-sample/_design/dev_MapReduce/_view/redefine_reduce?full_set=true

## Replace the reduce function with the built-in _sum function
## The output is the same as in the last version of the view


## A view to calculate average score

## The map() function
function (doc, meta) 
{
  emit(doc.student_id, doc.js_score);
}

# The reduce() function calculates the average score
function(key, values, rereduce) 
{
    return sum(values) / values.length;
}



## A view to calculate a weighted average score

## The map() function
function (doc, meta) 
{
  emit(doc.student_id, [doc.js_score, doc.python_score]);
}

# The reduce() function calculates the average score
function(key, values, rereduce) 
{
  var aggWeightedScore = 0;

  if(rereduce)
  {
    for (var i = 0; i < values.length; i++) 
    {
      var weightedScore = (2*values[i][0] + values[i][1]) / 3
      aggWeightedScore += weightedScore;
    } 

    return aggWeightedScore / values.length;
  }

  else 
  {
    for (var i = 0; i < values.length; i++) 
    {
      aggWeightedScore += 2*values[i][0] + values[i][1]
    }

    return (aggWeightedScore / 3) / values.length;
  }
    
}



















