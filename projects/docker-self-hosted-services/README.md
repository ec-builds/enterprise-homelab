# 🐳 Docker & Self-Hosted Services

**Status: 🟡 In Progress**

Containerized self-hosted applications running on dedicated Debian Docker hosts. Services are deployed with Docker Compose and managed as version-controlled infrastructure-as-code.

## Overview

This project deploys, manages, and documents self-hosted services using Docker and Docker Compose. It serves as a platform for learning container operations, networking, monitoring, and backup strategies, with the long-term goal of a repeatable self-hosted platform and foundational skills for future Kubernetes work.

Services are separated by operational role where appropriate. General self-hosted applications run on the primary Docker host (`docker-lab`), while monitoring and observability services run on a dedicated monitoring host (`monitor-lab`).

Separating monitoring from the primary application host provides better fault isolation. If `docker-lab` becomes unavailable, the monitoring stack remains operational and can continue reporting the outage and monitoring the rest of the environment.

## Services

### Docker Lab

| Node | VM | Category | Service | Status |
|---|---|---|---|---|
| `prox-lab-01` | `docker-lab-vm` | Management | Portainer | 🟢 Deployed |
| `prox-lab-01` | `docker-lab-vm` | Dashboard | Homepage | 🟢 Deployed |
| `prox-lab-01` | `docker-lab-vm` | Reverse Proxy | Nginx Proxy Manager | ⚪ Planned |
| `prox-lab-01` | `docker-lab-vm` | Password Management | Bitwarden Lite | ⚪ Planned |

### Monitoring Lab

| Node | VM | Category | Service | Status |
|---|---|---|---|---|
| `prox-lab-02` | `monitor-lab-vm` | Availability Monitoring | Uptime Kuma | 🟢 Deployed |
| `prox-lab-02` | `monitor-lab-vm` | Metrics | Prometheus | 🟢 Deployed |
| `prox-lab-02` | `monitor-lab-vm` | Visualization | Grafana | 🟢 Deployed |
| `prox-lab-02` | `monitor-lab-vm` | Logging | Loki | 🟢 Deployed |
| `prox-lab-02` | `monitor-lab-vm` | Alerting | Alertmanager | 🟢 Deployed |
| `prox-lab-02` | `monitor-lab-vm` | Log Collection | Grafana Alloy | 🟢 Deployed |
| `prox-lab-02` | `monitor-lab-vm` | Host Metrics | Node Exporter | ⚪ Planned |
| `prox-lab-02` | `monitor-lab-vm` | Container Metrics | cAdvisor | ⚪ Planned |
| `prox-lab-02` | `monitor-lab-vm` | Network Metrics | SNMP Exporter | ⚪ Planned |
| `prox-lab-02` | `monitor-lab-vm` | Availability Metrics | Blackbox Exporter | ⚪ Planned |

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus ───► Grafana
Blackbox Exporter ──┘          │
                               └──► Alertmanager

Servers/Containers ──► Alloy ──► Loki ──► Grafana

Uptime Kuma ──► Independent uptime checks/notifications
```

### Media Lab

| Node | VM | Category | Service | Status |
|---|---|---|---|---|
| `prox-lab-03` | `media-lab-vm` | Media Server | Jellyfin | ⚪ Planned |

> [!NOTE]
> Media services (Jellyfin) currently run on a separate Debian-based media host. A future migration will move these services from the existing physical host to the Proxmox environment, either as containers on `docker-lab` or on a dedicated media services VM. See [architecture.md](architecture.md) for the full environment topology.

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
    │   ├── Nginx Proxy Manager  (planned)
    │   ├── Portainer            (deployed)
    │   ├── Homepage             (deployed)
    │   └── Bitwarden Lite       (planned)
    │
    └── monitor-lab (Debian VM)
        │  (monitoring and observability)
        ├── Uptime Kuma          (deployed)
        ├── Prometheus           (deployed)
        ├── Grafana              (deployed)
        ├── Loki                 (deployed)
        ├── Alertmanager         (deployed)
        │
        └── Supporting Components
            ├── Grafana Alloy     (deployed)
            ├── Node Exporter     (planned)
            ├── cAdvisor          (planned)
            ├── SNMP Exporter     (planned)
            └── Blackbox Exporter (planned)
```


The monitoring host is placed separately from the primary Docker host so monitoring remains available if the application host becomes unavailable.

Nginx Proxy Manager will provide centralized hostname-based routing and HTTPS management for web services. Initial deployment will remain internal to the lab and will not require Internet-facing router port forwarding.

Compose files are version-controlled in this repository under `configs/` and deployed to `/opt/docker` on the appropriate host. See [architecture.md](architecture.md) for the complete environment topology.

## Host Roles

### docker-lab

The primary Docker host runs general self-hosted applications and management services.

Planned responsibilities include:

- Container management
- Internal dashboards
- Reverse proxy and HTTPS management
- Productivity applications
- Future self-hosted services

### monitor-lab

The monitoring host provides centralized monitoring, metrics, visualization, and logging for the environment.

Responsibilities include:

- Service availability monitoring
- Infrastructure metrics collection
- Metrics visualization
- Centralized log aggregation
- Alerting

Running monitoring on a separate host reduces dependency on `docker-lab` and allows monitoring to remain available during maintenance or failure of the primary application host.

## What's Next

### Docker Services

- [x] Deploy Portainer
- [x] Deploy Homepage
- [ ] Deploy Nginx Proxy Manager
- [ ] Deploy Bitwarden Lite

### Monitoring Stack

- [x] Deploy Uptime Kuma
- [x] Deploy Prometheus
- [x] Deploy Grafana
- [x] Deploy Loki
- [x] Deploy Alertmanager
- [x] Deploy Grafana Alloy
- [ ] Deploy Node Exporter
- [ ] Deploy cAdvisor
- [ ] Deploy SNMP Exporter
- [ ] Deploy Blackbox Exporter
- [ ] Create baseline dashboards
- [ ] Add infrastructure monitoring targets

### Networking

- [ ] Deploy Nginx Proxy Manager
- [ ] Configure internal DNS for service hostnames
- [ ] Configure reverse proxy hosts
- [ ] Configure and validate HTTPS/TLS
- [ ] Create custom Docker networks
- [ ] Document service exposure strategy

### Operations

- [ ] Standardize Compose and `.env` templates
- [ ] Configure Docker volume backups
- [ ] Define monitoring data retention
- [ ] Document upgrade and disaster recovery procedures

## Reference Documentation

Foundational Docker documentation is maintained centrally under `docs/reference/`:

| Document | Purpose |
|----------|---------|
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
