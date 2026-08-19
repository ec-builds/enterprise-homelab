# Proxmox Hosts

Physical compute nodes deployed as part of the Proxmox VE virtualization environment.

## Host Summary

| Host | Hardware | CPU | RAM | System Storage | VM Storage | Status |
|---|---|---|---:|---|---|---|
| `prox-lab-01` | Dell OptiPlex 3070 | Intel Core i5-9500T (6C/6T) | 32 GB | 1 TB SATA SSD | 1 TB NVMe SSD | Active |
| `prox-lab-02` | Dell OptiPlex 7040 | TBD | TBD | TBD | TBD | Planned |
| `prox-lab-03` | Dell OptiPlex 7040 | TBD | TBD | TBD | TBD | Planned |



## `prox-lab-01`

**Role:** Primary Proxmox VE host  
**Status:** Active

Initial bare-metal node used to establish the Proxmox environment and validate VM, storage, networking, and management workflows.



## `prox-lab-02`

**Role:** Proxmox VE host  
**Status:** Planned

Second compute node for multi-host virtualization, migration, and cluster testing.



## `prox-lab-03`

**Role:** Proxmox VE host  
**Status:** Planned

Third compute node intended to complete the three-node environment and support cluster and quorum testing.
