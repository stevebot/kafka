#!/bin/bash

# Load configuration
source config.cfg

# Define the base project directory
PROJECT_DIR="real-time-streaming-project"

# Function to create a directory and check if it was successful
create_dir() {
    local dir=$1
    mkdir -p "$dir"
    if [ ! -d "$dir" ]; then
        echo "Failed to create directory: $dir"
        exit 1
    fi
}

# Create base directories
create_dir "$PROJECT_DIR/kafka/config"
create_dir "$PROJECT_DIR/producer/src"
create_dir "$PROJECT_DIR/consumer/src"
create_dir "$PROJECT_DIR/processor/src"

# Create Maven pom.xml for Producer
cat <<EOL > $PROJECT_DIR/producer/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>producer</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>2.6.0</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                    <archive>
                        <manifest>
                            <mainClass>Main</mainClass>
                        </manifest>
                    </archive>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOL

# Create Maven pom.xml for Consumer
cat <<EOL > $PROJECT_DIR/consumer/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>consumer</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>2.6.0</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                    <archive>
                        <manifest>
                            <mainClass>Main</mainClass>
                        </manifest>
                    </archive>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOL

# Create Maven pom.xml for Processor
cat <<EOL > $PROJECT_DIR/processor/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>processor</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.apache.kafka</groupId>
            <artifactId>kafka-clients</artifactId>
            <version>2.6.0</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>11</source>
                    <target>11</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                    <archive>
                        <manifest>
                            <mainClass>Main</mainClass>
                        </manifest>
                    </archive>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOL

# Create Kafka Dockerfile
cat <<EOL > $PROJECT_DIR/kafka/Dockerfile
FROM wurstmeister/kafka:2.13-2.6.0
COPY config/server.properties /kafka/config/server.properties
EOL

# Create Kafka server.properties
cat <<EOL > $PROJECT_DIR/kafka/config/server.properties
broker.id=1
listeners=PLAINTEXT://0.0.0.0:9092
log.dirs=/kafka/kafka-logs
zookeeper.connect=zookeeper:2181
EOL

# Create Producer Dockerfile
cat <<EOL > $PROJECT_DIR/producer/Dockerfile
# Dockerfile for Producer
FROM maven:3.8.1-openjdk-11-slim AS build
COPY src /app/src
COPY pom.xml /app
WORKDIR /app
RUN mvn clean package -B

FROM openjdk:11-jre-slim
COPY --from=build /app/target/producer-1.0-SNAPSHOT.jar /app/producer.jar
WORKDIR /app
CMD ["java", "-jar", "producer.jar"]
EOL

# Create Producer main.java
cat <<EOL > $PROJECT_DIR/producer/src/main.java
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class Main {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        KafkaProducer<String, String> producer = new KafkaProducer<>(props);

        for (int i = 0; i < 100; i++) {
            producer.send(new ProducerRecord<>("test_topic", Integer.toString(i), "Message #" + i));
        }

        producer.close();
    }
}
EOL

# Create Consumer Dockerfile
cat <<EOL > $PROJECT_DIR/consumer/Dockerfile
# Dockerfile for Consumer
FROM maven:3.8.1-openjdk-11-slim AS build
COPY src /app/src
COPY pom.xml /app
WORKDIR /app
RUN mvn clean package -B

FROM openjdk:11-jre-slim
COPY --from=build /app/target/consumer-1.0-SNAPSHOT.jar /app/consumer.jar
WORKDIR /app
CMD ["java", "-jar", "consumer.jar"]
EOL

# Create Consumer main.java
cat <<EOL > $PROJECT_DIR/consumer/src/main.java
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.util.Collections;
import java.util.Properties;

public class Main {
    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "test_group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());

        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        consumer.subscribe(Collections.singletonList("test_topic"));

        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(100);
            for (ConsumerRecord<String, String> record : records) {
                System.out.printf("Consumed message: %s%n", record.value());
            }
        }
    }
}
EOL


# Create Processor Dockerfile
cat <<EOL > $PROJECT_DIR/processor/Dockerfile
# Dockerfile for Processor
FROM maven:3.8.1-openjdk-11-slim AS build
COPY src /app/src
COPY pom.xml /app
WORKDIR /app
RUN mvn clean package -B

FROM openjdk:11-jre-slim
COPY --from=build /app/target/processor-1.0-SNAPSHOT.jar /app/processor.jar
WORKDIR /app
CMD ["java", "-jar", "processor.jar"]
EOL

# Create Processor main.java
cat <<EOL > $PROJECT_DIR/processor/src/main.java
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Collections;
import java.util.Properties;

public class Main {
    public static void main(String[] args) {
        Properties consumerProps = new Properties();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, "processor_group");
        consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());

        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(consumerProps);
        consumer.subscribe(Collections.singletonList("test_topic"));

        Properties producerProps = new Properties();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        producerProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        producerProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        KafkaProducer<String, String> producer = new KafkaProducer<>(producerProps);

        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(100);
            for (ConsumerRecord<String, String> record : records) {
                String processedValue = "Processed " + record.value();
                producer.send(new ProducerRecord<>("processed_topic", record.key(), processedValue));
            }
        }
    }
}
EOL

# Create docker-compose.yml
cat <<EOL > $PROJECT_DIR/docker-compose.yml
version: '3.8'

services:
  zookeeper:
    image: arm64v8/zookeeper:3.7.0
    platform: $PLATFORM
    ports:
      - "2181:2181"

  kafka:
    build: ./kafka
    container_name: kafka-container
    ports:
      - "9092:9092"
    environment:
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181

  producer:
    build: ./producer
    depends_on:
      - kafka

  consumer:
    build: ./consumer
    depends_on:
      - kafka

  processor:
    build: ./processor
    depends_on:
      - kafka
EOL

# Build and start the services using Docker Compose
docker-compose -f $PROJECT_DIR/docker-compose.yml build
docker-compose -f $PROJECT_DIR/docker-compose.yml up -d --build --force-recreate

# Wait for Kafka to start
sleep 20

# Check if the Kafka container is running
if [ "$(docker ps -q -f name=kafka-container)" ]; then
    echo "Kafka container is up and running."

    # Create Kafka topics
    docker exec kafka-container kafka-topics.sh --create --topic test_topic --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1
    docker exec kafka-container kafka-topics.sh --create --topic processed_topic --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1

    echo "Topics created successfully."
else
    echo "Kafka container is not running. Please check the logs."
fi

echo "Project setup complete. Kafka is running, and the topics have been created."
What This Script Does: