# Proxmox Storage

## Overview

The Proxmox cluster separates VM storage from general storage where possible.

`prox-lab-01` and `prox-lab-02` use dedicated NVMe drives for VM and container
disks, while the primary SSD is used for Proxmox and general ext4 storage.

`prox-lab-03` uses a different layout because it has two smaller 500 GB drives.



## Storage Design

`prox-lab-01` and `prox-lab-02` use the standard storage design.

```text
Primary SSD — 1 TB
│
├── Proxmox VE
│   └── ~100 GB root
│
├── General Storage
│   └── ~800 GB ext4
│       ├── Backups
│       ├── ISO images
│       ├── Container templates
│       └── Snippets
│
└── ~26 GB LVM Reserve
    └── Future expansion


Secondary NVMe — 1 TB
│
└── LVM-Thin
    ├── VM disks
    └── Container disks
```

### Design Notes

- VM workloads stay on dedicated NVMe storage.
- General storage is separated from the root filesystem.
- A small amount of LVM space remains available for future expansion.
- Storage is local to each node and isn't shared across the cluster.

> [!NOTE]
> Network-backed storage is used when data needs to be accessible across
> multiple cluster nodes.



## Node Storage Summary

```text
prox-lab-01
├── 1 TB SSD
│   ├── ~100 GB root      → Proxmox VE
│   └── ~800 GB ext4      → Backups, ISOs, templates, snippets
└── 1 TB NVMe
    └── LVM-Thin          → VM and container disks

prox-lab-02
├── 1 TB SSD
│   ├── ~100 GB root      → Proxmox VE
│   └── ~800 GB ext4      → Backups, ISOs, templates, snippets
└── 1 TB NVMe
    └── LVM-Thin          → VM and container disks

prox-lab-03
├── 500 GB SSD/NVMe
│   └── Proxmox default   → Proxmox VE and VM storage
└── 500 GB HDD
    └── ext4              → Backups, ISOs, templates, snippets
```

> [!NOTE]
> Capacities are approximate. Actual usable capacity varies due to filesystem
> overhead, LVM metadata, disk sizing, and reserved filesystem space.



## `prox-lab-03` Architecture

`prox-lab-03` uses a different storage model because it contains two
500 GB drives.

```text
Primary SSD/NVMe — 500 GB
│
├── Proxmox VE
└── VM / CT storage


Secondary HDD — 500 GB
│
└── ext4
    ├── Backups
    ├── ISO images
    ├── Container templates
    └── Snippets
```

The primary drive retains the normal Proxmox host and VM storage allocation.

The secondary HDD is used for general-purpose storage rather than VM disks
because of its lower storage performance.



## Result

The storage architecture provides:

- Dedicated NVMe storage for VM workloads on the standard nodes
- Separation between operating system and bulk storage
- Effective use of available capacity on the primary SSDs
- Local backup, ISO, template, and snippet storage
- Reserved LVM capacity for future expansion
- A consistent storage model across the cluster
- A documented exception for `prox-lab-03`
