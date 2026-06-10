# Base System Configuration

This document outlines the initial configuration performed after the Debian 13 installation and initial SSH setup. The objective was to establish a stable baseline for administration, troubleshooting, storage integration, and ongoing platform management.

## Overview

Following the operating system installation and SSH configuration, the server was updated and configured with a standardized set of administration, networking, storage, and monitoring utilities. These tools provide the foundation for day-to-day Linux administration and support future project requirements within the homelab environment.

---

## System Updates

The operating system was updated to the latest available package versions prior to additional configuration.

```bash
sudo apt update
sudo apt upgrade -y
```

---

## Base Package Installation

The following packages were installed as part of the initial system configuration.

```bash
sudo apt install -y \
vim \
git \
curl \
wget \
htop \
tree \
dnsutils \
bash-completion \
avahi-daemon \
cifs-utils \
rsync \
unzip \
ncdu \
smartmontools
```

---

## Package Summary

| Package | Purpose |
|----------|----------|
| vim | Text editor for configuration and administration tasks |
| git | Version control and repository management |
| curl | Command-line HTTP client for API and network testing |
| wget | File downloads from remote systems |
| htop | Interactive process and resource monitoring |
| tree | Directory structure visualization |
| dnsutils | DNS troubleshooting and name resolution tools |
| bash-completion | Command-line auto-completion enhancements |
| avahi-daemon | Local network service discovery |
| cifs-utils | SMB/CIFS network share integration |
| rsync | File synchronization and backup operations |
| unzip | Archive extraction utility |
| ncdu | Disk usage analysis and storage management |
| smartmontools | Disk health monitoring and SMART diagnostics |

---

## Configuration Goals

The base configuration was designed to provide:

- Secure remote administration
- Storage and file-sharing integration
- Network troubleshooting capabilities
- System monitoring and diagnostics
- Backup and synchronization support
- Tools required for future project deployments

---

## Validation

Following package installation, the following checks were performed:

```bash
apt list --installed
```

```bash
systemctl status avahi-daemon
```

```bash
df -h
```

```bash
smartctl --scan
```

Successful execution confirmed that the system was prepared for additional configuration and service deployment.

---

## Related Documentation

- [Debian Installation](./debian-install.md)
- [SSH Configuration](./ssh-configuration.md)
- [SMB Storage](./smb-storage.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)

---

## Outcome

The server was successfully updated and configured with a standardized set of administration and troubleshooting tools, establishing the baseline operating environment for the Media Services Platform project.
