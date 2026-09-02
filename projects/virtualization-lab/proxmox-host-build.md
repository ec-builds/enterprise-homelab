# Proxmox Baseline Build

Baseline configuration applied when deploying a **Proxmox VE** virtualization host in the infrastructure homelab.

## Build Workflow

    Hardware Preparation
            ↓
    Firmware Configuration
            ↓
    Proxmox VE Installation
            ↓
    Network Configuration
            ↓
    System Updates
            ↓
    Administrative Access
            ↓
    Storage Configuration
            ↓
    Host Validation
            ↓
    Ready for Workloads

## Hardware Preparation

Before Proxmox VE was installed, the system was reset to a known hardware and firmware baseline.

- Updated system firmware to the latest stable release
- Loaded BIOS/UEFI defaults
- Cleared the TPM when repurposing previously deployed hardware
- Verified installed memory and storage were detected correctly

Firmware updates were performed using the manufacturer-supported update method before the system was converted into a Proxmox host.

## Firmware Configuration

System firmware was configured for virtualization and unattended server operation.

| Setting | Configuration |
|---|---|
| Boot Mode | UEFI |
| Hardware Virtualization | Enabled |
| Restore After AC Power Loss | Power On |
| Sleep / Hibernation | Disabled |
| TPM | Cleared before deployment |
| Storage Controller | AHCI where applicable |
| Boot Priority | Proxmox system disk |

Additional platform-specific settings varied by host.

After firmware configuration, the system was verified to detect the expected CPU, memory, storage, and network hardware before Proxmox VE was installed.

## Installation

Proxmox VE was installed using the graphical installer.

Baseline configuration:

| Component | Configuration |
|---|---|
| Hypervisor | Proxmox VE 9 |
| Boot Mode | UEFI |
| System Storage | SATA SSD |
| VM Storage | NVMe SSD |
| Memory | 32 GB (varied by host) |
| Network | Gigabit Ethernet |

Unique hardware identifiers such as serial numbers, MAC addresses, UUIDs, and disk serial numbers were excluded from public documentation.

## Network Configuration

The Proxmox management interface was configured with a **static IP address**.

The physical network interface was attached to the default Linux bridge:

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

Baseline Configuration:

- `vmbr0` operational
- Static management IP configured
- Default gateway reachable
- DNS resolution functional
- Hostname resolution configured as required for clustering

Static management addressing was used to provide predictable host connectivity and support Proxmox cluster membership.

See [`proxmox-network-configuration.md`](./proxmox-network-configuration.md) for detailed network configuration and troubleshooting.

## System Updates

After installation, the **Proxmox no-subscription repository** was configured and available system updates were applied through the Proxmox web interface.

The host was verified to have no outstanding package or repository issues before continuing.

## Administrative Access

A standard administrative Linux account was created for SSH access:

    useradd -m -s /bin/bash lab-admin
    passwd lab-admin
    usermod -aG sudo lab-admin

Administrative access was verified:

    su - lab-admin
    sudo whoami

Expected result:

    root

SSH access was performed using the administrative account rather than directly using `root`.

## Storage Configuration

Where available, the Proxmox system installation was separated from primary VM storage.

    Proxmox Host
    │
    ├── System SSD
    │   ├── Proxmox VE
    │   └── Local Storage
    │
    └── NVMe SSD
        └── Primary VM Storage

The system SSD hosted Proxmox VE, ISOs and local supporting storage. The NVMe SSD provided primary storage for virtual machine workloads.

## Host Validation

The host was validated before workloads were deployed or the host was joined to a cluster.

| Check | Requirement |
|---|---|
| Proxmox VE | Operational |
| System updates | Current |
| Repository configuration | Healthy |
| Static management IP | Configured |
| Linux bridge | Operational |
| Default gateway | Reachable |
| DNS resolution | Functional |
| Administrative SSH access | Verified |
| `sudo` access | Verified |
| System firmware | Current |
| Hardware virtualization | Enabled |
| Installed memory | Detected correctly |
| Storage | Active and healthy |
| Power recovery | Power On |

## Baseline Complete

    Proxmox Host
    │
    ├── Current Firmware
    ├── Updated Proxmox VE
    ├── Static Management Network
    ├── Administrative SSH Access
    ├── System Storage
    └── VM Storage
            │
            ▼
    Ready for Workloads / Cluster Membership

> **Prepare → Install → Network → Update → Admin Access → Storage → Validate**
