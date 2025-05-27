# Demo Spring Boot Application

🚀 A complete    └── resources/
       ├── application.yml               # Application configuration
       ├── db/migration/
       │   └── V1__create_tables.sql     # Database migration
       └── templates/
           ├── home.html                 # Hello World home page
           └── index.html                # Person management page Boot application demonstrating modern Java web development with deployment to Render.

## Features

- **Spring Boot 3.3.0** with Java 21
- **Thymeleaf** templating engine with Bootstrap UI
- **Hello World Home Page** with pickup truck image
- **PostgreSQL** database with JPA/Hibernate
- **Flyway** database migrations
- **Lombok** for reducing boilerplate code
- **Bean Validation** for form validation
- **Spring Boot Actuator** for monitoring
- **H2** in-memory database for testing
- **Render** deployment configuration

## Technologies Used

| Technology | Purpose |
|------------|---------|
| Spring Boot 3.3.0 | Application framework |
| Java 21 | Programming language |
| Thymeleaf | Server-side templating |
| PostgreSQL | Production database |
| H2 | Test database |
| Flyway | Database migrations |
| Lombok | Code generation |
| Bootstrap 5 | Frontend styling |
| Gradle | Build tool |

## Project Structure

```
src/
├── main/
│   ├── java/com/example/demo/
│   │   ├── DemoApplication.java          # Main application class
│   │   ├── controller/
│   │   │   └── PersonController.java     # Web controller
│   │   ├── model/
│   │   │   └── Person.java               # JPA entity
│   │   ├── repository/
│   │   │   └── PersonRepository.java     # Data repository
│   │   └── service/
│   │       └── PersonService.java        # Business logic
│   └── resources/
│       ├── application.yml               # Application configuration
│       ├── db/migration/
│       │   └── V1__create_tables.sql     # Database migration
│       └── templates/
│           └── index.html                # Thymeleaf template
└── test/
    ├── java/
    │   └── com/example/demo/
    │       └── DemoApplicationTests.java # Integration tests
    └── resources/
        └── application-test.yml          # Test configuration
```

## Quick Start

### Prerequisites

- Java 21 or higher
- Git

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd demo
   ```

2. **Option A: Using Docker Compose (Recommended)**
   ```bash
   # Start PostgreSQL and the application
   docker-compose up -d
   
   # View logs
   docker-compose logs -f app
   
   # Stop services
   docker-compose down
   ```
   
   Access the application:
   - Main app: http://localhost:8080
   - pgAdmin: http://localhost:5050 (admin@demo.com / admin)
   - Health check: http://localhost:8080/actuator/health

3. **Option B: Local Development with Gradle**
   
   First, set up PostgreSQL locally:
   ```bash
   # Create database
   createdb renderdemo
   
   # Create user
   psql -c "CREATE USER dev WITH PASSWORD 'dev';"
   psql -c "GRANT ALL PRIVILEGES ON DATABASE renderdemo TO dev;"
   ```
   
   Then run the application:
   ```bash
   # Build the application
   ./gradlew build
   
   # Run tests
   ./gradlew test
   
   # Start the application
   ./gradlew bootRun
   ```

4. **Access the application**
   - Home page: http://localhost:8080
   - Person management: http://localhost:8080/persons
   - Health check: http://localhost:8080/actuator/health

### Database Setup (Development)

For local development, set up PostgreSQL:

```bash
# Create database
createdb renderdemo

# Create user
psql -c "CREATE USER dev WITH PASSWORD 'dev';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE renderdemo TO dev;"
```

## Deployment

This application is configured for deployment on **Render** using the free tier.

### Render Deployment Steps

1. **Create a Render account** at https://render.com

2. **Create PostgreSQL database**
   - Go to Render Dashboard → New → PostgreSQL
   - Choose Free plan
   - Note the connection details

3. **Deploy the web service**
   - Go to Render Dashboard → New → Web Service
   - Connect your GitHub repository
   - Use these settings:
     - **Runtime**: Java
     - **Build Command**: `./gradlew bootJar`
     - **Start Command**: `java -jar build/libs/demo-*.jar`

4. **Set environment variables**
   - `SPRING_PROFILES_ACTIVE`: `prod`
   - `SPRING_DATASOURCE_URL`: Your PostgreSQL connection string

5. **Alternative: Use Blueprint**
   ```bash
   # The render.yaml file is included for infrastructure-as-code deployment
   # Go to Render Dashboard → Blueprints → Sync
   ```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SPRING_PROFILES_ACTIVE` | Active Spring profile | Yes |
| `SPRING_DATASOURCE_URL` | Database connection string | Yes (prod) |
| `JAVA_TOOL_OPTIONS` | JVM optimization flags | No |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Hello World home page with pickup truck image |
| GET | `/persons` | Person management page with form and list |
| POST | `/person` | Add a new person |
| GET | `/person/{id}/delete` | Delete a person |
| GET | `/actuator/health` | Health check endpoint |
| GET | `/actuator/info` | Application information |

## Configuration Profiles

### Development (`dev`)
- Uses local PostgreSQL database
- Hibernate auto-creates schema
- SQL logging enabled

### Production (`prod`)
- Uses Render PostgreSQL
- Flyway handles migrations
- Optimized for production

### Test (`test`)
- Uses H2 in-memory database
- Schema created from entities
- Flyway disabled

## Monitoring and Health Checks

The application includes Spring Boot Actuator endpoints:

- **Health Check**: `/actuator/health`
- **Application Info**: `/actuator/info`
- **Metrics**: `/actuator/prometheus` (for Grafana integration)

## Security Features

- CSRF protection enabled
- Input validation with Bean Validation
- SQL injection prevention via JPA
- XSS protection via Thymeleaf escaping

## Performance Optimizations

- HikariCP connection pooling
- Tomcat thread optimization
- JVM flags for low-memory environments
- Efficient Flyway migrations

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For deployment questions, refer to the [Render Documentation](https://render.com/docs).

---

**Built with ❤️ using Spring Boot and deployed on Render Free Tier**
