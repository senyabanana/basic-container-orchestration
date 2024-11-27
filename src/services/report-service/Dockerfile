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
ENV POSTGRES_DB=statistics_db
ENV RABBIT_MQ_HOST=rabbitmq
ENV RABBIT_MQ_PORT=5672
ENV RABBIT_MQ_USER=guest
ENV RABBIT_MQ_PASSWORD=guest
ENV RABBIT_MQ_QUEUE_NAME=messagequeue
ENV RABBIT_MQ_EXCHANGE=messagequeue-exchange

CMD ["./wait-for-it.sh", "-t", "60", "postgres:5432", "--", \
     "./wait-for-it.sh", "-t", "60", "rabbitmq:5672", "--", \
     "java", "-jar", "/app/app.jar"]
