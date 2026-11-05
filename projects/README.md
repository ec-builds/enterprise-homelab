# 🗂️ Projects

<img src="../diagrams/projects-banner.png" alt="Projects Banner" width="1000">

Welcome to the Projects section. This README gives an overview of the projects, how they connect and grew together, and links to each one.

## Project Status Legend

| Status | Meaning |
|---|---|
| 🟢 **Operational** | Deployed, documented, and working as intended |
| 🟡 **In Progress** | Currently being built, configured, or tested |
| ⚪ **Planned** | Defined and included in the project roadmap |

## Project Status & Navigation

| Project | Focus Area | Status |
|---|---|:---:|
| [Active Directory Lab](./active-directory-lab/) | Windows Server, AD DS, Group Policy | 🟢 |
| [Backup & Disaster Recovery](./backup-disaster-recovery/) | Backup strategy, restore testing, DR runbooks | 🟡 |
| [Containerization-Lab](./containerization-lab/) | Containerized self-hosted applications, Docker | 🟢 |
| [Infrastructure Automation](./infrastructure-automation/) | Terraform, Ansible, IaC, configuration management | ⚪ |
| [Infrastructure Monitoring](./infrastructure-monitoring/) | Prometheus, Grafana, alerting, observability | 🟢 |
| [Media Services Platform](./media-services-platform/) | Linux administration, storage, service deployment | 🟢 |
| [Microsoft 365 & Entra ID Lab](./microsoft-365-entra-id/) | M365 administration, Entra ID, hybrid identity | ⚪ |
| [Microsoft Intune Lab](./microsoft-intune/) | Intune, Autopilot, MDM, compliance, app deployment | 🟢 |
| [Network Infrastructure](./network-infrastructure/) | Routing, switching, VLANs, DNS/DHCP | 🟢 |
| [Network Security](./network-security/) | Firewalls, segmentation, VPN, access security, system hardening | 🟢 |
| [Virtualization Lab](./virtualization-lab/) | Proxmox, VM lifecycle, lab foundation | 🟢 |
| [Security Operations](./security-operations/) | SIEM, detection engineering, incident response | ⚪ |
| [Web Platform & Secure Delivery](./web-platform/) | Astro, Cloudflare Workers, CI/CD, web security, DNS | 🟢 |

<!--
MAINTENANCE: When a project changes, also update the main README (../README.md):
- Project Portfolio status table
- Architecture diagram / service lists, if infrastructure changed
- Current Infrastructure table
-->

## How the Projects Connect

Each project depends on the ones above it:

```text
Proxmox Virtualization
   └── Network Infrastructure
         ├── Network Security
         ├── Active Directory
         │     └── Entra ID → Intune
         └── Docker Services
               ├── Monitoring → Security Operations
               └── Media Services
```

Backup & DR and Infrastructure Automation apply across all of the above. Web Platform runs separately on Cloudflare.
