# Guia Completo – Implantação de uma Aplicação Spring Boot + Thymeleaf + PostgreSQL no Render (Plano Free)

## Objetivo
Colocar sua aplicação **Java 21 / Spring Boot 3.x** em produção *totalmente grátis*, usando:

* **Render Web Service (Free Tier)** – hospeda a aplicação  
* **Render Postgres (Free Tier)** – banco de dados relacional  
* **GitHub** como repositório & CI/CD  
* **Flyway** para versionar o esquema  
* **Gradle Wrapper** para build

---

## 1. Preparação local
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
 └── com/example/renderdemo
      ├── RenderDemoApplication.java
      ├── controller
      ├── model
      ├── repository
      └── service
```

### 1.4 Configurar perfis no `application.yml`

```yaml
spring:
  profiles.active: dev

--- # ambiente DEV
spring:
  config.activate.on-profile: dev
  datasource:
    url: jdbc:postgresql://localhost:5432/renderdemo
    username: dev
    password: dev
  jpa:
    hibernate:
      ddl-auto: update

--- # ambiente PROD (Render)
spring:
  config.activate.on-profile: prod
  datasource:
    url: ${SPRING_DATASOURCE_URL}
    username: ${SPRING_DATASOURCE_USERNAME}
    password: ${SPRING_DATASOURCE_PASSWORD}
  jpa:
    defer-datasource-initialization: true
    hibernate:
      ddl-auto: validate
```

### 1.5 Criar primeira migração Flyway

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
git commit -m "Versão inicial"
git remote add origin git@github.com:<usuario>/renderdemo.git
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
   java -jar build/libs/renderdemo-*.jar
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

Variável extra em **Environment**:

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
