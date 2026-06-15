# Debian Base System Configuration

This document outlines the standard baseline configuration applied to 
Debian servers in the homelab environment following OS installation and 
initial SSH setup.

Apply this standard to any new Debian server before beginning 
project-specific configuration.

> [!NOTE]
> If `sudo` is not yet installed on the system, follow the
> [Configure sudo Access](../runbooks/linux/configure-sudo.md)
> runbook before proceeding.

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
smartmontools \
ca-certificates
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

Run the following checks to verify package installation, system identity, storage visibility, network connectivity, and basic service health before proceeding with additional configuration.

```bash
apt list --installed | grep -E "curl|wget|git|vim|htop|tree"
systemctl status avahi-daemon
df -h
smartctl --scan
hostnamectl
ip addr
ping -c 4 8.8.8.8
ping -c 4 google.com
```

### Expected Results

- Required packages are installed.
- Avahi is active and running.
- Storage devices are detected and accessible.
- Hostname is configured correctly.
- Network interfaces have valid IP addresses.
- Internet connectivity and DNS resolution are functional.

If all checks pass, the system is ready for further configuration and service deployment.


>[!TIP]
>After applying operating system updates, consider rebooting the server
> before beginning project-specific configuration to ensure all updates
> are fully applied.


---

## Related Documentation

- [Naming Conventions](./naming-conventions.md)
- [SSH Hardening Standard](./ssh-hardening.md)
- [Media Services Platform](../../projects/media-services-platform/)
