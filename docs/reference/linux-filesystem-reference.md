# 📁 Linux Filesystem Reference

Reference guide for common Linux filesystem directories and their intended purpose. Applicable to Debian, Ubuntu, and most modern Linux distributions.

## Filesystem Overview

| Directory | Purpose | Typical Contents |
|------------|------------|------------|
| `/` | Root of the filesystem hierarchy | All files and directories |
| `/bin` | Essential user commands (symlink to `/usr/bin` on modern systems) | `ls`, `cp`, `mv`, `cat` |
| `/boot` | Bootloader and kernel files | GRUB, kernels, initramfs |
| `/dev` | Device files | Disks, terminals, USB devices |
| `/etc` | System configuration files | SSH, networking, services |
| `/home` | User home directories | User files and personal scripts |
| `/lib` | Essential shared libraries | Libraries required by core commands |
| `/lost+found` | Files recovered during filesystem repair | Normally empty |
| `/media` | Auto-mounted removable media | USB drives, DVDs |
| `/mnt` | Temporary mount point | Manual mounts |
| `/opt` | Optional and third-party software | Self-hosted applications |
| `/proc` | Virtual process and kernel information | CPU, memory, processes |
| `/root` | Root user's home directory | Root-owned files |
| `/run` | Runtime state information | PID files, sockets |
| `/sbin` | Essential system administration commands | `shutdown`, `reboot`, `fdisk` |
| `/srv` | Data served by the system | Websites, shared files, application data |
| `/sys` | Virtual hardware and kernel interface | Devices, drivers |
| `/tmp` | Temporary files | Short-lived data |
| `/usr` | Userland applications and libraries | Installed software |
| `/var` | Variable data | Logs, databases, caches |

---

## Important Directories for Homelabs

### `/etc`

Stores system-wide configuration files.

Examples:

```text
/etc/ssh/sshd_config
/etc/docker/
/etc/systemd/
/etc/network/
```

Common tasks:

- Configure SSH
- Manage services
- Configure networking
- Configure Docker daemon

---

### `/home`

Contains user home directories.

Examples:

```text
/home/ecadmin
/home/ecadmin/scripts
/home/ecadmin/git
```

Recommended uses:

- Personal scripts
- Git repositories
- Documentation drafts
- User downloads

---

### `/opt`

Recommended location for self-hosted applications and Docker Compose projects.

Examples:

```text
/opt/docker
/opt/docker/uptime-kuma
/opt/docker/prometheus
/opt/docker/grafana
/opt/docker/loki
```

Recommended uses:

- Docker Compose stacks
- Third-party software
- Custom applications

---

### `/srv`

Stores data provided by services running on the server.

Examples:

```text
/srv/jellyfin
/srv/files
/srv/wiki
/srv/web
```

Recommended uses:

- Media libraries
- Shared files
- Web content
- Service data

---

### `/var`

Contains data that changes frequently.

Examples:

```text
/var/log
/var/lib/docker
/var/lib/prometheus
/var/cache
```

Common contents:

- System logs
- Application databases
- Docker runtime data
- Package manager cache

---

## Common Homelab Layout

```text
/
├── etc/
├── home/
│   └── ecadmin/
├── opt/
│   └── docker/
│       ├── uptime-kuma/
│       ├── prometheus/
│       ├── grafana/
│       └── loki/
├── srv/
│   ├── jellyfin/
│   └── files/
└── var/
    ├── log/
    └── lib/
```

---

## General Guidelines

| Store This | Recommended Location |
|------------|------------|
| System configuration | `/etc` |
| User files and scripts | `/home` |
| Docker Compose projects | `/opt/docker` |
| Service content and shared data | `/srv` |
| Logs and application databases | `/var` |
| Temporary files | `/tmp` |

---

## Notes

- Avoid storing persistent application data in `/tmp`.
- Keep Docker Compose projects organized under a consistent directory structure.
- Use `/srv` when the server's primary purpose is providing data or content.
- Use `/opt` for self-hosted applications and third-party software.
- Always document custom directory structures in project documentation.
