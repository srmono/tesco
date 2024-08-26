#######################################
############# Manage Certificates for a Cluster
#######################################



------------------------------   Configure Server Certificates   -------------------------------

## Assume you have a host with an IP address 13.71.71.77
## which is the main host of your Couchbase cluster

##  Head to the shell of the first node

/opt/couchbase/bin/couchbase-cli setting-autofailover \
-c http://13.71.71.77:8091 \
-u admin \
-p bvsrao \
--enable-auto-failover 0

/opt/couchbase/bin/couchbase-cli node-to-node-encryption \
-c http://13.71.71.77:8091 \
-u admin \
-p bvsrao \
--disable

## Before we start, remove the second node from the cluster 
## Head to Servers, select the second node, then Remove, then Rebalance
## We'll re-add this later on

## Then head back to the shell of the first node

cd ~
touch ~/.rnd
mkdir servercertfiles

cd servercertfiles
mkdir -p {public,private,requests}
ls -n


###	Firstly, create private key so that we can create certificate with the help of this private
##	key. In case my cluster private key name is caprivkey.key

openssl genrsa -out caprivkey.key 2048

less caprivkey.key


###	Create cluster certificate which containe publuc key of public key.
##	in my case public key name is clusterkey.pem. And also set days of expiry, issuer name in my case
##	bvsrao Root CA.

openssl req -new -x509 \
-days 365 \
-sha256 \
-key caprivkey.key \
-out cacert.pem \
-subj "/CN=bvsrao Root CA"

less cacert.pem

###	See public key which comes with certificates

openssl x509 -in ./cacert.pem \
-noout \
-pubkey


###	View the issuer name and serial number of the certificate

openssl x509 -in ./cacert.pem \
-noout \
-subject \
-serial

openssl x509 -in ./cacert.pem \
-noout \
-text 


##	Create private key for node inside private directory

openssl genrsa \
-out private/couchbase.vmachine-01.key 2048

less private/couchbase.vmachine-01.key 

##	Create a certificate signing request for the node certificate.
openssl req -new \
-key private/couchbase.vmachine-01.key \
-out requests/couchbase.vmachine-01.csr \
-subj "/CN=Couchbase Server 01"

less requests/couchbase.vmachine-01.csr

##	See, request process and verification 

openssl req -in ./requests/couchbase.vmachine-01.csr \
-noout \
-text \
-verify 



###	Define certificate extensions for the node.

cat > server.ext <<EOF
basicConstraints=CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
extendedKeyUsage=serverAuth
keyUsage = digitalSignature,keyEncipherment
EOF

less server.ext 


###	Create a customized extension for the certificate file. 

cp ./server.ext ./server-01.ext.tmp

## This should match the IP address (public or private) of the node where it's meant for
echo "subjectAltName = IP:10.0.2.8" \
>> server-01.ext.tmp

###	This customized extesion file is to be used authenthicate a single node, whose IP is
##	13.71.71.77.

###	Create node certificate after signing request.
openssl x509 -req \
-CA cacert.pem \
-CAkey caprivkey.key \
-CAcreateserial -days 365 \
-in requests/couchbase.vmachine-01.csr \
-out public/couchbase.vmachine-01.pem \
-extfile server-01.ext.tmp

less public/couchbase.vmachine-01.pem

openssl x509 -in ./public/couchbase.vmachine-01.pem \
-noout \
-text 


###	Deploy the node certificate and node private key
##	Before deploy it, move it into inbox directory of the server and make it executable.
##	Follow these steps

sudo mkdir /opt/couchbase/var/lib/couchbase/inbox/

sudo cp ./public/couchbase.vmachine-01.pem \
/opt/couchbase/var/lib/couchbase/inbox/chain.pem

ls -n /opt/couchbase/var/lib/couchbase/inbox/

sudo chmod a+x /opt/couchbase/var/lib/couchbase/inbox/chain.pem

sudo cp ./private/couchbase.vmachine-01.key \
/opt/couchbase/var/lib/couchbase/inbox/pkey.key

ls -n /opt/couchbase/var/lib/couchbase/inbox/pkey.key

sudo chmod a+x /opt/couchbase/var/lib/couchbase/inbox/pkey.key

sudo chown -R couchbase:couchbase \
/opt/couchbase/var/lib/couchbase/inbox/

ls -l /opt/couchbase/var/lib/couchbase/inbox/

-->	sudo cp ./public/chain.pem /opt/couchbase/var/lib/couchbase/inbox/chain.pem
-->	sudo chmod a+x /opt/couchbase/var/lib/couchbase/inbox/chain.pem
-->	sudo cp ./private/pkey.key /opt/couchbase/var/lib/couchbase/inbox/pkey.key
-->	sudo chmod a+x /opt/couchbase/var/lib/couchbase/inbox/pkey.key


## Sign in as admin in the Couchbase Web UI
## Navigate to Security --> Root CA
## Take a look at the Root CA certificate before we upload the one we have created



## Upload the root certificate and then reload the certificates for the cluster

curl -X POST --data-binary "@./cacert.pem" \
http://admin:bvsrao@13.71.71.77:8091/controller/uploadClusterCA

## Head to the Couchbase UI,  Security --> Root CA
## The new certificate has been uploaded, but there is a warning since both nodes
## now use unsiged certificates. They need to be re-loaded

curl -X POST \
http://admin:bvsrao@13.71.71.77:8091/node/controller/reloadCertificate


## To check whether the signed certicate has been uploaded 
## go check the Security --> Root CA section in the Couchbase UI

## We now create the certificate for the second node
## The Root CA files are still on the first node, so we create the certificate there
## Then we transfer it over to the second node

## From the servercertfiles directory on vmachine-01

cp ./server.ext ./server-02.ext.tmp

## This should match the IP address (public or private) of the node where it's meant for
echo "subjectAltName = IP:10.0.2.7" \
>> ./server-02.ext.tmp

openssl genrsa \
-out private/couchbase.vmachine-02.key 2048

openssl req -new \
-key private/couchbase.vmachine-02.key \
-out requests/couchbase.vmachine-02.csr \
-subj "/CN=Couchbase Server 02"

openssl x509 -req \
-CA cacert.pem \
-CAkey caprivkey.key \
-CAcreateserial -days 365 \
-in requests/couchbase.vmachine-02.csr \
-out public/couchbase.vmachine-02.pem \
-extfile server-02.ext.tmp

openssl x509 -in ./public/couchbase.vmachine-02.pem \
-noout \
-text 


## Copy over certificate and private key to host-02
## The password for clouduser will need to be supplied
scp public/couchbase.vmachine-02.pem clouduser@vmachine-02:

scp private/couchbase.vmachine-02.key clouduser@vmachine-02:


### Login as clouduser to vmachine-02
sudo mkdir /opt/couchbase/var/lib/couchbase/inbox/

sudo cp couchbase.vmachine-02.pem \
/opt/couchbase/var/lib/couchbase/inbox/chain.pem

sudo chmod a+x /opt/couchbase/var/lib/couchbase/inbox/chain.pem

sudo cp couchbase.vmachine-02.key \
/opt/couchbase/var/lib/couchbase/inbox/pkey.key

sudo chmod a+x /opt/couchbase/var/lib/couchbase/inbox/pkey.key

sudo chown -R couchbase:couchbase /opt/couchbase/var/lib/couchbase/inbox/

ls -l /opt/couchbase/var/lib/couchbase/inbox/


## From vmachine-01, run this
## This loads the Root CA certificate (on the file system of vmachine-01) to vmachine-02
curl -X POST --data-binary "@./cacert.pem" \
http://admin:bvsrao@vmachine-02:8091/controller/uploadClusterCA

curl -X POST \
http://admin:bvsrao@vmachine-02:8091/node/controller/reloadCertificate

## Head to the admin UI and re-add the second host using it's private IP (10.0.2.7)

## From the shell of the first host, enable node-to-node encryption again
/opt/couchbase/bin/couchbase-cli node-to-node-encryption \
-c http://vmachine-01:8091 \
-u admin \
-p bvsrao \
--enable




