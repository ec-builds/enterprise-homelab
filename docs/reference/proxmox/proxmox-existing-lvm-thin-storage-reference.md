# Proxmox Existing LVM-Thin Storage Reference

Reference procedure for registering an existing Proxmox LVM-thin pool when the underlying storage exists on disk but is not available as a Proxmox storage resource.

This situation can occur after a node is added to a Proxmox cluster because storage configuration is maintained at the datacenter/cluster level.

> **Important:** This procedure registers an existing LVM-thin pool. It does not create, partition, format, or erase storage.

## Scenario

A Proxmox node was installed using a single NVMe drive.

The Proxmox installer created the standard LVM layout:

```text
NVMe
└── LVM Physical Volume
    └── Volume Group: pve
        ├── root
        ├── swap
        └── data
            └── LVM-thin pool for VM/LXC disks
```

After the node joined the existing Proxmox cluster, the node's `data` thin pool was not listed as available storage in the Proxmox interface.

The physical storage still existed. Only the Proxmox storage definition was missing.

## Symptoms

Running:

```bash
pvesm status
```

showed the node's directory storage as active but did not show an active LVM-thin storage resource for its existing `pve/data` pool.

The cluster storage configuration:

```bash
cat /etc/pve/storage.cfg
```

contained LVM-thin definitions for the existing cluster nodes but no definition for the newly added node.

## Why the GUI Could Not Create It

The NVMe drive was already in use by the Proxmox installation.

The disk contained:

- EFI/system partitions
- Proxmox root filesystem
- Swap
- LVM physical volume
- Existing LVM-thin pool

Therefore, workflows that require an **unused disk** could not be used to create another LVM-thin storage device.

This was expected behavior.

The objective was not to create another thin pool. The existing thin pool only needed to be registered with Proxmox.

## Verify the Existing Storage

Before modifying the Proxmox storage configuration, verify that the expected LVM-thin pool actually exists.

### Inspect Block Devices

```bash
lsblk
```

A typical single-disk Proxmox installation may resemble:

```text
nvme0n1
├── nvme0n1p1
├── nvme0n1p2
└── nvme0n1p3
    ├── pve-swap
    ├── pve-root
    ├── pve-data_tmeta
    │   └── pve-data
    └── pve-data_tdata
        └── pve-data
```

The exact disk names and sizes will vary.

### Verify the Physical Volume

```bash
pvs
```

Example:

```text
PV                VG
/dev/nvme0n1p3    pve
```

### Verify the Volume Group

```bash
vgs
```

Confirm that the expected volume group exists:

```text
VG
pve
```

### Verify the Logical Volumes

```bash
lvs
```

The important entry is the existing thin pool:

```text
LV      VG
data    pve
root    pve
swap    pve
```

For the standard installer-created layout, the storage we need to register is therefore:

```text
Volume Group: pve
Thin Pool:    data
```

Do **not** continue with this procedure if the expected thin pool does not exist.

## Register the Existing Thin Pool

Use `pvesm` to create a Proxmox storage definition referencing the existing LVM-thin pool.

Example:

```bash
pvesm add lvmthin nvme-04-lvm \
  --vgname pve \
  --thinpool data \
  --content images,rootdir \
  --nodes prox04
```

For a sanitized/general deployment:

```bash
pvesm add lvmthin <storage-id> \
  --vgname <volume-group> \
  --thinpool <thin-pool> \
  --content images,rootdir \
  --nodes <node-name>
```

For example:

```bash
pvesm add lvmthin nvme-node04-lvm \
  --vgname pve \
  --thinpool data \
  --content images,rootdir \
  --nodes prox-lab-04
```

## What the Command Does

The command creates a Proxmox storage definition similar to:

```text
Storage ID:   nvme-node04-lvm
Type:         LVM-Thin
Volume Group: pve
Thin Pool:    data
Content:      VM disks and LXC disks
Node:         prox-lab-04
```

Conceptually:

```text
Physical NVMe
     │
     ▼
LVM Physical Volume
     │
     ▼
Volume Group: pve
     │
     ├── root
     ├── swap
     │
     └── data
          │
          │ existing thin pool
          ▼
Proxmox Storage Definition
nvme-node04-lvm
          │
          ├── VM disk images
          └── LXC root disks
```

The command does **not**:

- Repartition the NVMe
- Format the NVMe
- Create another volume group
- Create another thin pool
- Move the Proxmox root filesystem
- Modify the existing VM storage layout
- Erase existing data

It tells Proxmox to use an LVM-thin pool that already exists.

## Cluster Configuration

Proxmox storage definitions are maintained in:

```text
/etc/pve/storage.cfg
```

In a cluster, this file is part of the Proxmox cluster filesystem and represents datacenter-level storage configuration.

The resulting definition will resemble:

```text
lvmthin: nvme-node04-lvm
        thinpool data
        vgname pve
        content images,rootdir
        nodes prox-lab-04
```

The `nodes` restriction is important because a local thin pool exists only on the specified physical node.

Although another node could have an LVM volume group and thin pool with identical names, these are separate local storage resources.

## Verify the Configuration

After registering the storage, run:

```bash
pvesm status
```

The new node-local storage should report:

```text
nvme-node04-lvm    lvmthin    active
```

Other node-local storage resources may appear as:

```text
disabled
```

when running the command from a node to which those resources are not assigned. This is expected.

Review the configuration:

```bash
cat /etc/pve/storage.cfg
```

Confirm:

```text
lvmthin: nvme-node04-lvm
        thinpool data
        vgname pve
        content images,rootdir
        nodes prox-lab-04
```

The storage should also appear in the Proxmox interface beneath the appropriate node.

## Storage Naming Convention

The Proxmox storage ID does not have to match the underlying LVM names.

For example:

```text
Proxmox Storage ID: nvme-node04-lvm
Volume Group:       pve
Thin Pool:          data
```

This allows consistent storage naming across the cluster even when nodes have different underlying disk layouts.

Example:

```text
Proxmox Cluster
│
├── prox-lab-01
│   └── nvme-node01-lvm
│
├── prox-lab-02
│   └── nvme-node02-lvm
│
├── prox-lab-03
│   └── nvme-node03-lvm
│
└── prox-lab-04
    └── nvme-node04-lvm
```

The Proxmox storage ID is the administrative name presented by Proxmox. It does not rename the underlying volume group or thin pool.

## Why CLI Was Appropriate

The underlying storage already existed and was actively used by the Proxmox installation.

A disk-creation workflow requiring an unused physical disk therefore was not appropriate.

Using:

```bash
pvesm add lvmthin
```

allowed the existing LVM-thin pool to be registered directly without modifying the disk layout.

This distinction is useful when troubleshooting Proxmox storage:

```text
Disk missing?
    │
    ├── Physical disk/pool does not exist
    │       └── Create/configure storage
    │
    └── Physical disk/pool already exists
            │
            └── Proxmox definition missing
                    └── Register existing storage
```

Always verify the physical and LVM layers before creating new storage.

## Quick Reference

| Purpose | Command |
|---|---|
| View block devices | `lsblk` |
| View LVM physical volumes | `pvs` |
| View LVM volume groups | `vgs` |
| View LVM logical volumes | `lvs` |
| View Proxmox storage status | `pvesm status` |
| View cluster storage configuration | `cat /etc/pve/storage.cfg` |
| Register existing LVM-thin pool | `pvesm add lvmthin ...` |

## Key Takeaway

Proxmox storage has two separate layers:

```text
Underlying Linux Storage
        +
Proxmox Storage Configuration
```

An LVM-thin pool can exist on disk without being configured as an available Proxmox storage resource.

Before creating, formatting, or repartitioning storage, verify whether the required storage already exists at the Linux/LVM layer. If it does, the correct solution may simply be to register that existing storage with Proxmox.
