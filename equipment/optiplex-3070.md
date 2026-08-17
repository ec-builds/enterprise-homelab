# Dell OptiPlex 3070

Dell OptiPlex 3070 repurposed as a dedicated Proxmox VE virtualization host for the Enterprise Homelab.

## System Overview

| Component | Specification |
|---|---|
| **Hostname** | `prox-lab-01` |
| **Role** | Proxmox VE Virtualization Host |
| **CPU** | Intel Core i5-9500T @ 2.20 GHz |
| **CPU Topology** | 6 cores / 6 threads |
| **Max Frequency** | 3.70 GHz |
| **Memory** | 32 GB |
| **System Storage** | 1 TB SATA SSD |
| **VM Storage** | 1 TB NVMe SSD |
| **Network** | 1 GbE |
| **Integrated Graphics** | Intel UHD Graphics 630 |
| **Architecture** | x86-64 |
| **Virtualization** | Intel VT-x / EPT |
| **Boot Mode** | UEFI |

## Storage Allocation

| Storage | Purpose |
|---|---|
| **1 TB SATA SSD** | Proxmox VE operating system & secondary virtual machine storage |
| **1 TB NVMe SSD** | Primary virtual machine storage |

## Role

The system serves as a dedicated virtualization node for:

- Proxmox VE
- Virtual machines
- Linux containers
- Infrastructure testing

Application workloads are hosted within VMs or containers rather than directly on the Proxmox host.

## Related Projects

- [Virtualization Lab](../projects/virtualization-lab/)
