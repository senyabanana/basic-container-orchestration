FROM maven:3.8.4-jdk-8 AS build

WORKDIR /app

COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN mvn -B dependency:go-offline

COPY src ./src

RUN mvn -B package -DskipTests

FROM openjdk:8-jdk-alpine

COPY --from=build /app/target/*.jar /app/app.jar
COPY wait-for-it.sh .

RUN apk add --no-cache bash
RUN chmod +x wait-for-it.sh

ENV POSTGRES_HOST=postgres
ENV POSTGRES_PORT=5432
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=payments_db

CMD ["./wait-for-it.sh", "-t", "60", "postgres:5432", "--", \
     "java", "-jar", "/app/app.jar"]
