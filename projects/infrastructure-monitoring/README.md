# 📊 Infrastructure Monitoring

**Status:** 🟢 Operational

Availability monitoring for the Enterprise Homelab, with a roadmap toward full observability through metrics, logging, alerting, and dashboards.

## Monitoring Architecture

![Infrastructure Monitoring Architecture](./diagrams/monitoring-architecture.png)

*Figure 1. High-level monitoring architecture.*

## Objectives

- Monitor infrastructure availability
- Collect metrics from hosts and services
- Visualize infrastructure health
- Alert on actionable events
- Extend monitoring to Azure resources

## Current Capabilities

| Capability | Status |
|------------|:------:|
| Uptime Monitoring | 🟢 |
| Metrics Collection | ⚪ |
| Dashboards | ⚪ |
| Centralized Logging | ⚪ |
| Alerting | ⚪ |
| Cloud Monitoring | ⚪ |

## Documentation

| Document | Purpose |
|----------|---------|
| `uptime-kuma.md` | Uptime Kuma deployment |
| `implementation-roadmap.md` | Build phases and milestones |
| `monitoring-strategy.md` | Monitoring goals and philosophy |
| `retention-policy.md` | Data retention standards |
| `lessons-learned.md` | Key decisions and implementation lessons |

## Folder Structure

```text
infrastructure-monitoring/
├── diagrams/
├── README.md
├── implementation-roadmap.md
├── lessons-learned.md
├── monitoring-strategy.md
├── retention-policy.md
└── uptime-kuma.md
```
