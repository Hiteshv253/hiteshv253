# AI Engineering & Automation Prompts for DevOps

This repository documents production-ready AI engineering prompts designed to accelerate DevOps tasks, automate Infrastructure as Code (IaC) generation, debug complex log traces, and construct resilient CI/CD pipelines.

---

## 🏗️ 1. Infrastructure as Code (IaC) Generator Prompt

Use this prompt to generate secure, modularized Terraform configurations.

```text
System Role: You are a Principal Cloud Architect specializing in AWS and HashiCorp Terraform.

Task: Generate a modularized Terraform module block to provision a secure, private AWS RDS PostgreSQL database.

Constraints:
1. Use version >= 1.5.0 and target AWS provider ~> 5.0.
2. The database must be deployed in private subnets only.
3. Allow incoming traffic on port 5432 exclusively from the Application Security Group ID variable (do not allow broad CIDR ingress blocks).
4. Enable Server-Side Encryption (storage_encrypted = true) using default KMS keys.
5. Do not hardcode database master passwords; declare a variable with the "sensitive = true" parameter.
6. Provide outputs for the DB connection endpoint and DB address.
7. Include thorough inline comments explaining resource tags, block definitions, and security groups.
```

---

## 🐛 2. Containerized Application Debugger Prompt

Use this prompt to analyze error logs from container engines and identify root-cause problems.

```text
System Role: You are a Staff Site Reliability Engineer (SRE).

Task: Analyze the following Kubernetes pod log trace and identify:
1. The root cause of the crash loop.
2. The specific configuration variable or database connection that failed.
3. Steps to remediate the problem.

Context: 
- App Framework: Laravel 10 (PHP 8.2-FPM)
- Data Tier: PostgreSQL database running as a ClusterIP service inside namespace 'production'.

Log Output:
[2026-08-03 12:45:01] production.ERROR: Database connection failed. Connection refused {"exception":"[object] (PDOException(code: 2002): SQLSTATE[HY000] [2002] Connection refused at /var/www/html/vendor/laravel/framework/src/Illuminate/Database/Connectors/Connector.php:70)
[2026-08-03 12:45:05] info: Entering crash loop back-off.
```

---

## ⚡ 3. Dockerfile Performance Optimization Prompt

Use this prompt to refactor a slow or large Dockerfile into an optimized, secure multi-stage build.

```text
System Role: You are a Senior DevOps Engineer.

Task: Optimize this single-stage Dockerfile to follow production security and sizing standards.

Single-Stage Input:
FROM php:8.2
RUN apt-get update && apt-get install -y git zip unzip libpng-dev mariadb-client
COPY . /var/www
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www
RUN composer install
EXPOSE 9000
CMD ["php-fpm"]

Refactoring Goals:
1. Transition to a Multi-stage build separating builder actions from execution runners.
2. Switch baseline image from 'php:8.2' to 'php:8.2-fpm-alpine' to reduce image footprint.
3. Run container processes under a non-root system user (e.g. www-data) instead of root.
4. Clean up local package repository caches after installation (using --no-cache in alpine).
```

---

## 🌀 4. CI/CD Pipeline Generator Prompt

Use this prompt to write automated workflows for GitHub Actions.

```text
System Role: You are a CI/CD Pipeline Architect.

Task: Generate a GitHub Actions YAML configuration file to compile a multi-stage Dockerfile and push to AWS Elastic Container Registry (ECR).

Required Stages:
1. Trigger: Run only on push to the 'main' branch.
2. Checkout: Clone the active workspace.
3. AWS Credentials: Log in securely using GitHub secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and target AWS_REGION).
4. Container Registry: Log in to AWS ECR.
5. Build and Push: Compile the Dockerfile and push to ECR, tag with the short commit SHA and "latest".
```
