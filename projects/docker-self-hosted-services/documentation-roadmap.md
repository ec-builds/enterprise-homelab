# Documentation Roadmap

This document tracks planned documentation for the Docker & Self-Hosted Services project. Documents are added as the project matures and operational procedures become established.

## Documentation Status

| Document | Status | Purpose | Reason for Addition |
|----------|--------|---------|---------------------|
| [Docker Installation Guide](../../docs/reference/docker/docker-installation.md) | ✅ Complete | Docker installation procedures | Provides a repeatable installation and configuration process for Docker hosts. |
| [architecture.md](architecture.md) | ✅ Complete | Service architecture and component relationships | Documents the separation of general applications, monitoring, and media services across dedicated Docker hosts. |
| [lessons-learned.md](lessons-learned.md) | 🟡 Ongoing | Architecture and operational decisions | Records decisions, lessons learned, and practices discovered while building the environment. |
| [docker-learning-roadmap.md](docker-learning-roadmap.md) | 🟡 Ongoing | Docker learning progression | Tracks Docker concepts that have been learned, applied, or identified for future study. |
| [reverse-proxy.md](reverse-proxy.md) | 🟡 In Progress | Reverse proxy deployment and design | Documents the planned Nginx Proxy Manager deployment, internal DNS integration, hostname routing, and HTTPS implementation. |
| `networking.md` | 📋 Pending | Project-specific network configuration | Documents exposed ports, Docker networks, internal DNS, and communication paths as the environment grows. |
| `troubleshooting.md` | 📋 Pending | Common issues and resolutions | Captures operational knowledge and reduces future troubleshooting time. |
| `backup-and-recovery.md` | 📋 Pending | Backup and restoration procedures | Defines how container configuration, persistent data, and services can be recovered following failure or data loss. |
| `update-procedures.md` | 📋 Pending | Application and image update procedures | Standardizes service maintenance and container image update workflows. |

## Shared Reference Documentation

Reusable Docker concepts and procedures are maintained under the repository's shared reference documentation rather than duplicated within this project.

Examples include:

- Docker installation
- Container deployment
- Docker networking concepts
- Volumes and bind mounts
- Port mapping
- Environment variables and secrets
- Reverse proxy concepts
- Backup and recovery concepts
- Image update procedures

Project-level documentation should be created only when configuration or procedures are specific to this environment.

## Documentation Prioritization

### Phase 1 - Core Documentation

Foundational documentation for understanding and operating the environment:

1. ✅ Docker Installation Guide
2. ✅ `architecture.md`
3. 🟡 `lessons-learned.md`
4. 🟡 `docker-learning-roadmap.md`
5. 🟡 `reverse-proxy.md`
6. 📋 `networking.md`
7. 📋 `troubleshooting.md`

### Phase 2 - Environment Management

Documentation added as additional services are deployed and operational procedures become established:

8. 📋 `backup-and-recovery.md`
9. 📋 `update-procedures.md`

### Phase 3 - Service-Specific Documentation

Documentation is created when individual service implementations become complex enough to justify dedicated material.

Current and potential topics include:

- Reverse proxy and TLS
  - Nginx Proxy Manager
  - Internal DNS
  - HTTPS/TLS
- Monitoring and observability stack
  - Uptime Kuma
  - Prometheus
  - Grafana
  - Loki
  - Alertmanager
  - Grafana Alloy
- Jellyfin and `media-lab`
- Bitwarden Lite
- Additional self-hosted applications

These documents should be created as the associated services are implemented rather than in advance.

## Documentation Strategy

The project uses two documentation scopes:

```text
Project Documentation
    │
    ├── Architecture
    ├── Environment-specific configuration
    ├── Operational procedures
    ├── Troubleshooting
    ├── Service relationships
    ├── Lessons learned
    └── Learning progress

Shared Reference Documentation
    │
    ├── Debian procedures
    ├── Docker procedures
    ├── Networking concepts
    └── Reusable technical references
```

This separation prevents duplication while keeping project documentation focused on how the environment is actually designed and operated.

Documentation should follow the general principle:

```text
Reusable Concept or Procedure
            │
            ▼
     Shared Reference Docs

Environment-Specific Design
            │
            ▼
      Project Documentation
```

## Notes

- Documentation should be created only after sufficient project experience has been gained to provide meaningful content.
- Lessons learned should be documented continuously and may drive the creation of additional reference material.
- The Docker learning roadmap should be updated as concepts are studied and applied.
- Reusable procedures should be placed in shared reference documentation rather than duplicated within the project.
- Service-specific documentation should be created when implementation complexity warrants it.
- Project documentation should reflect deployed or actively planned architecture rather than speculative services.
- All project documentation should be updated alongside significant architectural or operational changes.
- When new documentation is added, update the project README to include links to the new resources.
