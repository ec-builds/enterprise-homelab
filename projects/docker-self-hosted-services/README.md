# 🐳 Docker & Self-Hosted Services

**Status: 🟡 In Progress**

Containerized self-hosted applications running on dedicated Debian Docker hosts. Services are deployed with Docker Compose and managed as version-controlled infrastructure-as-code.

## Overview

This project deploys, manages, and documents self-hosted services using Docker and Docker Compose. It serves as a platform for learning container operations, networking, monitoring, and backup strategies, with the long-term goal of a repeatable self-hosted platform and foundational skills for future Kubernetes work.

Services are separated by operational role where appropriate. General self-hosted applications run on the primary Docker host (`docker-lab`), while monitoring and observability services run on a dedicated monitoring host (`monitor-lab`).

Separating monitoring from the primary application host provides better fault isolation. If `docker-lab` becomes unavailable, the monitoring stack remains operational and can continue reporting the outage and monitoring the rest of the environment.

## Services

| Host | Category | Service | Status |
|------|----------|---------|--------|
| `docker-lab` | Management | Portainer | 🟡 In Progress |
| `docker-lab` | Dashboard | Homepage | ⚪ Planned |
| `docker-lab` | Productivity | Vaultwarden | ⚪ Planned |
| `monitor-lab` | Monitoring | Uptime Kuma | 🟢 Deployed |
| `monitor-lab` | Monitoring | Prometheus | ⚪ Planned |
| `monitor-lab` | Monitoring | Grafana | ⚪ Planned |
| `monitor-lab` | Logging | Loki | ⚪ Planned |

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

The monitoring host is placed separately from the primary Docker host so monitoring remains available if the application host becomes unavailable.

Compose files are version-controlled in this repository under `services/` and deployed to `/opt/docker` on the appropriate host. See [architecture.md](architecture.md) for the complete environment topology.

## Host Roles

### docker-lab

The primary Docker host runs general self-hosted applications and management services.

Planned responsibilities include:

- Container management
- Internal dashboards
- Productivity applications
- Future self-hosted services

### monitor-lab

The monitoring host provides centralized monitoring, metrics, visualization, and logging for the environment.

Planned responsibilities include:

- Service availability monitoring
- Infrastructure metrics collection
- Metrics visualization
- Centralized log aggregation

Running monitoring on a separate host reduces dependency on `docker-lab` and allows monitoring to remain available during maintenance or failure of the primary application host.

## What's Next

### Docker Services

- [ ] Deploy Portainer
- [ ] Deploy Homepage
- [ ] Deploy Vaultwarden

### Monitoring Stack

- [ ] Deploy Prometheus
- [ ] Deploy Grafana
- [ ] Deploy Loki
- [ ] Create baseline dashboards
- [ ] Add infrastructure monitoring targets

### Networking

- [ ] Create custom Docker networks
- [ ] Evaluate reverse proxy and TLS options
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
- Persistent data is stored in Docker volumes; containers are treated as disposable and recreatable without data loss.
- Monitoring and logging data use defined retention policies to prevent uncontrolled storage growth.
