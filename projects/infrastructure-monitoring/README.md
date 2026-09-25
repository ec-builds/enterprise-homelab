# 📊 Infrastructure Monitoring

**Status:** 🟢 Operational

Centralized monitoring and observability for the Enterprise Homelab, providing visibility into infrastructure **availability, performance, metrics, events, and logs**.

The monitoring environment follows a layered observability model:

> **Uptime Kuma = Availability**  
> **Prometheus / SNMP = Metrics**  
> **Loki / Syslog = Events & Logs**  
> **Grafana = Visualization & Correlation**

The environment began with Uptime Kuma for basic availability monitoring and has expanded into a Prometheus- and Grafana-based observability stack. Metrics collection for Linux hosts, containers, endpoints, and network devices is operational. Centralized logging, expanded alerting, and cloud monitoring remain part of the planned architecture.



## Monitoring Architecture

<img src="./diagrams/monitoring-architecture.png" alt="Infrastructure Monitoring Architecture" width="800">

*Figure 1. High-level monitoring and observability architecture.*

The monitoring architecture separates observability into four primary functions:

| Layer | Platform | Purpose |
|------|----------|---------|
| **Availability** | Uptime Kuma | Determines whether infrastructure and services are reachable and operational |
| **Metrics** | Prometheus / SNMP | Collects performance, utilization, and infrastructure health data |
| **Events & Logs** | Loki / Syslog | Centralizes system, network, application, and infrastructure events |
| **Visualization & Correlation** | Grafana | Provides dashboards and correlates metrics and logs across the environment |

This separation allows the monitoring platform to answer different operational questions:

- **Is it up?** → Uptime Kuma
- **How is it performing?** → Prometheus / SNMP
- **What happened?** → Loki / Syslog
- **How does it all relate?** → Grafana



## Objectives

- Monitor infrastructure and service availability
- Collect performance and health metrics from hosts, containers, and network devices
- Monitor network infrastructure through SNMP
- Centralize infrastructure, system, and application logs
- Collect syslog events from hypervisors, network devices, and firewalls
- Visualize infrastructure health through Grafana dashboards
- Correlate availability events, metrics, and logs during troubleshooting
- Generate alerts for actionable infrastructure conditions
- Extend observability to Azure resources



## Status

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned

### Current Capabilities

| Capability | Status |
|------------|:------:|
| Availability Monitoring | 🟢 |
| Host Metrics | 🟢 |
| Container Metrics | 🟢 |
| Endpoint Probing | 🟢 |
| Network Metrics / SNMP | 🟢 |
| Grafana Dashboards | 🟢 |
| Centralized Logging | ⚪ |
| Syslog Collection | ⚪ |
| Alerting | 🟡 |
| Cloud Monitoring | ⚪ |



## Monitoring Stack

| Component | Role | Purpose | Status |
|-----------|------|---------|:------:|
| Uptime Kuma | Availability | Infrastructure and service availability monitoring | 🟢 |
| Prometheus | Metrics | Metrics collection and time-series storage | 🟢 |
| Grafana | Visualization | Dashboards, visualization, and telemetry correlation | 🟢 |
| Node Exporter | Metrics | Linux host metrics | 🟢 |
| cAdvisor | Metrics | Docker container resource and performance metrics | 🟢 |
| Blackbox Exporter | Availability / Metrics | HTTP, TCP, ICMP, and endpoint probing | 🟢 |
| SNMP Exporter | Metrics | Network device metrics through SNMP | 🟢 |
| Alertmanager | Alerting | Alert routing, grouping, and notifications | 🟡 |
| Loki | Logs | Centralized log and event storage | ⚪ |
| Grafana Alloy | Collection | Collection and forwarding of logs and telemetry | ⚪ |
| Syslog | Events / Logs | Infrastructure and network device event forwarding | ⚪ |
| Azure Monitor | Cloud | Monitoring and telemetry for Azure resources | ⚪ |



## Data Sources

The monitoring platform is designed to collect telemetry from multiple infrastructure layers.

| Infrastructure | Availability | Metrics | Logs / Events |
|---------------|--------------|---------|---------------|
| Proxmox Hosts | Uptime Kuma | Prometheus / Node Exporter | Syslog → Loki |
| Linux VMs | Uptime Kuma | Node Exporter | Alloy → Loki |
| Docker Hosts | Uptime Kuma | Node Exporter / cAdvisor | Alloy → Loki |
| Containers | Uptime Kuma / Blackbox | cAdvisor | Loki |
| Cisco Network Devices | Uptime Kuma | SNMP Exporter | Syslog → Loki |
| Firewalls | Uptime Kuma | SNMP / Exporter | Syslog → Loki |
| NAS / Storage | Uptime Kuma | SNMP | Syslog where supported |
| Web Services | Uptime Kuma / Blackbox | Prometheus | Application Logs |
| Azure Resources | Uptime Kuma where applicable | Azure Monitor | Azure Monitor |



## Observability Model

The monitoring environment is designed so that availability, metrics, and logs complement rather than duplicate each other.

```text
                         ┌─────────────────────┐
                         │       Grafana       │
                         │                     │
                         │ Visualization       │
                         │ Correlation         │
                         │ Troubleshooting     │
                         └──────────┬──────────┘
                                    │
                  ┌─────────────────┴─────────────────┐
                  │                                   │
          ┌───────▼────────┐                 ┌────────▼────────┐
          │   Prometheus   │                 │      Loki       │
          │                │                 │                 │
          │ Metrics        │                 │ Logs / Events   │
          └───────▲────────┘                 └────────▲────────┘
                  │                                   │
        ┌─────────┼──────────┐              ┌─────────┼─────────┐
        │         │          │              │         │         │
       SNMP     Node      cAdvisor        Syslog    Alloy   App Logs
     Exporter  Exporter
        │         │          │              │         │
        └─────────┴──────────┴──────────────┴─────────┘
                                    │
                          Infrastructure
                                    │
                         ┌──────────▼──────────┐
                         │    Uptime Kuma      │
                         │                    │
                         │ Availability       │
                         │ Service Health     │
                         └─────────────────────┘
```

Together, these systems provide both high-level service health and detailed troubleshooting data.

For example, an infrastructure failure may appear as:

```text
Syslog / Loki
    ↓
Switch interface reports DOWN
    ↓
Prometheus
    ↓
Host metrics stop arriving
    ↓
Uptime Kuma
    ↓
Host and dependent services become unavailable
    ↓
Grafana
    ↓
Metrics and logs can be correlated during investigation
```



## Implementation Status

| Status | Goal |
|:------:|------|
| 🟢 | Deploy Uptime Kuma for availability monitoring |
| 🟢 | Collect Linux host metrics with Node Exporter |
| 🟢 | Collect container metrics with cAdvisor |
| 🟢 | Perform endpoint probing with Blackbox Exporter |
| 🟢 | Collect network device metrics with SNMP Exporter |
| 🟢 | Build Grafana dashboards for infrastructure visibility |
| 🟡 | Configure Alertmanager and notification routing |
| ⚪ | Deploy Loki for centralized log storage |
| ⚪ | Deploy Grafana Alloy for log and telemetry collection |
| ⚪ | Forward Proxmox system events through syslog |
| ⚪ | Forward Cisco network events through syslog |
| ⚪ | Integrate firewall logging into Loki |
| ⚪ | Correlate metrics and logs within Grafana |
| ⚪ | Define log and metrics retention policies |
| ⚪ | Integrate Azure Monitor for cloud resources |



## Target State

The completed monitoring platform will provide centralized observability across the homelab:

```text
Availability  →  Uptime Kuma
Metrics       →  Prometheus + SNMP
Logs/Events   →  Loki + Syslog
Visualization →  Grafana
Alerting      →  Alertmanager
Cloud         →  Azure Monitor
```

The goal is not simply to determine when infrastructure is unavailable, but to provide enough telemetry to understand **when an event occurred, what changed, what infrastructure was affected, and why the failure occurred**.



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
