# 🐳 Docker & Self-Hosted Services

**Status: 🔨 In Progress**

Containerized self-hosted applications running on a dedicated Debian Docker host. Services are deployed using Docker Compose and managed through infrastructure-as-code principles.

## Overview

This project focuses on deploying, managing, and documenting self-hosted services using Docker and Docker Compose.

The environment serves as a platform for learning modern container operations, service management, monitoring, networking, backup strategies, and infrastructure documentation.

The long-term objective is to build a documented and repeatable self-hosted services platform while developing foundational skills applicable to enterprise infrastructure and future Kubernetes deployments.

---

## Objectives

- Deploy and maintain self-hosted applications using Docker Compose
- Manage container configurations through version-controlled Compose files
- Implement container networking and service isolation
- Configure persistent storage and backup procedures
- Monitor service availability and container health
- Document deployment, maintenance, and recovery procedures
- Establish operational standards and reusable documentation
- Prepare foundational knowledge for future Kubernetes workloads

---

## Technologies

| Category | Technologies |
|-----------|-----------|
| Container Platform | Docker Engine, Docker Compose, containerd, Docker Buildx |
| Monitoring & Observability | Uptime Kuma, Prometheus, Grafana, Loki |
| Service Management | Homepage, Dockge (planned), Portainer (evaluation) |
| Networking & Security | Custom Docker Networks, Reverse Proxy, TLS Certificates, Environment Variables (`.env`) |
| Backup & Recovery | Docker Volumes, Volume Backup Procedures, Disaster Recovery Documentation |

---

## Planned Services

| Category | Service | Status |
|----------|----------|----------|
| Monitoring | Uptime Kuma | ✅ Deployed |
| Monitoring | Prometheus | 📋 Planned |
| Monitoring | Grafana | 📋 Planned |
| Logging | Loki | 📋 Planned |
| Dashboard | Homepage | 📋 Planned |
| Management | Dockge | 📋 Planned |
| Management | Portainer | Research |
| Network | AdGuard Home | Research |
| Productivity | Vaultwarden | Future |
| Automation | n8n | Future |
| Utilities | Stirling-PDF | Future |

---

## Architecture

```text
Internet
    │
    ▼
ASUS RT-AX5400
    │
    ▼
Docker Host (infra01)
    │
    ├── Uptime Kuma
    ├── Homepage
    ├── Prometheus
    ├── Grafana
    ├── Loki
    └── Additional Services
```

All services are deployed as independent containers and managed through Docker Compose.

---

## Key Tasks

### Platform Setup

- [x] Install Docker Engine
- [x] Install Docker Compose Plugin
- [x] Configure Docker Repository and GPG Key
- [x] Configure Non-Root Docker Access
- [x] Create Docker project directory structure (`/opt/docker`)
- [x] Establish Docker deployment standards
- [x] Create Docker reference documentation

### Monitoring Stack

- [x] Deploy Uptime Kuma
- [x] Configure basic uptime monitoring
- [ ] Deploy Prometheus
- [ ] Deploy Grafana
- [ ] Deploy Loki
- [ ] Create baseline dashboards

### Networking

- [ ] Create custom Docker networks
- [ ] Evaluate reverse proxy solutions
- [ ] Implement TLS certificates
- [ ] Document service exposure strategy

### Operations

- [ ] Standardize Compose file templates
- [ ] Implement `.env` templates
- [ ] Configure backups for Docker volumes
- [ ] Document upgrade procedures
- [ ] Document disaster recovery procedures

---

## Documentation Standards

Each deployed service should include:

- Purpose
- Architecture diagram
- Docker Compose configuration
- Port assignments
- Storage locations
- Backup requirements
- Update procedures
- Lessons learned

Documentation should be updated whenever deployment procedures, architecture, or operational processes change.

---

## Reference Documentation

Foundational Docker documentation is maintained centrally under:

```text
docs/reference/
```

The following documents serve as authoritative references for this project:

| Document | Purpose |
|----------|----------|
| [docker-installation.md](../../docs/reference/docker-installation.md) | Docker Engine and Docker Compose installation procedures |
| [docker-container-deployment.md](../../docs/reference/docker-container-deployment.md) | Standard process for deploying Docker Compose applications |
| [docker-concepts.md](../../docs/reference/docker-concepts.md) | Core Docker concepts and architecture |
| [docker-command-reference.md](../../docs/reference/docker-command-reference.md) | Common Docker administration and troubleshooting commands |

> [!NOTE]
> Reference documentation is intentionally maintained outside of this project directory to avoid duplication and documentation drift. Project-specific documentation should reference these guides rather than duplicate their contents.

---

## Related Projects

- [kubernetes-lab](../kubernetes-lab/) — Future orchestration platform
- [backup-disaster-recovery](../backup-disaster-recovery/) — Volume backup and restore procedures
- [network-infrastructure](../network-infrastructure/) — Networking and service exposure
- [monitoring-observability](../monitoring-observability/) — Monitoring stack architecture and dashboards

---

## Folder Structure

```text
docker-self-hosted-services/
├── README.md
├── lessons-learned.md
├── services/
│   ├── uptime-kuma/
│   ├── prometheus/
│   ├── grafana/
│   └── loki/
├── diagrams/
├── scripts/
└── screenshots/
```

> [!NOTE]
> Reusable technical references are maintained under `docs/reference/` rather than within this project directory.

---

## Security Notes

- Secrets are never committed to source control.
- `.env` files are excluded through `.gitignore`.
- Example configuration files are provided as templates.
- Services are deployed with least-privilege principles whenever possible.
- Administrative access is restricted to authorized users.
- Persistent application data is stored in Docker volumes whenever possible.
- Containers are considered disposable and should be able to be recreated without data loss.

---

## Current Progress Summary

Completed:

- Docker Engine installation
- Docker Compose installation
- Docker repository configuration
- Non-root Docker administration
- Docker deployment standards
- Docker concepts documentation
- Docker command reference
- Docker installation guide
- Docker deployment guide
- Uptime Kuma deployment
- Initial monitoring configuration
- Docker volume and container lifecycle validation

Next Priorities:

1. Expand Uptime Kuma monitoring coverage
2. Deploy Prometheus
3. Deploy Grafana
4. Implement backup procedures
5. Establish Docker networking standards
6. Evaluate reverse proxy solutions
7. Prepare monitoring and observability architecture
```
:::

This version better reflects the project's current reality: you've moved beyond "learning Docker" and are now building a documented platform with standards, references, deployment procedures, and operational practices.
