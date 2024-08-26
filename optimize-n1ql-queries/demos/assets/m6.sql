################################################
################################ Setting up Couchbase on the Cloud
################################################

ssh clouduser@ ________

#yes
#password


#couchbase package

wget https://packages.couchbase.com/releases/6.5.0/couchbase-server-enterprise_6.5.0-ubuntu18.04_amd64.deb

sudo dpkg -i couchbase-server-enterprise_6.5.0-ubuntu18.04_amd64.deb

#ui in xcdr

# emp1001 and emp1002 is inserted to host1 before replication

create primary index `EmployeeBucket-primary` on `EmployeeBucket`;


insert into `EmployeeBucket` (key,value)
values("emp1001",{"id":"id1001", 
				  "name":"Chloe Smith",
				  "designation":"Web Developer",
				  "salary":7500,
				  "projects":"Dashboard, HomePage",
				  "type":"Employee"
				}),
values("emp1002",{"id":"id1002",
				  "name":"Emily Armstrong",
				  "designation":"",
				  "salary":7000,
				  "type":"Employe"
				 })
returning meta().id as docid;

# emp1003 is inserted to host1 after replication

insert into `EmployeeBucket` (key,value)
values("emp1003",{"id":"id1003",
				  "name":"Emma Atkinson",
				  "designation":"Product Manager",
				  "salary":9000,
				  "projects":"Search, Index",
				  "type":"Employee"
       			 })
returning meta().id as docid, *;


#pause replication (view the effect)


insert into `EmployeeBucket` (key,value)
values("emp1004",{"id":"id1004",
				  "name":"Ivo Buletov",
				  "designation":"Release Engineer",
				  "salary":8500,
				  "projects":"FastDeploy",
				  "type":"Employee"
    			 });

#resume

# in host2 
#add emp1005 to bucket and view the effect on the source bucket

insert into `RemoteEmployeeBucket` (key,value)
values("emp1005",{"id":"id1005",
					   "name":"George Miller",
					   "salary":9000,
					   "type":"Employee",
					   "projects":["UITest"]})
returning meta().id as docid;

#flush host2 RemoteEmployeeBucket
#delete doc id1003 and id1004 from EmployeeBucket







