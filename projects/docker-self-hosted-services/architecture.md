# Architecture

High-level architecture for the Docker & Self-Hosted Services project.

## Purpose

This document describes the major components, dependencies, and relationships within the self-hosted services environment.

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
    ├── monitor-lab (Debian VM)
    │   │  (monitoring and observability)
    │   ├── Uptime Kuma
    │   ├── Prometheus    (planned)
    │   ├── Grafana       (planned)
    │   └── Loki          (planned)
    │
    └── media-lab (Debian VM)
        │  (dedicated media services)
        └── Jellyfin      (planned migration)
```

> [!NOTE]
> This reflects the **target** Docker, monitoring, and media architecture while also showing the current media-service location. Jellyfin currently runs on a separate physical Debian-based media host. The target design migrates Jellyfin to a dedicated `media-lab` VM within the Proxmox environment so the media service remains operationally isolated from the general lab environment. The network path (firewall, managed switch, VLANs) is also in progress; see the repository roadmap for current build status.

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
| `media-lab` | Dedicated Debian VM hosting media services |
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

### Docker Service Hosts

```text
docker-lab (Debian VM)              monitor-lab (Debian VM)             media-lab (Debian VM)
    │  self-hosted applications         │  monitoring / observability       │  media services
    ├── Portainer                       ├── Uptime Kuma                      └── Jellyfin
    ├── Homepage (planned)              ├── Prometheus (planned)
    └── Vaultwarden (planned)           ├── Grafana (planned)
                                        └── Loki (planned)
```

General self-hosted applications, monitoring services, and media services are separated by operational role. This provides fault isolation between experimental workloads, observability infrastructure, and persistent household services.

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
          ├── media-lab
          └── NAS
```

`monitor-lab` provides centralized monitoring and observability for the environment. Separating monitoring from `docker-lab` reduces dependency on the primary application host and provides better fault isolation.

### Media Services

Current deployment:

```text
Current Physical Media Host
    │
    └── Jellyfin
          │
          ▼
       nas-lab
          │
          ▼
     Media Storage
```

Jellyfin currently runs on a separate physical Debian-based media host and accesses media storage from the NAS.

Target deployment:

```text
proxmox-lab
    │
    ▼
media-lab (Debian VM)
    │
    └── Jellyfin
          │
          ▼
       nas-lab
          │
          ▼
     Media Storage
```

The target architecture places Jellyfin on a dedicated `media-lab` VM rather than on `docker-lab`.

This separation keeps the media service independent from the general lab environment. Changes, testing, container deployments, or outages affecting `docker-lab` do not directly affect Jellyfin.

Because the media service is used as a persistent household service, `media-lab` is treated as a stable service VM with its own lifecycle, resource allocation, backup strategy, and maintenance schedule.

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

**`media-lab`** (media services):

```text
/opt/docker
└── jellyfin/
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

## Media Migration Strategy

The existing physical media host remains operational until `media-lab` is fully deployed and validated.

The migration process will follow this general sequence:

```text
Current Physical Media Host
    │
    │  remains operational
    ▼
Deploy media-lab
    │
    ▼
Configure Jellyfin
    │
    ▼
Connect NAS media storage
    │
    ▼
Validate playback and transcoding
    │
    ▼
Cut over clients
    │
    ▼
Retire current media host
```

This approach minimizes disruption to the existing media service while allowing the new VM to be built and tested independently.

## Future Enhancements

- Complete migration of Jellyfin to `media-lab`
- Evaluate hardware acceleration for media transcoding
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
