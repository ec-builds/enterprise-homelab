# 🐳 Docker & Self-Hosted Services

**Status: 🟡 In Progress**

Containerized self-hosted applications running on dedicated Debian Docker hosts. Services are deployed with Docker Compose and managed as version-controlled infrastructure-as-code.

## Overview

This project deploys, manages, and documents self-hosted services using Docker and Docker Compose. It serves as a platform for learning container operations, networking, monitoring, and backup strategies, with the long-term goal of a repeatable self-hosted platform and foundational skills for future Kubernetes work.

Services are separated by operational role where appropriate. General self-hosted applications run on the primary Docker host (`docker-lab`), monitoring and observability services are being validated before final deployment to their permanent Docker host, and media services run in Docker on a dedicated media VM on the third Proxmox node.

Separating workloads by operational role provides better fault isolation and allows application, monitoring, and media services to be maintained independently.

## Services

### Docker Lab

| Node | VM | Category | Service | Status |
|---|---|---|---|---|
| `prox-lab-01` | `docker-lab-vm` | Management | Portainer | 🟢 Deployed |
| `prox-lab-01` | `docker-lab-vm` | Dashboard | Homepage | 🟢 Deployed |
| `prox-lab-01` | `docker-lab-vm` | Reverse Proxy | Nginx Proxy Manager | ⚪ Planned |
| `prox-lab-01` | `docker-lab-vm` | Password Management | Bitwarden Lite | ⚪ Planned |

### Monitoring Stack

The monitoring stack has been deployed and tested on `test-docker-lab`. The services are operational in the test environment but are pending final deployment to the permanent `docker-lab-01` environment.

| Current Environment | Category | Service | Status |
|---|---|---|---|
| `monitor-lab-01` | Availability Monitoring | Uptime Kuma | 🟢 Deployed |
| `test-docker-lab` | Metrics | Prometheus | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Visualization | Grafana | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Logging | Loki | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Alerting | Alertmanager | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Log Collection | Grafana Alloy | 🟡 Tested / Pending Permanent Deployment |

Additional exporters will be introduced as monitoring coverage expands.

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus ───► Grafana
Blackbox Exporter ──┘          │
                               └──► Alertmanager

Servers/Containers ──► Alloy ──► Loki ──► Grafana

Uptime Kuma ──► Independent availability checks and notifications
```

### Media Lab

| Node | VM | Category | Service | Deployment | Status |
|---|---|---|---|---|---|
| `prox-lab-03` | `media-lab-vm` | Media Server | Jellyfin | Docker Compose | 🟢 Deployed |

> [!NOTE]
> Jellyfin runs as a Docker container on a dedicated Debian media VM hosted on the third Proxmox node. The service was migrated from a host-based installation to a containerized deployment to improve portability, simplify service recreation, and make configuration migration and backup workflows easier to manage.
>
> Persistent Jellyfin application data and required host resources are provided to the container using bind mounts, keeping persistent state outside the disposable container filesystem.

## Architecture

```text
Internet
    │
    ▼
Edge Router ──── VPN (remote access)
    │
    ▼
Firewall
    │
    ▼
Managed Switch
    │
    ├── docker-lab (Debian VM)
    │   │  (self-hosted applications)
    │   ├── Portainer             (deployed)
    │   ├── Homepage              (deployed)
    │   ├── Nginx Proxy Manager   (planned)
    │   └── Bitwarden Lite        (planned)
    │
    ├── monitor-lab-01
    │   └── Uptime Kuma           (deployed)
    │
    ├── test-docker-lab
    │   │  (monitoring stack validation)
    │   ├── Prometheus            (tested / pending)
    │   ├── Grafana               (tested / pending)
    │   ├── Loki                  (tested / pending)
    │   ├── Alertmanager          (tested / pending)
    │   └── Grafana Alloy         (tested / pending)
    │
    └── media-lab (Debian VM)
        │  (containerized media services)
        └── Jellyfin              (Docker / deployed)
```

The monitoring stack is currently running on `test-docker-lab`, where the services have been deployed and validated before final placement on the permanent Docker environment. Uptime Kuma is deployed independently on `monitor-lab-01` for availability monitoring.

Jellyfin runs as a Docker container on a dedicated Debian VM hosted on the third Proxmox node. The media workload remains separated from the primary application environment while using the same Docker Compose-based deployment approach.

Nginx Proxy Manager is planned to provide centralized hostname-based routing and HTTPS management for internal web services. Initial deployment will remain internal to the lab and will not require Internet-facing router port forwarding.

Compose files are version-controlled in this repository under `configs/` and deployed to `/opt/docker` on the appropriate host. See [architecture.md](architecture.md) for the complete environment topology.

## Host Roles

### docker-lab

The primary Docker host runs general self-hosted applications and management services.

Current and planned responsibilities include:

- Container management
- Internal dashboards
- Monitoring and observability services
- Reverse proxy and HTTPS management
- Productivity applications
- Future self-hosted services

The validated monitoring stack will be deployed to the permanent Docker environment after testing and configuration are finalized.

### monitor-lab-01

`monitor-lab-01` provides dedicated availability monitoring independently from the primary Docker application environment.

Current responsibilities include:

- Service availability monitoring
- Infrastructure availability checks
- Failure notifications

Uptime Kuma remains separated from the primary Docker host so availability monitoring can continue during maintenance or failure of the application environment.

### test-docker-lab

`test-docker-lab` provides a temporary environment for validating monitoring and observability services before permanent deployment.

Current responsibilities include:

- Infrastructure metrics collection
- Metrics visualization
- Centralized log aggregation
- Alerting
- Monitoring configuration validation

Once the monitoring stack is finalized, the validated configuration will be deployed to the permanent Docker environment.

### media-lab

`media-lab` is a dedicated Debian VM running on the third Proxmox node and hosts containerized media services.

Current services include:

- Jellyfin media server deployed with Docker
- Network-mounted media storage integration
- Persistent application data provided through bind mounts

Jellyfin was converted from a host-based installation to a Docker deployment. Containerizing the service separates the application runtime from the underlying Debian VM and makes the deployment easier to reproduce, migrate, and restore.

Persistent configuration and application data are maintained outside the container filesystem using bind mounts. This allows the container itself to remain disposable while important state can be backed up or transferred independently.

## What's Next

### Docker Services

- [x] Deploy Portainer
- [x] Deploy Homepage
- [ ] Deploy Nginx Proxy Manager
- [ ] Deploy Bitwarden Lite

### Monitoring Stack

- [x] Deploy Uptime Kuma to dedicated monitoring host
- [x] Deploy and test Prometheus
- [x] Deploy and test Grafana
- [x] Deploy and test Loki
- [x] Deploy and test Alertmanager
- [x] Deploy and test Grafana Alloy
- [ ] Deploy validated monitoring stack to permanent Docker environment
- [ ] Deploy Node Exporter
- [ ] Deploy cAdvisor
- [ ] Deploy SNMP Exporter
- [ ] Deploy Blackbox Exporter
- [ ] Create baseline dashboards
- [ ] Add infrastructure monitoring targets

### Media Services

- [x] Create dedicated media services VM on the third Proxmox node
- [x] Migrate Jellyfin to the Proxmox environment
- [x] Convert Jellyfin from host-based deployment to Docker
- [x] Deploy Jellyfin using Docker Compose
- [x] Configure persistent application data using bind mounts
- [x] Integrate network-mounted media storage

### Networking

- [ ] Deploy Nginx Proxy Manager
- [ ] Configure internal DNS for service hostnames
- [ ] Configure reverse proxy hosts
- [ ] Configure and validate HTTPS/TLS
- [ ] Create custom Docker networks
- [ ] Document service exposure strategy

### Operations

- [ ] Standardize Compose and `.env` templates
- [ ] Configure Docker volume and bind-mount backups
- [ ] Define monitoring data retention
- [ ] Document upgrade and disaster recovery procedures

## Reference Documentation

Foundational Docker documentation is maintained centrally under `docs/reference/`:

| Document | Purpose |
|---|---|
| [docker-installation.md](../../docs/reference/docker/docker-installation.md) | Docker Engine and Compose installation |
| [docker-container-deployment.md](../../docs/reference/docker/docker-container-deployment.md) | Standard container deployment process |
| [docker-concepts.md](../../docs/reference/docker/docker-concepts.md) | Core Docker concepts and architecture |
| [docker-command-reference.md](../../docs/reference/docker/docker-command-reference.md) | Common administration and troubleshooting commands |

> [!NOTE]
> Reference documentation is maintained outside this project directory to avoid duplication and drift. Project docs reference these guides rather than duplicate them.

## Security Notes

- Secrets are never committed to source control; `.env` files are excluded via `.gitignore`.
- Example configuration files are provided as templates.
- Services follow least-privilege principles, with administrative access restricted to authorized users.
- Persistent application data is stored outside the container filesystem using Docker volumes or bind mounts. Containers are treated as disposable and recreatable.
- Monitoring and logging data use defined retention policies to prevent uncontrolled storage growth.
- Reverse proxy services will initially remain internal to the lab without Internet-facing router port forwarding.
