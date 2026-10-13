# Proxmox Storage

## Overview

The Proxmox cluster uses a consistent two-drive storage strategy across all three nodes.

The primary NVMe drive is used for Proxmox VE and VM storage, while the secondary SATA drive provides general-purpose storage for backups, ISO images, templates, snippets, and other non-VM data.

This design keeps VM workloads on the faster NVMe storage while using the secondary drive for capacity-oriented workloads.

> [!NOTE]
> The environment currently uses virtual machines rather than LXC containers. Container storage may be added later if needed.



## Storage Design

The general storage model is:

```text
Primary NVMe
│
├── Proxmox VE
│   └── Root filesystem
│
└── LVM-Thin
    └── VM disks


Secondary SATA Drive
│
└── General Storage
    ├── Backups
    ├── ISO images
    ├── Templates
    ├── Snippets
    └── Other non-VM data
```

### Design Notes

- VM disks are stored on NVMe storage for better performance.
- Secondary SATA drives are used for backups and general-purpose storage.
- Proxmox VE and VM storage share the primary NVMe drive.
- VM workloads are kept off the slower secondary drives.
- Storage is local to each node and is not shared cluster storage.
- Secondary drive capacity and media type vary by node.



## Node Storage Summary

| Node | Primary Storage | Primary Role | Secondary Storage | Secondary Role |
|---|---|---|---|---|
| `prox-lab-01` | 1 TB NVMe | Proxmox VE + VM disks | 1 TB SSD | Backups and general storage |
| `prox-lab-02` | 1 TB NVMe | Proxmox VE + VM disks | 640 GB HDD | Backups and general storage |
| `prox-lab-03` | 500 GB NVMe | Proxmox VE + VM disks | 1 TB HDD | Backups and general storage |

```text
prox-lab-01
├── 1 TB NVMe
│   ├── Proxmox VE
│   └── LVM-Thin          → VM disks
│
└── 1 TB SSD
    └── General Storage   → Backups, ISOs, templates, snippets


prox-lab-02
├── 1 TB NVMe
│   ├── Proxmox VE
│   └── LVM-Thin          → VM disks
│
└── 640 GB HDD
    └── General Storage   → Backups, ISOs, templates, snippets


prox-lab-03
├── 500 GB NVMe
│   ├── Proxmox VE
│   └── LVM-Thin          → VM disks
│
└── 1 TB HDD
    └── General Storage   → Backups, ISOs, templates, snippets
```

> [!NOTE]
> Advertised drive capacities are shown for simplicity. Actual usable capacity is lower due to disk formatting, filesystem overhead, LVM metadata, and storage allocation.



## Storage Roles

### Primary NVMe Storage

Each node uses its NVMe drive as its primary performance storage.

The NVMe drive hosts:

- Proxmox VE
- LVM-thin VM storage
- Virtual machine disks

Keeping VM disks on NVMe storage provides significantly better random I/O performance and latency than the secondary HDD storage available on some nodes.

### Secondary Storage

Each node also contains a secondary SATA drive dedicated to general-purpose storage.

These drives are used for:

- VM backups
- ISO images
- Templates
- Snippets
- Other non-VM data

The secondary drives do not host normal VM workloads. This keeps capacity-oriented storage separate from performance-sensitive VM disks.



## Result

The storage architecture provides:

- NVMe-backed storage for VM workloads on every node
- Dedicated secondary storage for backups and general data
- Consistent storage roles despite different drive capacities and media types
- Separation of performance-sensitive VM disks from bulk storage
- Efficient use of the hardware available in each node
- A straightforward storage model that can be expanded as the lab grows
