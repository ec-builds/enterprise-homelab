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
    │   ├── Nginx Proxy Manager  (planned)
    │   ├── Portainer
    │   ├── Homepage
    │   └── Bitwarden Lite       (planned)
    │
    ├── monitor-lab (Debian VM)
    │   │  (monitoring and observability)
    │   ├── Uptime Kuma
    │   ├── Prometheus           (planned)
    │   ├── Grafana              (planned)
    │   ├── Loki                 (planned)
    │   ├── Alertmanager         (planned)
    │   │
    │   └── Supporting Components
    │       ├── Node Exporter    (planned)
    │       ├── SNMP Exporter    (planned)
    │       ├── cAdvisor         (planned)
    │       └── Grafana Alloy    (planned)
    │
    └── media-lab (Debian VM)
        │  (dedicated media services)
        └── Jellyfin             (planned migration)
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
| Nginx Proxy Manager | Reverse proxy and centralized HTTPS management (planned) |
| Portainer | Container management UI |
| Homepage | Service dashboard |
| Bitwarden Lite | Self-hosted password management (planned) |
| Uptime Kuma | Service availability monitoring |
| Prometheus | Metrics collection (planned) |
| Grafana | Metrics visualization (planned) |
| Loki | Log aggregation (planned) |
| Alertmanager | Monitoring alert management (planned) |
| Grafana Alloy | Telemetry and log collection (planned) |
| Jellyfin | Media streaming platform |

## Service Relationships

### Docker Service Hosts

```text
docker-lab (Debian VM)              monitor-lab (Debian VM)             media-lab (Debian VM)
    │  self-hosted applications         │  monitoring / observability       │  media services
    ├── Nginx Proxy Manager              ├── Uptime Kuma                      └── Jellyfin
    │   (planned)                        ├── Prometheus (planned)
    ├── Portainer                        ├── Grafana (planned)
    ├── Homepage                         ├── Loki (planned)
    └── Bitwarden Lite (planned)         └── Alertmanager (planned)
```

General self-hosted applications, monitoring services, and media services are separated by operational role. This provides fault isolation between experimental workloads, observability infrastructure, and persistent household services.

### Reverse Proxy

```text
Internal DNS
     │
     ▼
Nginx Proxy Manager
     │
     ├── Homepage
     ├── Bitwarden Lite
     └── Other Web Services
```

Internal DNS will resolve service hostnames to the reverse proxy. Nginx Proxy Manager will then route requests to the appropriate backend service and provide centralized HTTPS/TLS management.

The initial reverse proxy deployment will remain internal to the lab and will not require Internet-facing router port forwarding.

### Monitoring

```text
monitor-lab
    │
    ├── Uptime Kuma
    ├── Prometheus
    ├── Grafana
    ├── Loki
    └── Alertmanager
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
├── nginx-proxy-manager/  (planned)
├── portainer/
├── homepage/
└── bitwarden-lite/       (planned)
```

**`monitor-lab`** (monitoring and observability):

```text
/opt/docker
├── uptime-kuma/
├── prometheus/           (planned)
├── grafana/              (planned)
├── loki/                 (planned)
├── alertmanager/         (planned)
└── supporting-components/
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
Infrastructure
    │
    ├── Node Exporter
    ├── SNMP Exporter
    └── cAdvisor
          │
          ▼
      Prometheus
          │
          ▼
       Grafana

Logs
    │
    ▼
Grafana Alloy
    │
    ▼
Loki
    │
    ▼
Grafana

Prometheus
    │
    ▼
Alertmanager
```

Roles:

- Uptime Kuma → Availability monitoring
- Prometheus → Metrics collection
- Grafana → Visualization
- Loki → Log aggregation
- Alertmanager → Alert management
- Grafana Alloy → Telemetry and log collection
- Node Exporter → Linux host metrics
- SNMP Exporter → Network device metrics
- cAdvisor → Container metrics

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
- Deploy Nginx Proxy Manager
- Configure internal DNS for service hostnames
- Configure reverse proxy hosts
- Configure and validate HTTPS/TLS
- Complete centralized observability stack
- Automated backup procedures
- UPS-backed graceful shutdown
- Additional self-hosted services

## Related Documentation

| Document | Purpose |
|----------|---------|
| [reverse-proxy.md](reverse-proxy.md) | Reverse proxy deployment and design |
| [docker-installation.md](../../docs/reference/docker/docker-installation.md) | Docker installation procedure |
| [docker-container-deployment.md](../../docs/reference/docker/docker-container-deployment.md) | Container deployment standard |
| [docker-concepts.md](../../docs/reference/docker/docker-concepts.md) | Docker concepts and terminology |
| [uptime-kuma-reference.md](../../docs/reference/uptime-kuma/uptime-kuma-reference.md) | Uptime Kuma reference guide |
| [lessons-learned.md](lessons-learned.md) | Operational findings and decisions |
