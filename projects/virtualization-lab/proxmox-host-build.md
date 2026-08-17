# 🖥️ Proxmox Host Build

Bare-metal deployment of a **Proxmox VE** virtualization host for the infrastructure homelab.

## Overview

This build establishes the first physical Proxmox host and provides the foundation for virtual machines, networking, storage, and future clustering.

### Build Workflow

```text
Hardware Preparation
        ↓
Firmware Update
        ↓
Proxmox VE Installation
        ↓
Repository Configuration
        ↓
System Updates
        ↓
Network Configuration
        ↓
Storage Configuration
        ↓
Host Validation
        ↓
Ready for Workloads
```

## Hardware

| Component | Configuration |
|---|---|
| Platform | Dell OptiPlex 3070 |
| CPU | Intel Core i5-9500T, 6 cores / 6 threads |
| Virtualization | Intel VT-x |
| Memory | 32 GB DDR4 |
| Host Storage | Samsung 870 EVO 1 TB SATA SSD |
| VM Storage | Samsung 990 EVO Plus 1 TB NVMe SSD |
| Network | Gigabit Ethernet |

Unique hardware identifiers such as serial numbers, MAC addresses, UUIDs, and disk serial numbers are intentionally excluded.

## Platform

| Component | Configuration |
|---|---|
| Hypervisor | Proxmox VE 9 |
| Base OS | Debian GNU/Linux 13 |
| Architecture | x86-64 |
| Boot | UEFI |

System firmware was updated before deployment, and Intel VT-x hardware virtualization was enabled and verified.

## Proxmox Installation

Proxmox VE was installed directly on the physical host using the SATA SSD as the system disk.

The installer created the standard Proxmox LVM layout:

```text
Samsung 870 EVO 1 TB
│
├── EFI
└── Proxmox LVM
    ├── pve-root
    ├── pve-swap
    └── pve-data
        └── local-lvm
```

The SATA SSD provides the Proxmox system installation and retains `local-lvm` capacity for secondary VM storage.

## Post-Installation Configuration

The host was configured to use the **Proxmox no-subscription repository** for lab use.

System packages were updated:

```bash
apt update
apt full-upgrade
```

During initial validation, several Proxmox packages reported incomplete installation states. Updating the system and rebooting resolved the package issues.

The final package state was verified with:

```bash
pveversion -v
```

## Networking

The physical Ethernet interface is attached to the Proxmox Linux bridge `vmbr0`, which provides connectivity for host management and virtual machines.

```text
Physical Network
       │
       ▼
     nic0
       │
       ▼
     vmbr0
       │
       ├── Proxmox Management
       └── Virtual Machines
```

Management addressing was changed from the installation-time static configuration to DHCP with a reservation for predictable addressing.

During configuration, the original static address remained active alongside the DHCP-assigned address. The persistent network configuration and hostname mapping were corrected to remove the old address.

See [`proxmox-network-configuration.md`](./proxmox-network-configuration.md) for networking implementation and troubleshooting details.

## Storage Design

The host contains two 1 TB SSDs with separate roles.

```text
Proxmox Host
│
├── SATA SSD
│   ├── Proxmox VE
│   ├── ISOs / Templates
│   └── Secondary VM Storage
│
└── NVMe SSD
    └── Primary VM Storage
```

### SATA SSD

The SATA SSD serves as the Proxmox system disk while retaining `local-lvm` capacity for additional virtual machine storage.

### NVMe SSD

The NVMe SSD is designated as the primary storage location for virtual machine disks.

This separates the host installation from primary guest workloads while retaining the usable capacity of both drives.

## Host Validation

The host was validated before deploying workloads.

| Check | Result |
|---|---|
| Proxmox VE installed | ✅ |
| System packages updated | ✅ |
| Package state healthy | ✅ |
| Firmware updated | ✅ |
| Intel VT-x detected | ✅ |
| 32 GB RAM detected | ✅ |
| SATA SSD SMART health | ✅ |
| NVMe SSD SMART health | ✅ |
| Proxmox storage active | ✅ |
| Linux bridge operational | ✅ |
| Default route present | ✅ |
| Failed systemd services | None |

SMART health checks were performed on both SSDs. Both drives passed with no reported media or data-integrity errors.

General Linux system-information and validation commands are maintained separately in the Linux reference documentation.

## Final State

```text
Dell OptiPlex 3070
        │
        ▼
   Proxmox VE 9
        │
        ├── vmbr0
        │     └── Management / VM Networking
        │
        ├── SATA SSD
        │     └── Host / Secondary VM Storage
        │
        └── NVMe SSD
              └── Primary VM Storage
```

The initial Proxmox host is operational, updated, and validated. Virtual machine deployment and additional virtualization capabilities will be implemented in subsequent stages of the lab.

## Next Steps

- Configure dedicated NVMe VM storage
- Deploy initial virtual machines
- Build reusable Linux and Windows VM templates
- Implement cloud-init
- Configure backup and recovery
- Introduce VLAN-aware virtual networking
- Add additional Proxmox hosts
- Test migration and clustering
