#!/bin/bash

# Get the correct container names
KAFKA_CONTAINER=$(docker ps -qf "ancestor=real-time-streaming-project-kafka")
CONSUMER_CONTAINER=$(docker ps -qf "ancestor=real-time-streaming-project-consumer")
PROCESSOR_CONTAINER=$(docker ps -qf "ancestor=real-time-streaming-project-processor")
PRODUCER_CONTAINER=$(docker ps -qf "ancestor=real-time-streaming-project-producer")

# Verify containers are running
if [ -z "$KAFKA_CONTAINER" ] || [ -z "$CONSUMER_CONTAINER" ] || [ -z "$PROCESSOR_CONTAINER" ] || [ -z "$PRODUCER_CONTAINER" ]; then
    echo "One or more containers are not running."
    exit 1
fi



# Function to produce a message to test_topic
produce_message() {
    echo "Producing a message to test_topic..."
    docker exec -it $(docker ps -qf "ancestor=real-time-streaming-project-producer") \
    bash -c "echo 'Test Message' | java -jar /app/producer.jar"
}

# Function to consume a message from test_topic
consume_message() {
    echo "Consuming a message from test_topic..."
    docker exec -it $(docker ps -qf "ancestor=real-time-streaming-project-consumer") \
    java -jar /app/consumer.jar
}

# Function to consume a message from processed_topic
consume_processed_message() {
    echo "Consuming a message from processed_topic..."
    docker exec -it $(docker ps -qf "ancestor=real-time-streaming-project-processor") \
    java -jar /app/processor.jar
}

# Produce a message
produce_message

# Consume the message from test_topic
consume_message

# Consume the processed message from processed_topic
consume_processed_message
