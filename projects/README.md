# 🗂️ Projects

Hands-on projects that make up the **enterprise-homelab** environment. Each project contains its own documentation, configurations, scripts, and lessons learned.

## Project Status Legend

| Status | Meaning |
|---|---|
| 🟢 **Operational** | Deployed, documented, and working as intended |
| 🟡 **In Progress** | Currently being built, configured, or tested |
| ⚪ **Planned** | Defined and included in the project roadmap |

## Project Status & Navigation

| Project | Focus Area | Status |
|---|---|---|
| [Active Directory Lab](./active-directory-lab/) | Windows Server, AD DS, Group Policy | 🟢 Operational |
| [Backup & Disaster Recovery](./backup-disaster-recovery/) | Backup strategy, restore testing, DR runbooks | ⚪ Planned |
| [Docker & Self-Hosted Services](./docker-self-hosted-services/) | Containerized self-hosted applications | 🟢 Operational |
| [Infrastructure Automation](./infrastructure-automation/) | Terraform, Ansible, IaC, configuration management | ⚪ Planned |
| [Infrastructure Monitoring](./infrastructure-monitoring/) | Prometheus, Grafana, alerting, observability | 🟢 Operational |
| [Media Services Platform](./media-services-platform/) | Linux administration, storage, service deployment | 🟢 Operational |
| [Microsoft 365 & Entra ID Lab](./microsoft-365-entra-id/) | M365 administration, Entra ID, hybrid identity | ⚪ Planned |
| [Microsoft Intune Lab](./microsoft-intune/) | Intune, Autopilot, MDM, compliance, app deployment | 🟡 In Progress |
| [Network Infrastructure](./network-infrastructure/) | Routing, switching, VLANs, DNS/DHCP | 🟢 Operational |
| [Network Security](./network-security/) | Firewalls, segmentation, VPN, access security, system hardening | 🟢 Operational |
| [Proxmox Virtualization Lab](./proxmox-virtualization-lab/) | Proxmox, VM lifecycle, lab foundation | 🟢 Operational |
| [Security Operations](./security-operations/) | SIEM, detection engineering, incident response | ⚪ Planned |

> [!NOTE]
> When making changes to any project, also update the main README located at [homepage README](../README.md).

## Build Order

The projects build on each other intentionally:

```text
Proxmox Virtualization
   └── Network Infrastructure
         ├── Network Security
         ├── Active Directory
         │     └── Microsoft 365 & Entra ID
         │           └── Microsoft Intune
         └── Docker & Self-Hosted Services
               ├── Infrastructure Monitoring
               │     └── Security Operations
               └── Media Services Platform

Infrastructure Automation and Backup & Disaster Recovery
support and mature the environment across each infrastructure domain.

Infrastructure Automation and Backup & Disaster Recovery
support and mature the environment across each infrastructure domain.
```


> ⚠️ All configs and screenshots are sanitized before commit — no credentials, keys, public IPs, or license information.
