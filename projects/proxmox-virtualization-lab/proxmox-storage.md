# Proxmox Storage

## Overview

The Proxmox cluster uses a local storage architecture designed to separate
virtual machine workloads from general-purpose host storage where hardware
permits.

The standard nodes use dedicated NVMe storage for VM and container disks,
while the primary SSD provides the Proxmox VE operating system and
general-purpose ext4 storage.

`prox-lab-03` uses a modified layout due to its smaller storage configuration.



## Storage Layout

| Node | Drive | Storage | Purpose |
|---|---|---|---|
| `prox-lab-01` | 1 TB SSD | ~100 GB root | Proxmox VE host |
|  |  | ~800 GB ext4 | Backups, ISOs, templates, snippets |
|  | 1 TB NVMe | LVM-Thin | VM and container disks |
| `prox-lab-02` | 1 TB SSD | ~100 GB root | Proxmox VE host |
|  |  | ~800 GB ext4 | Backups, ISOs, templates, snippets |
|  | 1 TB NVMe | LVM-Thin | VM and container disks |
| `prox-lab-03` | 500 GB SSD/NVMe | Default Proxmox allocation | Proxmox VE host and VM storage |
|  | 500 GB HDD | ext4 | Backups, ISOs, templates, snippets |

> [!NOTE]
> Capacities are approximate. Actual usable capacity varies due to filesystem
> overhead, LVM metadata, disk sizing, and reserved filesystem space.



## Standard Node Architecture

`prox-lab-01` and `prox-lab-02` use the standard storage architecture.

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
└── LVM Reserve
    └── Future expansion


Secondary NVMe — 1 TB
│
└── LVM-Thin
    ├── VM disks
    └── Container disks
```

The primary SSD therefore serves two roles:

- Proxmox VE system storage
- General-purpose local storage

VM and container disks are isolated on the secondary NVMe.



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



## Storage Roles

| Storage Type | VM / CT Disks | Backups | ISOs | Templates | Snippets |
|---|---:|---:|---:|---:|---:|
| Root-backed `local` | No | Limited | Limited | Limited | Limited |
| General ext4 storage | No | Yes | Yes | Yes | Yes |
| NVMe LVM-Thin | Yes | No | No | No | No |
| `prox-lab-03` HDD | No | Yes | Yes | Yes | Yes |



## Design Decisions

### Dedicated VM Storage

VM and container disks are placed on dedicated NVMe storage on the standard
nodes.

This keeps virtualization workloads separate from the Proxmox operating
system and provides high-performance storage for guest workloads.



### Separate General Storage

Most unused capacity on the standard nodes' primary SSDs is allocated to a
separate ext4 filesystem.

This storage is used for:

- Backups
- ISO images
- Container templates
- Snippets
- Other general Proxmox storage

Using a separate filesystem prevents bulk storage from consuming the root
filesystem.



### LVM Reserve

A small amount of capacity remains unallocated in the system LVM volume group.

This provides room for future expansion of the root filesystem or another
logical volume without requiring the general storage filesystem to be
reduced first.



### Local Storage Scope

The ext4 filesystems are local to their respective Proxmox nodes.

```text
prox-lab-01-storage → prox-lab-01
prox-lab-02-storage → prox-lab-02
prox-lab-03-storage → prox-lab-03
```

They are not configured as shared cluster storage.

Network-backed storage is used when data must be accessible across multiple
cluster nodes.



## Result

The storage architecture provides:

- Dedicated NVMe storage for VM workloads on the standard nodes
- Separation between operating system and bulk storage
- Effective use of available capacity on the primary SSDs
- Local backup, ISO, template, and snippet storage
- Reserved LVM capacity for future expansion
- A consistent storage model across the cluster
- A documented exception for `prox-lab-03`
