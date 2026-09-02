# Documentation Roadmap

This document tracks planned documentation for the Docker & Self-Hosted Services project. Documents are added as the project matures and operational procedures become established.

## Documentation Status

| Document | Status | Purpose | Reason for Addition |
|----------|--------|---------|---------------------|
| [Docker Installation Guide](../../docs/reference/docker/docker-installation.md) | ✅ Complete | Docker installation procedures | Provides a repeatable installation and configuration process for Docker hosts. |
| [architecture.md](architecture.md) | ✅ Complete | Service architecture and component relationships | Documents the separation of general applications, monitoring, and media services across dedicated Docker hosts. |
| `troubleshooting.md` | 📋 Pending | Common issues and resolutions | Captures operational knowledge and reduces future troubleshooting time. |
| `networking.md` | 📋 Pending | Project-specific network configuration | Documents exposed ports, Docker networks, and communication paths as the environment grows. |
| `backup-and-recovery.md` | 📋 Pending | Backup and restoration procedures | Defines how container configuration, persistent data, and services can be recovered following failure or data loss. |
| `update-procedures.md` | 📋 Pending | Application and image update procedures | Standardizes service maintenance and container image update workflows. |
| `inventory.md` | 📋 Pending | Service inventory and status tracking | Provides a centralized list of deployed services, hosts, ports, and purposes. |

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
3. 📋 `troubleshooting.md`
4. 📋 `networking.md`

### Phase 2 - Environment Management

Documentation added as additional services are deployed and operational procedures become established:

5. 📋 `backup-and-recovery.md`
6. 📋 `update-procedures.md`
7. 📋 `inventory.md`

### Phase 3 - Service-Specific Documentation

Documentation created when individual service implementations become complex enough to justify dedicated material.

Potential topics include:

- Monitoring and observability stack
  - Uptime Kuma
  - Prometheus
  - Grafana
  - Loki
- Jellyfin and `media-lab`
- Reverse proxy and TLS
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
    └── Service relationships

Shared Reference Documentation
    │
    ├── Debian procedures
    ├── Docker procedures
    ├── Networking concepts
    └── Reusable technical references
```

This separation prevents duplication while keeping project documentation focused on how the environment is actually designed and operated.

### Notes

* Documentation should be created only after sufficient project experience has been gained to provide meaningful content.
* Lessons learned should be documented continuously and may drive the creation of additional reference material.
* Reusable procedures should be placed in shared reference documentation rather than duplicated within the project.
* Service-specific documentation should be created when implementation complexity warrants it.
* All project documentation should be updated alongside significant architectural or operational changes.
* When new documentation is added, update the project README to include links to the new resources.
