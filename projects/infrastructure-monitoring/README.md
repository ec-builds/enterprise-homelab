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

## Status

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned

### Current Capabilities

| Capability | Status |
|------------|:------:|
| Uptime Monitoring | 🟢 |
| Metrics Collection | 🟢 |
| Dashboards | 🟢 |
| Network Monitoring | 🟢 |
| Centralized Logging | ⚪ |
| Alerting | 🟡 |
| Cloud Monitoring | ⚪ |

### Monitoring Stack

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


### Monitoring Roadmap

| Status | Phase | Goal |
|:------:|-------|------|
| 🟢 | **Phase 1** | Deploy Uptime Kuma for availability monitoring |
| 🟢 | **Phase 2** | Collect infrastructure metrics with Prometheus and exporters |
| 🟢 | **Phase 3** | Build Grafana dashboards for infrastructure visibility |
| ⚪ | **Phase 4** | Centralize logs with Loki and Promtail |
| ⚪ | **Phase 5** | Configure Alertmanager and notification routing |
| ⚪ | **Phase 6** | Integrate Azure Monitor for cloud resources |


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
```

