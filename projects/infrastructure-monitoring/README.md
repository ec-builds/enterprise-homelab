# 📊 Infrastructure Monitoring

**Status: 📋 Planned**

Metrics, logging, alerting, and dashboards across the entire lab — know about problems before they become outages.

## Objectives

- Collect metrics from the Proxmox host, VMs, containers, and network devices
- Build dashboards that answer "is everything healthy?" at a glance
- Alert on actionable conditions while avoiding alert fatigue
- Progress from simple uptime checks to full observability (metrics → logs → alerts)
- Extend into Azure Monitor for cloud resources

## Technologies

- Prometheus + exporters (node_exporter, cAdvisor, SNMP exporter)
- Grafana (dashboards)
- Uptime Kuma (service/endpoint uptime)
- Loki + Promtail (log aggregation)
- Alertmanager / ntfy / webhooks (notifications)
- Azure Monitor (cloud-side observability)

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
