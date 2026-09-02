# 🖥️ Domain Controller Architecture

This document defines the initial deployment architecture for the Active Directory domain controllers used in the homelab.

> [!NOTE]
> Hostnames and infrastructure identifiers shown in this document have been sanitized for public release.


## Platform

The domain controllers are deployed as virtual machines on the existing **Proxmox VE cluster**.

Proxmox was selected because it provides the virtualization foundation for the homelab and allows domain controllers to eventually be distributed across separate physical hosts.

```text
Proxmox Cluster
      │
      ├── prox-lab-01
      │     └── dc-lab-01-vm
      │
      └── prox-lab-02
            └── dc-lab-02-vm
                (Planned)
```

The initial deployment consists of `dc-lab-01` running as a virtual machine on `prox-lab-01`.

A second domain controller, `dc-lab-02`, is planned for `prox-lab-02` to provide directory and DNS redundancy and reduce dependency on a single virtualization host.

For additional information about the virtualization platform, architecture, and resource strategy, see the [Proxmox Virtualization Lab](../../proxmox-virtualization-lab/).

## Operating System

The domain controllers use:

**Windows Server 2025 Standard Evaluation (Desktop Experience)**

Desktop Experience was selected to provide the full graphical Windows Server administration environment while building and learning the Active Directory environment.

The graphical installation provides access to tools such as:

- Server Manager
- Active Directory Users and Computers
- Group Policy Management
- DNS Manager
- DHCP Manager
- Event Viewer
- Active Directory Administrative Center

PowerShell will also be used for administration and automation.


## Primary Domain Controller

The initial domain controller, `dc-lab-01`, is deployed as the `dc-lab-01-vm` virtual machine on `prox-lab-01`.

| Setting | Configuration |
|---|---|
| **VM** | `dc-lab-01-vm` |
| **Server Hostname** | `dc-lab-01` |
| **Proxmox Host** | `prox-lab-01` |
| **Operating System** | Windows Server 2025 Standard Evaluation |
| **Installation** | Desktop Experience |
| **vCPU** | 2 |
| **Memory** | 2 GB |
| **System Disk** | 64 GB |
| **Machine Type** | q35 |
| **Firmware** | OVMF (UEFI) |
| **Storage Controller** | VirtIO SCSI |
| **Network Adapter** | VirtIO |
| **QEMU Guest Agent** | Enabled |
| **Network Addressing** | Static |

The VM is intentionally allocated modest resources because the initial workload consists primarily of Active Directory Domain Services and DNS.

Resources can be increased if monitoring indicates additional capacity is required.

## Planned Domain Controller Roles

### Primary Domain Controller

```text
dc-lab-01
├── Active Directory Domain Services
├── DNS
└── DHCP
```

`dc-lab-01` will initially host the FSMO roles and provide directory, DNS, and DHCP services for the lab.

### Secondary Domain Controller

```text
dc-lab-02
├── Active Directory Domain Services
└── DNS
```

`dc-lab-02` will be deployed later on `prox-lab-02` and promoted as an additional domain controller.

## Redundancy Strategy

The target architecture distributes the two domain controllers across separate Proxmox hosts.

```text
             Active Directory Domain
                       │
            ┌──────────┴──────────┐
            │                     │
            ▼                     ▼
       dc-lab-01 ◄── AD/DNS ──► dc-lab-02
            │       Replication    │
            ▼                      ▼
       prox-lab-01            prox-lab-02
```

This design allows directory and DNS services to remain available if one domain controller or its underlying Proxmox host becomes unavailable.

The dual-domain-controller deployment will also provide a lab environment for practicing:

- Active Directory replication
- DNS redundancy
- FSMO role management
- Domain controller maintenance
- Active Directory Sites and Services
- Domain controller failure and recovery

## Deployment Strategy

```text
Deploy dc-lab-01 on prox-lab-01
              │
              ▼
Configure Windows Server
              │
              ▼
Configure Static Networking
              │
              ▼
Install AD DS + DNS
              │
              ▼
Create Active Directory Forest
              │
              ▼
Build and Validate AD Environment
              │
              ▼
Deploy dc-lab-02 on prox-lab-02
              │
              ▼
Promote Additional Domain Controller
              │
              ▼
Validate AD + DNS Redundancy
```

> [!NOTE]
> **`dc-lab-01` provides the initial Active Directory environment → `dc-lab-02` will later provide a second replicated domain controller on a separate Proxmox host → the resulting architecture provides both a realistic multi-domain-controller environment and resilience against a single VM or virtualization-host failure.**
