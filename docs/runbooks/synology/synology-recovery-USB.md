# Create Synology Active Backup Recovery Media on macOS

**ISO:** `Synology-Recovery-Media-4503(5053).iso`

## Overview

This guide creates a bootable Synology Active Backup Recovery USB on macOS using `dd` with `pv` for progress monitoring.

---

## Prerequisites

- macOS
- Synology Recovery ISO
- USB flash drive (8 GB or larger)
- Homebrew
- `pv` installed

Install `pv` if necessary:

```bash
brew install pv
```

---

## 1. Identify the USB Drive

List all disks:

```bash
diskutil list
```

Locate the external USB drive.

Example:

```text
/dev/disk4 (external, physical)
```

> **Warning:** Double-check the disk number before continuing. Writing to the wrong disk will permanently erase it.

---

## 2. Unmount the USB

Unmount the disk without ejecting it:

```bash
diskutil unmountDisk /dev/disk4
```

Replace `disk4` with your USB's disk identifier.

---

## 3. Write the ISO

Use the raw disk device (`rdisk`) for significantly faster write speeds.

```bash
pv ~/Downloads/Synology-Recovery-Media-4503\(5053\).iso \
| sudo dd of=/dev/rdisk4 bs=4m conv=sync,status=progress
```

Notes:

- `pv` displays progress and throughput.
- `rdisk4` provides raw device access for improved performance.
- Parentheses in the filename are escaped using `\(` and `\)`.

---

## 4. Flush Pending Writes

Ensure all buffered data is written to the USB.

```bash
sync
```

---

## 5. Eject the USB

Safely eject the drive.

```bash
diskutil eject /dev/disk4
```

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

## Verify Boot Media

1. Insert the USB into the target computer.
2. Enter the system boot menu (typically **F12**, **Esc**, or **F11**, depending on the manufacturer).
3. Select the USB device.
4. Confirm that the Synology Active Backup Recovery environment loads successfully.

---

## Troubleshooting

### Device is Busy

If `dd` reports that the device is busy:

```bash
diskutil unmountDisk /dev/disk4
```

Try the command again.

---

### Permission Denied

Ensure `sudo` is used with `dd`.

---

### Wrong Disk Selected

Cancel immediately using:

```text
Ctrl + C
```

Then verify the correct disk with:

```bash
diskutil list
```

---

