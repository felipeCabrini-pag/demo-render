# Guia Completo – Implantação de uma Aplicação Spring Boot + Thymeleaf + PostgreSQL no Render (Plano Free)

## Objetivo
Colocar sua aplicação **Java 21 / Spring Boot 3.x** em produção *totalmente grátis*, usando:

* **Render Web Service (Free Tier)** – hospeda a aplicação  
* **Render Postgres (Free Tier)** – banco de dados relacional  
* **GitHub** como repositório & CI/CD  
* **Flyway** para versionar o esquema  
* **Gradle Wrapper** para build

-### 1.7 Criar primeira migração Flyway

`src/main/resources/db/migrat### 1.9 Compilar e testar localmente

```bash
# Limpar e construir o projeto
./gradlew clea1. **New → Web Service** → conecte GitHub e escolha o repositório **demo**.   build

# Executar apenas os testes
./gradlew test

# Construir o JAR executável
./gradlew bootJar

# Para executar localmente (requer PostgreSQL configurado)
./gradlew bootRun
# Navegue em http://localhost:8080
```

> **Nota**: Para executar localmente, você precisará ter PostgreSQL instalado e configurado conforme as credenciais do perfil `dev` no `application.yml`.

### 1.10 Verificar estrutura final do projeto

Sua estrutura deve ficar assim:

```
src/
├── main/
│   ├── java/com/example/demo/
│   │   ├── DemoApplication.java
│   │   ├── controller/
│   │   │   └── PersonController.java
│   │   ├── model/
│   │   │   └── Person.java
│   │   ├── repository/
│   │   │   └── PersonRepository.java
│   │   └── service/
│   │       └── PersonService.java
│   └── resources/
│       ├── application.yml
│       ├── db/migration/
│       │   └── V1__create_tables.sql
│       └── templates/
│           └── index.html
└── test/
    ├── java/com/example/demo/
    │   └── DemoApplicationTests.java
    └── resources/
        └── application-test.yml
```__create_tables.sql`

```sql
CREATE TABLE person (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120)  NOT NULL,
  email VARCHAR(160) UNIQUE NOT NULL
);
```

### 1.8 Configurar testes

Para evitar problemas com conexão ao PostgreSQL durante os testes, adicione H2 como dependência de teste no `build.gradle`:

```gradle
dependencies {
    // ...existing dependencies...
    testImplementation 'com.h2database:h2'
}
```

Crie `src/test/resources/application-test.yml`:

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password: 
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    hibernate:
      ddl-auto: create-drop
  flyway:
    enabled: false
```

E atualize a classe de teste para usar o perfil de teste:

```java
package com.example.demo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest
@ActiveProfiles("test")
class DemoApplicationTests {

    @Test
    void contextLoads() {
    }
}
```

### 1.9 Compilar e testar localmenteparação local
### 1.1 Instalar ferramentas

| Ferramenta | Comando recomendado |
|------------|--------------------|
| **SDKMAN** | `curl -s "https://get.sdkman.io" \| bash` |
| **JDK 21** | `sdk install java 21-tem` |
| **Gradle 8** | `sdk install gradle 8.7` |
| **Git** | `sudo apt install git -y` (Linux) / Homebrew (macOS) |

> **Dica**: O Render compila usando o *Gradle Wrapper* já incluído no repositório; a versão local pode ser diferente.

### 1.2 Criar projeto Spring Boot

```bash
curl https://start.spring.io/starter.zip   -d type=gradle-project   -d dependencies=web,thymeleaf,data-jpa,postgresql,validation,actuator,flyway,lombok   -d bootVersion=3.3.0   -d javaVersion=21   -d name=renderdemo -o renderdemo.zip && unzip renderdemo.zip
cd renderdemo
```

### 1.3 Estrutura inicial de pacotes

```
src/main/java
 └── com/example/demo
      ├── DemoApplication.java
      ├── controller
      │   └── PersonController.java
      ├── model
      │   └── Person.java
      ├── repository
      │   └── PersonRepository.java
      └── service
          └── PersonService.java
```

### 1.4 Implementar as classes do domínio

#### 1.4.1 Entidade Person (`model/Person.java`)

```java
package com.example.demo.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "person")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Person {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank(message = "Name is required")
    @Size(max = 120, message = "Name must not exceed 120 characters")
    @Column(nullable = false, length = 120)
    private String name;
    
    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    @Size(max = 160, message = "Email must not exceed 160 characters")
    @Column(nullable = false, unique = true, length = 160)
    private String email;
}
```

#### 1.4.2 Repository (`repository/PersonRepository.java`)

```java
package com.example.demo.repository;

import com.example.demo.model.Person;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PersonRepository extends JpaRepository<Person, Long> {
    Optional<Person> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

#### 1.4.3 Service (`service/PersonService.java`)

```java
package com.example.demo.service;

import com.example.demo.model.Person;
import com.example.demo.repository.PersonRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PersonService {
    
    private final PersonRepository personRepository;
    
    public List<Person> findAll() {
        return personRepository.findAll();
    }
    
    public Optional<Person> findById(Long id) {
        return personRepository.findById(id);
    }
    
    public Optional<Person> findByEmail(String email) {
        return personRepository.findByEmail(email);
    }
    
    public Person save(Person person) {
        return personRepository.save(person);
    }
    
    public void deleteById(Long id) {
        personRepository.deleteById(id);
    }
    
    public boolean existsByEmail(String email) {
        return personRepository.existsByEmail(email);
    }
}
```

#### 1.4.4 Controller (`controller/PersonController.java`)

```java
package com.example.demo.controller;

import com.example.demo.model.Person;
import com.example.demo.service.PersonService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
public class PersonController {
    
    private final PersonService personService;
    
    @GetMapping("/")
    public String index(Model model) {
        model.addAttribute("persons", personService.findAll());
        model.addAttribute("person", new Person());
        return "index";
    }
    
    @PostMapping("/person")
    public String addPerson(@Valid @ModelAttribute Person person, 
                           BindingResult bindingResult, 
                           Model model, 
                           RedirectAttributes redirectAttributes) {
        
        if (bindingResult.hasErrors()) {
            model.addAttribute("persons", personService.findAll());
            return "index";
        }
        
        if (personService.existsByEmail(person.getEmail())) {
            bindingResult.rejectValue("email", "email.exists", "Email already exists");
            model.addAttribute("persons", personService.findAll());
            return "index";
        }
        
        personService.save(person);
        redirectAttributes.addFlashAttribute("success", "Person added successfully!");
        return "redirect:/";
    }
    
    @GetMapping("/person/{id}/delete")
    public String deletePerson(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        personService.deleteById(id);
        redirectAttributes.addFlashAttribute("success", "Person deleted successfully!");
        return "redirect:/";
    }
}
```

### 1.5 Configurar perfis no `application.yml`

```yaml
spring:
  application:
    name: demo
  profiles:
    active: dev

server:
  tomcat:
    threads:
      max: 50
      min-spare: 5

management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus

--- # ambiente DEV
spring:
  config:
    activate:
      on-profile: dev
  datasource:
    url: jdbc:postgresql://localhost:5432/renderdemo
    username: dev
    password: dev
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        format_sql: true

--- # ambiente PROD (Render)
spring:
  config:
    activate:
      on-profile: prod
  datasource:
    url: ${SPRING_DATASOURCE_URL}
    username: ${SPRING_DATASOURCE_USERNAME:}
    password: ${SPRING_DATASOURCE_PASSWORD:}
    hikari:
      maximum-pool-size: 10
  jpa:
    defer-datasource-initialization: true
    hibernate:
      ddl-auto: validate
    show-sql: false
```

### 1.6 Criar template Thymeleaf

Crie o arquivo `src/main/resources/templates/index.html` com uma interface moderna:

```html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Render Demo - Spring Boot App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .hero-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 4rem 0;
        }
        .card {
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: none;
        }
        .btn-gradient {
            background: linear-gradient(45deg, #667eea, #764ba2);
            border: none;
        }
        .btn-gradient:hover {
            background: linear-gradient(45deg, #5a6fd8, #6a4190);
        }
    </style>
</head>
<body>
    <!-- Hero Section -->
    <div class="hero-section">
        <div class="container">
            <div class="row justify-content-center text-center">
                <div class="col-lg-8">
                    <h1 class="display-4 fw-bold mb-3">🚀 Render Demo</h1>
                    <p class="lead mb-4">Spring Boot + Thymeleaf + PostgreSQL running on Render Free Tier</p>
                    <div class="d-flex justify-content-center gap-3">
                        <span class="badge bg-light text-dark fs-6">Java 21</span>
                        <span class="badge bg-light text-dark fs-6">Spring Boot 3.x</span>
                        <span class="badge bg-light text-dark fs-6">PostgreSQL</span>
                        <span class="badge bg-light text-dark fs-6">Flyway</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container my-5">
        <!-- Success/Error Messages -->
        <div th:if="${success}" class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>
            <span th:text="${success}"></span>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>

        <div class="row">
            <!-- Add Person Form -->
            <div class="col-lg-6">
                <div class="card mb-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0"><i class="fas fa-user-plus me-2"></i>Add New Person</h5>
                    </div>
                    <div class="card-body">
                        <form th:action="@{/person}" th:object="${person}" method="post">
                            <div class="mb-3">
                                <label for="name" class="form-label">Name</label>
                                <input type="text" 
                                       class="form-control"
                                       th:class="${#fields.hasErrors('name')} ? 'form-control is-invalid' : 'form-control'"
                                       id="name" 
                                       th:field="*{name}" 
                                       placeholder="Enter full name">
                                <div th:if="${#fields.hasErrors('name')}" class="invalid-feedback">
                                    <span th:errors="*{name}"></span>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="email" class="form-label">Email</label>
                                <input type="email" 
                                       class="form-control"
                                       th:class="${#fields.hasErrors('email')} ? 'form-control is-invalid' : 'form-control'"
                                       id="email" 
                                       th:field="*{email}" 
                                       placeholder="Enter email address">
                                <div th:if="${#fields.hasErrors('email')}" class="invalid-feedback">
                                    <span th:errors="*{email}"></span>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn btn-gradient text-white w-100">
                                <i class="fas fa-plus me-2"></i>Add Person
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Statistics -->
            <div class="col-lg-6">
                <div class="card mb-4">
                    <div class="card-header bg-info text-white">
                        <h5 class="mb-0"><i class="fas fa-chart-bar me-2"></i>Statistics</h5>
                    </div>
                    <div class="card-body text-center">
                        <h2 class="text-primary mb-1" th:text="${#lists.size(persons)}">0</h2>
                        <p class="text-muted mb-3">Total People Registered</p>
                        <div class="row">
                            <div class="col">
                                <div class="border rounded p-3">
                                    <h6 class="text-muted mb-1">Environment</h6>
                                    <span class="badge bg-success">Production</span>
                                </div>
                            </div>
                            <div class="col">
                                <div class="border rounded p-3">
                                    <h6 class="text-muted mb-1">Database</h6>
                                    <span class="badge bg-primary">PostgreSQL</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- People List -->
        <div class="card">
            <div class="card-header bg-dark text-white">
                <h5 class="mb-0"><i class="fas fa-users me-2"></i>People Directory</h5>
            </div>
            <div class="card-body">
                <div th:if="${#lists.isEmpty(persons)}" class="text-center py-5">
                    <i class="fas fa-users fa-3x text-muted mb-3"></i>
                    <h5 class="text-muted">No people registered yet</h5>
                    <p class="text-muted">Add the first person using the form above!</p>
                </div>
                
                <div th:if="${!#lists.isEmpty(persons)}" class="table-responsive">
                    <table class="table table-hover">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th width="100">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr th:each="p : ${persons}">
                                <td th:text="${p.id}" class="align-middle"></td>
                                <td th:text="${p.name}" class="align-middle"></td>
                                <td th:text="${p.email}" class="align-middle"></td>
                                <td class="align-middle">
                                    <a th:href="@{/person/{id}/delete(id=${p.id})}" 
                                       class="btn btn-outline-danger btn-sm"
                                       onclick="return confirm('Are you sure you want to delete this person?')">
                                        <i class="fas fa-trash"></i>
                                    </a>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="text-center mt-5 py-4 border-top">
            <p class="text-muted mb-2">
                <i class="fas fa-heart text-danger"></i> 
                Built with Spring Boot and deployed on <strong>Render</strong> Free Tier
            </p>
            <div class="d-flex justify-content-center gap-3">
                <a href="/actuator/health" class="btn btn-outline-success btn-sm">Health Check</a>
                <a href="/actuator/info" class="btn btn-outline-info btn-sm">App Info</a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

### 1.7 Criar primeira migração Flyway

`src/main/resources/db/migration/V1__create_tables.sql`

```sql
CREATE TABLE person (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(120)  NOT NULL,
  email VARCHAR(160) UNIQUE NOT NULL
);
```

### 1.6 Compilar e testar localmente

```bash
./gradlew clean test bootRun
# Navegue em http://localhost:8080
```

---

## 2. Publicar o repositório

```bash
git init
git branch -M main
git add .
git commit -m "Initial Spring Boot application setup

- Added Spring Boot 3.3.0 with Java 21
- Implemented Person entity with JPA and validation
- Created PersonRepository, PersonService, and PersonController
- Added Thymeleaf template with Bootstrap UI
- Configured Flyway migrations for PostgreSQL
- Set up multiple application profiles (dev, prod, test)
- Added H2 database for testing
- Comprehensive project documentation"
git remote add origin git@github.com:<usuario>/demo.git
git push -u origin main
```

---

## 3. Criar banco Postgres no Render

1. Acesse **dashboard.render.com** → **New → PostgreSQL**.  
2. Escolha **Plan: Free** (1 GB, 10 000 writes/dia, expira em 30 dias). **⚠ Importante:** o Render envia e‑mails de aviso seis dias antes da expiração.  
3. Selecione a **região** mais próxima dos usuários.  
4. Clique **Create Database** e guarde:  
   * `DATABASE_URL` – string de conexão (ex.: `postgres://user:pwd@dpg-xyz.render.com:5432/renderdemo`)  
   * Usuário e senha (caso queira separar nas variáveis)

---

## 4. Criar Web Service (Free)

1. **New → Web Service** → conecte GitHub e escolha o repositório **renderdemo**.  
2. Preencha:  
   * **Runtime**: *Native Runtime (Java)*  
   * **Instance Type**: *Free* (512 MB RAM, 0.1 vCPU)  
3. **Build Command**

   ```bash
   ./gradlew bootJar
   ```

4. **Start Command**

   ```bash
   java -jar build/libs/demo-*.jar
   ```

5. **Environment → Add Variable**

| Name | Value |
|------|-------|
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `SPRING_DATASOURCE_URL` | `${DATABASE_URL}?sslmode=require` |
| `SPRING_DATASOURCE_USERNAME` | (opcional) |
| `SPRING_DATASOURCE_PASSWORD` | (opcional) |

6. Clique **Create Web Service** e aguarde o primeiro deploy.

### 4.1 Verificando logs

* Guarde o endereço `https://<nome-servico>.onrender.com`.  
* A aba **Events** mostra *Cloning*, *Building* e *Deploying*.

---

## 5. Otimizações de runtime

### 5.1 Ajuste de memória e conexões

As configurações já foram incluídas no `application.yml` no perfil de produção:

```yaml
server:
  tomcat:
    threads:
      max: 50
      min-spare: 5
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
```

### 5.2 Variáveis de ambiente adicionais

```
JAVA_TOOL_OPTIONS=-XX:+UseZGC -XX:MaxRAMFraction=1 -Xlog:gc
```

### 5.2 Health Check

Altere **Settings → Health Checks** para `/actuator/health`.

---

## 6. Hibernação & limites

* **Spindown**: 15 min sem tráfego → container suspenso; wake‑up ~30–60 s.  
* **Quota**: 750 h CPU/mês para todas as instâncias Free do usuário.  
* Evite “pings” automáticos (viola ToS).

---

## 7. Backup automático (GitHub Actions)

`.github/workflows/pg-backup.yml`

```yaml
name: Postgres Backup
on:
  schedule:
    - cron: "0 3 * * 6"   # sábados 03:00 UTC
jobs:
  dump:
    runs-on: ubuntu-latest
    steps:
      - name: Dump DB
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          sudo apt-get update && sudo apt-get install -y postgresql-client
          pg_dump $DATABASE_URL -Fc -f backup.dump
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: pg-backup-${{ github.run_number }}
          path: backup.dump
          retention-days: 30
```

---

## 8. Blueprint `render.yaml` (Infra‑as‑Code)

```yaml
services:
  - type: web
    name: renderdemo-web
    runtime: java
    branch: main
    plan: free
    buildCommand: ./gradlew bootJar
    startCommand: java -jar build/libs/renderdemo-*.jar
    envVars:
      - key: SPRING_PROFILES_ACTIVE
        value: prod
      - key: SPRING_DATASOURCE_URL
        fromDatabase:
          name: renderdemo-db
          property: connectionString
databases:
  - name: renderdemo-db
    plan: free
    databaseName: renderdemo
```

Commit, depois **Blueprints → Sync** no dashboard.

---

## 9. Monitoramento externo

1. Crie conta em **Grafana Cloud Free**.  
2. Habilite **Prometheus Remote‑Write**.  
3. Exponha `/actuator/prometheus` e envie métricas (sidecar pago ou pull externo).

---

## 10. Checklist de produção

☑ Variáveis sem credenciais hard‑coded  
☑ Migrations versionadas (Flyway)  
☑ Backup agendado e testado  
☑ HTTPS forçado + HSTS  
☑ Health check ativo  
☑ Logs estruturados (JSON) + observabilidade

---

Parabéns! Sua aplicação Spring Boot está em produção no Render, pronta para seu novo hobby, sem gastar um centavo.
