# Proxmox Storage

## Overview

The Proxmox cluster separates VM storage from general storage where possible.

`prox-lab-01` and `prox-lab-02` use dedicated NVMe drives for VM and container
disks, while the primary SSD is used for Proxmox and general ext4 storage.

`prox-lab-03` uses a modified layout because it contains two smaller 500 GB
drives. Its primary NVMe hosts Proxmox and an LVM-thin pool for VM and
container disks, while the secondary HDD provides general ext4 storage.



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

- VM workloads stay on dedicated NVMe storage where possible.
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
├── 500 GB NVMe
│   ├── ~100 GB root      → Proxmox VE
│   └── ~337 GB LVM-Thin  → VM and container disks
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
Primary NVMe — 500 GB
│
├── Proxmox VE
│   └── ~100 GB root
│
├── LVM-Thin
│   └── ~337 GB
│       ├── VM disks
│       └── Container disks
│
└── ~16 GB LVM Reserve
    └── Future expansion


Secondary HDD — 500 GB
│
└── ext4
    ├── Backups
    ├── ISO images
    ├── Container templates
    └── Snippets
```

The primary NVMe hosts both the Proxmox operating system and the LVM-thin
pool used for VM and container disks.

The secondary HDD is used for general-purpose storage rather than VM disks
because of its lower storage performance.



## Result

The storage architecture provides:

- NVMe storage for VM and container workloads across all cluster nodes
- Separation between operating system and bulk storage
- Effective use of available local storage capacity
- Local backup, ISO, template, and snippet storage
- Reserved LVM capacity for future expansion
- A consistent storage strategy across the cluster
- A documented storage exception for `prox-lab-03`
