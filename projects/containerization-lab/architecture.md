# Architecture

High-level architecture for the Docker & Self-Hosted Services project.

## Purpose

This document describes the major components, dependencies, and relationships within the self-hosted services environment.

Operational procedures, installation guides, deployment procedures, and troubleshooting documentation are maintained separately to avoid duplication.

## Current Architecture

The Docker environment consists of three dedicated Debian virtual machines distributed across the three-node Proxmox VE cluster.

```text
                         Proxmox VE Cluster
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
        prox-lab-01       prox-lab-02       prox-lab-03
              │                 │                 │
              ▼                 ▼                 ▼
       docker-lab-01      monitor-lab-01     media-lab-01
              │                 │                 │
       General Apps        Monitoring &           Media
       Portainer CE        Observability          Services
              │                 │                 │
              │            Uptime Kuma          Jellyfin
              │            Prometheus              │
              │            Grafana                 ▼
              │            Loki                  nas-lab
              │            Alertmanager
              │            Grafana Alloy
              │
              │          Portainer Agent     Portainer Agent
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                       Centralized Docker
                          Management
```

Workloads are separated by operational role:

- `docker-lab-01` hosts general self-hosted applications and centralized Docker management.
- `monitor-lab-01` hosts monitoring and observability services.
- `media-lab-01` hosts containerized media services.

Each Docker VM resides on a separate Proxmox node, providing workload separation and allowing the environments to be maintained independently.

## Core Components

| Component | Role |
|---|---|
| Proxmox VE Cluster | Three-node virtualization platform hosting Docker service VMs |
| `docker-lab-01` | General self-hosted applications and Portainer CE Server |
| `monitor-lab-01` | Monitoring and observability services |
| `media-lab-01` | Containerized media services |
| `nas-lab` | Shared storage, backup, and media repository |
| Portainer CE | Centralized Docker management |
| Portainer Agent | Remote Docker Engine management |
| Homepage | Internal service dashboard |
| Uptime Kuma | Availability and synthetic service monitoring |
| Prometheus | Metrics collection |
| Grafana | Metrics and log visualization |
| Loki | Centralized log aggregation |
| Alertmanager | Prometheus alert management |
| Grafana Alloy | Telemetry and log collection |
| Jellyfin | Containerized media streaming platform |
| Nginx Proxy Manager | Reverse proxy and centralized HTTPS management (planned) |
| Bitwarden Lite | Self-hosted password management (planned) |

## Container Management

Portainer Community Edition provides centralized Docker management across all three permanent Docker environments.

```text
                       docker-lab-01
                      Portainer CE Server
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
         docker-lab-01  monitor-lab-01  media-lab-01
             Local        Agent 9001      Agent 9001
                │             │             │
                ▼             ▼             ▼
          Docker Engine  Docker Engine  Docker Engine
```

`docker-lab-01` is connected to Portainer as the local Docker environment.

`monitor-lab-01` and `media-lab-01` run Portainer Agent, allowing their Docker Engines to be managed remotely through the central Portainer interface.

Portainer manages the Docker layer only. Proxmox VE remains responsible for VM lifecycle, virtual hardware, and the underlying virtualization platform.

Docker Compose remains the source of truth for important service configuration, while Portainer provides centralized visibility and routine administration.

See [portainer.md](portainer.md) for the detailed Portainer architecture and deployment design.

## Application Services

General self-hosted applications run on `docker-lab-01`.

```text
docker-lab-01
      │
      ├── Portainer CE
      ├── Homepage
      ├── Nginx Proxy Manager  (planned)
      └── Bitwarden Lite       (planned)
```

This host provides the primary environment for general-purpose containerized applications that do not require dedicated workload isolation.

Nginx Proxy Manager is planned to provide centralized hostname-based routing and HTTPS/TLS management for internal web services.

The initial reverse proxy deployment will remain internal to the lab without requiring Internet-facing router port forwarding.

## Monitoring and Observability

`monitor-lab-01` provides the dedicated monitoring and observability environment.

```text
                       monitor-lab-01
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
     Uptime Kuma          Prometheus             Loki
          │                   │                   ▲
          │                   │                   │
          │                   ▼                   │
          │                Grafana ◄──────────────┤
          │                   │                   │
          │                   │              Grafana Alloy
          │                   │
          │                   ▼
          │              Alertmanager
          │
          └──────────────► Availability
                            Monitoring
```

The monitoring stack provides several complementary capabilities:

- **Uptime Kuma** provides availability and basic synthetic service monitoring.
- **Prometheus** provides infrastructure and service metrics collection.
- **Grafana** provides metrics and log visualization.
- **Loki** provides centralized log aggregation.
- **Grafana Alloy** provides telemetry and log collection.
- **Alertmanager** provides alert handling for Prometheus-based monitoring.

Monitoring targets include infrastructure systems, virtualization hosts, Docker hosts, containers, network services, and application endpoints.

The metrics architecture supports additional exporters as monitoring coverage expands.

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus ───► Grafana
Blackbox Exporter ──┘          │
                               └──► Alertmanager

Servers / Containers ─► Grafana Alloy ─► Loki ─► Grafana

Services / Endpoints ─► Uptime Kuma
```

Keeping the monitoring stack on a dedicated Docker VM separates observability workloads from the primary application and media environments.

A future enhancement may introduce an additional Uptime Kuma instance on infrastructure outside `monitor-lab-01`, providing availability-monitoring redundancy if the primary monitoring VM or its Proxmox host becomes unavailable.

## Media and Storage

Jellyfin runs as a containerized workload on the dedicated `media-lab-01` VM.

```text
Proxmox VE Cluster
       │
       ▼
  media-lab-01
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

Jellyfin was migrated from a host-based installation to Docker Compose to improve portability and simplify service recreation, migration, and backup workflows.

Media content is accessed from network-mounted NAS storage, while persistent Jellyfin application data and configuration are maintained outside the disposable container filesystem using bind mounts where appropriate.

Separating media storage from the application container allows Jellyfin to be recreated or migrated without relocating the underlying media library.

Because Jellyfin is used as a persistent household service, `media-lab-01` maintains its own lifecycle, resource allocation, backup considerations, and maintenance schedule.

## Storage Integration

The NAS provides centralized network storage for media, backups, and other shared data.

```text
                      nas-lab
                         │
             ┌───────────┼───────────┐
             ▼           ▼           ▼
          Backups      Media     Shared Data
                         │
                         ▼
                    media-lab-01
                         │
                         ▼
                      Jellyfin
```

This separation keeps persistent data independent from the lifecycle of individual application containers and service VMs.

## Deployment Model

Containers are deployed using Docker Compose, with service configuration and persistent data organized under `/opt/docker` on the appropriate host.

### `docker-lab-01`

```text
/opt/docker/
├── portainer/
├── homepage/
├── nginx-proxy-manager/  (planned)
└── bitwarden-lite/       (planned)
```

### `monitor-lab-01`

```text
/opt/docker/
├── uptime-kuma/
├── prometheus/
├── grafana/
├── loki/
├── alertmanager/
└── grafana-alloy/
```

### `media-lab-01`

```text
/opt/docker/
└── jellyfin/
```

Each service is deployed independently with its own configuration and persistence requirements.

Docker Compose provides reproducible service definitions, while bind mounts and Docker-managed storage are selected according to the persistence, visibility, backup, and migration requirements of each workload.

Repository-managed configuration is maintained separately from runtime secrets and environment-specific data.

Example Compose configurations are maintained under the repository `configs/` directory, including configurations for Portainer CE Server and Portainer Agent deployments.

## Current Deployment State

| Capability | Status |
|---|---|
| Docker platform | 🟢 Operational |
| Multi-host Portainer management | 🟢 Operational |
| Portainer CE Server | 🟢 Operational |
| Portainer Agents | 🟢 Operational |
| Homepage | 🟢 Operational |
| Uptime Kuma | 🟢 Operational |
| Prometheus | 🟢 Operational |
| Grafana | 🟢 Operational |
| Loki | 🟢 Operational |
| Grafana Alloy | 🟢 Operational |
| Alertmanager | 🟢 Operational |
| Jellyfin Docker deployment | 🟢 Operational |
| NAS media integration | 🟢 Operational |
| Nginx Proxy Manager | ⚪ Planned |
| Bitwarden Lite | ⚪ Planned |
| Expanded exporter coverage | 🟡 In Progress |
| Secondary availability monitoring | ⚪ Future Enhancement |

## Design Decisions

### Workload Separation

General applications, monitoring, and media services are separated across dedicated Docker VMs rather than placing every container on a single host.

Each Docker VM is distributed across a different Proxmox node, providing operational separation and independent resource allocation.

### Dedicated Monitoring Host

Monitoring and observability services are consolidated on `monitor-lab-01`.

This keeps metrics, logging, visualization, alerting, and availability monitoring separate from the primary application and media environments.

### Centralized Docker Management

Portainer CE provides a single management interface across the three Docker environments.

The central Portainer Server runs on `docker-lab-01`, while Portainer Agent provides remote management of `monitor-lab-01` and `media-lab-01`.

Portainer remains a management layer rather than a runtime dependency for deployed containers.

### Dedicated Media Host

Jellyfin is isolated from general-purpose application workloads because it is a persistent service with different storage, availability, and resource requirements.

### Network-Based Media Storage

Media content remains on centralized NAS storage rather than inside the Jellyfin VM.

This separates the application lifecycle from the media-data lifecycle and simplifies migration and recovery.

### Docker Compose

Docker Compose provides declarative and reproducible service definitions while remaining appropriate for the scale of the current environment.

Compose configuration remains independent of Portainer so the Docker environment can be administered and recovered without relying exclusively on the Portainer management database.

## Future Enhancements

- Deploy Nginx Proxy Manager
- Configure internal DNS for proxied service hostnames
- Configure reverse proxy hosts
- Configure and validate internal HTTPS/TLS
- Expand Prometheus metrics coverage
- Expand centralized log collection
- Expand network-device monitoring
- Complete additional alerting workflows
- Expand automated backup procedures
- Implement UPS-backed graceful shutdown
- Evaluate a secondary Uptime Kuma deployment for monitoring redundancy
- Add additional self-hosted services
- Continue configuration standardization and automation

## Related Documentation

| Document | Purpose |
|---|---|
| [portainer-deployment.md](portainer-deployment.md) | Portainer CE and multi-host Agent architecture |
| [reverse-proxy.md](reverse-proxy.md) | Reverse proxy deployment and design |
| [docker-installation.md](../../docs/reference/docker/docker-installation.md) | Docker installation procedure |
| [docker-container-deployment.md](../../docs/reference/docker/docker-container-deployment.md) | Container deployment standard |
| [docker-concepts.md](../../docs/reference/docker/docker-concepts.md) | Docker concepts and terminology |
| [uptime-kuma-reference.md](../../docs/reference/uptime-kuma/uptime-kuma-reference.md) | Uptime Kuma reference guide |
| [lessons-learned.md](lessons-learned.md) | Operational findings and decisions |
