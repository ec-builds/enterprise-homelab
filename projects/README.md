# 🗂️ Projects

Hands-on projects that make up the **enterprise-homelab** environment. Each project contains its own documentation, configurations, scripts, and lessons learned.

## Project Status & Navigation

| Project | Focus Area | Status |
|----------|----------|----------|
| [Active Directory Lab](projects/active-directory-lab/) | Windows Server, AD DS, Group Policy | 📋 Planned |
| [Azure Administration Lab](projects/azure-administration-lab/) | Azure infrastructure, RBAC, governance | 📋 Planned |
| [Backup & Disaster Recovery](projects/backup-disaster-recovery/) | Backup strategy, restore testing, DR runbooks | 📋 Planned |
| [CI/CD Pipelines](projects/ci-cd-pipelines/) | GitHub Actions, automated build & deploy | 📋 Planned |
| [Docker & Self-Hosted Services](projects/docker-self-hosted-services/) | Containerized self-hosted applications | 📋 Planned |
| [Home Network Security](projects/home-network-security/) | Firewalls, segmentation, hardening, VPN | 📋 Planned |
| [Infrastructure Automation](projects/infrastructure-automation/) | Terraform, Ansible, Infrastructure as Code | 📋 Planned |
| [Infrastructure Monitoring](projects/infrastructure-monitoring/) | Prometheus, Grafana, alerting, observability | 📋 Planned |
| [Kubernetes Lab](projects/kubernetes-lab/) | k3s, container orchestration, AKS | 📋 Planned |
| [Media Services Platform](projects/media-services-platform/) | Linux administration, storage, service deployment | 🟢 Operational |
| [Microsoft 365 & Entra ID Lab](projects/microsoft-365-entra-id/) | M365 administration, Entra ID, hybrid identity | 📋 Planned |
| [Network Infrastructure](projects/network-infrastructure/) | Routing, switching, VLANs, DNS/DHCP | 🔨 In Progress |
| [Security Operations Lab](projects/security-operations-lab/) | SIEM, detection engineering, incident response | 📋 Planned |
| [Virtualization Lab](projects/virtualization-lab/) | Proxmox, VM lifecycle, lab foundation | 🔨 In Progress |

> [!NOTE]
> When making changes to any project, also update the main README located at [homepage README](../README.md).


## Build Order

The projects stack on each other intentionally:

```
Proxmox (virtualization-lab)
   └── Network design (network-infrastructure)
         └── Enterprise identity (active-directory-lab → microsoft-365-entra-id)
               └── Cloud (azure-administration-lab)
                     └── Engineering practices (infrastructure-automation → kubernetes-lab → ci-cd-pipelines)
                           └── Operations maturity (infrastructure-monitoring → security-operations-lab → backup-disaster-recovery → home-network-security)
```

Every project folder should follow this structure:

```text
projects/project-name/
├── README.md              ← Project overview and navigation table
├── architecture.md        ← System design and component relationships
├── hardware.md            ← Hardware specifications (if applicable)
├── diagrams/              ← Architecture diagrams and screenshots
├── lessons-learned.md     ← Key takeaways and reflections
└── [topic].md             ← Additional documentation as needed
```

The `README.md` must include:
- Status badge
- Project objectives
- Technologies used
- Completed work checklist
- Future enhancements
- Navigation table linking to all documents in the folder


> ⚠️ All configs and screenshots are sanitized before commit — no credentials, keys, public IPs, or license information.
