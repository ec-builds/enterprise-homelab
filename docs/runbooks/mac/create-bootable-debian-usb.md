# Create a Bootable Debian USB on macOS


---

## Overview

This runbook documents the process for creating a bootable Debian installation USB from macOS using native command-line tools and `pv` for progress monitoring.

---

## Prerequisites

- Debian ISO image (`.iso`)
- USB flash drive (8 GB or larger)
- Homebrew installed
- `pv` installed

Install `pv` if needed:

```bash
brew install pv
```

---

## Step 1 - Identify the USB Drive

Insert the USB drive and run:

```bash
diskutil list
```

Example output:

```text
/dev/disk6 (external, physical)
   #: TYPE NAME SIZE IDENTIFIER
   0: FDisk_partition_scheme *16.0 GB disk6
   1: Windows_NTFS Untitled 16.0 GB disk6s1
```

In this example, the USB device is:

```text
/dev/disk6
```

> [!WARNING]
> Verify the correct disk before proceeding. Writing to the wrong disk will permanently erase its contents.

---

## Step 2 - Unmount the USB Drive

```bash
diskutil unmountDisk /dev/disk6
```

Expected output:

```text
Unmount of all volumes on disk6 was successful
```

---

## Step 3 - Verify the ISO File

List available ISO files:

```bash
ls -lh ~/Downloads/*.iso
```

Example:

```text
-rw-r--r--  1 username  staff  647M debian-12.11.0-amd64-netinst.iso
```

Confirm the correct ISO is present before continuing.

---

## Step 4 - Write the ISO to the USB Drive

Use the raw disk device (`rdisk`) for improved performance:

```bash
pv ~/Downloads/debian-12.11.0-amd64-netinst.iso | sudo dd of=/dev/rdisk6 bs=8m
```

### Command Breakdown

| Component | Purpose |
|------------|------------|
| `pv` | Displays transfer progress and speed |
| `dd` | Writes the ISO image directly to the USB |
| `of=/dev/rdisk6` | Target USB device |
| `bs=8m` | Transfer block size |

---

## Step 5 - Flush Pending Writes

```bash
sync
```

This ensures all buffered data is written to the USB device.

---

## Step 6 - Eject the USB Drive

```bash
diskutil eject /dev/disk6
```

Expected output:

```text
Disk disk6 ejected
```

The USB drive can now be safely removed.

---

## Notes

After writing the image, the USB drive may no longer appear as a normal storage device in macOS.

You may receive the following message:

```text
The disk you inserted was not readable by this computer.
```

This behavior is expected for many Linux installation media.

Select:

```text
Ignore
```

Do not reformat the drive.

---

## Verify Bootability

1. Insert the USB drive into the target computer.
2. Open the system boot menu (commonly F12, Esc, F9, or F11).
3. Select the USB device.
4. Confirm the Debian installer starts successfully.

---

## Example Workflow

```bash
diskutil list

diskutil unmountDisk /dev/disk6

pv ~/Downloads/debian-12.11.0-amd64-netinst.iso | sudo dd of=/dev/rdisk6 bs=8m

sync

diskutil eject /dev/disk6
```

---

## Related Runbooks

- Debian Installation
- Hypervisor Deployment
- Proxmox Installation
- Operating System Deployment Standards
