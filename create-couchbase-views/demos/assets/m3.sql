#############################################
############################## Exporting and Backing up Views
#############################################

# Backup the views

# cd into the bin directory
cd /Applications/Couchbase\ Server.app/Contents/Resources/couchbase-core/bin/ 

./cbbackup http://127.0.0.1:8091 \
-u Administrator -p bvsrao \
~/backup \
-x design_doc_only=1 \
-b student-sample

## Open the backed up folder and show that the design docs are backed up
## open design_docs.json
## copy the design_docs and go to https://www.freeformatter.com/json-formatter.html
## View the results



#######

#############################################
############################## Exploring Features of the Map Function
#############################################


# go to views and select `travel-sample`
# create a view: _design/dev_travel_view and view_one
# click on Edit

# Click on 'Load Another Document' for 2 times

function (doc, meta) 
{
  emit(meta.id, null);
}

# in the results, as the limit is 6, click on next 6 data 
# click on Rest api link 
# give fullset= false -> this will give the results very fast compared to fullset= true
# in the UI, when you change from 'Development Time Subset' to 'Full Cluster Data Set' 
#     in the line, fullset= true is assigned. But we dont want that now.


#######

function (doc, meta) 
{
  emit(meta.id);
}

#######

function(doc, meta)
{
  emit(doc.type)
}

#######

function (doc, meta) 
{
  emit(meta.id, doc.type);
}

#######


#######

function (doc, meta) 
{
  if(doc.type == "airport")
	{
	    emit(doc.airportname, doc.geo);
  }
}

function (doc, meta) 
{
    if(doc.type == "airport")
    {
      emit(doc.airportname, doc.geo);
      emit(doc.faa, doc.city);
    }
}
## You may need to navigate to the next pages to view both emits
 
#######

function(doc,meta) 
{
  if(doc.type == "airport" && meta.type == "json")
  {
    emit(meta.id, doc.airportname);
  }
}


#######

function (doc, meta) 
{
  if(doc.type=="airport")
  {
    emit(doc.type, doc.faa);
  }
  else if (doc.type=="hotel")
  {
    emit(doc.type, doc.name);
  }
  else
  {
    emit(doc.type, null)
  }
}

## You may need to navigate over a few pages to view each of the 3 types


#############################################
############################## Generating Composite Keys and Values
#############################################

####### 

function (doc, meta) 
{
  if(doc.type == "airport" && doc.country == "France")
  {
    emit(doc.airportname, doc.geo, doc.city);
  }
}

function (doc, meta) 
{
  if(doc.type == "airport" && doc.country == "France")
  {
    emit(doc.airportname, [doc.geo, doc.city]);
  }
}

function (doc, meta) 
{
  if(doc.type == "airport" && doc.country == "France")
  {
    emit(doc.airportname, [{"location":doc.geo, 
                            "city":doc.city}]);
  }
}



#######

function ( doc, meta )
    {
      if((doc.type == "hotel")||( doc.type=="airport")) 
    	 {
    	   emit(doc.type, doc.name );
    	 }
    }

######


function (doc, meta) 
{
  if(meta.id=="airport_3637")
	  {
	   emit(doc.type,[{"airport_name": doc.airportname, 
	  				         "faa":doc.faa, 
	  				         "aiport_Id":doc.id}]);
    }
}

#######

function (doc, meta) 
{
  if(meta.id=="airport_3637")
    {
     emit(doc.type,[{"airport_name": doc.airportname.toUpperCase(), 
                     "faa":doc.faa.toLowerCase(), 
                     "aiport_Id":doc.id}]);
    }
}


########


function (doc, meta) 
{
  if(doc.type=="hotel")
 	  {
	    emit(doc.name, doc.reviews);
    }
}

#######

function (doc, meta) 
{
  if(doc.type=="hotel")
    {
      emit(doc.name, doc.reviews[0].ratings);
    }
}


# value is null

#######

function (doc, meta) 
{
  if(doc.reviews)
	{
 	  for(i=0; i <doc.reviews.length; i++)
	  {
	    emit(doc.name, doc.reviews[i].ratings);
    }
  }
}

#######

function (doc, meta) 
{
  if(doc.reviews)
  {
    for(i=0; i <doc.reviews.length; i++)
    {
      emit(doc.name, doc.reviews[i].ratings.Cleanliness);
    }
  }
}



# using switch and case

function(doc, meta) {

  switch(doc.type){

    case "hotel":
      emit([meta.id]);
      break;

    case "airline":
      if (doc.country){
        emit([doc.country, meta.id]);
      }
      break;
  }
}
