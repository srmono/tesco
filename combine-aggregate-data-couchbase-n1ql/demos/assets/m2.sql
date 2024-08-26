										

####		Combine_and_Aggregate_Data_from_Couchbase_using_N1QL

##################################
############### Installing and Setting up Docker
##################################


# Installing single node Couchbase server:

# to create docker account navigate to : https://hub.docker.com/signup

# click on Get started with Docker Desktop > Download Docker Desktop for Mac
# once the download is complete move the docker to application and open it
# follow the setup-instruction (within terminal)

# 	Step2: 
$ git clone https://github.com/docker/doodle.git

# 	Step3: 
$ cd doodle/cheers2019 && docker build -t amrithahp/cheers2019 .

#	Step4: 
$ docker run -it --rm amrithahp/cheers2019

#	Step5: 
$ docker login && docker push amrithahp/cheers2019

# to install the couchbase container:
$ docker run -d --name db -p 8091-8096:8091-8096 -p 11210-11211:11210-11211 couchbase

# check the installation by:
$ docker logs db

# navitae to http://localhost:8091 in the browser 
# Setup new cluster (my-cluster)
# give default space

##################################
############### Loading Data into Couchbase
##################################

# add travel-sample 

# create new buckets:

ordersbucket:

order_10308
{
	"order_id" : 10308,
	"customer_id": 12,
	"order_date": "1996-09-18",
	"payment_method": "12_CC1",
	"contact": "555-1212",
	"order_items":["cap", "shorts","socks", "tshirt"]
}

order_10309
{
	"order_id" : 10309,
	"customer_id": 37,
	"order_date": "1996-09-19",
	"payment_method": "37_epay3",
	"order_items":["blazer","cap", "trousers","tshirt"]
}

order_10310
{
	"order_id" : 10310,
	"customer_id": 77,
	"order_date": "1996-09-20",
	"payment_method": "77_DC1",
	"order_items":["blazer", "shoes", "socks", "tshirt"]
}

order_10311
{
	"order_id" : 10311,
	"customer_id": 13,
	"order_date": "1996-09-21",
	"payment_method": "13_DC2",
	"order_items":["gloves", "shoes", "shorts", "socks"]
}

order_10312
{
	"order_id" : 10312,
	"customer_id": 13,
	"order_date": "1996-09-21",
	"payment_method": "13_epay1",
	"order_items":["sweater", "tshirt"]
}


customersbucket:

cust_11
{
	"customer_id" : 11,
	"customer_name": "Alfred Schmidt",
	"contact_name": "Maria Anders",
	"country": "Germany",
	"frequent_order": ["gloves","socks"],
	"payment_methods":["11_CC1","11_epay1"]
}

cust_12
{
	"customer_id" : 12,
	"customer_name": "Jonathon Mayer",
	"contact_name": "Jon Mayer",
	"country": "Austria",
	"frequent_order": ["cap","tshirt"],
	"payment_methods":["12_CC1","12_DC1"]
}


cust_13
{
	"customer_id" : 13,
	"customer_name": "Alison Murray",
	"contact_name": "Alison",
	"country": "UK",
	"frequent_order": ["gloves", "shoes", "shorts", "socks"],
	"payment_methods":["13_CC1","13_CC2", "13_epay1"]
}


##################################
############### Performing Simple JOIN Operations
##################################

# Joining documents by related values using the JOIN clause

# create index for new buckets:

CREATE PRIMARY INDEX on `ordersbucket`;

CREATE PRIMARY INDEX on `customersbucket`;

CREATE INDEX idx_o ON `ordersbucket`(customer_id);

CREATE INDEX idx_c ON `customersbucket`(customer_id) ;

########

# show the data

SELECT *
FROM `ordersbucket`;

#######

SELECT *
FROM `customersbucket`;

#######

# how join works

SELECT *
FROM `ordersbucket`
JOIN `customersbucket` 
ON ordersbucket.customer_id = customersbucket.customer_id; # 3 docs

# click on table
# show Plan

#######

SELECT *
FROM `ordersbucket`
JOIN `customersbucket` 
ON ordersbucket.customer_id = customersbucket.customer_id
WHERE country="Austria"; 
# error (even though only one bucket has field country, we need to specify the bucket)

########

SELECT *
FROM `ordersbucket`
JOIN `customersbucket` 
ON ordersbucket.customer_id = customersbucket.customer_id
WHERE customersbucket.country="Austria";






