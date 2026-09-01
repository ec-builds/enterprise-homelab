# 🖥️ Proxmox VM Deployment Baseline

This document records the virtual machine deployment baseline implemented
throughout the Proxmox homelab.

The initial implementation uses `docker-lab-vm`, a Debian 13 virtual machine
serving as the primary Docker host. Other workloads use the same general
deployment baseline, with virtual hardware and resources adjusted according to
guest operating system and workload requirements.

Rather than documenting the Proxmox creation wizard for every VM, this document
records the standard configuration, guest-specific differences, implementation
decisions, and validation performed.

## Navigation

- [VM Deployment Baseline](#vm-deployment-baseline)
- [Debian / Docker Implementation](#debian--docker-implementation)
  - [Configuration](#configuration)
  - [Post-Installation](#post-installation)
  - [Validation](#validation)
- [Windows 11 Guest Considerations](#windows-11-guest-considerations)
  - [Windows 11 Configuration](#windows-11-configuration)
  - [VirtIO Drivers](#virtio-drivers)
  - [QEMU Guest Agent](#qemu-guest-agent)
  - [Windows 11 Validation](#windows-11-validation)
- [Baseline Strategy](#baseline-strategy)

## VM Deployment Baseline

Virtual machines in the homelab use a common set of virtualization technologies
where appropriate.

The implemented baseline uses:

- UEFI firmware for modern guest operating systems.
- VirtIO devices for efficient paravirtualized storage and networking.
- SCSI-backed virtual disks using VirtIO SCSI.
- Thin-provisioned NVMe storage for VM disks.
- QEMU Guest Agent integration for guest communication and management.
- Conservative initial resource allocation with expansion based on observed utilization.

Individual workloads deviate from the baseline when operating system or
application requirements justify a different configuration.

## Debian / Docker Implementation

The initial baseline was implemented using `docker-lab-vm`, a Debian 13 virtual
machine serving as the primary Docker host.

### Configuration

| Setting | Configuration |
|---|---|
| Guest OS | Debian 13 |
| Machine | `q35` |
| Firmware | OVMF (UEFI) |
| EFI Disk | Enabled |
| Secure Boot Keys | Pre-enrolled |
| CPU | 2 vCPU |
| CPU Type | `x86-64-v2-AES` |
| Memory | 6144 MiB (6 GiB) |
| Disk | 64 GiB |
| Storage | NVMe-backed LVM-Thin |
| Disk Bus | SCSI |
| Disk Controller | VirtIO SCSI single |
| Cache | Default (No cache) |
| Discard | Enabled |
| IO Thread | Enabled |
| Network Adapter | VirtIO |
| Bridge | `vmbr0` |
| Proxmox Firewall | Enabled |
| VLAN | None |
| QEMU Guest Agent | Enabled |
| TPM | Disabled |
| HA | Disabled |

Resources were intentionally allocated conservatively to establish an efficient
starting point while allowing additional CPU and memory to be assigned as
workload requirements increase.

VirtIO devices are used for storage and networking instead of emulated legacy
hardware to provide efficient paravirtualized I/O.

TPM was not enabled because it is not required for this Linux workload.

VLAN assignment was not configured during the initial deployment. Network
segmentation will be introduced as the lab networking architecture is expanded.

> **Screenshot:** Completed Debian VM hardware configuration

### Post-Installation

After Debian installation, the guest operating system was updated:

```bash
apt update
apt full-upgrade
```

The QEMU Guest Agent was installed and enabled:

```bash
apt install qemu-guest-agent
systemctl enable --now qemu-guest-agent
```

The guest-agent service was verified:

```bash
systemctl status qemu-guest-agent
```

### Validation

The completed Debian deployment was validated by confirming:

- Debian booted successfully using UEFI.
- The virtual disk was available and operating normally.
- The VirtIO network adapter was operational.
- Network connectivity was available through `vmbr0`.
- QEMU Guest Agent was running inside the guest.
- Proxmox could communicate with the guest.
- Graceful shutdown and reboot could be initiated from Proxmox.

## Windows 11 Guest Considerations

Windows 11 was deployed using the same general VM baseline with several
guest-specific changes.

Windows 11 required additional virtual hardware and guest drivers compared with
the Debian implementation, including TPM 2.0, Secure Boot support, and VirtIO
Windows drivers.

### Windows 11 Configuration

| Setting | Windows 11 Configuration |
|---|---|
| Guest OS | Windows 11 |
| Machine | `q35` |
| Firmware | OVMF (UEFI) |
| EFI Disk | Enabled |
| Secure Boot | Pre-enrolled keys enabled |
| TPM | TPM 2.0 |
| CPU | 4 vCPU |
| CPU Type | `x86-64-v2-AES` |
| Memory | 8192 MiB (8 GiB) |
| Disk | 64 GiB |
| Storage | NVMe-backed LVM-Thin |
| Disk Bus | SCSI |
| Disk Controller | VirtIO SCSI single |
| Discard | Enabled |
| IO Thread | Enabled |
| Network Adapter | VirtIO |
| Bridge | `vmbr0` |
| Proxmox Firewall | Enabled |
| Driver Media | VirtIO Windows driver ISO |
| QEMU Guest Agent | Enabled |

TPM 2.0 and UEFI Secure Boot support were configured to meet Windows 11 virtual
hardware requirements.

VirtIO devices are used for storage and networking instead of emulated legacy
hardware to provide efficient paravirtualized I/O.

> **Screenshot:** Completed Windows 11 VM hardware configuration

### VirtIO Drivers

The Windows installation media did not include all VirtIO drivers required by
the configured virtual hardware. The VirtIO Windows driver ISO was therefore
attached as secondary installation media.

The following VirtIO components were used:

- `vioscsi` provides the VirtIO SCSI storage driver.
- `NetKVM` provides the VirtIO network driver.
- `vioserial` provides the VirtIO serial communication device used by guest
  integration components.
- `Balloon` provides the VirtIO memory balloon driver.

During Windows Setup, the VirtIO SCSI driver was loaded to make the virtual
disk available to the installer.

For the 64-bit Windows 11 installation, the storage driver was located under:

```text
VirtIO Driver ISO
└── vioscsi
    └── w11
        └── amd64
```

The VirtIO network driver was available under:

```text
VirtIO Driver ISO
└── NetKVM
    └── w11
        └── amd64
```

After Windows installation, the VirtIO guest tools were installed to provide
the required virtualization drivers and guest integration components.

### QEMU Guest Agent

QEMU Guest Agent support was enabled in the Proxmox VM configuration, creating
the communication channel between the hypervisor and guest.

The corresponding QEMU Guest Agent was also installed and enabled inside
Windows.

The resulting communication path is:

```text
Proxmox
    ↓
QEMU Guest Agent Channel
    ↓
VirtIO Serial
    ↓
QEMU Guest Agent Service
    ↓
Windows
```

The guest-side service was validated using PowerShell:

```powershell
Get-Service qemu-ga
```

The expected running state was confirmed:

```text
Status   Name      DisplayName
------   ----      -----------
Running  qemu-ga   QEMU Guest Agent
```

The Windows service running confirmed that the guest-side agent was operational,
but did not by itself confirm communication with the hypervisor.

Hypervisor-to-guest communication was therefore validated from the Proxmox host:

```bash
qm agent <VMID> ping
```

A successful response confirmed communication between Proxmox and the Windows
guest.

Guest-agent functionality was further validated by initiating graceful power
operations from Proxmox.

### Windows 11 Validation

The completed Windows 11 deployment was validated by confirming:

- Windows booted successfully using UEFI.
- Secure Boot was available to the guest.
- TPM 2.0 was available to the guest.
- The VirtIO SCSI storage device was operational.
- The VirtIO network adapter was operational.
- VirtIO guest components were installed.
- QEMU Guest Agent was running inside Windows.
- Proxmox could communicate with QEMU Guest Agent.
- Network connectivity was available through `vmbr0`.
- Graceful shutdown and reboot could be initiated from Proxmox.

The Windows deployment demonstrated that the standard VM baseline could be
adapted for an operating system with additional virtual hardware and driver
requirements without requiring a separate deployment process.

## Baseline Strategy

The implemented deployment model serves as the starting point for virtual
machines throughout the homelab.

Virtual hardware and resource allocation are adjusted according to workload
requirements rather than creating a separate deployment procedure for every
guest.

The implemented deployment pattern is:

```text
Define Workload
      ↓
Select Guest OS
      ↓
Apply VM Baseline
      ↓
Adjust Guest-Specific Hardware
      ↓
Allocate Resources
      ↓
Install Guest OS
      ↓
Install Guest Tools
      ↓
Validate
```

Examples of workload-specific adjustments include:

| Workload | Baseline Adjustment |
|---|---|
| Windows 11 | TPM 2.0, Secure Boot, VirtIO Windows drivers |
| Domain Controller | Windows Server sizing and static network configuration |
| Docker Host | Linux guest with resources sized for container workloads |
| Monitoring Server | Resources adjusted according to monitoring workload |
| Firewall / Router | Multiple virtual NICs and workload-specific networking |

This approach keeps VM deployment consistent while allowing each workload to
receive the virtual hardware and resources appropriate for its role.

> **The baseline defines the starting configuration, while workload requirements determine the final configuration.**
