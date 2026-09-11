# 📊 Infrastructure Monitoring

**Status:** 🟢 Operational

Centralized monitoring and observability for the Enterprise Homelab, providing visibility into infrastructure availability, performance, and health through metrics and dashboards.

The environment began with Uptime Kuma for basic availability monitoring and has expanded into a Prometheus and Grafana-based monitoring stack. Centralized logging, expanded alerting, and cloud monitoring remain planned.

## Monitoring Architecture

<img src="./diagrams/monitoring-architecture.png" alt="Infrastructure Monitoring Architecture" width="800">

*Figure 1. High-level monitoring architecture.*

## Objectives

- Monitor infrastructure and service availability
- Collect metrics from hosts, containers, and network devices
- Visualize infrastructure health through Grafana
- Centralize infrastructure and application logs
- Alert on actionable events
- Extend monitoring to Azure resources

## Current Capabilities

| Capability | Status |
|------------|:------:|
| Uptime Monitoring | 🟢 |
| Metrics Collection | 🟢 |
| Dashboards | 🟢 |
| Network Monitoring | 🟢 |
| Centralized Logging | ⚪ |
| Alerting | 🟡 |
| Cloud Monitoring | ⚪ |

## Monitoring Stack

| Component | Purpose | Status |
|-----------|---------|:------:|
| Uptime Kuma | Availability monitoring | 🟢 |
| Prometheus | Metrics collection and storage | 🟢 |
| Grafana | Dashboards and visualization | 🟢 |
| Node Exporter | Linux host metrics | 🟢 |
| cAdvisor | Container metrics | 🟢 |
| Blackbox Exporter | Endpoint probing | 🟢 |
| SNMP Exporter | Network device metrics | 🟢 |
| Alertmanager | Alert routing and notifications | 🟡 |
| Loki | Centralized log storage | ⚪ |
| Grafana Alloy | Telemetry and log collection | ⚪ |
| Azure Monitor | Cloud monitoring | ⚪ |

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned


## Folder Structure

```text
infrastructure-monitoring/
├── diagrams/
├── README.md
├── grafana.md
├── implementation-roadmap.md
├── lessons-learned.md
├── monitoring-strategy.md
├── retention-policy.md
└── uptime-kuma.md
