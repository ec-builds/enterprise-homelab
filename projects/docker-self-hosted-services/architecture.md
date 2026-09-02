# Architecture

High-level architecture for the Docker & Self-Hosted Services project.

## Purpose

This document describes the major components, dependencies, and relationships within the Docker environment.

Operational procedures, installation guides, deployment procedures, and troubleshooting documentation are maintained separately to avoid duplication.

## Target Architecture

```text
Internet
    │
    ▼
Edge Router ──── VPN (remote access)
    │  (gateway)
    ▼
Firewall
    │  (routing, IDS/IPS, DNS)
    ▼
Managed Switch
    │  (switching / VLAN segmentation)
    ├──────────────┬──────────────────────┐
    ▼              ▼                       ▼
proxmox-lab     nas-lab              media-server-lab
(virtualization)(storage)            (media only)
    │                │                     │
    │                ▼                     ▼
    │           Media Storage          Jellyfin
    │
    ▼
docker-lab (Debian VM)
    │  (infrastructure containers)
    ├── Uptime Kuma
    ├── Portainer
    ├── Prometheus   (planned)
    ├── Grafana      (planned)
    ├── Loki         (planned)
    └── Homepage     (planned)
```

> [!NOTE]
> This reflects the **target** architecture. The network path (firewall, managed switch, VLANs) is in progress; see the repository roadmap for current build status.

## Core Components

| Component | Role |
|-----------|------|
| Edge Router | Gateway and internet connectivity |
| Firewall | Routing, firewall, IDS/IPS, DNS (planned) |
| Managed Switch | Switching and VLAN segmentation |
| VPN | Secure remote access |
| `proxmox-lab` | Virtualization host for VMs and containers |
| `docker-lab` | Debian VM hosting all infrastructure containers |
| `media-lab` | Dedicated media host — runs Jellyfin only |
| `nas-lab` | Shared storage and media repository |
| Portainer | Container management UI |
| Uptime Kuma | Service availability monitoring |
| Jellyfin | Media streaming platform |
| Prometheus | Metrics collection (planned) |
| Grafana | Metrics visualization (planned) |
| Loki | Log aggregation (planned) |
| Homepage | Service dashboard (planned) |

## Service Relationships

### Docker Hosts

```text
docker-lab (Debian VM)                media-server-lab
    │  infrastructure containers          │  media only
    ├── Uptime Kuma                       └── Jellyfin
    ├── Portainer
    └── Monitoring stack (planned)
```

### Monitoring

```text
Uptime Kuma
    │
    ├── Edge router / firewall
    ├── proxmox-lab
    ├── docker-lab
    ├── media-server-lab
    └── Jellyfin
```

### Media Services

```text
nas-lab
    │
    ▼
Media Storage
    │
    ▼
Jellyfin (media-server-lab)
```

Jellyfin runs on `media-server-lab` and depends on media storage from the NAS.

## Deployment Model

Containers are deployed using Docker Compose, with each service in its own directory on the relevant host.

**`docker-lab`** (infrastructure containers):
```text
/opt/docker
├── uptime-kuma/
├── portainer/
├── prometheus/   (planned)
├── grafana/      (planned)
├── loki/         (planned)
└── homepage/     (planned)
```

**`media-server-lab`** (media only):
```text
jellyfin/
```

Each service is deployed independently with its own configuration and persistent data. Portainer provides a management UI across the Docker environment.

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

Roles:
- Uptime Kuma → Availability monitoring
- Prometheus → Metrics collection
- Grafana → Visualization
- Loki → Log aggregation

## Future Enhancements

- Reverse proxy implementation
- TLS certificate management
- Centralized observability stack
- Automated backup procedures
- UPS-backed graceful shutdown
- Additional self-hosted services

## Related Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview and objectives |
| [docker-installation.md](../../docs/reference/docker/docker-installation.md) | Docker installation procedure |
| [docker-container-deployment.md](../../docs/reference/docker/docker-container-deployment.md) | Container deployment standard |
| [docker-concepts.md](../../docs/reference/docker/docker-concepts.md) | Docker concepts and terminology |
| [uptime-kuma-reference.md](../../docs/reference/uptime-kuma/uptime-kuma-reference.md) | Uptime Kuma reference guide |
| [lessons-learned.md](lessons-learned.md) | Operational findings and decisions |
