# Production Readiness, Security & Configuration Audit

This document details configurations, security architecture, and observability parameters across all portfolios.

---

## ⚙️ 1. Configuration Audit & Justifications

### 🐳 A. Multi-Stage Dockerfiles (`Dockerfile`)
- **Stage 1 (Builder)**: Installs build dependencies (e.g. compilers, `git`, database development headers) and uses Composer to install backend code libraries. It optimizes loader classes but excludes dev dependencies (`--no-dev`).
- **Stage 2 (Runner)**: copies only the vendor folder and source code from Stage 1 into a minimal alpine baseline. It does not carry over build utilities, leaving a final container size of < 120MB.
- **Security Constraint**: Runs under the default unprivileged `www-data` system user (`USER www-data`) instead of `root` to prevent hosts partition takeovers in case of container escapes.

### ☸️ B. Kubernetes Ingress & Sidecar Proxy Pattern
- **Shared Volume Namespace**: The pod config uses a shared `emptyDir` memory volume (`web-root`). The PHP container puts its compiled static public assets there on boot.
- **Nginx Sidecar**: Nginx mounts the same `web-root` volume to serve CSS/JS files directly. It forwards any dynamic dynamic requests to PHP-FPM running on `127.0.0.1:9000` via localhost networking.
- **Probes**:
  - **Liveness Probe**: Regularly pings `GET /api/v1/healthz`. If it fails (e.g. PHP process hung), kubelet restarts the container.
  - **Readiness Probe**: Pings `GET /api/v1/readiness` checking active connections to PostgreSQL and Redis. If they fail, the pod is pulled from service routing, preventing user request drops.

### 🌐 C. Terraform Module Design
- **Subnet Separation**: The database subnet group isolates PostgreSQL RDS nodes in private subnets. They cannot obtain public IPs and are routed exclusively inside the private subnet CIDR.
- **Bastion Access Tunnels**: The compute nodes (App servers) in the private subnets allow inbound port `22` (SSH) traffic only from the Bastion host's security group. All external admin traffic must tunnel through the Bastion.

---

## 🛡️ 2. Comprehensive Security Architecture

### 🔒 A. Host Security
- **UFW Firewall Configurations**: Only ports `22` (SSH - restricted to bastion IP), `80` (HTTP), and `443` (HTTPS) are open. All other inbound traffic is dropped.
- **SSH Hardening**:
  - Disallows root login (`PermitRootLogin no`).
  - Disallows password authentication (`PasswordAuthentication no`), requiring SSH Key-Pairs.
- **Fail2Ban Policies**: Restricts brute-force SSH targets. If a client registers 5 failed authentication attempts within 10 minutes, the host IP is temporarily banned via iptables for 1 hour.

### 🐳 B. Container Security
- **Static Image Vulnerability Scans**: Integrates `Trivy` or `Snyk` scanners inside the GitHub Actions pipeline, blocking container deployment if critical vulnerabilities are flagged.
- **Read-Only Root Filesystems**: Containers run with read-only root filesystems where possible, mounting storage volumes to writeable locations (e.g., `/tmp` or `/var/www/html/storage`).

---

## ⚡ 3. Performance Tuning & Observability

### 🗄️ A. Database & Caching Architecture
- **Indexing Rules**: Ensure database foreign keys and target lookup fields are indexed in migrations to prevent full table scans.
- **Redis Integration**:
  - Laravel cache and session drivers route to Redis.
  - Redis utilizes standard Least Recently Used (`allkeys-lru`) eviction policies with memory ceilings to prevent out-of-memory crashes.

### 📊 B. Metrics Scraping & Alerts Thresholds
- **Node Exporter**: Exposes physical host system parameters (Memory, Disk, Network throughput) on port `9100`.
- **cAdvisor**: Connects directly to `/var/run/docker.sock` to extract resource usage stats (CPU, RAM limits) from containers.
- **Prometheus**: Aggregates metrics and evaluates rules inside `alert.rules.yml`:
  - **`HostHighCpuLoad`**: Triggers warning alerts if CPU usage > 85% for more than 2 minutes.
  - **`LaravelHighHttp5xxRate`**: Triggers critical alerts if application 5xx response ratios exceed 5% over a 5-minute moving window.
- **Alertmanager**: Integrates alerting outputs with webhook receivers to automatically push JSON notifications to Discord/Slack.
