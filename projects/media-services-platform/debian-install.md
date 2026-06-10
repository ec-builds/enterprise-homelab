# Debian Installation

This document outlines the process used to create bootable installation media and install Debian 13 on the Media Services Platform host.

## Overview

Debian 13 was selected as the operating system for this project due to its stability, extensive package repository, long-term maintainability, and suitability for self-hosted services.

The installation media was created on **macOS Tahoe 26.5** and deployed to a dedicated host system **(2014 Mac Mini)**.

---

## Installation Media Preparation

### Download Installation Image

Download the Debian 13 NetInstall ISO from the official Debian website.

Example:

```text
debian-13.0.0-amd64-netinst.iso
```

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
shasum -a 256 debian-13.0.0-amd64-netinst.iso
```

Compare the resulting hash with the checksum published by the Debian project.

---

### Write the ISO to the USB Device

Create the bootable installation media.

```bash
pv debian-13.0.0-amd64-netinst.iso | sudo dd of=/dev/rdiskX bs=4m
```

Replace `rdiskX` with the raw disk identifier for the target USB device.

Using the raw device (`rdisk`) generally provides faster write performance on macOS.

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
| Installation Type | Debian NetInstall |
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
