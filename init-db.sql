-- Initialize the database for local development
-- This script runs when the PostgreSQL container starts for the first time

-- Ensure the database exists (it's already created by POSTGRES_DB environment variable)
-- Grant additional permissions if needed
GRANT ALL PRIVILEGES ON DATABASE renderdemo TO dev;

-- Connect to the database
\c renderdemo;

-- Grant schema permissions
GRANT ALL ON SCHEMA public TO dev;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dev;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dev;

-- Create extensions if needed (optional)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- The actual tables will be created by Flyway migrations when the Spring Boot app starts
