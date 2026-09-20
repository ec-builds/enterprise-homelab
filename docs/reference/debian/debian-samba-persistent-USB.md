# Debian Persistent USB Storage Reference

Sanitized reference for deploying a permanently mounted USB storage device on Debian using an ext4 filesystem, UUID-based `/etc/fstab` mounting, and mount-point protection.

## Overview

This deployment configures a USB storage device as persistent local storage for a Debian server.

The design uses:

- A dedicated USB storage device
- `ext4` filesystem
- Filesystem UUID for persistent identification
- `/mnt/storage` as the mount point
- `/etc/fstab` for automatic mounting
- `nofail` to allow Debian to boot if the USB device is unavailable
- Protected underlying mount point to prevent accidental writes to system storage

Example architecture:

```text
Debian Server
│
├── System Storage
│   └── /mnt/storage
│       └── Protected underlying mount point
│
└── USB Storage
    └── ext4 filesystem
        └── /mnt/storage
            └── shared
```

When the USB filesystem is mounted, it overlays the underlying `/mnt/storage` directory.

## Identify the USB Drive

Before formatting or modifying any disk, positively identify the intended device.

List block devices:

```bash
lsblk -o NAME,SIZE,MODEL,TRAN,FSTYPE,UUID,MOUNTPOINTS
```

Display partition information:

```bash
sudo fdisk -l
```

Example:

```text
NAME        SIZE MODEL       TRAN FSTYPE UUID MOUNTPOINTS
sda         250G USB Storage usb
└─sda1      250G                  exfat  XXXX-XXXX
mmcblk0      64G             mmc
└─mmcblk0p1  64G                  ext4  <system-uuid> /
```

In this example:

```text
/dev/sda
```

is the USB storage device and:

```text
/dev/sda1
```

is its existing partition.

> Always verify the device before running filesystem creation commands. Formatting the wrong device will destroy data.

## Verify the Partition Is Not Mounted

Before formatting:

```bash
findmnt /dev/sda1
```

If the command returns nothing, the filesystem is not currently mounted.

You can also check:

```bash
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS
```

## Format the Partition as ext4

For a storage device permanently owned by a Linux server, `ext4` is a good general-purpose filesystem.

Format the partition:

```bash
sudo mkfs.ext4 -L storage /dev/sda1
```

If an existing filesystem is detected, `mkfs.ext4` will ask for confirmation before replacing it.

Example:

```text
/dev/sda1 contains an existing filesystem
Proceed anyway? (y,N)
```

Formatting destroys the existing filesystem and its data.

The resulting filesystem will receive a new UUID.

## Find the Filesystem UUID

Display the new filesystem information:

```bash
sudo blkid /dev/sda1
```

Example:

```text
/dev/sda1: LABEL="storage" UUID="<filesystem-uuid>" BLOCK_SIZE="4096" TYPE="ext4"
```

The UUID uniquely identifies the filesystem.

Use the UUID for persistent mounting instead of relying on:

```text
/dev/sda1
```

Device names such as `/dev/sda` can potentially change depending on device detection order.

## Create the Mount Point

Create the directory where the filesystem will be mounted:

```bash
sudo mkdir -p /mnt/storage
```

Verify:

```bash
ls -ld /mnt/storage
```

Before the USB filesystem is mounted, this directory exists on the Debian system filesystem.

## Back Up `/etc/fstab`

Before modifying the filesystem table:

```bash
sudo cp /etc/fstab /etc/fstab.bak
```

The backup can be restored if necessary:

```bash
sudo cp /etc/fstab.bak /etc/fstab
```

## Configure `/etc/fstab`

Edit:

```bash
sudo vi /etc/fstab
```

Or:

```bash
sudo nano /etc/fstab
```

Add:

```fstab
UUID=<filesystem-uuid> /mnt/storage ext4 defaults,nofail 0 2
```

Example structure:

```text
UUID=<filesystem-uuid> /mnt/storage ext4 defaults,nofail 0 2
```

### `/etc/fstab` Fields

| Field | Value | Purpose |
|---|---|---|
| Device | `UUID=<filesystem-uuid>` | Identifies the filesystem |
| Mount point | `/mnt/storage` | Directory where it is mounted |
| Filesystem | `ext4` | Filesystem type |
| Options | `defaults,nofail` | Standard options and non-fatal boot behavior |
| Dump | `0` | Disables legacy dump backups |
| fsck pass | `2` | Checks filesystem after the root filesystem |

### Why Use `nofail`

The `nofail` option allows Debian to continue booting if the USB storage device:

- Is disconnected
- Fails
- Is temporarily unavailable
- Takes longer than expected to appear

This is particularly useful when the server provides other services that should continue operating independently of the USB storage.

## Reload systemd

After modifying `/etc/fstab`, systemd may report:

```text
your fstab has been modified, but systemd still uses the old version
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

## Mount the Filesystem

Test all `/etc/fstab` entries:

```bash
sudo mount -a
```

A successful command normally produces no output.

Verify:

```bash
findmnt /mnt/storage
```

Example:

```text
TARGET       SOURCE    FSTYPE OPTIONS
/mnt/storage /dev/sda1 ext4   rw,relatime
```

Check capacity:

```bash
df -h /mnt/storage
```

Example:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       230G  2.1M  218G   1% /mnt/storage
```

## Create Storage Directories

Create directories according to the workload.

Example:

```bash
sudo mkdir -p /mnt/storage/shared
```

Assign ownership:

```bash
sudo chown <linux-user>:<linux-user> /mnt/storage/shared
```

Apply permissions:

```bash
sudo chmod 2770 /mnt/storage/shared
```

Verify:

```bash
ls -ld /mnt/storage/shared
```

Expected structure:

```text
drwxrws--- <linux-user> <linux-user> /mnt/storage/shared
```

## Understanding `2770`

The standard permissions are:

```text
770 = rwxrwx---
```

This means:

```text
Owner  → read + write + execute
Group  → read + write + execute
Others → no access
```

The leading:

```text
2
```

enables the **setgid** bit.

Therefore:

```text
2770
```

is displayed approximately as:

```text
rwxrws---
```

The `s` indicates setgid.

For a directory, setgid causes newly created files and subdirectories to inherit the parent directory's group.

This is useful for shared storage where multiple authorized users may eventually need access.

## Test Filesystem Writes

Before configuring applications to use the storage, verify that the intended Linux user can write to it without `sudo`.

Create a test file:

```bash
touch /mnt/storage/shared/test.txt
```

Verify:

```bash
ls -l /mnt/storage/shared/test.txt
```

Remove it:

```bash
rm /mnt/storage/shared/test.txt
```

If these commands succeed without `sudo`, the user has working filesystem access.

## Protect the Underlying Mount Point

There is an important behavior to understand with Linux mount points.

The directory:

```text
/mnt/storage
```

exists on the system filesystem even when the USB filesystem is not mounted.

Normally:

```text
USB mounted
     ↓
/mnt/storage
     ↓
USB filesystem
```

But if the USB fails to mount:

```text
USB unavailable
     ↓
/mnt/storage
     ↓
Underlying system directory
```

An application configured to write to `/mnt/storage` could therefore accidentally write data to the system disk.

This is particularly important when using:

```fstab
nofail
```

because the server intentionally continues booting when the USB storage is unavailable.

### Protect the Underlying Directory

Stop applications currently using the storage.

For example:

```bash
sudo systemctl stop <service>
```

Unmount the USB filesystem:

```bash
sudo umount /mnt/storage
```

Confirm it is unmounted:

```bash
findmnt /mnt/storage
```

The command should return nothing.

The visible `/mnt/storage` directory is now the underlying directory on the system filesystem.

Lock it:

```bash
sudo chmod 000 /mnt/storage
```

Verify:

```bash
ls -ld /mnt/storage
```

Expected:

```text
d--------- root root /mnt/storage
```

This prevents normal service users from accidentally traversing or writing to the underlying directory.

## Remount the USB Filesystem

Mount it again using the `/etc/fstab` configuration:

```bash
sudo mount /mnt/storage
```

Verify:

```bash
findmnt /mnt/storage
```

Then:

```bash
ls -ld /mnt/storage
ls -ld /mnt/storage/shared
```

Once mounted, the USB filesystem's root directory permissions replace the visible permissions of the protected underlying mount point.

For example:

```text
/mnt/storage
drwxr-xr-x root root

/mnt/storage/shared
drwxrws--- <linux-user> <linux-user>
```

The underlying:

```text
d--------- /mnt/storage
```

still exists on the system filesystem but remains hidden while the USB filesystem is mounted.

## Mount-Point Protection Behavior

### Normal Operation

```text
System filesystem
└── /mnt/storage     mode 000
        │
        │ USB mounted over directory
        ▼
USB ext4 filesystem
└── /mnt/storage
    └── shared       mode 2770
```

Applications access the USB filesystem normally.

### USB Not Mounted

```text
System filesystem
└── /mnt/storage     mode 000
```

Normal service users cannot traverse or write into the directory.

This helps prevent data intended for the USB device from accidentally filling the system filesystem.

## Restart Dependent Services

After the USB filesystem is mounted and verified, restart any service that depends on it.

Example:

```bash
sudo systemctl start <service>
```

Verify:

```bash
systemctl status <service> --no-pager
```

## Reboot Persistence Test

The final deployment test is a reboot.

```bash
sudo reboot
```

After reconnecting, verify:

```bash
findmnt /mnt/storage
```

Check capacity:

```bash
df -h /mnt/storage
```

Expected:

```text
TARGET       SOURCE    FSTYPE OPTIONS
/mnt/storage /dev/sda1 ext4   rw,relatime
```

The presence of `/dev/sda1` in this output is only an example. The important point is that the filesystem identified by the configured UUID mounted successfully at `/mnt/storage`.

## Verify the UUID

At any time, verify the filesystem identity with:

```bash
sudo blkid
```

Or:

```bash
sudo blkid /dev/sda1
```

Compare the UUID with the entry in:

```text
/etc/fstab
```

View the active configuration:

```bash
cat /etc/fstab
```

## Verify Storage Health and Usage

Check mounted filesystems:

```bash
findmnt
```

Check storage usage:

```bash
df -h
```

Check only the persistent USB storage:

```bash
df -h /mnt/storage
```

Inspect the directory:

```bash
ls -lash /mnt/storage
```

Display block-device information:

```bash
lsblk -o NAME,SIZE,MODEL,TRAN,FSTYPE,UUID,MOUNTPOINTS
```

## `lost+found`

An ext4 filesystem normally contains:

```text
lost+found
```

Example:

```text
/mnt/storage/lost+found
```

This directory is automatically created by `mkfs.ext4`.

It is used by filesystem recovery tools such as `fsck` to store recovered filesystem objects when their original directory information cannot be determined.

It should normally be left alone.

## Unmount the Storage Safely

Before physically disconnecting the USB device, stop services actively using it.

Example:

```bash
sudo systemctl stop <service>
```

Then unmount:

```bash
sudo umount /mnt/storage
```

Verify:

```bash
findmnt /mnt/storage
```

If nothing is returned, the filesystem is no longer mounted.

Do not unplug a storage device while applications are actively writing to it.

## Troubleshooting

### `mount -a` Reports an `/etc/fstab` Reload Hint

Run:

```bash
sudo systemctl daemon-reload
```

Then:

```bash
sudo mount -a
```

### Filesystem Does Not Mount

Check the device:

```bash
lsblk -o NAME,SIZE,MODEL,TRAN,FSTYPE,UUID,MOUNTPOINTS
```

Check its UUID:

```bash
sudo blkid
```

Compare it with:

```bash
cat /etc/fstab
```

Test:

```bash
sudo mount -a
```

Check system logs:

```bash
journalctl -b --no-pager
```

### Device Name Changed

This should not affect the deployment if `/etc/fstab` uses:

```text
UUID=<filesystem-uuid>
```

The kernel may assign a different `/dev/sdX` name, but the filesystem UUID remains the persistent identifier.

### Permission Denied

Check the mount:

```bash
findmnt /mnt/storage
```

Then inspect permissions:

```bash
ls -ld /mnt/storage
ls -ld /mnt/storage/shared
```

Check the complete path:

```bash
namei -l /mnt/storage/shared
```

Verify the user:

```bash
id <linux-user>
```

### Unable to Unmount

Determine which processes are using the filesystem:

```bash
sudo fuser -vm /mnt/storage
```

Make sure your shell is not currently inside:

```text
/mnt/storage
```

Move elsewhere:

```bash
cd ~
```

Then retry:

```bash
sudo umount /mnt/storage
```

Avoid forcing an unmount unless there is a specific reason to do so.

## Security and Reliability Notes

The USB storage device should not be treated as a backup simply because it is separate from the system disk.

Important data should exist on another independent storage system.

Examples include:

- NAS
- Backup server
- Separate external storage
- Off-site storage
- Cloud backup

Using `nofail` improves server availability because unrelated services can continue running when the USB device is unavailable.

Protecting the underlying mount point helps prevent applications from silently redirecting storage onto the system filesystem when that happens.

## Quick Deployment Checklist

- [ ] Identify the correct USB device
- [ ] Confirm the intended partition
- [ ] Verify the partition is unmounted
- [ ] Format the partition as ext4
- [ ] Record the filesystem UUID
- [ ] Create `/mnt/storage`
- [ ] Back up `/etc/fstab`
- [ ] Add UUID-based `/etc/fstab` entry
- [ ] Include `nofail`
- [ ] Reload systemd
- [ ] Run `mount -a`
- [ ] Verify with `findmnt`
- [ ] Verify capacity with `df -h`
- [ ] Create application/storage directories
- [ ] Configure ownership
- [ ] Configure permissions
- [ ] Test writes without `sudo`
- [ ] Stop dependent services
- [ ] Unmount the USB filesystem
- [ ] Protect the underlying mount point
- [ ] Remount the USB filesystem
- [ ] Restart dependent services
- [ ] Reboot the server
- [ ] Verify the filesystem automatically remounted

## Quick Reference

```bash
# Identify storage
lsblk -o NAME,SIZE,MODEL,TRAN,FSTYPE,UUID,MOUNTPOINTS

# Partition information
sudo fdisk -l

# Filesystem UUIDs
sudo blkid

# Create ext4 filesystem
sudo mkfs.ext4 -L storage /dev/sda1

# Create mount point
sudo mkdir -p /mnt/storage

# Back up fstab
sudo cp /etc/fstab /etc/fstab.bak

# Reload systemd after editing fstab
sudo systemctl daemon-reload

# Mount fstab filesystems
sudo mount -a

# Verify mount
findmnt /mnt/storage

# Check capacity
df -h /mnt/storage

# Create shared storage directory
sudo mkdir -p /mnt/storage/shared

# Assign ownership
sudo chown <linux-user>:<linux-user> /mnt/storage/shared

# Apply shared-directory permissions
sudo chmod 2770 /mnt/storage/shared

# Safely unmount
sudo umount /mnt/storage

# Protect underlying mount point
sudo chmod 000 /mnt/storage

# Remount
sudo mount /mnt/storage

# Inspect permissions
ls -ld /mnt/storage
ls -ld /mnt/storage/shared

# Determine what is using the filesystem
sudo fuser -vm /mnt/storage
```
