# 🗂️ Projects

Hands-on projects that make up the **enterprise-homelab** environment. Each project contains its own documentation, configurations, scripts, and lessons learned.

## Project Status & Navigation

| Project | Focus Area | Status |
|----------|----------|----------|
| [active-directory-lab](./active-directory-lab/) | Windows Server, AD DS, Group Policy | 📋 Planned |
| [azure-administration-lab](./azure-administration-lab/) | Azure infrastructure, RBAC, governance | 📋 Planned |
| [backup-disaster-recovery](./backup-disaster-recovery/) | Backup strategy, restore testing, DR runbooks | 📋 Planned |
| [ci-cd-pipelines](./ci-cd-pipelines/) | GitHub Actions, automated build & deploy | 📋 Planned |
| [docker-self-hosted-services](./docker-self-hosted-services/) | Containerized self-hosted applications | 📋 Planned |
| [home-network-security](./home-network-security/) | Firewalls, segmentation, hardening, VPN | 📋 Planned |
| [infrastructure-automation](./infrastructure-automation/) | Terraform, Ansible, Infrastructure as Code | 📋 Planned |
| [infrastructure-monitoring](./infrastructure-monitoring/) | Prometheus, Grafana, alerting, observability | 📋 Planned |
| [kubernetes-lab](./kubernetes-lab/) | k3s, container orchestration, AKS | 📋 Planned |
| [media-services-platform](./media-services-platform/) | Linux administration, storage, service deployment | ✅ Complete |
| [microsoft-365-entra-id](./microsoft-365-entra-id/) | M365 administration, Entra ID, hybrid identity | 📋 Planned |
| [network-infrastructure](./network-infrastructure/) | Routing, switching, VLANs, DNS/DHCP | 📋 Planned |
| [security-operations-lab](./security-operations-lab/) | SIEM, detection engineering, incident response | 📋 Planned |
| [virtualization-lab](./virtualization-lab/) | Proxmox, VM lifecycle, lab foundation | 🔨 In Progress |

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

## Documentation Standard

Each project folder follows the same internal structure:

```
project-name/
├── README.md          # Overview, objectives, architecture summary
├── docs/
│   ├── build-notes.md
│   ├── troubleshooting.md
│   └── lessons-learned.md
├── configs/           # Sanitized configuration files
├── scripts/           # Automation written for the project
└── screenshots/       # Visual documentation
```

> ⚠️ All configs and screenshots are sanitized before commit — no credentials, keys, public IPs, or license information.
