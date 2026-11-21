# 🖥️ Domain Controller Architecture

**Status: 🟢 Operational**

## Overview

This document records the design decisions behind the Active Directory domain controllers: where they run, how they were configured, what failures the design tolerates, and its known limitations.

Deployment steps are in [Domain Controller Deployment](./domain-controller-deployment.md). DNS and DHCP details are in [Active Directory DNS](./active-directory-DNS.md) and [Active Directory DHCP](./active-directory-DHCP.md).

> [!NOTE]
> Hostnames, IP addresses, and domain names have been sanitized for public release.

## Environment

| Setting | Value |
|---|---|
| Forest / domain | `lab.example.com` |
| NetBIOS name | `LAB` |
| Forest / domain functional level | Windows Server 2025 |
| Domain controllers | `dc-lab-01` (`10.0.0.10`), `dc-lab-02` (`10.0.0.11`) |
| Network | `10.0.0.0/24`, single site |
| Platform | Proxmox VE cluster, one domain controller per host |

## Design Decisions

| Decision | Choice | Reason |
|---|---|---|
| Number of domain controllers | Two | Smallest design that removes a single point of failure for directory, DNS, and DHCP |
| Placement | One domain controller per Proxmox host | A host failure or maintenance window takes down at most one domain controller |
| Build method | Both cloned from the generalized `win-server-2025-template`, then promoted separately | Consistent OS baseline; Sysprep gives each clone a unique identity. Roles were added after cloning, never baked into the template |
| Build order | `dc-lab-01` created the forest; `dc-lab-02` was promoted into the existing domain once `dc-lab-01` was validated | The additional domain controller needs a working domain to replicate from |
| Replication model | Multi-master (active-active) | Both domain controllers accept changes and serve clients; replication keeps them in sync |
| Global Catalog | Enabled on both | Single domain and forest, so there is no replication cost; either domain controller can answer GC queries |
| Operating system | Windows Server 2025 Standard Evaluation, Desktop Experience | Full GUI tooling while learning; PowerShell used alongside it |
| DNS | AD-integrated zones on both domain controllers | Zones replicate through AD; no secondary zones to maintain |
| DC DNS client settings | Partner domain controller preferred, local DNS alternate | Avoids a domain controller depending only on itself for DNS at startup |
| External resolution | Forward to two AdGuard Home instances on separate hosts | Network-wide filtering and DNS-over-HTTPS upstream, with no single forwarder dependency |
| DHCP | Windows DHCP on both domain controllers, 50/50 load-balanced failover | Both servers hand out leases normally; either can serve the whole scope during an outage |
| DHCP automatic state transition | Disabled | A network interruption alone should not trigger `PartnerDown`; it is declared manually for a confirmed extended outage |
| DHCP dynamic DNS | Disabled | Domain-joined clients register their own records securely; infrastructure records are managed manually |
| AD DS paths | Defaults (`C:\Windows\NTDS`, `C:\Windows\SYSVOL`) | No separate data disk needed at lab scale |

## Virtual Machine Configuration

Both domain controllers were cloned from the same template.

| Setting | Value |
|---|---|
| vCPU | 2 |
| Memory | 2 GB |
| System disk | 64 GB |
| Machine type | q35 |
| Firmware | OVMF (UEFI) |
| Storage controller | VirtIO SCSI |
| Network adapter | VirtIO |
| QEMU Guest Agent | Enabled |
| Addressing | Static IPv4 |

2 GB is the minimum memory for Windows Server 2025 Desktop Experience. Each domain controller only runs AD DS, DNS, and DHCP for a small environment, so this was sufficient. Resources will be increased if monitoring shows sustained memory pressure.

## FSMO Roles

The forest was created on `dc-lab-01`, so it holds all five FSMO roles:

| Role | Holder |
|---|---|
| Schema Master | `dc-lab-01` |
| Domain Naming Master | `dc-lab-01` |
| PDC Emulator | `dc-lab-01` |
| RID Master | `dc-lab-01` |
| Infrastructure Master | `dc-lab-01` |

Confirmed from both domain controllers with:

```powershell
netdom query fsmo
```

In a single-domain forest where every domain controller is a Global Catalog, keeping all roles on one domain controller is a normal configuration.

## Failure Domains

| Failure | Effect | Tested |
|---|---|---|
| `dc-lab-01` offline | Authentication, DNS, and DHCP continue through `dc-lab-02`; FSMO-dependent operations wait for `dc-lab-01` | ✅ |
| `dc-lab-02` offline | Authentication, DNS, and DHCP continue through `dc-lab-01` | ✅ |
| One Proxmox host offline | Same as losing the domain controller on that host | ✅ (via DC shutdown) |
| One AdGuard instance offline | External resolution continues through the other instance | ✅ |
| Both AdGuard instances offline | Internal AD names still resolve; external resolution fails | — |

## Known Limitations

- **Single site and subnet:** both domain controllers share the same network, switch, and router. A network-level failure affects both. Sites and Services and VLAN segmentation are planned.
- **FSMO on one server:** if `dc-lab-01` were lost permanently, its roles would need to be seized on `dc-lab-02`. A recovery procedure is planned under backup and recovery.
- **No directory backup yet:** domain controller redundancy is not a backup. Deletions and corruption replicate to both servers. System state backup and an authoritative restore test are planned.
- **Evaluation licensing:** Windows Server 2025 Evaluation has a 180-day evaluation period. Expiry dates should be tracked for both domain controllers.

## Outcome

The two-domain-controller design removed the single points of failure for directory, DNS, and DHCP at the VM and host level. Controlled failure testing confirmed each failure domain above. Remaining risks are network-level failures, permanent loss of the FSMO holder, and the lack of a directory backup, which are addressed in planned work.

## Related Documentation

- [Active Directory Lab](./README.md)
- [Domain Controller Deployment](./domain-controller-deployment.md)
- [Active Directory DNS](./active-directory-DNS.md)
- [Active Directory DHCP](./active-directory-DHCP.md)
- [Virtualization Lab](../virtualization-lab/)
- [Windows VM Templates](../../docs/reference/proxmox/proxmox-windows-vm-template.md)
