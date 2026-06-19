# Architecture

High-level architecture for the Docker & Self-Hosted Services project.

## Purpose

This document describes the major components, dependencies, and relationships within the Docker environment.

Operational procedures, installation guides, deployment procedures, and troubleshooting documentation are maintained separately to avoid duplication.

---

## Current Architecture

```text
Internet
    │
    ▼
ASUS RT-AX5400
    │
    ▼
Home Network
    │
    ├── Synology NAS
    │     └── Media Storage
    │
    └── Docker Host (homesrv01)
          │
          ├── Uptime Kuma
          ├── Jellyfin
          └── Future Services
```

---

## Core Components

| Component | Role |
|----------|----------|
| ASUS RT-AX5400 | Primary network gateway |
| Synology NAS | Shared storage and media repository |
| Docker Host | Runs containerized applications |
| Uptime Kuma | Service availability monitoring |
| Jellyfin | Media streaming platform |
| Prometheus | Metrics collection (planned) |
| Grafana | Metrics visualization (planned) |
| Loki | Log aggregation (planned) |
| Homepage | Service dashboard (planned) |

---

## Service Relationships

### Monitoring

```text
Uptime Kuma
    │
    ├── Router
    ├── Docker Host
    ├── Jellyfin
    └── Future Services
```

### Media Services

```text
Synology NAS
    │
    ▼
Media Storage
    │
    ▼
Jellyfin
```

Jellyfin depends on media storage being available from the Synology NAS.

---

## Deployment Model

Applications are deployed using Docker Compose.

```text
/opt/docker
├── uptime-kuma/
├── grafana/
├── prometheus/
├── loki/
└── homepage/
```

Each service is deployed independently and maintains its own configuration and persistent data.

---

## Planned Observability Stack

```text
Prometheus
    │
    ├── Node Exporter
    ├── cAdvisor
    └── Additional Exporters
          │
          ▼
       Grafana

Loki
    │
    ▼
Log Aggregation
```

Purpose:

- Uptime Kuma → Availability Monitoring
- Prometheus → Metrics Collection
- Grafana → Visualization
- Loki → Log Aggregation

---

## Future Enhancements

- Reverse proxy implementation
- TLS certificate management
- Centralized observability stack
- Automated backup procedures
- UPS-backed graceful shutdown
- Additional self-hosted services

---

## Related Documentation

| Document | Purpose |
|----------|----------|
| [README.md](README.md) | Project overview and objectives |
| [docker-installation.md](../../docs/reference/docker-installation.md) | Docker installation procedure |
| [docker-container-deployment.md](../../docs/reference/docker-container-deployment.md) | Container deployment standard |
| [docker-concepts.md](../../docs/reference/docker-concepts.md) | Docker concepts and terminology |
| [uptime-kuma-reference.md](../../docs/reference/uptime-kuma-reference.md) | Uptime Kuma reference guide |
| [lessons-learned.md](lessons-learned.md) | Operational findings and decisions |
