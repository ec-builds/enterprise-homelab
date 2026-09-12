# Architecture

This document provides a high-level overview of the Media Services Platform architecture and its evolution from the original native deployment to the current virtualized and containerized platform.

## Overview

The Media Services Platform runs Jellyfin in a Docker container inside a dedicated Debian 13 virtual machine hosted on Proxmox VE.

Media is stored independently on centralized network-attached storage and presented to Jellyfin through a read-only SMB mount. This separates compute, application state, and media storage while simplifying recovery, migration, and lifecycle management.

## Architecture Diagram

<img src="./diagrams/media-lab-architecture.png" alt="Media Services Platform Architecture" width="900">

*Figure 1. Current Media Services Platform architecture.*

## Components

| Component | Role | Responsibilities |
|---|---|---|
| **Proxmox VE** | Virtualization platform | Hosts the media VM and provides virtual compute, networking, backup, and lifecycle management |
| **media-lab-vm** | Media services VM | Runs Debian 13, Docker, and the supporting media services environment |
| **Debian 13** | Operating system | Provides package management, networking, storage integration, system administration, and Docker host functionality |
| **Docker Engine** | Container runtime | Runs and isolates Jellyfin and manages container networking and lifecycle |
| **Docker Compose** | Service definition | Defines the Jellyfin deployment declaratively and provides repeatable container configuration |
| **Jellyfin** | Media server | Provides library management, metadata, authentication, streaming, client compatibility, and transcoding |
| **Read-Only SMB Mount** | Storage integration | Makes centralized media available to Jellyfin while preventing modification of source files |
| **nas-lab** | Centralized storage | Provides primary media storage, file management, retention, expansion, and backup integration |
| **Client Devices** | Service consumers | Access Jellyfin through browsers, mobile devices, smart TVs, streaming devices, and applications |

## Application Layout

Jellyfin follows the standardized Docker service structure under `/opt/docker`:

```text
/opt/docker/jellyfin/
├── docker-compose.yaml
├── config/
└── cache/
```

Persistent storage is mapped into the container using bind mounts:

| Host Path | Container Path | Access | Purpose |
|---|---|---|---|
| `/opt/docker/jellyfin/config` | `/config` | Read/Write | Jellyfin configuration and persistent application state |
| `/opt/docker/jellyfin/cache` | `/cache` | Read/Write | Application cache and temporary generated data |
| `/mnt/media` | `/media` | Read-Only | Centralized media library |

Keeping persistent application state outside the container allows Jellyfin to be recreated or upgraded without storing configuration inside the container filesystem.

## Design Considerations

| Design Decision | Implementation | Benefits |
|---|---|---|
| **Virtualization** | Dedicated Debian VM on Proxmox VE | Improves resource allocation, workload portability, backup, and recovery |
| **Containerization** | Jellyfin deployed through Docker Compose | Provides application isolation, repeatable deployment, and simplified recreation |
| **Persistent Application Data** | Bind mounts under `/opt/docker/jellyfin` | Simplifies inspection, backup, troubleshooting, and future migration |
| **Storage Separation** | Media remains on centralized network storage | Keeps application and storage lifecycles independent and reduces VM storage requirements |
| **Read-Only Media Access** | Media is exposed to Jellyfin as read-only | Reduces accidental modification or deletion and reinforces least privilege |
| **Dedicated Workload VM** | Media services operate within `media-lab-vm` | Separates the media workload from other infrastructure services |
| **Declarative Deployment** | Service configuration maintained in `docker-compose.yaml` | Makes deployment repeatable, reviewable, and easier to document |

## Architecture Evolution

The Media Services Platform has progressed through two deployment models:

**Original deployment**

```text
Standalone Debian Host
        │
        ├── Jellyfin (systemd)
        │
        └── Mounted Media Storage
```

**Current deployment**

```text
Proxmox VE
    │
    └── Debian VM (media-lab-vm)
            │
            ├── Docker Engine
            │
            └── Jellyfin Container
                    │
                    ├── /config  → /opt/docker/jellyfin/config
                    ├── /cache   → /opt/docker/jellyfin/cache
                    └── /media   → /mnt/media
```

Jellyfin configuration and cache storage use Docker bind mounts rather than Docker-managed volumes. This keeps persistent application data directly accessible under `/opt/docker/jellyfin`, simplifying inspection, backup, recovery, and future migrations.

Media storage remains external to the Jellyfin container and is mounted read-only at `/media`.

The original deployment was intentionally simple and provided hands-on experience with Debian administration, APT repositories, systemd, Linux permissions, SMB storage, and native service troubleshooting.

As the broader homelab matured, the workload was moved into the Proxmox virtualization environment and Jellyfin was redeployed according to the standardized Docker Compose service model.

For a detailed example docker-compose config file see [Jellyfin Docker Compose YAML](../../configs/docker/jellyfin/docker-compose.yaml)


## Migration Strategy

A clean Jellyfin deployment was selected rather than migrating the database and configuration from the original native installation.

| Decision | Rationale |
|---|---|
| **Deploy a fresh Jellyfin instance** | Moving from a native package installation to Docker represented a significant architectural change, and a clean deployment reduced migration complexity |
| **Recreate users** | The small number of users made recreation simpler than preserving the existing application database |
| **Accept loss of watch history** | Watch history did not provide enough value to justify migrating the old database |
| **Preserve media storage** | Media remained centralized and independent of Jellyfin, so no media migration was required |
| **Retain old service temporarily** | The original Jellyfin installation was stopped but kept available during validation to provide a rollback path |
| **Use bind mounts** | Persistent application state is easier to identify, inspect, back up, and migrate in the future |

The migration treated the application as replaceable while preserving the more important and significantly larger media storage layer.

## Related Documentation

| Document | Purpose |
|---|---|
| [Jellyfin Deployment](./jellyfin-deployment.md) | Jellyfin installation and container deployment |
| [SMB Storage](./smb-storage.md) | Network storage integration and mount configuration |
| [Backup Strategy](./backup-strategy.md) | Application and infrastructure backup strategy |
| [Monitoring](./monitoring.md) | Availability, health, and resource monitoring |
| [Lessons Learned](./lessons-learned.md) | Technical and architectural lessons from the project |

## Outcome

The current architecture separates compute, operating system, container runtime, application state, and media storage into distinct layers.

This modernization preserves the original design's storage separation and least-privilege principles while adding virtualization, containerization, workload portability, and standardized deployment practices.
