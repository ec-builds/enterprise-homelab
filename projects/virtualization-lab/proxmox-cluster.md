# 🖥️ Proxmox Cluster

Proxmox VE compute environment designed to scale from a single virtualization host into a three-node cluster.

The environment provides hands-on experience with clustered virtualization, Linux networking, node-local storage, Corosync, quorum, migration, and failure testing.

## Cluster Overview

**Current State:** Two-node Proxmox VE cluster  
**Target State:** Three-node Proxmox VE cluster

```text
Current Cluster
├── prox-lab-01
│   ├── System SSD
│   └── NVMe VM Storage
│
└── prox-lab-02
    ├── System SSD
    └── NVMe VM Storage

Planned
└── prox-lab-03
```

## Node Summary

| Node | Hardware | CPU | RAM | System Storage | VM Storage | Status |
|---|---|---|---:|---|---|---|
| `prox-lab-01` | Dell OptiPlex 3070 | Intel Core i5-9500T (6C/6T) | 32 GB | 1 TB SATA SSD | 1 TB NVMe SSD | Active |
| `prox-lab-02` | Dell OptiPlex 7040 | TBD | TBD | System SSD | 1 TB NVMe SSD | Active |
| `prox-lab-03` | Dell OptiPlex 7040 | TBD | TBD | TBD | TBD | Planned |

## Cluster Nodes

### `prox-lab-01`

**Role:** Primary virtualization node  
**Status:** Active

Initial bare-metal node used to establish the Proxmox environment and validate VM, storage, networking, and management workflows.

The node was subsequently used to initialize the Proxmox cluster.

### `prox-lab-02`

**Role:** Cluster compute node  
**Status:** Active

Second virtualization host joined to the cluster to introduce multi-node management, Corosync communication, node-local storage, and migration testing.

### `prox-lab-03`

**Role:** Cluster compute node  
**Status:** Planned

Third node intended to complete the three-node architecture and provide a more resilient quorum configuration for cluster and failure testing.

## Target Architecture

```text
                    Proxmox VE Cluster
                           │
          ┌────────────────┼────────────────┐
          │                │                │
   prox-lab-01       prox-lab-02       prox-lab-03
          │                │                │
          └────────────────┼────────────────┘
                           │
                  Cluster Services
                           │
              ┌────────────┼────────────┐
              │            │            │
           Corosync     Migration     Quorum
```

## Network & Cluster Configuration

Cluster nodes use static management addressing to provide stable endpoints for management and Corosync communication.

Each host's physical Ethernet interface is attached to a Linux bridge:

```text
Physical NIC
     │
     ▼
   vmbr0
     │
     ├── Proxmox Management
     └── VM Networking
```

Management addressing is configured on `vmbr0` rather than directly on the physical network interface.

Corosync currently uses the primary management network through **Link 0** for node-to-node cluster communication.

A dedicated cluster network or additional Corosync link may be introduced later for network segmentation and redundancy testing.

Hostname resolution is validated before clustering to ensure each node resolves consistently to its static management address.

## Storage Architecture

Each cluster node contains separate system and VM storage.

```text
prox-lab-01
├── System SSD
│   └── pve
│       ├── root
│       ├── swap
│       └── data
│           └── local-lvm
│
└── NVMe SSD
    └── nvme-01-lvm


prox-lab-02
├── System SSD
│   └── pve
│       ├── root
│       ├── swap
│       └── data
│           └── local-lvm
│
└── NVMe SSD
    └── nvme-02-lvm
```

The system SSD on each node contains the Proxmox operating system and default LVM-thin storage.

Additional NVMe devices provide dedicated LVM-thin storage for VM and container disks.

Storage IDs are node-specific because the underlying NVMe devices are local to each host rather than shared storage.

## Cluster Storage Model

Proxmox storage configuration and the underlying Linux storage stack are separate layers.

```text
Physical NVMe
     │
     ▼
LVM Physical Volume
     │
     ▼
Volume Group
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

This distinction became important during cluster deployment because Proxmox storage definitions are managed at the cluster level while the underlying LVM devices remain local to their respective nodes.

## Implementation Notes

### Static Management Addressing

The initial deployment used DHCP for the Proxmox management interface.

Before clustering, the management bridges were migrated to static addressing to provide stable endpoints for cluster communication.

Hostname resolution was also validated to ensure that each node resolved to its correct management address before initializing Corosync.

Validation included:

```bash
ip addr
hostname -I
getent hosts <node>
```

### Cluster Storage Configuration

After the second node joined the cluster, its secondary NVMe remained visible to Linux and LVM but did not initially appear as usable storage in the Proxmox resource tree.

Storage inspection included:

```bash
pvesm status
pvs
vgs
lvs
```

The investigation confirmed that the physical disk, LVM physical volume, volume group, and thin pool remained intact.

The issue highlighted the distinction between **node-local LVM configuration** and **cluster-wide Proxmox storage definitions**.

NVMe storage naming was subsequently standardized using node-specific storage IDs:

```text
prox-lab-01 → nvme-01-lvm
prox-lab-02 → nvme-02-lvm
prox-lab-03 → nvme-03-lvm (planned)
```

This provides consistent storage identification as the cluster expands.

## Implementation Stages

- [x] Deploy initial Proxmox host
- [x] Configure static management networking
- [x] Deploy second Proxmox host
- [x] Configure Corosync cluster
- [x] Join second node to cluster
- [x] Configure node-local NVMe LVM-thin storage
- [x] Standardize cluster storage naming
- [ ] Deploy third Proxmox host
- [ ] Validate three-node quorum
- [ ] Test VM migration
- [ ] Test node failure and recovery
- [ ] Evaluate dedicated cluster network
- [ ] Evaluate shared storage
