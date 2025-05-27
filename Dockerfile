# Multi-stage build for optimized production image
FROM gradle:8.7-jdk21-alpine AS build

# Set working directory
WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradlew gradlew.bat ./
COPY gradle/ gradle/
COPY build.gradle settings.gradle ./

# Copy source code
COPY src/ src/

# Build the application
RUN ./gradlew bootJar --no-daemon

# Production stage with minimal JRE optimized for Render
FROM eclipse-temurin:21-jre-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Create non-root user for security
RUN addgroup -g 1001 -S spring && \
    adduser -S spring -u 1001 -G spring

# Set working directory
WORKDIR /app

# Copy JAR from build stage
COPY --from=build /app/build/libs/demo-*.jar app.jar

# Change ownership to spring user
RUN chown spring:spring app.jar

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Set default Spring profile for production
ENV SPRING_PROFILES_ACTIVE=prod

# JVM optimization for Render's free tier (512MB RAM)
ENV JAVA_OPTS="-XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=75.0 \
    -XX:+UseG1GC \
    -XX:G1HeapRegionSize=16m \
    -XX:+UseStringDeduplication \
    -XX:+OptimizeStringConcat \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.jmx.enabled=false"

# Run the application with environment debug
ENTRYPOINT ["sh", "-c", "echo 'Environment variables:' && echo 'SPRING_PROFILES_ACTIVE='$SPRING_PROFILES_ACTIVE && echo 'SPRING_DATASOURCE_URL='$SPRING_DATASOURCE_URL && java $JAVA_OPTS -jar app.jar"]
