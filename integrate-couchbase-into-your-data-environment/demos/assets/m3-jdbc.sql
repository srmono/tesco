#############################################
############################## JDBC Connector for Couchbase
#############################################

##	Resources:- http://cdn.cdata.com/help/CKE/jdbc/pg_connectionj.htm

##	Prerequisite:-
#	1. Couchbase server
#	2. Any IDEA for java code (e.g. intelliJ IDEA)


##	Download JDBC from:- https://www.cdata.com/drivers/couchbase/jdbc/


cd ~/tools/CouchbaseJDBCDriver
java -jar setup.jar

##	- After running that above command a prompt titled CData JDBC Driver Couchbase Setup pops up
#	- click Next to continue
#	- accept T&C and click Next
#	- Continue with the default configs
#	- When prompted for registration information, fill in your details
#	- When asked to download a license, click yes
#   - Download the license to the same directory where the JDBC driver is placed

## In a new Terminal tab / new shell
cd "/Applications/CData/CData JDBC Driver for Couchbase 2020"
ls

cd lib

## Rename the key.reg file as cdata.jdbc.couchbase.lic
mv keys.reg cdata.jdbc.couchbase.lic

## Load the jar file into your project in your IDE


-------------JAVA App to connect to Couchbase ---------------

## Connection class

package com.bvsrao;

import cdata.jdbc.couchbase.CouchbaseDataSource;
import javax.sql.DataSource;

public class CouchbaseConnection {

    public static DataSource getCouchbaseDataSource() {

        CouchbaseDataSource couchbaseDS = null;

        try {
            couchbaseDS = new CouchbaseDataSource();
            couchbaseDS.setUrl("jdbc:couchbase:User='admin';Password='bvsrao';Server=127.0.0.1");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return couchbaseDS;
    }
}


## Data retrieval class

package com.bvsrao;


import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class GetCouchbaseData {

    public static void main(String[] args) {

        try (Connection conn = CouchbaseConnection.getCouchbaseDataSource().getConnection()) {

            if (conn != null) {
                System.out.println("The connection has been successfully established!");

                Statement stat = conn.createStatement();
                boolean ret = stat.execute("select * from `academic-data` where semester = 'First'");
                if (ret) {
                    ResultSet rs = stat.getResultSet();
                    while (rs.next()) {
                        System.out.println("\ndocument ID: " + rs.getString("Document.Id"));
                        System.out.println("semester: " + rs.getString("semester"));
                        System.out.println("test_score: " + rs.getString("test_score"));

                    }
                }
            }

        } catch (SQLException ex) {
            System.out.println("A connection error has occurred:");
            ex.printStackTrace();
        }
    }
}











