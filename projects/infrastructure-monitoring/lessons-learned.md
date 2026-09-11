# Monitoring Lessons Learned

| Date | Lesson | Context | Result |
|---|---|---|---|
| 2026-09-10 | Observability Is Incremental | Monitoring expanded from Uptime Kuma into Prometheus and Grafana rather than deploying the full stack at once. | Built monitoring in stages, with logging and advanced alerting as future additions. |
| 2026-09-10 | Dashboards Should Answer Operational Questions | Grafana panels were organized around infrastructure health instead of simply displaying available metrics. | Created a focused view of resource usage, containers, endpoints, and network health. |
| 2026-09-10 | Network Devices Require Different Telemetry | Network infrastructure required SNMP-based collection rather than traditional host exporters. | Added SNMP Exporter to collect interface and traffic metrics from the Cisco switch. |
| 2026-09-10 | Exporters Bridge Infrastructure and Prometheus | Exporters were deployed to expose infrastructure metrics for Prometheus collection. | Established a repeatable pattern for adding new telemetry sources. |
| 2026-09-10 | Monitoring Should Answer Infrastructure Questions | Grafana brought host, container, endpoint, and network telemetry into one view. | Moved beyond uptime checks to visibility into performance and infrastructure behavior. |
| 2026-07-24 | Simple Monitoring Is Better Than No Monitoring | Uptime Kuma was deployed as the first monitoring solution for the homelab. | Established basic availability monitoring and identified the need for metrics, logging, and alerting. |
