# 🖥️ Proxmox Baseline Build

Baseline configuration for deploying a **Proxmox VE** virtualization host in the infrastructure homelab.

## Build Workflow

```text
Hardware Preparation
        ↓
Firmware Configuration
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

## Hardware Baseline

| Component | Configuration |
|---|---|
| Platform | Business-class x86-64 system |
| CPU | Hardware virtualization capable |
| Memory | 32 GB |
| Host Storage | SATA SSD |
| VM Storage | NVMe SSD |
| Network | Gigabit Ethernet |
| Boot | UEFI |

Unique identifiers such as serial numbers, MAC addresses, UUIDs, and disk serial numbers are intentionally excluded.

## Platform

| Component | Configuration |
|---|---|
| Hypervisor | Proxmox VE 9 |
| Base OS | Debian GNU/Linux 13 |
| Architecture | x86-64 |
| Repository | Proxmox no-subscription |
| Boot Mode | UEFI |

System firmware should be updated and hardware virtualization enabled before deployment.

## Installation

Install Proxmox VE directly on the designated system SSD.

Default storage layout:

```text
System SSD
│
├── EFI
└── Proxmox LVM
    ├── pve-root
    ├── pve-swap
    └── pve-data
        └── local-lvm
```

After installation, configure the no-subscription repository and update the system:

```bash
apt update
apt full-upgrade
```

Verify the installed environment:

```bash
pveversion -v
```

## Networking

Attach the physical Ethernet interface to the Proxmox Linux bridge `vmbr0`.

```text
Physical Network
       │
       ▼
      NIC
       │
       ▼
     vmbr0
       │
       ├── Proxmox Management
       └── Virtual Machines
```

Baseline requirements:

- `vmbr0` operational
- Management connectivity established
- Predictable management addressing
- Default gateway reachable
- DNS resolution functional

See [`proxmox-network-configuration.md`](./proxmox-network-configuration.md) for detailed networking configuration and troubleshooting.

## Storage

Separate system and primary VM storage where available.

```text
Proxmox Host
│
├── System SSD
│   ├── Proxmox VE
│   ├── ISOs / Templates
│   └── Secondary VM Storage
│
└── VM SSD
    └── Primary VM Storage
```

The system SSD hosts Proxmox and supporting storage, while the faster VM SSD is used for primary guest workloads.

## Host Validation

Validate the host before deploying workloads.

| Check | Requirement |
|---|---|
| Proxmox VE | Installed and operational |
| System packages | Updated |
| Package state | Healthy |
| System firmware | Current |
| Hardware virtualization | Enabled |
| Installed memory | Detected correctly |
| Storage health | Healthy |
| Proxmox storage | Active |
| Linux bridge | Operational |
| Default route | Present |
| DNS resolution | Functional |
| Failed systemd services | None |

## Baseline Complete

```text
Proxmox Host
│
├── Proxmox VE
├── Management Network
├── System Storage
└── VM Storage
        │
        ▼
Ready for Workloads
```

Once the host passes validation, workload deployment can begin.

> **Build → Update → Configure → Validate → Deploy**
