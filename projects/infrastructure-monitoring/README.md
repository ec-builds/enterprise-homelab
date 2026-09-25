# 📊 Infrastructure Monitoring

**Status:** 🟢 Operational · logging and cloud monitoring planned

Centralized monitoring and observability for the Enterprise Homelab, providing visibility into infrastructure availability, performance, metrics, events, and logs.

The monitoring environment follows a layered observability model:

> **Uptime Kuma** = Availability  
> **Prometheus / SNMP** = Metrics  
> **Loki / Syslog** = Events & Logs  
> **Grafana** = Visualization & Correlation

The environment began with Uptime Kuma for basic availability monitoring and has expanded into a Prometheus- and Grafana-based observability stack. Metrics collection for Linux hosts, containers, endpoints, and network devices is operational. Centralized logging, expanded alerting, and cloud monitoring remain part of the planned architecture.


## Monitoring Architecture

<img src="./diagrams/monitoring-architecture.png" alt="Infrastructure Monitoring Architecture" width="100%">

*Figure 1. High-level monitoring and observability architecture.*

Observability is separated into four layers, each answering a different operational question:

| Layer | Platform | Question | Purpose |
|-------|----------|----------|---------|
| **Availability** | Uptime Kuma | Is it up? | Determines whether infrastructure and services are reachable and operational |
| **Metrics** | Prometheus + exporters | How is it running? | Collects performance, utilization, and infrastructure health data |
| **Events & Logs** | Loki (via Syslog / Alloy) | What happened? | Centralizes system, network, application, and infrastructure events |
| **Visualization & Correlation** | Grafana | How does it all relate? | Provides dashboards and correlates metrics and logs across the environment |


> **Alerting:** Alerting operates across the observability stack rather than as a separate telemetry layer. Prometheus alert rules are routed through Alertmanager, with additional Grafana-based alerting available as the environment evolves.

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



## Monitoring Stack

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned

| Component | Layer | Purpose | Status |
|-----------|-------|---------|:------:|
| Uptime Kuma | Availability | Infrastructure and service availability monitoring | 🟢 |
| Prometheus | Metrics | Metrics collection and time-series storage | 🟢 |
| Node Exporter | Metrics | Linux host metrics | 🟢 |
| cAdvisor | Metrics | Docker container resource and performance metrics | 🟢 |
| Blackbox Exporter | Availability / Metrics | HTTP, TCP, ICMP, and endpoint probing | 🟢 |
| SNMP Exporter | Metrics | Network device metrics through SNMP | 🟢 |
| Grafana | Visualization | Dashboards, visualization, and telemetry correlation | 🟢 |
| Alertmanager | Alerting | Alert routing, grouping, and notifications | 🟡 |
| Loki | Events & Logs | Centralized log and event storage | ⚪ |
| Grafana Alloy | Events & Logs | Collection and forwarding of logs and telemetry | ⚪ |
| Syslog | Events & Logs | Infrastructure and network device event forwarding | ⚪ |
| Azure Monitor | Cloud | Monitoring and telemetry for Azure resources | ⚪ |



## Data Sources

Telemetry is collected from each infrastructure layer as follows:

| Infrastructure | Availability | Metrics | Logs / Events |
|----------------|--------------|---------|---------------|
| Proxmox Hosts | Uptime Kuma | Node Exporter | Syslog → Loki |
| Linux VMs | Uptime Kuma | Node Exporter | Alloy → Loki |
| Docker Hosts | Uptime Kuma | Node Exporter / cAdvisor | Alloy → Loki |
| Containers | Uptime Kuma / Blackbox | cAdvisor | Alloy → Loki |
| Cisco Network Devices | Uptime Kuma | SNMP Exporter | Syslog → Loki |
| Firewalls | Uptime Kuma | SNMP Exporter | Syslog → Loki |
| NAS / Storage | Uptime Kuma | SNMP Exporter | Syslog → Loki (where supported) |
| Web Services | Uptime Kuma / Blackbox | Blackbox Exporter | Application logs → Loki |
| Azure Resources | Uptime Kuma (where applicable) | Azure Monitor | Azure Monitor |

> **Note:** The Logs / Events column reflects the planned design. Loki, Alloy, and syslog forwarding are not yet deployed, and Azure Monitor integration is planned.



## Troubleshooting Example

Availability, metrics, and logs are designed to complement rather than duplicate each other. When all layers are in place, a single failure, such as a switch interface going down, surfaces as correlated signals:

| Signal | Source | What It Shows |
|--------|--------|---------------|
| Interface DOWN event | Syslog → Loki *(planned)* | What changed |
| Host metrics stop arriving | Prometheus | What infrastructure is affected |
| Host and dependent services unreachable | Uptime Kuma | Impact on availability |
| Correlated timeline across all three | Grafana | Context for identifying the root cause |



## Next Steps

Remaining work beyond the components listed in the Monitoring Stack:

- 🟡 Configure Alertmanager notification routing
- ⚪ Deploy Loki and Grafana Alloy for centralized logging
- ⚪ Forward Proxmox system events through syslog
- ⚪ Forward Cisco network events through syslog
- ⚪ Integrate firewall logging into Loki
- ⚪ Correlate metrics and logs within Grafana
- ⚪ Define log and metrics retention policies
- ⚪ Integrate Azure Monitor for cloud resources



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
