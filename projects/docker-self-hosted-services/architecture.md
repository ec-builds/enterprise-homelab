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
    ▼              ▼                      ▼
proxmox-lab     nas-lab              Current Media Host
(virtualization)(storage)            (temporary)
    │                │                      │
    │                ▼                      ▼
    │           Media Storage           Jellyfin
    │
    ├── docker-lab (Debian VM)
    │   │  (self-hosted applications)
    │   ├── Portainer
    │   ├── Homepage      (planned)
    │   └── Vaultwarden   (planned)
    │
    └── monitor-lab (Debian VM)
        │  (monitoring and observability)
        ├── Uptime Kuma
        ├── Prometheus    (planned)
        ├── Grafana       (planned)
        └── Loki          (planned)
```

> [!NOTE]
> This reflects the **target** Docker and monitoring architecture while also showing the current location of the media service. Jellyfin currently runs on a separate physical Debian-based media host. A future migration will move Jellyfin into the Proxmox environment, either as a container on `docker-lab` or on a dedicated media services VM. The network path (firewall, managed switch, VLANs) is also in progress; see the repository roadmap for current build status.

## Core Components

| Component | Role |
|-----------|------|
| Edge Router | Gateway and internet connectivity |
| Firewall | Routing, firewall, IDS/IPS, DNS (planned) |
| Managed Switch | Switching and VLAN segmentation |
| VPN | Secure remote access |
| `proxmox-lab` | Virtualization environment for VMs and containers |
| `docker-lab` | Debian VM hosting general self-hosted applications |
| `monitor-lab` | Debian VM hosting monitoring and observability services |
| Current Media Host | Physical Debian-based host currently running Jellyfin |
| `nas-lab` | Shared storage and media repository |
| Portainer | Container management UI |
| Uptime Kuma | Service availability monitoring |
| Jellyfin | Media streaming platform |
| Prometheus | Metrics collection (planned) |
| Grafana | Metrics visualization (planned) |
| Loki | Log aggregation (planned) |
| Homepage | Service dashboard (planned) |
| Vaultwarden | Self-hosted password management (planned) |

## Service Relationships

### Docker Hosts

```text
docker-lab (Debian VM)              monitor-lab (Debian VM)
    │  self-hosted applications         │  monitoring / observability
    ├── Portainer                       ├── Uptime Kuma
    ├── Homepage (planned)              ├── Prometheus (planned)
    └── Vaultwarden (planned)           ├── Grafana (planned)
                                        └── Loki (planned)
```

General self-hosted applications and monitoring services are separated by operational role. This allows the monitoring stack to remain available if `docker-lab` becomes unavailable or undergoes maintenance.

### Monitoring

```text
monitor-lab
    │
    ├── Uptime Kuma
    ├── Prometheus
    ├── Grafana
    └── Loki
          │
          ▼
    Monitored Environment
          │
          ├── Edge router / firewall
          ├── Proxmox hosts
          ├── docker-lab
          ├── NAS
          └── Media services
```

`monitor-lab` provides centralized monitoring and observability for the environment. Separating monitoring from `docker-lab` reduces dependency on the primary application host and provides better fault isolation.

### Media Services

Current deployment:

```text
nas-lab
    │
    ▼
Media Storage
    │
    ▼
Jellyfin
    │
    ▼
Current Physical Media Host
```

Jellyfin currently runs on a separate physical Debian-based media host and accesses media storage from the NAS.

The media service is planned for migration into the Proxmox environment. The final deployment model has not yet been selected.

Potential migration paths include:

```text
Option A

proxmox-lab
    │
    ▼
docker-lab
    │
    └── Jellyfin
```

```text
Option B

proxmox-lab
    │
    ▼
Dedicated Media VM
    │
    └── Jellyfin
```

The final design will be selected based on resource requirements, hardware acceleration needs, operational isolation, and maintainability.

## Deployment Model

Containers are deployed using Docker Compose, with each service in its own directory on the relevant host.

**`docker-lab`** (self-hosted applications):

```text
/opt/docker
├── portainer/
├── homepage/      (planned)
└── vaultwarden/   (planned)
```

**`monitor-lab`** (monitoring and observability):

```text
/opt/docker
├── uptime-kuma/
├── prometheus/    (planned)
├── grafana/       (planned)
└── loki/          (planned)
```

Each service is deployed independently with its own configuration and persistent data.

Compose files are version-controlled in the repository and deployed to `/opt/docker` on the appropriate host.

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

- Complete migration of media services into the Proxmox environment
- Determine final Jellyfin deployment model
- Reverse proxy implementation
- TLS certificate management
- Complete centralized observability stack
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
