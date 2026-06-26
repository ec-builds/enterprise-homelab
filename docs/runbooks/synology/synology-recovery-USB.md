# Create Synology Active Backup Recovery Media on macOS

**File:** `create-synology-recovery-media-macos.md`

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Install Dependencies](#install-dependencies)
- [Verify the Recovery ISO](#verify-the-recovery-iso)
- [Identify the USB Drive](#identify-the-usb-drive)
- [Unmount the USB Drive](#unmount-the-usb-drive)
- [Write the Recovery Media](#write-the-recovery-media)
- [Flush and Eject the USB](#flush-and-eject-the-usb)
- [Test the Recovery Media](#test-the-recovery-media)
- [Complete Workflow](#complete-workflow)
- [Troubleshooting](#troubleshooting)
- [Notes](#notes)
- [References](#references)

---

## Overview

This guide creates a bootable Synology Active Backup Recovery USB on macOS using `dd` with `pv` for progress monitoring.

This method was validated using:

- macOS
- `Synology-Recovery-Media-4503(5053).iso`
- USB flash drive
- Terminal

Although Synology documents several supported methods, this guide focuses on the direct imaging approach.

---

## Prerequisites

- macOS
- Synology Recovery ISO
- USB flash drive (8 GB or larger)
- Homebrew
- `pv`

---

## Install Dependencies

Install Pipe Viewer if it is not already installed.

```bash
brew install pv
```

---

## Verify the Recovery ISO

Confirm that the ISO is recognized as bootable.

```bash
file ~/Downloads/Synology-Recovery-Media-4503\(5053\).iso
```

Expected output:

```text
ISO 9660 CD-ROM filesystem data 'slax' (bootable)
```

---

## Identify the USB Drive

List all storage devices.

```bash
diskutil list
```

Locate the external USB drive.

Example:

```text
/dev/disk4 (external, physical)
```

> **Warning**
>
> Verify the disk identifier before continuing. Writing to the wrong device will permanently erase its contents.

---

## Unmount the USB Drive

Unmount the USB without ejecting it.

```bash
diskutil unmountDisk /dev/disk4
```

---

## Write the Recovery Media

Use the raw disk device (`rdisk`) for improved write performance.

```bash
pv ~/Downloads/Synology-Recovery-Media-4503\(5053\).iso \
| sudo dd of=/dev/rdisk4 bs=4m conv=sync,status=progress
```

---

## Flush and Eject the USB

Flush pending writes.

```bash
sync
```

Safely eject the drive.

```bash
diskutil eject /dev/disk4
```

---

## Test the Recovery Media

1. Insert the USB into the target computer.
2. Open the system boot menu.
3. Select the USB device.
4. Verify that the Synology Active Backup Recovery environment loads successfully.

---

## Complete Workflow

```bash
diskutil list

diskutil unmountDisk /dev/disk4

pv ~/Downloads/Synology-Recovery-Media-4503\(5053\).iso \
| sudo dd of=/dev/rdisk4 bs=4m conv=sync,status=progress

sync

diskutil eject /dev/disk4
```

---

## Troubleshooting

### USB is Busy

```bash
diskutil unmountDisk /dev/disk4
```

---

### Permission Denied

Run the command using `sudo`.

---

### Incorrect Disk Selected

Immediately stop the operation.

```text
Ctrl + C
```

Run:

```bash
diskutil list
```

Verify the correct device before retrying.

---

### Recovery Media Does Not Boot

If the USB fails to boot on a UEFI-only system:

- Verify Secure Boot settings.
- Test the USB on another computer.
- Recreate the media using Synology's documented UEFI procedure.

---

## Notes

### Why use `rdisk`?

macOS exposes two device nodes.

- `/dev/diskX` — Buffered device access
- `/dev/rdiskX` — Raw device access

Using the raw device significantly improves write performance.

---

### Why use `pv`?

`pv` provides:

- Progress indicator
- Throughput
- Elapsed time
- Estimated time remaining

This makes long-running `dd` operations easier to monitor.

---

### Why use `dd`?

The downloaded recovery image is recognized as a bootable ISO:

```text
ISO 9660 CD-ROM filesystem data 'slax' (bootable)
```

Writing the ISO directly with `dd` creates bootable recovery media in the same manner as many ISO imaging applications.

---

### Validation

This procedure has been validated on macOS using:

- `Synology-Recovery-Media-4503(5053).iso`

Boot testing on the target hardware is recommended after writing the image.

---

## References

Synology documents three supported approaches for creating recovery media:

1. ISO burning software (recommended for general use)
2. Legacy BIOS (`dd`)
3. Manual UEFI media creation

This guide documents the direct imaging workflow using `dd`, which is suitable for bootable ISO images and provides a fast, scriptable method for macOS.
