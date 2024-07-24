# Use a base image with Java installed
FROM openjdk:11-jre-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the packaged JAR file into the container at /app
COPY /var/lib/jenkins/workspace/Java-app-pipeline/target/*.jar /app/application.jar

# Command to run the application
CMD ["java", "-jar", "/app/application.jar"]
