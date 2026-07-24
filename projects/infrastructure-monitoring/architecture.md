# Monitoring Architecture

The monitoring platform provides visibility into the health, availability, and performance of the Enterprise Homelab.

## Architecture Overview

![Infrastructure Monitoring Architecture](./diagrams/monitoring-architecture.png)

*Figure 1. High-level monitoring architecture showing how availability, metrics, logs, dashboards, and alerts flow through the platform.*

## Components

| Component | Purpose |
|-----------|---------|
| Uptime Kuma | Availability monitoring |
| Prometheus | Metrics collection |
| Node Exporter | Linux host metrics |
| cAdvisor | Docker container metrics |
| SNMP Exporter | Network device metrics |
| Grafana | Dashboards and visualization |
| Promtail | Log collection |
| Loki | Centralized logging |
| Alertmanager | Alert routing |
| ntfy / Webhooks | Notifications |
| Azure Monitor | Cloud monitoring |

## Data Flow

```text
Infrastructure
      │
      ▼
Availability • Metrics • Logs
      │
      ▼
Collection
      │
      ▼
Visualization
      │
      ▼
Alerting
      │
      ▼
Notifications
```

## Design Principles

- Build in layers.
- Monitor infrastructure before applications.
- Alert only on actionable events.
- Expand the platform incrementally.
