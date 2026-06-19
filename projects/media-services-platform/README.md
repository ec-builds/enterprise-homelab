# Media Services Platform (Debian & Jellyfin)

**Status: ✅ Complete** — first completed project in the lab.

Self-hosted media platform built on Debian, focused on Linux administration fundamentals: OS installation, storage integration, service deployment, permissions, and documentation.

> [!NOTE]
> This project documents the original Media Services Platform implementation, which deployed Jellyfin as a native systemd service on Debian. At the time of development, containerization was not part of the project's scope.
>
> Since completing this project, the homelab has adopted a standardized Docker Compose deployment model for new services. Future iterations of the Media Services Platform may evaluate migrating Jellyfin to a containerized deployment, but the documentation in this project reflects the original implementation and learning objectives.


---

<p align="left">
  <img src="./diagrams/architecture.png" alt="Architecture Diagram" width="700">
  <br>
  <em>Figure 1. High-level architecture of the Media Services Platform.</em>
</p>

For more information about this diagram, see [architecture.md](./architecture.md)

---

## Objectives

- Install and configure a Debian server from scratch
- Deploy and manage Jellyfin as a systemd service
- Configure storage mounts and Linux file permissions for media libraries
- Establish update, maintenance, and monitoring routines
- Document the full build for repeatability

## Technologies

- Debian 13.5 (server installation, apt package management)
- Jellyfin media server
- systemd service management
- Linux storage (fstab, mount points, permissions/ownership)
- SSH administration

## Completed Work

- [x] Debian server installation and base configuration
- [x] Jellyfin deployment and library configuration
- [x] Storage mount configuration with correct permissions
- [x] Client access verified across household devices

## Future Enhancements

- [ ] Migrate to a VM on the Proxmox host ([virtualization-lab](../virtualization-lab/))
- [ ] Migrate to a Docker container ([docker-self-hosted-services](../docker-self-hosted-services/))
- [ ] Add hardware transcoding (GPU/QuickSync)
- [ ] Include config in backup jobs ([backup-disaster-recovery](../backup-disaster-recovery/))
- [x] Add uptime/resource monitoring ([infrastructure-monitoring](../infrastructure-monitoring/))

## 📁 Folder Structure

| Document | Description |
|-----------|-----------|
| [README.md](./README.md) | Project overview, objectives, architecture summary, and navigation |
| [Diagrams](./diagrams/) | Architecture diagrams, screenshots, and visual documentation |
| [architecture.md](./architecture.md) | High-level architecture, component relationships, and system design |
| [backup-strategy.md](./backup-strategy.md) | Backup procedures, recovery considerations, and data protection strategy |
| [base-system-configuration.md](./base-system-configuration.md) | Initial Debian configuration, package setup, and system preparation |
| [client-testing.md](./client-testing.md) | Validation testing, client access verification, and functionality checks |
| [debian-install.md](./debian-install.md) | Debian installation process and operating system deployment notes |
| [hardware.md](./hardware.md) | Hardware inventory, specifications, and platform selection rationale |
| [jellyfin-deployment.md](./jellyfin-deployment.md) | Jellyfin installation, configuration, and service deployment procedures |
| [lessons-learned.md](./lessons-learned.md) | Key takeaways, challenges encountered, and project reflections |
| [media-libraries.md](./media-libraries.md) | Media organization, library structure, and content management configuration |
| [monitoring.md](./monitoring.md) | System monitoring, health checks, and observability considerations |
| [smb-storage.md](./smb-storage.md) | SMB share configuration, storage integration, and network file access |
| [ssh-configuration.md](./ssh-configuration.md) | SSH hardening, remote access configuration, and administration practices |
| [system-hardening.md](./system-hardening.md) | Security controls, system hardening measures, and security recommendations |
| [troubleshooting.md](./troubleshooting.md) | Troubleshooting procedures, validation testing, and issue resolution documentation |

## 💡 Lessons Learned

_See [Lessons Learned](./lessons-learned.md) — Linux permissions, storage mounting, and service troubleshooting notes from the build._


## Outcome

The Media Services Platform successfully demonstrated:

- Debian server deployment
- Linux administration fundamentals
- SMB storage integration
- Service management with systemd
- Media streaming with Jellyfin
- Client compatibility validation
- Technical documentation practices

This project serves as the foundation for future homelab initiatives involving virtualization, monitoring, automation, backup, and infrastructure management.
