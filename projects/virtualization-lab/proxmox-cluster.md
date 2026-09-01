# Proxmox Cluster

Proxmox VE compute environment designed to scale from a single virtualization host into a three-node cluster.

The environment provides hands-on experience with multi-node virtualization, cluster management, Corosync, quorum, VM migration, and failure testing.

## Cluster Overview

**Current State:** Two-node Proxmox VE cluster  
**Target State:** Three-node Proxmox VE cluster

```text
Current Cluster
├── prox-lab-01
└── prox-lab-02

Planned
└── prox-lab-03
```

## Node Summary

| Node | Hardware | CPU | RAM | System Storage | VM Storage | Status |
|---|---|---|---:|---|---|---|
| `prox-lab-01` | Dell OptiPlex 3070 | Intel Core i5-9500T (6C/6T) | 32 GB | ~1 TB SATA SSD | ~1 TB NVMe SSD | Active |
| `prox-lab-02` | Dell OptiPlex 7040 | Intel Core i7-6700T (4C/8T) | 16 GB | ~1 TB SATA SSD | ~1 TB NVMe SSD | Active |
| `prox-lab-03` | Dell OptiPlex 7040 | Pending | Pending | Pending | Pending | Planned |

Detailed host capacity and workload allocation are documented in `resource-allocation.md`.

## Cluster Nodes

### `prox-lab-01`

**Role:** Initial cluster node  
**Status:** Active

Initial bare-metal node used to establish the Proxmox environment and validate VM, storage, networking, and management workflows.

The node was subsequently used to initialize the Proxmox cluster and currently hosts the majority of persistent lab workloads.

### `prox-lab-02`

**Role:** Cluster compute node  
**Status:** Active

Second virtualization host joined to the cluster to introduce multi-node management, Corosync communication, node-local storage, and VM migration testing.

### `prox-lab-03`

**Role:** Cluster compute node  
**Status:** Planned

Third node intended to complete the three-node architecture and provide an odd number of voting members for quorum and failure testing.

Final hardware specifications will be documented after deployment and validation.

## Cluster Architecture

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

The current two-node configuration provides multi-node management and migration testing. The third node will complete the planned cluster and provide a more appropriate quorum configuration for failure testing.

## Cluster Networking

Cluster nodes use static management addressing to provide stable endpoints for Proxmox management and Corosync communication.

Each host uses a Linux bridge for management and VM networking:

```text
Physical NIC
     │
     ▼
   vmbr0
     │
     ├── Proxmox Management
     └── VM Networking
```

Management addressing is assigned to the bridge rather than directly to the physical interface.

Corosync currently uses the primary management network through **Link 0** for node-to-node cluster communication.

A dedicated cluster network or additional Corosync link may be evaluated later for network segmentation and redundancy testing.

## Storage Model

Each active node uses separate local storage for the Proxmox installation and VM workloads.

| Node | System Storage | VM Storage |
|---|---|---|
| `prox-lab-01` | SATA SSD | `nvme-01-lvm` |
| `prox-lab-02` | SATA SSD | `nvme-02-lvm` |
| `prox-lab-03` | Pending | `nvme-03-lvm` (planned) |

The system SSD on each active node contains the Proxmox operating system and default local storage. Dedicated NVMe storage provides LVM-thin storage for VM and container disks.

NVMe storage is node-local rather than shared between cluster members.

Proxmox storage definitions are managed at the cluster level while the underlying LVM devices remain local to their respective nodes. Node-specific storage IDs provide clear identification of storage associated with each host.

Shared storage may be evaluated later as the cluster expands.

## Quorum

The current two-node cluster supports multi-node management and migration testing but has quorum limitations if communication between the nodes is lost.

```text
Current

prox-lab-01 ───── prox-lab-02
     vote              vote

       2 voting nodes
```

The planned third node creates an odd-numbered voting configuration:

```text
Target

prox-lab-01 ─┐
             │
prox-lab-02 ─┼── 3 voting nodes
             │
prox-lab-03 ─┘

Majority = 2 votes
```

This provides a more appropriate environment for testing quorum behavior, node failure, and recovery.

## VM Migration

The cluster provides the foundation for moving workloads between virtualization hosts.

Because VM storage is currently node-local rather than shared, migration may require transferring VM disk data between nodes in addition to the VM configuration.

Migration testing will validate:

- VM movement between nodes
- Node-local storage compatibility
- Network consistency between hosts
- Workload availability during migration
- Recovery procedures following node maintenance or failure

## Implementation Stages

- [x] Deploy initial Proxmox host
- [x] Configure static management networking
- [x] Deploy second Proxmox host
- [x] Initialize Proxmox cluster
- [x] Join second node to cluster
- [x] Validate Corosync communication
- [x] Configure node-local NVMe LVM-thin storage
- [x] Standardize node-specific storage naming
- [ ] Deploy third Proxmox host
- [ ] Join third node to cluster
- [ ] Validate three-node quorum
- [ ] Test VM migration
- [ ] Test node failure and recovery
- [ ] Evaluate dedicated cluster networking
- [ ] Evaluate shared storage
