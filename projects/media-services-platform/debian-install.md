# Debian Installation

This document outlines the process used to create bootable installation media and install Debian 13 **(13.5.0)** on the Media Services Platform host **(2014 Mac Mini)**.

## Overview

Debian 13 was selected as the operating system for this project due to its stability, extensive package repository, long-term maintainability, and suitability for self-hosted services.

The installation media was created on **macOS Tahoe 26.5** and deployed to a dedicated host system **(2014 Mac Mini)**.

---

## Installation Media Preparation

### Download Installation Image

Download the Debian 13 installation image from the official Debian website.

Website:

```text
https://www.debian.org
```

Example:

```text
debian-13.5.0-amd64-DVD-1.iso
```

For this project, the **DVD ISO** was used instead of the NetInstall image. The DVD image contains a large collection of Debian packages and allows installation without relying heavily on an internet connection during setup.

The target platform was a **Late 2014 Mac Mini** connected to the local network via Ethernet.

**Benefits of the DVD ISO:**

- Includes a large package repository on the installation media
- Less dependent on internet connectivity during installation
- Useful for environments with limited or unreliable network access
- Provides flexibility when installing additional packages during setup

### DVD ISO vs NetInstall

Debian provides multiple installation images. The two most common options are the DVD ISO and NetInstall ISO.

| Feature | DVD ISO | NetInstall |
|----------|----------|----------|
| Download Size | Large (several GB) | Small (hundreds of MB) |
| Internet Required | Minimal | Required for most packages |
| Package Availability During Install | Extensive | Downloads packages as needed |
| Installation Speed | Faster on slower networks | Faster download, slower install if many packages are required |
| Best Use Case | Offline or limited-connectivity environments | Connected environments with reliable internet access |

Either approach is valid. For this project, the DVD ISO was selected to provide a self-contained installation experience while learning the Debian deployment process.

---

### Identify the USB Device

List all connected disks and identify the target USB device.

```bash
diskutil list
```

> **Note:** Verify the correct disk identifier before proceeding. Selecting the wrong device may result in data loss.

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

---

### Write the ISO to the USB Device

Create the bootable installation media.

```bash
pv debian-13.5.0-amd64-DVD-1.iso | sudo dd of=/dev/rdiskX bs=4m
```

Replace `rdiskX` with the raw disk identifier for the target USB device.

Using the raw device (`rdisk`) generally provides faster write performance on macOS.

> **Note:** After writing the Debian ISO to a USB device using `dd`, macOS may not display the installation media normally in Finder or Disk Utility. The operating system may show unfamiliar partitions, a small visible volume, or large amounts of unallocated space. This behavior is expected and does not necessarily indicate that the installation media was created incorrectly.
>
> The most reliable validation method is to boot the target system and confirm that an **EFI Boot** option is available in the startup menu.

---

### Eject the USB Device

After the write process completes, safely eject the installation media.

```bash
diskutil eject /dev/diskX
```

---

## Booting the Installation Media

Insert the USB drive into the target system.

For the Mac Mini host:

1. Power on the system.
2. Hold the **Option (⌥)** key during startup.
3. Select **EFI Boot** from the boot menu.

```text
Option (⌥)
```

```text
EFI Boot
```

---

## Debian Installation

The following installation choices were used:

| Setting | Selection |
|----------|----------|
| Installation Type | Debian DVD ISO |
| Hostname | media-services-platform |
| Desktop Environment | None |
| SSH Server | Installed |
| Standard System Utilities | Installed |
| Partitioning | Guided (Entire Disk) |
| Package Repository | Debian Official Mirrors |

The server was deployed as a headless Linux system managed primarily through SSH.

---

## Post-Installation Tasks

After the initial installation:

- Applied all available package updates
- Configured SSH access
- Configured storage mounts
- Installed Jellyfin
- Created media library directories
- Verified network connectivity
- Documented system configuration

Subsequent configuration steps are documented in:

- [Base System Configuration](./base-system-configuration.md)
- [SSH Configuration](./ssh-configuration.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)
- [SMB Storage](./smb-storage.md)

---

## Outcome

A clean Debian 13 server installation was successfully deployed and prepared as the foundation for the Media Services Platform project.
