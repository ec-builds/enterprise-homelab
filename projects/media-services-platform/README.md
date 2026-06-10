# 🎬 Media Services Platform (Debian & Jellyfin)

**Status: ✅ Complete** — first completed project in the lab.

Self-hosted media platform built on Debian, focused on Linux administration fundamentals: OS installation, storage integration, service deployment, permissions, and documentation.

## 🎯 Objectives

- Install and configure a Debian server from scratch
- Deploy and manage Jellyfin as a systemd service
- Configure storage mounts and Linux file permissions for media libraries
- Establish update, maintenance, and monitoring routines
- Document the full build for repeatability

## 🛠️ Technologies

- Debian (server installation, apt package management)
- Jellyfin media server
- systemd service management
- Linux storage (fstab, mount points, permissions/ownership)
- SSH administration

## 📋 Completed Work

- [x] Debian server installation and base configuration
- [x] Jellyfin deployment and library configuration
- [x] Storage mount configuration with correct permissions
- [x] Client access verified across household devices

## 🔮 Future Enhancements

- [ ] Migrate to a VM on the Proxmox host ([virtualization-lab](../virtualization-lab/))
- [ ] Add hardware transcoding (GPU/QuickSync)
- [ ] Include config in backup jobs ([backup-disaster-recovery](../backup-disaster-recovery/))
- [ ] Add uptime/resource monitoring ([infrastructure-monitoring](../infrastructure-monitoring/))

## 📁 Folder Structure

```
media-services-platform/
├── docs/            # build-notes.md, troubleshooting.md, lessons-learned.md
├── configs/         # Sanitized configuration files
├── scripts/         # Maintenance/automation scripts
└── screenshots/     # Visual documentation
```

## 💡 Lessons Learned

_See [docs/lessons-learned.md](./docs/lessons-learned.md) — Linux permissions, storage mounting, and service troubleshooting notes from the build._
