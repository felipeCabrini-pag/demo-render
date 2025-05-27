#!/bin/bash

echo "Setting up environment for production testing..."

export SPRING_PROFILES_ACTIVE=prod
export SPRING_DATASOURCE_URL="postgresql://demo_render_zrrc_user:e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw@dpg-d0qhb8emcj7s73e1puc0-a.virginia-postgres.render.com:5432/demo_render_zrrc?sslmode=require&connectTimeout=30"
export SPRING_DATASOURCE_USERNAME="demo_render_zrrc_user"
export SPRING_DATASOURCE_PASSWORD="e3AAvfWvYJfqaC6AcbDrgzch4tzvo8qw"

echo "Environment variables set:"
echo "SPRING_PROFILES_ACTIVE=$SPRING_PROFILES_ACTIVE"
echo "Database URL configured: ✓"

echo "Starting application..."
java -jar build/libs/demo-0.0.1-SNAPSHOT.jar
