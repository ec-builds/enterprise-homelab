# Uptime Kuma

**Status:** 🟢 Operational

Uptime Kuma provides independent availability monitoring for infrastructure and services across the Enterprise Homelab.

#### Uptime Kuma Dashboard

![uptime-kuma](./diagrams/uptime-kuma.png)

*Uptime Kuma dashboard monitoring the availability and health of infrastructure and services across the Enterprise Homelab.*

## Objectives

- Monitor infrastructure and service availability
- Detect outages and connectivity failures
- Track uptime and response times
- Maintain a simple availability layer independent of the broader monitoring stack

## Deployment

| Component | Value |
|---|---|
| Platform | Debian |
| Deployment | Docker Compose |
| Image | `louislam/uptime-kuma:2` |
| Database | Embedded MariaDB |
| Interface | Port 3001 |
| Storage | Docker Volume |

## Current Monitors

- Internet Connectivity
- ASUS Router
- Synology NAS
- Jellyfin
- Uptime Kuma (Self Monitoring)

Additional monitors will be added as the homelab grows.

## Features

- HTTP/HTTPS Monitoring
- Ping Monitoring
- TCP Port Monitoring
- Status Dashboard
- Uptime History
- Response Time Tracking

## Role in Monitoring Architecture

Uptime Kuma serves as the dedicated availability monitoring layer alongside the broader observability platform.

Prometheus and its exporters provide infrastructure metrics, while Grafana provides centralized visualization and analysis. Uptime Kuma remains focused on quickly determining whether critical infrastructure and services are reachable.

## Related Documentation

- Infrastructure Monitoring
- Monitoring Architecture
- Prometheus
- Grafana

## Security Note

Sanitize all configurations before committing them to the repository. Never include credentials, API tokens, public IP addresses, or other sensitive information.
