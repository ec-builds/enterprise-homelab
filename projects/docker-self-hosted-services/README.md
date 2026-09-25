# 🐳 Docker & Self-Hosted Services

**Status: 🟡 In Progress**

Containerized self-hosted applications running across dedicated Debian Docker hosts. Services are deployed using version-controlled Docker Compose configuration and centrally managed through Portainer Community Edition.

## Overview

This project deploys and manages self-hosted services using Docker and Docker Compose. It provides a platform for developing practical experience with container operations, service networking, monitoring, persistent storage, backup strategies, and multi-host Docker administration.

Workloads are separated by operational role across the Proxmox VE cluster:

- `docker-lab-01` hosts general applications and centralized Docker management.
- `monitor-lab-01` provides independent availability monitoring.
- `media-lab-01` hosts containerized media services.
- `test-docker-lab` provides a temporary environment for monitoring stack validation.

Separating workloads by role provides better fault isolation and allows application, monitoring, and media services to be maintained independently.

## Architecture

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
       Portainer CE          Uptime Kuma          Jellyfin
          Server          Portainer Agent     Portainer Agent
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                       Centralized Docker
                          Management


                       test-docker-lab
                                │
                    Monitoring Validation
                                │
                 Prometheus / Grafana / Loki
                  Alertmanager / Grafana Alloy
```

The three permanent Docker environments are distributed across separate Proxmox nodes.

Portainer CE runs on `docker-lab-01` and provides centralized management of all three environments. `monitor-lab-01` and `media-lab-01` connect to the central Portainer Server through Portainer Agent.

The broader monitoring stack is currently being validated on `test-docker-lab` before permanent deployment.

## Docker Hosts

| Host | Role | Current Workloads |
|---|---|---|
| `docker-lab-01` | General applications and Docker management | Portainer CE, Homepage |
| `monitor-lab-01` | Independent availability monitoring | Uptime Kuma, Portainer Agent |
| `media-lab-01` | Media services | Jellyfin, Portainer Agent |
| `test-docker-lab` | Temporary monitoring validation | Prometheus, Grafana, Loki, Alertmanager, Grafana Alloy |

## Services

### General Applications

| Node | Docker Host | Category | Service | Status |
|---|---|---|---|---|
| `prox-lab-01` | `docker-lab-01` | Management | Portainer CE | 🟢 Deployed |
| `prox-lab-01` | `docker-lab-01` | Dashboard | Homepage | 🟢 Deployed |
| `prox-lab-01` | `docker-lab-01` | Reverse Proxy | Nginx Proxy Manager | ⚪ Planned |
| `prox-lab-01` | `docker-lab-01` | Password Management | Bitwarden Lite | ⚪ Planned |

### Monitoring and Observability

Uptime Kuma is deployed independently on `monitor-lab-01` for service and infrastructure availability monitoring.

The broader monitoring stack has been deployed and tested on `test-docker-lab`. These services remain in the validation environment pending final deployment to the permanent Docker environment.

| Environment | Category | Service | Status |
|---|---|---|---|
| `monitor-lab-01` | Availability Monitoring | Uptime Kuma | 🟢 Deployed |
| `test-docker-lab` | Metrics | Prometheus | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Visualization | Grafana | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Logging | Loki | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Alerting | Alertmanager | 🟡 Tested / Pending Permanent Deployment |
| `test-docker-lab` | Log Collection | Grafana Alloy | 🟡 Tested / Pending Permanent Deployment |

The target monitoring architecture includes additional exporters as monitoring coverage expands.

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus ───► Grafana
Blackbox Exporter ──┘          │
                               └──► Alertmanager

Servers / Containers ─► Alloy ─► Loki ─► Grafana

Uptime Kuma ─► Independent availability checks and notifications
```

### Media Services

| Node | Docker Host | Category | Service | Deployment | Status |
|---|---|---|---|---|---|
| `prox-lab-03` | `media-lab-01` | Media Server | Jellyfin | Docker Compose | 🟢 Deployed |

Jellyfin runs as a Docker container on a dedicated Debian media VM hosted on the third Proxmox node.

The service was migrated from a host-based installation to Docker Compose to improve portability and simplify service recreation, migration, and backup workflows.

Persistent application data and required host resources are provided through bind mounts, while media storage is integrated from network-attached storage.

## Container Management

Portainer Community Edition provides centralized visibility and routine administration across the three permanent Docker environments.

```text
docker-lab-01
    │
    └── Portainer CE Server
              │
              ├──── Local ─────► docker-lab-01
              │
              ├── TCP 9001 ───► monitor-lab-01
              │                  Portainer Agent
              │
              └── TCP 9001 ───► media-lab-01
                                 Portainer Agent
```

Portainer complements rather than replaces the existing Docker administration model:

```text
Docker Compose = Service configuration and deployment
Docker CLI     = Direct administration and troubleshooting
Portainer CE   = Centralized management and visibility
```

Portainer manages the Docker Engines running inside the Docker VMs. Proxmox VE remains responsible for the underlying virtualization platform and VM lifecycle.

See [portainer.md](portainer.md) for the detailed Portainer architecture and deployment design.

## Configuration Management

Docker Compose remains the source of truth for important container deployments.

Version-controlled Compose configurations and examples are maintained under:

```text
configs/
```

This includes `docker-compose.yaml` examples for the Portainer CE Server and Portainer Agent deployments.

Configurations are deployed to the appropriate Docker hosts, where persistent service data is generally maintained outside the disposable container filesystem using bind mounts or Docker volumes as appropriate.

This approach keeps deployments reproducible while allowing services to be recreated, migrated, and backed up independently of Portainer.

See [architecture.md](architecture.md) for the broader Docker environment architecture.

## What's Next

### Docker Services

- [x] Deploy Portainer CE
- [x] Deploy Portainer Agent across remote Docker hosts
- [x] Deploy Homepage
- [ ] Deploy Nginx Proxy Manager
- [ ] Deploy Bitwarden Lite

### Monitoring and Observability

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
- [ ] Expand infrastructure monitoring targets

### Media Services

- [x] Create dedicated media services VM
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
- [ ] Create required custom Docker networks
- [ ] Document service exposure strategy

### Operations

- [ ] Standardize Compose and `.env` templates
- [ ] Configure Docker volume and bind-mount backups
- [ ] Define monitoring data retention
- [ ] Document upgrade and disaster recovery procedures

## Security Notes

- Secrets are not committed to source control; `.env` files are excluded through `.gitignore`.
- Public configuration examples exclude credentials and other sensitive values.
- Portainer is treated as part of the privileged infrastructure management plane.
- Portainer and Agent interfaces are not intentionally exposed to the public Internet.
- Administrative access is restricted to trusted networks or VPN access.
- Docker socket access is treated as highly privileged.
- Persistent application data is maintained outside disposable container filesystems where appropriate.
- Reverse proxy services will initially remain internal to the lab without Internet-facing router port forwarding.

## Reference Documentation

Foundational Docker documentation is maintained centrally under `docs/reference/`:

| Document | Purpose |
|---|---|
| [docker-installation.md](../../docs/reference/docker/docker-installation.md) | Docker Engine and Compose installation |
| [docker-container-deployment.md](../../docs/reference/docker/docker-container-deployment.md) | Standard container deployment process |
| [docker-concepts.md](../../docs/reference/docker/docker-concepts.md) | Core Docker concepts and architecture |
| [docker-command-reference.md](../../docs/reference/docker/docker-command-reference.md) | Administration and troubleshooting commands |

> [!NOTE]
> Reference documentation is maintained outside this project directory to avoid duplication and drift. Project documentation focuses on the deployed architecture, implementation decisions, and current environment state.
