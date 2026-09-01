# Debian Installation

This document outlines the standard procedure for installing Debian 13 on Intel x86_64 systems within the EC-Builds homelab environment.

The objective is to establish a consistent installation process that can be reused across future Debian-based projects and server deployments.

> [!NOTE]
> This guide applies to Intel x86_64 systems.
>
> AMD x86_64 systems typically follow the same installation process but have not been formally validated under this standard.
>
> ARM-based platforms are not covered by this document and may require different installation media, firmware configuration, drivers, and deployment procedures.

---

## Overview

Use Debian 13 as the standard Linux distribution for Debian-based projects within the homelab environment.

Debian provides:

- Long-term stability
- Extensive package availability
- Strong community support
- Predictable release management
- Excellent support for self-hosted services and infrastructure workloads

Create installation media from the official Debian DVD ISO and deploy it to the target Intel-based system.

---

## Implementation Summary

| Stage | Notes |
|---------|---------|
| Installation Media Preparation | Write the Debian 13.5.0 DVD ISO to a USB drive |
| Booting the Installer | Boot the target system from USB installation media using UEFI boot mode |
| Debian Installation | Install Debian 13.5.0 using a minimal server configuration (no desktop environment) |
| Initial System Configuration | Install SSH Server and Standard System Utilities |
| Post-Installation Tasks | Verify successful boot, network connectivity, and remote access |
| Validation & Handoff | Confirm the operating system is stable and ready for baseline configuration |

---

## Installation Media Preparation

### Download Installation Image

Download the Debian installation image from the official Debian website.

Website:

```text
https://www.debian.org
```

Example:

```text
debian-13.5.0-amd64-DVD-1.iso
```

Use the DVD ISO for this standard installation procedure.

The DVD image contains a large collection of Debian packages and reduces dependency on internet connectivity during installation.

### DVD ISO vs NetInstall

Debian provides multiple installation images. The two most common options are the DVD ISO and NetInstall ISO.

| Feature | DVD ISO | NetInstall |
|----------|----------|----------|
| Download Size | Large (several GB) | Small (hundreds of MB) |
| Internet Required | Minimal | Required for most packages |
| Package Availability During Install | Extensive | Downloads packages as needed |
| Installation Speed | Faster on slower networks | Faster download, slower install if many packages are required |
| Best Use Case | Offline or limited-connectivity environments | Connected environments with reliable internet access |

Either approach is valid. This standard uses the DVD ISO to provide a self-contained installation experience.

---

### Identify the USB Device

List all connected disks and identify the target USB device.

```bash
diskutil list
```

> [!NOTE]
> Verify the correct disk identifier before proceeding. Selecting the wrong device may result in data loss.

---

### Unmount the USB Device

Unmount the entire USB device prior to writing the ISO.

```bash
diskutil unmountDisk /dev/diskX
```

Replace `diskX` with the appropriate disk identifier.

---

### Verify ISO Integrity

Validate the downloaded image using SHA-256.

```bash
shasum -a 256 debian-13.5.0-amd64-DVD-1.iso
```

Compare the resulting hash with the checksum published by the Debian project.

```text
https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/
```

---

### Write the ISO to the USB Device

Create the bootable installation media.

```bash
pv debian-13.5.0-amd64-DVD-1.iso | sudo dd of=/dev/rdiskX bs=4m
```

This command writes the Debian installation image directly to the USB device and creates bootable installation media.

- `pv` (Pipe Viewer) displays transfer progress, throughput, and estimated completion time.
- `dd` performs a block-level copy of the ISO image to the target USB device.
- `/dev/rdiskX` represents the raw USB device and typically provides faster write performance on macOS than `/dev/diskX`.
- `bs=4m` sets the block size to 4 MB and improves write performance.

> [!WARNING]
> Verify the target device before running this command. Writing to the wrong disk will overwrite its contents and may result in data loss.

> [!NOTE]
> Installation media created by writing a Debian ISO directly to a USB device may not be fully recognized by macOS. Because the ISO contains Linux and EFI boot partitions, Disk Utility and Finder may display unexpected partition layouts or report unused space on the device.
>
> This behavior is normal.
>
> Validate the installation media by confirming that the target system recognizes the USB device as a UEFI boot option.

---

### Eject the USB Device

After the write process completes, safely eject the installation media.

```bash
diskutil eject /dev/diskX
```

---

## Booting the Installation Media

1. Insert the USB drive into the target system.
2. Access the system boot menu or firmware boot selection menu.
3. Select the USB installation media.
4. Boot using UEFI mode.
5. Launch the Debian installer.

---

## Debian Installation

Use the following installation selections.

| Setting | Selection |
|----------|----------|
| Installation Media | Debian DVD ISO |
| Hostname | Assigned according to Naming Conventions |
| Desktop Environment | None |
| SSH Server | Installed |
| Standard System Utilities | Installed |
| Partitioning | Guided (Entire Disk) |
| Package Repository | Debian Official Mirrors |

### Package Selection

Select the following package groups during installation:

- SSH Server
- Standard System Utilities

Do not install a desktop environment.

Deploy the system as a headless Linux server managed primarily through SSH.

---

## Post-Installation Tasks

After installation completes:

1. Verify successful system boot.
2. Verify network connectivity.
3. Verify SSH connectivity.
4. Apply system updates.
5. Complete the Debian Base System Configuration standard.
6. Proceed with project-specific configuration.

---

## Validation

Verify the following before proceeding:

- System boots successfully
- Network connectivity is operational
- SSH access is functional
- Hostname follows Naming Conventions
- Debian repositories are reachable

Successful validation confirms that the operating system is ready for baseline configuration.

---

## Related Documentation

- [Naming Conventions](./naming-conventions.md)
- [Debian Base System Configuration](./debian-baseline.md)
- [SSH Hardening Standard](./ssh-hardening.md)

---

## Outcome

A clean Debian 13 installation is deployed and ready for baseline configuration and project-specific implementation.
