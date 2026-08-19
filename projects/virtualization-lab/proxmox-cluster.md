# 🖥️ Proxmox Cluster

Proxmox VE compute environment designed to scale from a single virtualization host into a three-node cluster.

## Cluster Overview

**Current State:** Single-node deployment  
**Target State:** Three-node Proxmox VE cluster

```text
Current
└── prox-lab-01
    └── Active

Planned Cluster
├── prox-lab-01
├── prox-lab-02
└── prox-lab-03
```

## Node Summary

| Node | Hardware | CPU | RAM | System Storage | VM Storage | Status |
|---|---|---|---:|---|---|---|
| `prox-lab-01` | Dell OptiPlex 3070 | Intel Core i5-9500T (6C/6T) | 32 GB | 1 TB SATA SSD | 1 TB NVMe SSD | Active |
| `prox-lab-02` | Dell OptiPlex 7040 | TBD | TBD | TBD | TBD | Planned |
| `prox-lab-03` | Dell OptiPlex 7040 | TBD | TBD | TBD | TBD | Planned |

## Cluster Nodes

### `prox-lab-01`

**Role:** Primary virtualization node  
**Status:** Active

Initial bare-metal node used to establish the Proxmox environment and validate VM, storage, networking, and management workflows.

### `prox-lab-02`

**Role:** Cluster compute node  
**Status:** Planned

Second node intended to introduce multi-host virtualization and migration testing.

### `prox-lab-03`

**Role:** Cluster compute node  
**Status:** Planned

Third node intended to complete the three-node environment and support cluster and quorum testing.

## Target Architecture

```text
Proxmox VE Cluster
│
├── prox-lab-01
│
├── prox-lab-02
│
└── prox-lab-03
│
├── Cluster Management
├── VM Migration
├── Shared Configuration
└── Quorum
```

## Implementation Stages

- [x] Deploy initial Proxmox host
- [ ] Deploy second Proxmox host
- [ ] Deploy third Proxmox host
- [ ] Configure cluster
- [ ] Validate quorum
- [ ] Test VM migration
- [ ] Test node failure and recovery
