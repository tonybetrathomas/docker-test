# Build stage
FROM eclipse-temurin:17.0.13_11-jre-alpine AS build
WORKDIR /app
COPY pom.xml ./
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# Run stage
FROM gcr.io/distroless/java17-debian12
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8081
LABEL tag="multi-stage" tag1="multi"

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl -f http://localhost:8081/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]