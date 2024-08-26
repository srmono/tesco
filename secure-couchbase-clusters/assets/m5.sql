###################################################
################# Securing Communication with Encryption and Cipher Suites
###################################################


link:- https://docs.couchbase.com/server/6.5/manage/manage-security/manage-tls.html
       https://docs.couchbase.com/server/6.5/cli/cbcli/couchbase-cli-setting-security.html


### First check default our client server which cipher suites uses

/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--get | jq

/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--get | jq '.tlsMinVersion'

#	we get initially empty cipher suites and TLS version is tlsv1
### Before setting cipher suites we have to set TLS version tlsv1.1 or latest
###	Updating TLS version 

/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--set \
--tls-min-version tlsv1.1

/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--get | jq '.cipherSuites'


/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--set \
--cipher-suites TLS_RSA_WITH_AES_256_GCM_SHA384,\
TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,\
TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,\
TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA

/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--get | jq '.cipherSuites'



########### Node-to-node Encryption


/opt/couchbase/bin/couchbase-cli setting-autofailover \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--enable-auto-failover 0

/opt/couchbase/bin/couchbase-cli node-to-node-encryption \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--enable

/opt/couchbase/bin/couchbase-cli setting-autofailover \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--enable-auto-failover 1 \
--auto-failover-timeout 120 

/opt/couchbase/bin/couchbase-cli node-to-node-encryption \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--get

/opt/couchbase/bin/couchbase-cli setting-security \
-c http://127.0.0.1:8091 \
-u admin \
-p bvsrao \
--get | jq '.'









