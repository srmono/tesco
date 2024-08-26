#############################################
############################## Spark Connector for Couchbase
#############################################


##	Resources:- https://docs.couchbase.com/spark-connector/current/getting-started.html


## Create an IntelliJ project for Scala called CouchbaseConnectSpark
## This should be an SBT project
## Choose Scala version 2.12.10

## In the project, create this SBT file

name := "CouchbaseConnectSpark"

version := "0.1"

scalaVersion := "2.12.10"

libraryDependencies ++= Seq(
  "org.apache.spark" %% "spark-core" % "2.4.5",
  "org.apache.spark" %% "spark-sql" % "2.4.5",
  "com.couchbase.client" %% "spark-connector" % "2.4.0"
)


## Within src/main/scala, create this source called SparkConnect.scala


import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.sources.EqualTo
import com.couchbase.spark.sql._

object SparkConnect {

  def main(args: Array[String]): Unit = {

    val spark = SparkSession
      .builder()
      .appName("CouchbaseSpark")
      .master("local[*]")
      .config("spark.couchbase.nodes", "127.0.0.1")
      .config("spark.couchbase.username", "admin")
      .config("spark.couchbase.password", "bvsrao")
      .config("spark.couchbase.bucket.academic-data", "")
      .getOrCreate()

    val sc = spark.sparkContext
    spark.sparkContext.setLogLevel("WARN")

    val allStudents = spark.read.couchbase()
    println("\nCount of students by nationality:")

    allStudents
      .groupBy("nationality")
      .count()
      .show()

    val firstSems = spark.read.couchbase(EqualTo("semester", "First"))
    println("\nSchema for student documents:")
    println("student Schema:" + firstSems.schema.treeString)

    println("\nDetails of students in their first semester:")
    firstSems
      .select("META_ID", "nationality", "test_score")
      .sort(firstSems("META_ID").desc)
      .show(5)

  }

}


## Refresh the scala source from the SBT file - this will download the referenced libraries
## Run the Scala App









