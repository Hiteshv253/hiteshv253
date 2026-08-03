# Prometheus & Grafana Monitoring Stack

This project provisions a production-ready system monitoring stack using Docker Compose. It integrates **Prometheus** (time-series database), **Grafana** (dashboard visualization), **Node Exporter** (OS metrics), **cAdvisor** (container diagnostic insights), and **Alertmanager** (alerting notification router).

## 🏗️ Monitoring Architecture Diagram

The diagram below maps the layout and connection routes of the monitoring stack.

![Monitoring Stack Architecture](monitoring_architecture.png)

### Core Integration Points:
1. **Data Gathering**: 
   - **Node Exporter**: Reads system parameters (CPU, RAM, Disk, Network) from the Linux host kernel.
   - **cAdvisor**: Connects to the Docker socket to read resource quotas from individual running containers.
2. **Database Scraping**: Prometheus pulls (scrapes) metrics from Node Exporter, cAdvisor, and container targets at 15-second intervals.
3. **Alert Routing**: If metrics breach definitions inside `alert.rules.yml`, Prometheus fires notification alerts to Alertmanager, which maps route rules to deliver JSON payloads to Slack or Discord webhooks.
4. **Data Visualization**: Grafana connects to Prometheus as a datasource to render analytics dashboards.

---

## 📁 Directory Layout

```text
monitoring-stack/
├── alertmanager/
│   └── alertmanager.yml                  # Alert routing configurations
├── grafana/
│   ├── dashboards/
│   │   └── system-dashboard.json         # Pre-loaded CPU & RAM host dashboard
│   └── provisioning/
│       ├── dashboards/
│       │   └── dashboards.yml            # Dashboard auto-loader instructions
│       └── datasources/
│           └── datasource.yml            # Prometheus datasource configurations
├── prometheus/
│   ├── alert.rules.yml                   # Metrics threshold conditions
│   └── prometheus.yml                    # Scrape targets and rules declarations
├── docker-compose.yml                    # Monitoring containers orchestration
└── README.md                             # Project documentation
```

---

## 🚀 Installation & Boot Instructions

1. Ensure Docker and Docker Compose are installed on the host machine.
2. Boot the complete monitoring environment:
   ```bash
   docker-compose up -d --build
   ```
3. Access services:
   - **Prometheus UI**: `http://localhost:9090`
   - **Grafana Dashboards**: `http://localhost:3000` (Default Credentials: Username `admin` / Password `SecretGrafanaPassword123`)
   - **Alertmanager Console**: `http://localhost:9093`

---

## 📊 Pre-configured Dashboards

On boot, Grafana automatically provisions:
- **Prometheus Datasource**: Points directly to `http://prometheus:9090`.
- **System Diagnostics Dashboard**: Pre-loads timeseries panels monitoring **Host CPU Usage** and **Memory Usage** to bypass initial manually-created layouts.

---

## 🔔 Alert Threshold Actions

Alert rules at `prometheus/alert.rules.yml` check for:
- **InstanceDown**: Exporter offline > 1m (Critical).
- **HostHighCpuLoad**: CPU load > 85% > 2m (Warning).
- **HostDiskSpaceFilling**: Free root partition storage < 15% (Critical).
- **LaravelHighHttp5xxRate**: Web app 5xx response rate > 5% over 5m (Critical).
