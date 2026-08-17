# 🐳 Docker & Self-Hosted Services

**Status: 🟡 In Progress**

Containerized self-hosted applications running on a dedicated Debian Docker host (`docker-lab`). Services are deployed with Docker Compose and managed as version-controlled infrastructure-as-code.

## Overview

This project deploys, manages, and documents self-hosted services using Docker and Docker Compose. It serves as a platform for learning container operations, monitoring, networking, and backup strategies, with the long-term goal of a repeatable self-hosted platform and foundational skills for future Kubernetes work.

## Services

| Category | Service | Status |
|----------|---------|--------|
| Monitoring | Uptime Kuma | 🟢 Deployed |
| Management | Portainer | 🟡 In Progress |
| Monitoring | Prometheus | ⚪ Planned |
| Monitoring | Grafana | ⚪ Planned |
| Logging | Loki | ⚪ Planned |
| Dashboard | Homepage | ⚪ Planned |
| Productivity | Vaultwarden | ⚪ Planned |

> [!NOTE]
> Media services (Jellyfin) run on a separate dedicated media host (`media-server-lab`), not on this Docker host. See [architecture.md](architecture.md) for the full topology.

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
    ▼
docker-lab (Debian VM)
    │  (infrastructure containers)
    ├── Uptime Kuma
    ├── Portainer
    ├── Homepage    (planned)
    ├── Prometheus  (planned)
    ├── Grafana     (planned)
    └── Loki        (planned)
```

Compose files are version-controlled in this repository under `services/` and deployed to `/opt/docker` on the host. See [architecture.md](architecture.md) for the complete environment topology.

## What's Next

### Monitoring Stack
- [ ] Deploy Prometheus, Grafana, and Loki
- [ ] Create baseline dashboards

### Management
- [ ] Deploy Portainer

### Networking
- [ ] Create custom Docker networks
- [ ] Evaluate reverse proxy and TLS options
- [ ] Document service exposure strategy

### Operations
- [ ] Standardize Compose and `.env` templates
- [ ] Configure Docker volume backups
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
