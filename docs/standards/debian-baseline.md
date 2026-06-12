# Debian Base System Configuration

This document outlines the standard baseline configuration applied to 
Debian servers in the homelab environment following OS installation and 
initial SSH setup.

Apply this standard to any new Debian server before beginning 
project-specific configuration.

---

## Baseline Components

The Debian baseline consists of:

- Operating system updates
- Administrative utilities
- Storage integration tools
- Monitoring and diagnostic tools
- Network troubleshooting utilities

---

## Baseline Updates

Update the operating system to the latest available packages before
making any additional changes.

```bash
sudo apt update
sudo apt upgrade -y
```

---

## Base Package Installation

Install the following packages as part of every Debian baseline build.

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
|---|---|
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

This baseline provides:

- Secure remote administration
- Storage and file-sharing integration
- Network troubleshooting capabilities
- System monitoring and diagnostics
- Backup and synchronization support
- Foundation for future project-specific deployments

---

## Validation

Run the following checks after package installation to confirm the 
system is ready for additional configuration.

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

Successful execution confirms the system baseline is complete and 
ready for project-specific configuration.

---

## Related Documentation

- [Naming Conventions](../naming-conventions.md)
- [SSH Hardening Standard](./ssh-hardening.md)
- [Media Services Platform](../../projects/media-services-platform/)
