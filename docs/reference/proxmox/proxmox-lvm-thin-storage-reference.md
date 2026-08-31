# Proxmox LVM-Thin Storage Reference

Quick reference for understanding, configuring, inspecting, removing, and troubleshooting LVM-thin storage in Proxmox VE.

> Examples use fictional device names, storage identifiers, and node names. Values do not represent the internal storage configuration of the documented environment.

## Storage Architecture

Proxmox can use Linux Logical Volume Manager (LVM) thin provisioning to provide storage for virtual machine and container disks.

The storage stack consists of several separate layers:

```text
Physical Disk
     │
     ▼
LVM Physical Volume (PV)
     │
     ▼
Volume Group (VG)
     │
     ▼
LVM Thin Pool
     │
     ▼
Proxmox Storage Definition
     │
     ▼
VM / Container Disks
```

Understanding these layers is important because removing or modifying one layer does not necessarily affect the others.

## LVM Components

### Physical Volume (PV)

A physical disk or partition initialized for use by LVM.

Example:

```text
/dev/nvme0n1
```

View physical volumes:

```bash
pvs
```

Example:

```text
PV             VG        Fmt   Attr   PSize     PFree
/dev/nvme0n1   nvme-01   lvm2  a--   <1.00t    100.00m
/dev/sda3      pve       lvm2  a--   <1.00t     16.00g
```

### Volume Group (VG)

A storage pool created from one or more physical volumes.

Example:

```text
/dev/nvme0n1
      │
      ▼
   nvme-01
```

View volume groups:

```bash
vgs
```

Example:

```text
VG        #PV  #LV  #SN  Attr    VSize    VFree
nvme-01     1    1    0  wz--n-  <1.00t   100.00m
pve         1    3    0  wz--n-  <1.00t    16.00g
```

### Logical Volume / Thin Pool

A thin pool is an LVM logical volume capable of thin provisioning.

Example:

```text
VG:        nvme-01
Thin Pool: nvme-01
```

View logical volumes:

```bash
lvs
```

Example:

```text
LV        VG        Attr        LSize    Data%  Meta%
nvme-01   nvme-01   twi-a-tz-- <950g     0.00   0.20
data      pve       twi-a-tz-- <800g     5.00   0.25
root      pve       -wi-ao----   96g
swap      pve       -wi-ao----    8g
```

## Default Proxmox Storage

A standard Proxmox installation commonly creates a volume group named:

```text
pve
```

It may contain:

```text
pve
├── root
├── swap
└── data
```

These serve different purposes:

| Logical Volume | Purpose |
|---|---|
| `root` | Proxmox operating system |
| `swap` | Linux swap |
| `data` | Default LVM thin pool |
| `local-lvm` | Proxmox storage ID pointing to `pve/data` |

The relationship is:

```text
System SSD
    │
    ▼
PV
    │
    ▼
VG: pve
    │
    ├── root
    ├── swap
    │
    └── Thin Pool: data
              │
              ▼
     Proxmox Storage: local-lvm
```

> **Caution:** The `pve` volume group normally contains the Proxmox operating system. Do not remove or modify it when working with an additional storage device unless the intended operation specifically requires it.

## Additional NVMe Storage

A secondary NVMe device can be configured independently from the Proxmox system drive.

Example:

```text
/dev/nvme0n1
      │
      ▼
PV: /dev/nvme0n1
      │
      ▼
VG: nvme-01
      │
      ▼
Thin Pool: nvme-01
      │
      ▼
Proxmox Storage ID: nvme-01-lvm
```

In a multi-node cluster, a consistent naming convention makes node-local storage easier to identify:

```text
pve01 → nvme-01-lvm
pve02 → nvme-02-lvm
pve03 → nvme-03-lvm
```

These names identify separate local storage devices. They do not imply shared storage.

## Proxmox Storage Definitions

Proxmox maintains a storage configuration separate from the underlying LVM configuration.

View configured storage:

```bash
pvesm status
```

Example:

```text
Name          Type      Status
local         dir       active
local-lvm     lvmthin   active
nvme-01-lvm   lvmthin   active
```

Cluster storage configuration can also be inspected with:

```bash
cat /etc/pve/storage.cfg
```

Example:

```text
lvmthin: nvme-01-lvm
        thinpool nvme-01
        vgname nvme-01
        content images,rootdir
        nodes pve01
```

This describes the relationship:

```text
Proxmox Storage ID
nvme-01-lvm
      │
      ├── Node: pve01
      ├── VG: nvme-01
      └── Thin Pool: nvme-01
```

The **storage ID does not need to have the same name as the VG or thin pool**.

For example, this is valid:

```text
Storage ID: nvme-01-lvm
VG:         vm-storage
Thin Pool:  vm-thin
```

Consistent names are primarily an administrative convention.

## Node-Local Storage in a Cluster

Proxmox storage configuration is cluster-wide, while physical disks and their LVM structures can remain local to individual nodes.

For example:

```text
                 Proxmox Cluster
                       │
              /etc/pve/storage.cfg
                       │
          ┌────────────┴────────────┐
          │                         │
        pve01                     pve02
          │                         │
   Local NVMe SSD            Local NVMe SSD
          │                         │
   nvme-01-lvm               nvme-02-lvm
```

A node-specific storage definition can restrict storage to the node containing the physical device:

```text
lvmthin: nvme-01-lvm
        thinpool nvme-01
        vgname nvme-01
        content images,rootdir
        nodes pve01
```

This prevents Proxmox from treating the storage definition as available on nodes that do not contain the corresponding LVM structures.

## Inspect Storage

### Physical Disks

```bash
lsblk
```

For additional detail:

```bash
lsblk -o NAME,SIZE,TYPE,MODEL,SERIAL
```

> Avoid publishing real hardware serial numbers in public documentation or screenshots.

### LVM Physical Volumes

```bash
pvs
```

### Volume Groups

```bash
vgs
```

### Logical Volumes and Thin Pools

```bash
lvs
```

### Proxmox Storage

```bash
pvesm status
```

### Proxmox Storage Configuration

```bash
cat /etc/pve/storage.cfg
```

Together, these commands allow the complete storage path to be traced:

```text
lsblk
  ↓
Physical disk

pvs
  ↓
Physical Volume

vgs
  ↓
Volume Group

lvs
  ↓
Thin Pool

pvesm status
  ↓
Proxmox Storage
```

## Removing Storage vs Removing LVM

Removing a storage entry through:

```text
Datacenter
  └── Storage
       └── Remove
```

removes the **Proxmox storage definition**.

It does not necessarily remove:

```text
Physical Disk
LVM Physical Volume
Volume Group
Thin Pool
```

Therefore, a device can disappear from the normal Proxmox storage tree while remaining visible under:

```text
Node → Disks → LVM-Thin
```

This is expected because the underlying Linux LVM structures still exist.

## Safely Removing an Empty LVM-Thin Pool

> **Warning:** The following commands are destructive. Verify the target device, volume group, thin pool, and stored data before proceeding.

First inspect the environment:

```bash
lsblk
pvs
vgs
lvs
pvesm status
```

Confirm that:

- The correct physical device has been identified.
- The volume group does not contain required volumes.
- The thin pool contains no VM or container disks that must be preserved.
- The target is not the Proxmox system `pve` volume group.
- The Proxmox storage definition has been removed or is no longer in use.

For this fictional example:

```text
Physical device: /dev/nvme0n1
VG:              nvme-old
Thin Pool:       nvme-old
```

Remove the thin pool:

```bash
lvremove /dev/nvme-old/nvme-old
```

Remove the now-empty volume group:

```bash
vgremove nvme-old
```

Remove LVM physical-volume metadata from the device:

```bash
pvremove /dev/nvme0n1
```

Verify afterward:

```bash
pvs
vgs
lvs
```

The removed NVMe should no longer appear as an LVM physical volume.

> Never copy destructive LVM commands from documentation without first verifying the actual device and LVM names on the target system.

## Recreating LVM-Thin Storage

After the previous LVM configuration has been removed, the device can be recreated using the desired naming convention.

One approach is through the Proxmox interface:

```text
Node
└── Disks
    └── LVM-Thin
        └── Create: Thinpool
```

Example naming:

```text
Node:       pve01
Disk:       /dev/nvme0n1
VG Name:    nvme-01
Thin Pool:  nvme-01
```

The resulting thin pool can then be registered as Proxmox storage.

Example:

```text
Storage ID: nvme-01-lvm
Node:       pve01
VG:         nvme-01
Thin Pool:  nvme-01
Content:    Disk image, Container
```

Verify:

```bash
pvs
vgs
lvs
pvesm status
```

## Issue 1 — NVMe Exists but Does Not Appear in the Node Storage Tree

### Symptom

An NVMe device appears under:

```text
Node → Disks
```

and its thin pool appears under:

```text
Node → Disks → LVM-Thin
```

but no corresponding storage appears in the node's main resource tree.

### Diagnosis

Check:

```bash
pvesm status
lvs
cat /etc/pve/storage.cfg
```

A possible state is:

```text
Linux/LVM
VG:        nvme-02
Thin Pool: nvme-02
Status:    Active
```

while `/etc/pve/storage.cfg` contains no corresponding Proxmox storage definition.

### Cause

The underlying LVM configuration exists, but it has not been registered as usable Proxmox storage.

### Resolution

Add an LVM-thin storage definition pointing to the existing VG and thin pool:

```text
Storage ID: nvme-02-lvm
VG:         nvme-02
Thin Pool:  nvme-02
Node:       pve02
```

No disk wipe or LVM recreation is required when the existing structures are correct.

## Issue 2 — Storage Becomes Disabled After Joining a Cluster

### Symptom

After a node joins a Proxmox cluster:

```bash
pvesm status
```

may show a storage definition as:

```text
nvme-01-lvm   lvmthin   disabled
```

even though:

```bash
lvs
```

shows that the node's local thin pool remains active.

### Cause

Proxmox storage definitions are part of the cluster-wide configuration.

The cluster may contain a definition similar to:

```text
lvmthin: nvme-01-lvm
        thinpool nvme-01
        vgname nvme-01
        nodes pve01
```

On `pve02`, this storage is correctly unavailable because the definition is restricted to `pve01`.

Meanwhile, `pve02` may have its own completely separate local NVMe and LVM configuration.

### Resolution

Create a separate node-specific storage definition:

```text
pve01 → nvme-01-lvm
pve02 → nvme-02-lvm
```

Each definition should point to the VG and thin pool physically present on that node.

## Issue 3 — Removing Storage Does Not Remove the Thin Pool

### Symptom

A storage entry is removed from:

```text
Datacenter → Storage
```

but the thin pool still appears under:

```text
Node → Disks → LVM-Thin
```

### Cause

The Proxmox storage definition and Linux LVM configuration are separate.

Removing:

```text
Proxmox Storage Definition
```

does not automatically remove:

```text
Thin Pool
   ↓
Volume Group
   ↓
Physical Volume
```

### Resolution

If the goal was only to unregister the storage from Proxmox, no further action is necessary.

If the goal is to completely remove or recreate the LVM configuration, inspect it first:

```bash
pvs
vgs
lvs
```

Only after confirming the correct device and that no required data exists should the underlying LVM objects be removed.

## Issue 4 — Standardizing Storage Names

### Scenario

A cluster may accumulate inconsistent storage names during initial deployment:

```text
pve01 → nvme-lvm
pve02 → nvme-01
```

While technically functional, inconsistent naming makes larger environments harder to understand.

A standardized convention could instead be:

```text
pve01 → nvme-01-lvm
pve02 → nvme-02-lvm
pve03 → nvme-03-lvm
```

### Storage ID vs Underlying LVM Name

Changing only the **Proxmox storage ID** does not require wiping the physical disk.

However, VM and container configurations may reference that storage ID:

```text
scsi0: nvme-01-lvm:vm-100-disk-0
```

Changing a storage ID after workloads exist therefore requires additional planning.

If the underlying VG and thin-pool names also need to be rebuilt, doing so while the storage is empty is considerably simpler.

### Lesson

Establish a storage naming convention before deploying persistent workloads whenever possible.

## Troubleshooting Workflow

When Proxmox storage does not appear where expected, work from the physical layer upward:

```text
1. Does Linux detect the disk?
        │
        └── lsblk
             │
             ▼
2. Is it an LVM Physical Volume?
        │
        └── pvs
             │
             ▼
3. Does the Volume Group exist?
        │
        └── vgs
             │
             ▼
4. Does the thin pool exist?
        │
        └── lvs
             │
             ▼
5. Does Proxmox know about it?
        │
        └── pvesm status
             │
             ▼
6. Is the storage definition correct?
        │
        └── /etc/pve/storage.cfg
```

This helps determine whether a problem exists at the:

- Physical disk layer
- Linux LVM layer
- Proxmox storage layer
- Cluster configuration layer

## Quick Validation Commands

```bash
# Physical disks and block devices
lsblk

# Physical volumes
pvs

# Volume groups
vgs

# Logical volumes / thin pools
lvs

# Proxmox storage status
pvesm status

# Cluster-wide Proxmox storage definitions
cat /etc/pve/storage.cfg
```

## Key Takeaways

| Item | Purpose |
|---|---|
| Physical disk | Provides the underlying storage device |
| PV | Makes a disk or partition available to LVM |
| VG | Aggregates LVM storage capacity |
| Thin pool | Provides thin-provisioned virtual disk capacity |
| Proxmox Storage ID | Registers storage for use by Proxmox |
| `pvs` | Displays LVM physical volumes |
| `vgs` | Displays LVM volume groups |
| `lvs` | Displays logical volumes and thin pools |
| `pvesm status` | Displays Proxmox storage availability |
| `/etc/pve/storage.cfg` | Defines cluster-wide Proxmox storage resources |
| Node restriction | Associates local storage with the node where it physically exists |

> **Caution:** LVM administration can permanently destroy VM, container, and host data. Always identify the physical device and verify its contents before using `lvremove`, `vgremove`, `pvremove`, disk initialization, or other destructive storage operations.
