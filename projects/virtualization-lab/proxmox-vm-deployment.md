# 🖥️ Proxmox VM Deployment Baseline

Example implementation of the standard Proxmox VM deployment process using
`docker-lab-vm`, a Debian 13 virtual machine serving as the primary Docker host.

The configuration establishes a reusable starting point for future VMs.
Other workloads will follow the same general deployment process but will not
require individual step-by-step documentation.

## VM Creation

### 1. General

| Setting | Configuration |
|---|---|
| VM Name | `docker-lab-vm` |
| VM ID | Automatically assigned |
| Resource Pool | None |
| HA | Disabled |

> **Screenshot:** Proxmox VM Creation — General

---

### 2. Operating System

| Setting | Configuration |
|---|---|
| Installation Media | Debian 13 ISO |
| Guest OS | Linux |
| Version | 6.x / 2.6 Kernel |

> **Screenshot:** Proxmox VM Creation — OS

---

### 3. System

| Setting | Configuration |
|---|---|
| Machine | `q35` |
| BIOS | OVMF (UEFI) |
| EFI Disk | Enabled |
| Pre-Enroll Keys | Enabled |
| QEMU Guest Agent | Enabled |
| TPM | Disabled |
| SCSI Controller | VirtIO SCSI single |

TPM is not required for this Linux workload. It may be enabled for guest operating systems or workloads that require it.

> **Screenshot:** Proxmox VM Creation — System

---

### 4. Disk

| Setting | Configuration |
|---|---|
| Storage | NVMe VM storage |
| Size | 64 GiB |
| Bus / Device | SCSI |
| Cache | Default (No cache) |
| Discard | Enabled |
| IO Thread | Enabled |

> **Screenshot:** Proxmox VM Creation — Disks

---

### 5. CPU

| Setting | Configuration |
|---|---|
| Sockets | 1 |
| Cores | 2 |
| CPU Type | `x86-64-v2-AES` |

CPU resources can be increased later if workload utilization requires additional capacity.

> **Screenshot:** Proxmox VM Creation — CPU

---

### 6. Memory

| Setting | Configuration |
|---|---|
| Memory | 6144 MiB (6 GiB) |

Memory is intentionally allocated conservatively and can be increased as workload requirements grow.

> **Screenshot:** Proxmox VM Creation — Memory

---

### 7. Network

| Setting | Configuration |
|---|---|
| Bridge | `vmbr0` |
| Model | VirtIO |
| Proxmox Firewall | Enabled |
| VLAN | None |

VLAN assignment will be introduced as network segmentation is implemented.

> **Screenshot:** Proxmox VM Creation — Network

---

### 8. Configuration Review

Before creating the VM, verify the complete configuration.

| Resource | Baseline |
|---|---|
| Guest OS | Debian 13 |
| Machine | `q35` |
| Firmware | OVMF (UEFI) |
| CPU | 2 vCPU |
| Memory | 6 GiB |
| Disk | 64 GiB |
| Disk Controller | VirtIO SCSI |
| Network | VirtIO / `vmbr0` |
| QEMU Guest Agent | Enabled |
| TPM | Disabled |

> **Screenshot:** Proxmox VM Creation — Confirm

---

## Post-Installation

After Debian installation, update the guest:

```bash
apt update
apt full-upgrade
```

Install and enable the QEMU Guest Agent:

```bash
apt install qemu-guest-agent
systemctl enable --now qemu-guest-agent
```

Verify the service:

```bash
systemctl status qemu-guest-agent
```

## Baseline Strategy

This VM serves as the documented example for the homelab's general VM deployment process.

Future workloads may require different CPU, memory, storage, firmware, TPM, or networking configurations, but will follow the same general workflow:

```text
Define Workload
      ↓
Select Guest OS
      ↓
Configure Virtual Hardware
      ↓
Allocate Resources
      ↓
Configure Networking
      ↓
Review Configuration
      ↓
Install Guest OS
      ↓
Install Guest Tools
      ↓
Validate
```

> **This baseline is used as a starting point, resources and virtual hardware are then adjusted according to workload requirements.**
