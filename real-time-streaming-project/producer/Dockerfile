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
