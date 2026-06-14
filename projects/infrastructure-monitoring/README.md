# 📊 Infrastructure Monitoring

**Status: 🔨 In Progress**

Metrics, logging, alerting, and dashboards across the entire lab — know about problems before they become outages.

## Objectives

- Collect metrics from the Proxmox host, VMs, containers, and network devices
- Build dashboards that answer "is everything healthy?" at a glance
- Alert on actionable conditions while avoiding alert fatigue
- Progress from simple uptime checks to full observability (metrics → logs → alerts)
- Extend into Azure Monitor for cloud resources

## Technologies



| Layer | Technology | What It Monitors | Primary Purpose |
|---------|------------|------------------|-----------------|
| Metrics Collection | Prometheus | Infrastructure, services, applications | Central metrics collection, storage, and querying |
| Host Monitoring | node_exporter | Linux servers and VMs | CPU, memory, disk, filesystem, and network metrics |
| Container Monitoring | cAdvisor | Docker containers | Container performance, resource usage, and health |
| Network Monitoring | SNMP Exporter | Routers, switches, printers, UPS devices | Network device metrics via SNMP |
| Visualization | Grafana | Metrics and logs | Dashboards, charts, and observability visualization |
| Uptime Monitoring | Uptime Kuma | Websites, services, APIs, endpoints | Availability and uptime monitoring |
| Log Collection | Promtail | Servers and applications | Collects and forwards logs to Loki |
| Log Aggregation | Loki | Infrastructure and application logs | Centralized log storage and querying |
| Alerting | Alertmanager | Prometheus alerts | Alert routing, grouping, and notification management |
| Notifications | ntfy / Webhooks | Alertmanager and Uptime Kuma events | Push notifications and third-party integrations |
| Cloud Monitoring | Azure Monitor | Azure resources and services | Native Azure metrics, logs, alerts, and insights |



## Key Tasks

- [ ] Deploy the monitoring stack (containerized on the Docker host)
- [ ] Install exporters on all hosts and VMs
- [ ] Monitor the Proxmox host itself (CPU, memory, storage, VM status)
- [ ] Build dashboards: host health, containers, network throughput, storage capacity
- [ ] Centralize logs with Loki; create useful saved queries
- [ ] Define alert rules with sensible thresholds and routing
- [ ] Monitor TLS certificate and domain expiration
- [ ] Test alerting end-to-end by simulating a failure
- [ ] Configure Azure Monitor + alerts in the [Azure lab](../azure-administration-lab/)

## Folder Structure

```
infrastructure-monitoring/
├── dashboards/      # Grafana dashboard JSON exports
├── configs/         # Prometheus/Alertmanager configs (sanitized)
├── docs/            # Build notes, alert tuning decisions, lessons learned
└── screenshots/     # Visual documentation
```
