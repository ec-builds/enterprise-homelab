# 🐳 Docker & Self-Hosted Services

**Status: 🔨 In Progress**

Containerized self-hosted applications running on a dedicated Debian Docker host. Services are deployed using Docker Compose and managed through infrastructure-as-code principles.

## Overview

This project focuses on deploying, managing, and documenting self-hosted services using Docker and Docker Compose.

The environment serves as a platform for learning modern container operations, service management, monitoring, networking, backup strategies, and infrastructure documentation.

## Objectives

- Deploy and maintain self-hosted applications using Docker Compose
- Manage container configurations through version-controlled compose files
- Implement container networking and service isolation
- Configure persistent storage and backup procedures
- Monitor service availability and container health
- Document deployment, maintenance, and recovery procedures
- Prepare foundational knowledge for future Kubernetes workloads


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
| Monitoring | Uptime Kuma | 📋 Planned |
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
Docker Host (Debian)
    │
    ├── Homepage
    ├── Uptime Kuma
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
- [ ] Create Docker project directory structure

### Monitoring Stack

- [ ] Deploy Uptime Kuma
- [ ] Configure uptime monitoring
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

- [ ] Standardize compose file structure
- [ ] Implement `.env` templates
- [ ] Configure backups for Docker volumes
- [ ] Document upgrade procedures
- [ ] Document disaster recovery procedures

---

## Documentation

Each deployed service should include:

- Purpose
- Architecture diagram
- Docker Compose configuration
- Port assignments
- Storage locations
- Backup requirements
- Update procedures
- Lessons learned

---

## Reference Documentation

To avoid duplication and documentation drift, foundational Docker documentation is maintained centrally under:

```text
docs/reference/
```

The following documents serve as the authoritative references for this project:

| Document | Purpose |
|----------|----------|
| [docker-installation.md](../../docs/reference/docker-installation.md) | Docker Engine and Docker Compose installation procedures |
| [docker-container-deployment.md](../../docs/reference/docker-container-deployment.md) | Standard process for deploying Docker Compose applications |
| [docker-concepts.md](../../docs/reference/docker-concepts.md) | Core Docker concepts and architecture |
| [docker-command-reference.md](../../docs/reference/docker-command-reference.md) | Common Docker administration and troubleshooting commands |

> [!NOTE]
> These documents are intentionally maintained outside of this project directory so they can be reused across multiple projects. Project-specific documentation should reference these guides rather than duplicate their contents. This helps ensure procedures remain consistent and reduces maintenance overhead when documentation is updated.

---

## Related Projects

- [kubernetes-lab](../kubernetes-lab/) — future orchestration platform
- [backup-disaster-recovery](../backup-disaster-recovery/) — volume backup and restore procedures
- [network-infrastructure](../network-infrastructure/) — networking and service exposure

---

## Folder Structure

```text
docker-self-hosted-services/
├── compose/            # Docker Compose files
├── services/           # Individual service documentation
├── runbooks/           # Installation and maintenance procedures
├── diagrams/           # Architecture diagrams
├── scripts/            # Administrative scripts
└── screenshots/        # Visual documentation
```

---

## ⚠️ Security Notes

- Secrets are never committed to source control.
- `.env` files are excluded through `.gitignore`.
- Example configuration files are provided as templates.
- Services are deployed with least-privilege principles whenever possible.
- Administrative access is restricted to authorized users.

