# 🖥️ Proxmox Host Build

Bare-metal deployment of a **Proxmox VE** virtualization host for the infrastructure homelab.

## Overview

This build establishes the first physical Proxmox host and provides the foundation for virtual machines, containers, networking, storage, and future clustering.

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
| CPU | Intel Core i5-9500T |
| CPU | 6 cores / 6 threads |
| Virtualization | Intel VT-x |
| Memory | 32 GB DDR4 |
| Host Storage | Samsung 870 EVO 1 TB SATA SSD |
| VM Storage | Samsung 990 EVO Plus 1 TB NVMe SSD |
| Network | Gigabit Ethernet |

Unique hardware identifiers such as serial numbers, service tags, MAC addresses, UUIDs, and disk serial numbers are intentionally excluded.

## Platform

| Component | Configuration |
|---|---|
| Hypervisor | Proxmox VE 9 |
| Base OS | Debian GNU/Linux 13 |
| Architecture | x86-64 |
| Boot | UEFI |

The system firmware was updated before deploying the host.

Hardware virtualization was enabled and verified:

```bash
lscpu
```

Expected:

```text
Virtualization: VT-x
```

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

The SATA SSD provides the operating system, Proxmox installation, and additional local VM storage.

## Post-Installation Configuration

The host was configured to use the **Proxmox no-subscription repository** for lab use.

System packages were then updated:

```bash
apt update
apt full-upgrade
```

The host was rebooted after the updates.

During initial validation, several Proxmox packages reported incomplete installation states. Updating the system resolved the package issues and brought the host to a healthy state.

Verification:

```bash
pveversion -v
```

## Networking

The physical Ethernet interface is connected to the Proxmox Linux bridge:

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
       ├── Virtual Machines
       └── LXC Containers
```

The physical interface operates as a bridge port while the management configuration resides on `vmbr0`.

### Bridge Configuration

```text
auto lo
iface lo inet loopback

iface nic0 inet manual

auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0

source /etc/network/interfaces.d/*
```

The host currently obtains its management address through DHCP.

A DHCP reservation can provide predictable addressing while allowing the Proxmox interface to remain configured for DHCP.

## Networking Issue Encountered

The Proxmox installer originally configured a static management address.

After changing `vmbr0` to DHCP, the host temporarily had both the original static address and a DHCP-assigned address:

```text
vmbr0
├── 10.0.0.10/24     static
└── 10.0.0.100/24    dynamic
```

The persistent network configuration was corrected by changing:

```text
iface vmbr0 inet static
```

to:

```text
iface vmbr0 inet dhcp
```

This resolved the duplicate addressing and established DHCP as the management-addressing method.

Detailed networking configuration and troubleshooting are documented separately in:

```text
proxmox-networking.md
```

## Storage Design

The host contains two 1 TB SSDs with different roles.

```text
prox01
│
├── SATA SSD
│   ├── Proxmox VE
│   ├── Debian
│   ├── ISOs / Templates
│   └── Secondary VM Storage
│
└── NVMe SSD
    └── Primary VM / LXC Storage
```

### SATA SSD

The SATA SSD serves as the Proxmox system disk while retaining its `local-lvm` capacity for additional VM and container storage.

### NVMe SSD

The NVMe SSD is designated as the primary storage location for VM and LXC disks where higher storage performance is beneficial.

This keeps the host installation and primary guest workloads logically separated while retaining the capacity of both drives.

## Disk Validation

SMART health was checked on both SSDs.

```bash
smartctl -a /dev/sda
smartctl -a /dev/nvme0n1
```

Both drives passed SMART health checks with no reported media or data-integrity errors.

## Host Validation

After installation and configuration, the host was validated before deploying workloads.

| Check | Result |
|---|---|
| Proxmox VE installed | ✅ |
| System packages updated | ✅ |
| Package installation state healthy | ✅ |
| Firmware updated | ✅ |
| Intel VT-x detected | ✅ |
| 32 GB RAM detected | ✅ |
| SATA SSD SMART health | ✅ |
| NVMe SSD SMART health | ✅ |
| Proxmox storage active | ✅ |
| Linux bridge operational | ✅ |
| Default route present | ✅ |
| Failed systemd services | None |

Key validation commands:

```bash
pveversion -v
lscpu
free -h
pvesm status
ip -br addr
ip route
systemctl --failed
```

General Linux hardware and system-information commands are maintained separately in:

```text
linux-system-information.md
```

## Final State

```text
Dell OptiPlex 3070
        ↓
Proxmox VE 9
        ↓
Debian 13
        ↓
┌─────────────────────────┐
│                         │
Linux Bridge          Local Storage
   vmbr0              SATA + NVMe
│                         │
└──────────┬──────────────┘
           ↓
        KVM / LXC
           ↓
    Ready for Workloads
```

## Next Steps

- Configure dedicated NVMe VM storage
- Deploy initial virtual machines
- Build reusable VM templates
- Implement cloud-init
- Configure backup and recovery
- Introduce VLAN-aware virtual networking
- Add additional Proxmox nodes
- Test migration and clustering
