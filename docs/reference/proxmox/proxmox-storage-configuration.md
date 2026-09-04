# Proxmox Storage Configuration

## Purpose

Documents the standard Proxmox local storage configuration using `prox-lab-01`
as the representative implementation for repeatability across current and future nodes.

## Background

During the initial install of each node, I didn't plan out the final storage
layout and used the Proxmox defaults. This created an unused `/data` section
of approximately 800 GB on the primary drive.
I used this process to reclaim that space as ext4 storage so it could be used
for backups, ISOs, templates, and other general storage.

> [!NOTE]
> For future deployments, plan the final storage layout during installation where
> practical. This post-installation method achieves the same intended architecture.

> [!WARNING]
> This procedure modifies LVM logical volumes and can destroy data.
> Verify that the target thin pool contains no VM or container disks before removal.



## Target Layout

```text
Primary SSD
├── Proxmox root
├── ext4 general storage
└── LVM free-space reserve

Secondary NVMe
└── LVM-Thin VM / CT storage
```



## Inspect Existing Storage

```bash
lsblk
pvs
vgs
lvs
pvesm status
```

Verify the Proxmox storage configuration:

```bash
cat /etc/pve/storage.cfg
```

Confirm that the OS-drive thin pool contains no VM or container disks before
continuing.



## Remove the Unused Thin Pool

```bash
lvremove /dev/pve/data
```

Verify:

```bash
lvs
vgs
```



## Create General Storage

Example using `prox-lab-01`:

```bash
lvcreate -L 800G -n prox-lab-01-storage pve
```

Verify:

```bash
lvs
vgs
```

A portion of the volume group is intentionally left unallocated for future
expansion.



## Create the ext4 Filesystem

```bash
mkfs.ext4 /dev/pve/prox-lab-01-storage
```

Create the mount point:

```bash
mkdir -p /mnt/prox-lab-01-storage
```

Retrieve the filesystem UUID:

```bash
blkid /dev/pve/prox-lab-01-storage
```



## Configure Persistent Mounting

Add the filesystem to `/etc/fstab` using its UUID:

```text
UUID=<filesystem-uuid> /mnt/prox-lab-01-storage ext4 defaults 0 2
```

Reload and mount:

```bash
systemctl daemon-reload
mount -a
```

Verify:

```bash
df -h /mnt/prox-lab-01-storage
```



## Adjust ext4 Reserved Space

Reduce the reserved filesystem capacity to 1%:

```bash
tune2fs -m 1 /dev/pve/prox-lab-01-storage
```

Verify:

```bash
df -h /mnt/prox-lab-01-storage
```

> [!NOTE]
> This adjustment is intended for the dedicated data filesystem, not the
> Proxmox root filesystem.



## Add Storage to Proxmox

Navigate to:

```text
Datacenter
└── Storage
    └── Add
        └── Directory
```

Example:

```text
ID:
prox-lab-01-storage

Directory:
/mnt/prox-lab-01-storage

Content:
✓ ISO image
✓ Container template
✓ Backup
✓ Snippets

Nodes:
✓ prox-lab-01

Shared:
☐
```

Do not enable VM or container disk content when dedicated LVM-Thin storage
is used for those workloads.



## Validate

```bash
pvesm status
```

Confirm that:

- The new Directory storage is active
- The storage is restricted to the correct node
- The filesystem is mounted correctly
- VM storage remains on the dedicated LVM-Thin volume
- The system volume group retains the intended free-space reserve



## Additional Nodes

Nodes following the standard architecture use the same procedure with
node-specific names.

For example:

```text
prox-lab-01-storage
prox-lab-02-storage
```

Always inspect the existing LVM configuration before making changes rather
than assuming another node has an identical disk state.
