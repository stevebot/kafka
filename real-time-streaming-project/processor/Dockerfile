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
