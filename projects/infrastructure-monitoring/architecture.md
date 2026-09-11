# Monitoring Architecture

The monitoring platform provides visibility into the health, availability, and performance of the Enterprise Homelab through independent availability monitoring, metrics collection, centralized logging, dashboards, and alerting.

## Architecture Overview

<img src="./diagrams/monitoring-architecture-02.png" alt="Infrastructure Monitoring Architecture" width="600">

*Figure 1. High-level monitoring architecture showing metric, log, availability, visualization, and alerting flows across the platform.*

## Components

| Component | Purpose |
|-----------|---------|
| Uptime Kuma | Independent availability monitoring |
| Prometheus | Metrics collection, storage, and querying |
| Node Exporter | Linux host metrics |
| cAdvisor | Docker container metrics |
| SNMP Exporter | Network device metrics |
| Blackbox Exporter | HTTP, TCP, DNS, and endpoint probing |
| Grafana | Dashboards, visualization, and analysis |
| Grafana Alloy | Telemetry and log collection |
| Loki | Centralized log storage and querying |
| Alertmanager | Alert routing, grouping, and silencing |
| ntfy / Webhooks | Notifications and integrations |
| Azure Monitor | Azure metrics, logs, alerts, and insights |

## Data Flow

```text
Infrastructure
   │
   ├── Host / Container / Network Metrics
   │        │
   │        ▼
   │     Exporters
   │        │
   │        ▼
   │    Prometheus
   │        │
   │        ├────────► Grafana
   │        │
   │        └────────► Alertmanager
   │                     │
   │                     ▼
   │               ntfy / Webhooks
   │
   ├── Logs
   │     │
   │     ▼
   │ Grafana Alloy
   │     │
   │     ▼
   │    Loki
   │     │
   │     ▼
   │  Grafana
   │
   └── Availability
         │
         ▼
     Uptime Kuma
```

Azure resources are monitored through Azure Monitor and can be queried or visualized through Grafana as the cloud environment expands.

## Design Principles

- Build monitoring in layers.
- Keep availability monitoring independent where practical.
- Monitor infrastructure before expanding into application telemetry.
- Alert only on actionable conditions.
- Separate metrics, logs, and alerting responsibilities.
- Add telemetry sources incrementally as the environment grows.
