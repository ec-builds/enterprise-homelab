# Debian Installation on Intel Mac Mini

A reference for installing Debian Linux on Intel-based Apple Mac Mini hardware using bootable USB installation media.

This procedure was validated on a **Late 2014 Mac Mini (Macmini7,1)** using Debian 13.

## Overview

Intel-based Mac Mini systems can be repurposed as compact Linux servers by replacing macOS with Debian.

The Late 2014 Mac Mini supports EFI boot and can load the standard Debian installer from USB through Apple's Startup Manager.

This reference covers:

- Preparing Debian installation media
- Booting an Intel Mac Mini from USB
- Installing a minimal Debian system
- Configuring the system for headless operation
- Performing initial post-installation validation

## Tested Platform

| Component | Details |
|---|---|
| Platform | Apple Mac Mini |
| Model | Late 2014 |
| Model Identifier | Macmini7,1 |
| Architecture | x86_64 |
| Processor Family | Intel |
| Firmware | Apple EFI |
| Tested Operating System | Debian 13 |
| Installation Method | USB |
| Administration | SSH |
| Desktop Environment | None |

> This procedure may also apply to other Intel-based Mac models, but boot behavior, hardware compatibility, and firmware requirements can vary.

## Prerequisites

Before beginning, prepare:

- Intel-based Mac Mini
- USB flash drive
- Debian installation ISO
- Mac or Linux system for creating the installation media
- Wired Ethernet connection
- Keyboard and display for initial installation

> **Warning:** Installing Debian to the internal disk can erase the existing operating system and data. Back up important data before proceeding.

## Debian Installation Media

Download the appropriate **64-bit AMD64 Debian installation image** for Intel-based Mac hardware.

For a minimal server deployment, the Debian network installer is sufficient when reliable Internet connectivity is available during installation.

Verify the downloaded image before writing it to installation media.

> ➡️ **Debian Installation Media:** See the Debian installation reference documentation for ISO download, checksum verification, and bootable USB creation procedures.

## Boot from USB

Insert the Debian installation USB into the Mac Mini.

Power on or restart the system while holding:

```text
Option (⌥)
```

Continue holding the key until the Apple Startup Manager appears.

The boot sequence is:

```text
Power On
    │
    ▼
Hold Option (⌥)
    │
    ▼
Apple Startup Manager
    │
    ▼
Select EFI Boot
    │
    ▼
Debian Installer
```

The Debian USB installer normally appears as:

```text
EFI Boot
```

Select **EFI Boot** to launch the Debian installer.

## Debian Installation

For a headless server deployment, a minimal Debian installation can be used.

Recommended selections:

| Setting | Selection |
|---|---|
| Installation Mode | Graphical Install or Install |
| Network | Ethernet |
| Hostname | Environment-specific |
| Domain | Environment-specific or blank |
| Partitioning | Guided or manually defined |
| Package Repository | Official Debian mirror |
| Desktop Environment | None |
| SSH Server | Installed |
| Standard System Utilities | Installed |

Avoid installing a desktop environment when the Mac Mini will operate exclusively as a server.

This reduces resource consumption, installed packages, and unnecessary services.

## Disk Configuration

For a dedicated Linux server where Debian will use the entire internal disk, guided partitioning provides a straightforward deployment method.

Typical selection:

```text
Guided - use entire disk
```

The exact partition layout depends on the Debian installer version, disk capacity, and selected partitioning options.

After installation, inspect the resulting layout:

```bash
lsblk
```

Additional filesystem information can be displayed with:

```bash
df -h
```

## Network Configuration

Wired Ethernet is recommended for server deployments.

Inspect network interfaces and addressing:

```bash
ip addr
```

Inspect the routing table:

```bash
ip route
```

Test network connectivity:

```bash
ping -c 4 1.1.1.1
```

Test DNS resolution:

```bash
getent hosts debian.org
```

## SSH Administration

If the SSH server was selected during installation, verify the service:

```bash
systemctl status ssh
```

Confirm that SSH is listening:

```bash
ss -tlnp | grep ':22'
```

Remote administration can then be tested from another system:

```bash
ssh <username>@<hostname>
```

Further SSH configuration and hardening should follow the standard Debian SSH reference documentation.

## Headless Operation

After installation and remote-access validation, the Mac Mini can operate without a permanently connected display, keyboard, or mouse.

Before placing the system into headless operation, confirm:

| Check | Expected Result |
|---|---|
| Debian Boot | Successful |
| Ethernet | Connected |
| IP Configuration | Valid |
| DNS Resolution | Functional |
| SSH | Remote login successful |
| Package Repositories | Reachable |
| System Updates | Functional |

## System Validation

Collect basic platform information:

```bash
hostnamectl
lscpu
free -h
lsblk
```

Check the operating system:

```bash
cat /etc/os-release
```

Check for failed systemd services:

```bash
systemctl --failed
```

Update package metadata and installed packages:

```bash
sudo apt update
sudo apt upgrade
```

Reboot after installation and significant updates:

```bash
sudo reboot
```

After rebooting, reconnect through SSH to confirm that the system returns to normal operation without local intervention.

## Hardware Identification

Apple model information may be available through DMI:

```bash
sudo dmidecode -t system
```

CPU information:

```bash
lscpu
```

PCI devices:

```bash
lspci
```

USB devices:

```bash
lsusb
```

Storage devices:

```bash
lsblk
```

These commands are useful when validating Linux hardware detection or troubleshooting drivers.

## Platform Considerations

| Area | Consideration |
|---|---|
| **Architecture** | Intel Mac Mini systems use x86_64-compatible processors and can run standard AMD64 Debian builds |
| **EFI Boot** | Debian installation media is launched through Apple's Startup Manager as `EFI Boot` |
| **Networking** | Wired Ethernet is preferable for server workloads |
| **Memory** | Some Mac Mini generations have soldered memory that cannot be upgraded |
| **Storage** | Internal storage options and upgradeability vary by model |
| **Headless Use** | Debian can operate without a desktop environment or permanently attached peripherals |
| **Power Consumption** | Mac Mini hardware provides a compact, relatively low-power platform for lightweight infrastructure workloads |
| **Hardware Age** | Older models may have limited compute resources compared with modern virtualization hardware |

## Suitable Homelab Roles

Repurposed Intel Mac Mini hardware can be useful for:

- Linux administration labs
- Network services
- Monitoring
- Container hosting
- DNS and DHCP
- Firewall and routing experiments
- Lightweight application hosting
- Infrastructure automation
- Backup or utility services

Suitability depends on the resources available in the specific Mac Mini generation.

## Related Documentation

- Debian Baseline Build
- Debian Initial Validation
- SSH Configuration
- Docker Installation
- Debian Networking Reference

## Outcome

Intel-based Mac Mini hardware can provide a practical platform for learning Linux administration and hosting lightweight infrastructure services.

Installing Debian directly on the hardware converts an older desktop system into a compact headless Linux server while providing hands-on experience with EFI booting, operating system deployment, networking, SSH administration, hardware validation, and ongoing Linux system management.
