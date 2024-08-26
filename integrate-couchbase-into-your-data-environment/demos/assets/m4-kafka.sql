#############################################
############################## Kafka Connector for Couchbase
#############################################

##	Resources:- https://docs.couchbase.com/kafka-connector/current/quickstart.html

##	To do this, we need three things Apache Kafka, kafka connector and preinstalled couchbase
#	- Download from 
#	- Kafka:- https://www.apache.org/dyn/closer.cgi?path=/kafka/2.5.0/kafka_2.12-2.5.0.tgz
#	- kafka-connector:- https://docs.couchbase.com/kafka-connector/current/release-notes.html
#	- then set root installation directory. eg:- $KAFKA_HOME for kafka and 

vi .bash_profile

## Enter these lines in the bash profile
export KAFKA_HOME=~/kafka_2.12-2.5.0
export PATH=$PATH:$KAFKA_HOME/bin

export KAFKA_CONNECT_COUCHBASE_HOME=~/kafka-connect-couchbase-3.4.8
export PATH=$PATH:$KAFKA_CONNECT_COUCHBASE_HOME/config

## Let the new environment variables take effect in your shell
source .bash_profile

#	To start kafka run these two below command
## From one shell, run this 
zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties

## On a separate shell
kafka-server-start.sh $KAFKA_HOME/config/server.properties


##	Configure the source connector
subl $KAFKA_HOME/config/quickstart-couchbase-source.properties

## Set these properties in the config file
connection.bucket=academic-data
connection.username=admin
connection.password=bvsrao

## Navigate to the connector directory
cd $KAFKA_CONNECT_COUCHBASE_HOME

##  Run the source connector script
env CLASSPATH=./* \
connect-standalone.sh $KAFKA_HOME/config/connect-standalone.properties \
config/quickstart-couchbase-source.properties  


## The goal now is to create two consumers of messages published to the Kafka topic:
##      - one runs from the command line
##      - a second consumer is a Java program 

*/##	Create an topic to cast message, by help below command

kafka-console-consumer.sh \
--bootstrap-server localhost:9092 \
--topic test-couchbase \
--from-beginning


## Building a Kafka Consumer in Java
## Download the slf4j api jar file from here:
## https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.9/slf4j-api-1.7.9.jar
## The cdata.jdbc.couchbase library will already be part of your project
## Add the following jars into your project library:
##		- $KAFKA_HOME/libs/kafka-clients-2.5.0.jar
##		- slf4j-api-1.7.9.jar
## Create a main class and a separate Run Config for the following and then run


package com.bvsrao;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Arrays;
import java.util.Properties;
import org.slf4j.LoggerFactory;

public class KafkaConsumerTest {

    public static void main(String[] args) {

        String host="127.0.0.1:9092";
        String groupId="couchbase_kafka_consumer";
        String topic="test-default";

        Properties properties=new Properties();
        properties.setProperty(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG,host);
        properties.setProperty(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                               StringDeserializer.class.getName());
        properties.setProperty(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                               StringDeserializer.class.getName());
        properties.setProperty(ConsumerConfig.GROUP_ID_CONFIG,groupId);

        KafkaConsumer<String,String> consumer= new KafkaConsumer<String,String>(properties);

        consumer.subscribe(Arrays.asList(topic));

        while(true){
            ConsumerRecords<String,String> records=consumer.poll(Duration.ofMillis(1000));

            for(ConsumerRecord<String,String> record: records){
                System.out.println("Key: "+ record.key() + ", Value:" +record.value());
                System.out.println("Partition:" + record.partition()+",Offset:"+record.offset());
            }
        }
    }
}


## Update a value in the academic-data bucket and watch it displayed in the Java app console
## It should also appear in the shell where the topic has been subscribed to
update `academic-data` 
set semester = 'Third' where 
meta().id = '1009';

## Add a document - this should also appear for both consumers
insert into `academic-data` (key, value)
values('1012', {'user_id': 1012,
       'gender' : 'F',
       'nationality' : 'Mexico',
       'parent_school_satisfaction': 'good',
       'topic': 'Chemistry',
       'semester' : 'First',
       'absence_days' : 'Under-7',
       'test_score': 71});

## Delete operations are also propagated to the consumers
delete from `academic-data`
where meta().id = '1004';














