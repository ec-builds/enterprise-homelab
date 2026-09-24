# Architecture

High-level architecture for the Docker & Self-Hosted Services project.

## Purpose

This document describes the major components, dependencies, and relationships within the self-hosted services environment.

Operational procedures, installation guides, deployment procedures, and troubleshooting documentation are maintained separately to avoid duplication.

## Current Architecture

```text
Internet
    │
    ▼
Edge Router ──── WireGuard VPN
    │
    ▼
Managed Switch
    │
    ├───────────────┬────────────────────┐
    ▼               ▼                    ▼
Proxmox VE       nas-lab             Client Devices
Cluster          (storage)
    │
    ├── docker-lab (Debian VM)
    │   │  (self-hosted applications)
    │   ├── Portainer
    │   ├── Homepage
    │   ├── Nginx Proxy Manager  (planned)
    │   └── Bitwarden Lite       (planned)
    │
    ├── monitor-lab (Debian VM)
    │   │  (monitoring and observability)
    │   ├── Uptime Kuma
    │   └── Monitoring Stack
    │       ├── Prometheus
    │       ├── Grafana
    │       ├── Loki
    │       ├── Alertmanager
    │       └── Grafana Alloy
    │
    └── media-lab (Debian VM)
        │  (dedicated media services)
        └── Jellyfin
              │
              ▼
           nas-lab
              │
              ▼
         Media Storage
```

> [!NOTE]
> The environment separates general self-hosted applications, monitoring, and media services across dedicated Debian virtual machines. This provides workload isolation and allows each service host to be maintained independently.
>
> Uptime Kuma is operational on the dedicated monitoring host. The broader Prometheus, Grafana, Loki, Alertmanager, and Grafana Alloy stack has been deployed and tested as part of the monitoring environment, with permanent deployment and continued integration still being refined.
>
> Jellyfin has been migrated from its previous host-based deployment to a dedicated `media-lab` virtual machine and now runs as a Docker Compose workload with network-mounted NAS media storage.

## Core Components

| Component | Role |
|-----------|------|
| Edge Router | Internet gateway, perimeter routing, firewalling, wireless networking, and WireGuard remote access |
| Managed Switch | Managed switching for internal infrastructure |
| Proxmox VE Cluster | Three-node virtualization platform hosting service VMs |
| `docker-lab` | Debian VM hosting general self-hosted applications |
| `monitor-lab` | Debian VM hosting monitoring and observability services |
| `media-lab` | Dedicated Debian VM hosting containerized media services |
| `nas-lab` | Shared storage, backup, and media repository |
| Nginx Proxy Manager | Reverse proxy and centralized HTTPS management (planned) |
| Portainer | Container management UI |
| Homepage | Service dashboard |
| Bitwarden Lite | Self-hosted password management (planned) |
| Uptime Kuma | Availability and service monitoring |
| Prometheus | Metrics collection |
| Grafana | Metrics and log visualization |
| Loki | Centralized log aggregation |
| Alertmanager | Monitoring alert management |
| Grafana Alloy | Telemetry and log collection |
| Jellyfin | Containerized media streaming platform |

## Service Relationships

### Docker Service Hosts

```text
docker-lab                         monitor-lab                       media-lab
(Debian VM)                        (Debian VM)                       (Debian VM)
    │                                  │                                │
    │ General Applications             │ Monitoring / Observability     │ Media Services
    │                                  │                                │
    ├── Portainer                      ├── Uptime Kuma                  └── Jellyfin
    ├── Homepage                       ├── Prometheus                        │
    ├── Nginx Proxy Manager            ├── Grafana                           ▼
    │   (planned)                      ├── Loki                           nas-lab
    └── Bitwarden Lite                 ├── Alertmanager
        (planned)                      └── Grafana Alloy
```

General self-hosted applications, monitoring services, and media services are separated by operational role.

This provides fault isolation between application workloads, observability infrastructure, and persistent household services. It also allows maintenance or testing on one service host without unnecessarily affecting unrelated workloads.

### Reverse Proxy

Planned architecture:

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

Internal DNS will resolve selected service hostnames to the reverse proxy. Nginx Proxy Manager will then route requests to the appropriate backend service and provide centralized HTTPS/TLS management.

The initial reverse proxy deployment will remain internal to the lab and will not require Internet-facing router port forwarding.

### Monitoring and Observability

```text
                    monitor-lab
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
   Uptime Kuma                    Observability Stack
        │                                 │
        │                       ┌─────────┼─────────┐
        │                       ▼         ▼         ▼
        │                  Prometheus   Loki     Grafana
        │                       │         ▲
        │                       ▼         │
        │                  Alertmanager   │
        │                                 │
        │                          Grafana Alloy
        │
        └────────────────┬────────────────┘
                         ▼
                Monitored Environment
                         │
             ┌───────────┼───────────┐
             ▼           ▼           ▼
        Network       Proxmox      Service Hosts
      Infrastructure   Hosts
                                      │
                                  ┌───┴───┐
                                  ▼       ▼
                             docker-lab media-lab
```

`monitor-lab` provides dedicated monitoring and observability capabilities for the environment.

Uptime Kuma provides availability and basic synthetic service monitoring. Prometheus provides metrics collection, Grafana provides visualization, Loki provides centralized log aggregation, Grafana Alloy supports telemetry and log collection, and Alertmanager provides alert handling for Prometheus-based monitoring.

Separating monitoring from the primary application host reduces dependency on `docker-lab` and provides better fault isolation.

### Media Services

```text
Proxmox VE Cluster
       │
       ▼
media-lab (Debian VM)
       │
       ▼
Docker Compose
       │
       ▼
    Jellyfin
       │
       ▼
    nas-lab
       │
       ▼
  Media Storage
```

Jellyfin runs as a containerized workload on a dedicated `media-lab` virtual machine rather than on the general-purpose `docker-lab` host.

Media content is accessed from network-mounted NAS storage, while persistent Jellyfin application data and configuration use bind-mounted storage where appropriate.

This separation keeps the media service independent from the general self-hosted application environment. Changes, testing, container deployments, or outages affecting `docker-lab` do not directly affect Jellyfin.

Because the media platform is used as a persistent household service, `media-lab` is treated as a stable service VM with its own lifecycle, resource allocation, backup considerations, and maintenance schedule.

## Deployment Model

Containers are deployed using Docker Compose, with services organized under `/opt/docker` on the relevant host.

**`docker-lab`** (self-hosted applications):

```text
/opt/docker
├── portainer/
├── homepage/
├── nginx-proxy-manager/  (planned)
└── bitwarden-lite/       (planned)
```

**`monitor-lab`** (monitoring and observability):

```text
/opt/docker
├── uptime-kuma/
├── prometheus/
├── grafana/
├── loki/
├── alertmanager/
└── grafana-alloy/
```

**`media-lab`** (media services):

```text
/opt/docker
└── jellyfin/
```

Each service is deployed independently with its own configuration and persistent data requirements.

Docker Compose files provide reproducible service definitions, while bind mounts and Docker-managed storage are selected according to the persistence, visibility, backup, and migration requirements of each workload.

Repository-managed configuration is maintained separately from runtime secrets and environment-specific data.

## Observability Architecture

```text
Infrastructure
    │
    ├── Host Metrics
    ├── Network Metrics
    ├── Container Metrics
    └── Service Metrics
          │
          ▼
      Prometheus
          │
          ├──────────────► Alertmanager
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


Services / Endpoints
    │
    ▼
Uptime Kuma
    │
    ▼
Availability Monitoring
```

Roles:

- **Uptime Kuma** → Availability and basic synthetic service monitoring
- **Prometheus** → Metrics collection
- **Grafana** → Metrics and log visualization
- **Loki** → Centralized log aggregation
- **Alertmanager** → Prometheus alert management
- **Grafana Alloy** → Telemetry and log collection
- **Node Exporter** → Linux host metrics
- **SNMP Exporter** → Network device metrics
- **cAdvisor** → Container metrics

Exporter coverage will continue to expand as additional infrastructure is integrated into the monitoring environment.

## Storage Integration

```text
                   nas-lab
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Backups     Media       Shared Data
                      │
                      ▼
                  media-lab
                      │
                      ▼
                   Jellyfin
```

The NAS provides centralized network storage for persistent data, backups, and media content.

Media storage remains separate from the Jellyfin application container, allowing the service to be recreated or migrated without relocating the underlying media library.

This separation supports easier service recovery, host migration, and lifecycle management.

## Current Deployment State

| Capability | Status |
|------------|--------|
| Docker platform | 🟢 Operational |
| Portainer | 🟢 Operational |
| Homepage | 🟢 Operational |
| Uptime Kuma | 🟢 Operational |
| Jellyfin Docker deployment | 🟢 Operational |
| NAS media integration | 🟢 Operational |
| Prometheus / Grafana / Loki stack | 🟡 Deployed / Being Refined |
| Grafana Alloy | 🟡 Deployed / Being Refined |
| Alertmanager | 🟡 Deployed / Being Refined |
| Nginx Proxy Manager | ⚪ Planned |
| Bitwarden Lite | ⚪ Planned |
| Expanded exporter coverage | ⚪ Planned |

## Design Decisions

### Separate Application, Monitoring, and Media Hosts

Workloads are separated according to operational role rather than placing every container on a single Docker host.

This improves fault isolation and allows each environment to have its own maintenance lifecycle and resource allocation.

### Dedicated Monitoring Host

Monitoring infrastructure is kept separate from the primary application host so an outage affecting `docker-lab` does not automatically remove the primary mechanism used to detect that outage.

### Dedicated Media Host

Jellyfin is isolated from general-purpose application workloads because it is a persistent household service with different availability and resource requirements.

### Network-Based Media Storage

Media content remains on centralized NAS storage rather than inside the Jellyfin VM. This separates application lifecycle from media-data lifecycle and simplifies migration and recovery.

### Docker Compose

Docker Compose provides declarative and reproducible service definitions while remaining appropriate for the scale of the current environment.

## Future Enhancements

- Deploy Nginx Proxy Manager
- Configure internal DNS for proxied service hostnames
- Configure reverse proxy hosts
- Configure and validate internal HTTPS/TLS
- Expand Prometheus metrics coverage
- Expand centralized log collection
- Expand network-device monitoring
- Complete and validate alerting workflows
- Expand automated backup procedures
- Implement UPS-backed graceful shutdown
- Add additional self-hosted services
- Continue configuration standardization and automation

## Related Documentation

| Document | Purpose |
|----------|---------|
| [reverse-proxy.md](reverse-proxy.md) | Reverse proxy deployment and design |
| [docker-installation.md](../../docs/reference/docker/docker-installation.md) | Docker installation procedure |
| [docker-container-deployment.md](../../docs/reference/docker/docker-container-deployment.md) | Container deployment standard |
| [docker-concepts.md](../../docs/reference/docker/docker-concepts.md) | Docker concepts and terminology |
| [uptime-kuma-reference.md](../../docs/reference/uptime-kuma/uptime-kuma-reference.md) | Uptime Kuma reference guide |
| [lessons-learned.md](lessons-learned.md) | Operational findings and decisions |
