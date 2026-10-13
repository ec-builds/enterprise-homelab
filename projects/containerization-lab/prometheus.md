# Prometheus

Prometheus is the metrics collection and time-series storage platform deployed as part of Docker Lab.

**Status:** 🟢 Operational

Prometheus collects metrics from infrastructure targets and exporters and makes those metrics available to Grafana for visualization and analysis.

Detailed metrics architecture, monitoring coverage, dashboard design, and alerting strategy are documented in the Infrastructure Monitoring project.

## Deployment

| Setting | Value |
|---|---|
| **Platform** | Docker |
| **Deployment** | Docker Compose |
| **Image** | `prom/prometheus:v3.15.0` |
| **Service Directory** | `/opt/docker/prometheus` |
| **Web Interface** | `9090/TCP` |
| **Restart Policy** | `unless-stopped` |
| **Docker Network** | `monitoring` |
| **Data Storage** | Bind-mounted persistent storage |

The deployment directory contains the Prometheus configuration and persistent time-series data:

```text
/opt/docker/prometheus/
├── docker-compose.yml
├── prometheus.yaml
└── data/
```

The host configuration file is mounted into the container as:

```text
/etc/prometheus/prometheus.yml
```

Persistent Prometheus data is stored under:

```text
/opt/docker/prometheus/data/
```

The data directory must be writable by the user running Prometheus inside the container.

## Configuration

Prometheus is configured through:

```text
prometheus.yaml
```

The configuration defines global collection behavior and the targets Prometheus scrapes for metrics.

The initial deployment includes Prometheus monitoring itself:

```text
Prometheus
    │
    └──► localhost:9090
```

Additional infrastructure targets and exporters are added as monitoring coverage expands.

## Metrics Collection

Prometheus uses a pull-based collection model.

```text
Infrastructure
      │
      ▼
   Exporters
      │
      ▼
  Prometheus
      │
      ▼
    Grafana
```

Exporters expose metrics over HTTP endpoints that Prometheus periodically scrapes.

The monitoring environment may use several exporter types:

| Exporter | Purpose |
|---|---|
| **Node Exporter** | Linux host metrics |
| **cAdvisor** | Docker container metrics |
| **SNMP Exporter** | Network device metrics |
| **Blackbox Exporter** | HTTP, TCP, ICMP, and endpoint probing |

Exporter deployment and monitoring strategy are documented separately from the Prometheus container deployment.

## Persistent Storage

Prometheus stores collected time-series data in its local TSDB.

The container path:

```text
/prometheus
```

is persisted to:

```text
/opt/docker/prometheus/data/
```

This allows collected metrics to survive container recreation and upgrades.

The current deployment uses Prometheus's configured local retention period for stored metrics.

## Service Access

Prometheus listens on:

```text
9090/TCP
```

The web interface provides access to:

- target health
- service discovery information
- PromQL queries
- runtime information
- configuration status
- rule status

Prometheus is intended for internal monitoring access and should not be exposed directly to the public Internet.

## Monitoring Integration

Prometheus provides the metrics backend for the Infrastructure Monitoring environment.

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus ───► Grafana
Blackbox Exporter ──┘
```

Prometheus is responsible for:

- scraping metrics
- storing time-series data
- evaluating PromQL queries
- evaluating alert rules
- providing metrics to Grafana

Grafana provides the primary visualization layer for collected metrics.

## Alerting

Prometheus supports metrics-based alert rules.

The alerting architecture is designed around:

```text
Prometheus
     │
     ▼
 Alert Rules
     │
     ▼
Alertmanager
     │
     ▼
Notifications
```

Alert thresholds and notification routing are managed as part of the broader Infrastructure Monitoring alerting strategy rather than the Docker deployment itself.

## Validation

Prometheus health can be verified through its readiness endpoint:

```bash
curl http://localhost:9090/-/ready
```

The Prometheus self-scrape can be validated with:

```bash
curl -s 'http://localhost:9090/api/v1/query?query=up'
```

A value of:

```text
1
```

indicates that the target is being successfully scraped.

## Security

- Keep the Prometheus web interface restricted to trusted networks.
- Do not expose `9090/TCP` directly to the public Internet.
- Do not store credentials, tokens, or sensitive target information in public repository examples.
- Protect configuration files that contain authentication information.
- Use sanitized target names and addresses in public documentation.

## References

- Infrastructure Monitoring — metrics architecture and monitoring strategy
- `infrastructure-monitoring/metric-monitoring.md`
- `infrastructure-monitoring/alerting.md`
- Prometheus documentation — container deployment and configuration

This document is intentionally limited to the Prometheus Docker deployment and its role within Docker Lab. Detailed metrics monitoring design and operations are documented in the Infrastructure Monitoring project.
