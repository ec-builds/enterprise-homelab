# Architecture

The components of the Docker & Self-Hosted Services environment and how they fit together. Installation, deployment and troubleshooting steps are in separate documents.

## Current Architecture

Three Debian VMs run Docker, one on each node of the Proxmox VE cluster, each with its own role:

```text
                         Proxmox VE Cluster
                                │
              ┌─────────────────┼─────────────────┐
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

| VM | Role |
|---|---|
| `docker-lab-01` | General self-hosted applications and the Portainer CE Server |
| `monitor-lab-01` | Monitoring and observability |
| `media-lab-01` | Media services |

Putting each VM on its own node keeps the workloads separate and lets each one be maintained independently.

## Components

| Component | Role |
|---|---|
| Proxmox VE Cluster | Three-node virtualization platform for the Docker VMs |
| `nas-lab` | Shared storage, backups and the media library |
| Portainer CE / Portainer Agent | Docker management across all three VMs |
| Homepage | Internal service dashboard |
| Uptime Kuma | Availability and synthetic service monitoring |
| Prometheus | Metrics collection |
| Grafana | Metrics and log visualization |
| Loki | Log aggregation |
| Alertmanager | Prometheus alert management |
| Grafana Alloy | Telemetry and log collection |
| Jellyfin | Media streaming |
| Nginx Proxy Manager | Reverse proxy and HTTPS (planned) |
| Bitwarden Lite | Self-hosted password manager (planned) |

## Container Management

One Portainer CE Server on `docker-lab-01` manages all three Docker hosts: its own engine directly, and `monitor-lab-01` and `media-lab-01` through Portainer Agent on TCP 9001. Portainer manages Docker only; Proxmox still handles the VMs themselves. Compose files remain the source of truth for service configuration.

Details are in [Portainer CE Deployment](./portainer.md).

## Application Services

`docker-lab-01` runs general-purpose applications that don't need their own VM:

```text
docker-lab-01
      ├── Portainer CE
      ├── Homepage
      ├── Nginx Proxy Manager  (planned)
      └── Bitwarden Lite       (planned)
```

Nginx Proxy Manager is planned for hostname-based routing and HTTPS for internal web services. The first deployment will stay internal, with no port forwarding from the internet.

## Monitoring and Observability

`monitor-lab-01` runs the monitoring stack:

| Service | Role |
|---|---|
| Uptime Kuma | Availability and basic synthetic checks |
| Prometheus | Infrastructure and service metrics |
| Grafana | Metrics and log dashboards |
| Loki | Log storage |
| Grafana Alloy | Log and telemetry collection |
| Alertmanager | Alert handling for Prometheus |

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus ───► Grafana
Blackbox Exporter ──┘          │
                               └──► Alertmanager

Servers / Containers ─► Grafana Alloy ─► Loki ─► Grafana

Services / Endpoints ─► Uptime Kuma
```

It monitors infrastructure systems, virtualization hosts, Docker hosts, containers, network services and application endpoints. Keeping the stack on its own VM separates it from application and media workloads. A second Uptime Kuma instance outside `monitor-lab-01` may be added later, so availability monitoring survives the loss of that VM or its Proxmox host.

The full monitoring design is in the [Infrastructure Monitoring](../infrastructure-monitoring/README.md) project.

## Media and Storage

Jellyfin runs in Docker Compose on `media-lab-01` and reads its media library from `nas-lab` over the network:

```text
media-lab-01 ──► Docker Compose ──► Jellyfin ──► nas-lab (media storage)
```

- **Moved to Compose.** Jellyfin was migrated from a host-based install to Docker Compose so it's easier to recreate, migrate and back up.
- **Persistent config.** Jellyfin's configuration and data live outside the container in bind mounts, and the media stays on the NAS. The container can be rebuilt or moved without touching the library.
- **Its own VM.** Jellyfin is a household service, so `media-lab-01` keeps its own lifecycle, resources, backups and maintenance schedule.

`nas-lab` also holds backups and other shared data, keeping persistent data independent of any one container or VM.

## Deployment Model

Each service is deployed with Docker Compose, with its configuration and data under `/opt/docker/<service>` on its host:

```text
docker-lab-01:  /opt/docker/{portainer, homepage, nginx-proxy-manager (planned), bitwarden-lite (planned)}
monitor-lab-01: /opt/docker/{uptime-kuma, prometheus, grafana, loki, alertmanager, grafana-alloy}
media-lab-01:   /opt/docker/jellyfin
```

Bind mounts or Docker-managed volumes are chosen per service based on persistence, visibility, backup and migration needs. Runtime secrets and environment-specific data are kept out of the repository. Example Compose files, including Portainer Server and Agent, are under [`configs/docker`](../../configs/docker/).

## Current Deployment State

| Capability | Status |
|---|---|
| Docker platform | 🟢 Operational |
| Multi-host Portainer management | 🟢 Operational |
| Homepage | 🟢 Operational |
| Uptime Kuma | 🟢 Operational |
| Prometheus | 🟢 Operational |
| Grafana | 🟢 Operational |
| Loki | 🟢 Operational |
| Grafana Alloy | 🟢 Operational |
| Alertmanager | 🟡 In Progress |
| Jellyfin Docker deployment | 🟢 Operational |
| NAS media integration | 🟢 Operational |
| Nginx Proxy Manager | ⚪ Planned |
| Bitwarden Lite | ⚪ Planned |
| Expanded exporter coverage | 🟡 In Progress |
| Secondary availability monitoring | ⚪ Planned |

## Design Decisions

- **Separate VMs by workload.** Applications, monitoring and media each have their own Docker VM on a different Proxmox node, with their own resources.
- **Dedicated monitoring host.** Metrics, logs, dashboards, alerting and availability checks run apart from the services they watch.
- **One Docker management interface.** Portainer gives a single view of all three hosts, but containers don't depend on it to keep running.
- **Dedicated media host.** Jellyfin has different storage, availability and resource needs from general applications.
- **Media on the NAS.** Keeping media off the Jellyfin VM separates the application from its data and simplifies migration and recovery.
- **Docker Compose.** Compose gives reproducible service definitions at this scale, and because it's independent of Portainer, the hosts can be managed and recovered without the Portainer database.

## Future Enhancements

- Deploy Nginx Proxy Manager, with internal DNS names, proxy hosts and validated internal HTTPS
- Expand Prometheus metrics, log collection and network-device monitoring
- Complete additional alerting workflows
- Expand automated backups
- Add UPS-backed graceful shutdown
- Evaluate a second Uptime Kuma deployment for monitoring redundancy
- Add more self-hosted services
- Keep standardizing and automating configuration
