# Kafka-Based Streaming Project Setup and Testing

## Overview
This project is a Kafka-based real-time streaming system with three components: Producer, Consumer, and Processor. The setup utilizes Docker to build and run Kafka, Zookeeper, and the respective services.

## Files
- **`init.sh`**: Initializes the project by setting up directories, generating Maven `pom.xml` files, Dockerfiles for each component, and starting services via Docker Compose.
- **`test.sh`**: Runs tests to ensure that Kafka is functioning correctly by sending and consuming messages.
- **`cleanup.sh`**: Cleans up Docker containers, images, and project files based on the options provided.

---

## Installation and Setup

### Prerequisites
- Docker
- Docker Compose
- Maven

### Steps to Initialize the Project

1. Clone or create the project folder.
2. Navigate to the directory containing the scripts.
3. Modify `config.cfg` to specify platform information (e.g., `linux/arm64`).
4. Run the initialization script:
   ```bash
   ./init.sh
