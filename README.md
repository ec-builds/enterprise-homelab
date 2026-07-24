# Enterprise Homelab

Welcome to my Enterprise Homelab.

This repository documents my enterprise-focused homelab, where I build and document projects in systems administration, networking, Microsoft infrastructure, Linux, automation, virtualization, and cloud technologies.

The goal is to learn enterprise concepts through hands-on projects while emphasizing documentation, operational procedures, and production-inspired design.

---


## Navigation


### README Sections

- [Roadmap](#roadmap)
- [Equipment](#equipment)
- [Current Environment](#current-environment)
- [Architecture Overview](#architecture-overview)
- [Areas of Focus](#areas-of-focus)
- [Project Portfolio](#project-portfolio)
- [Documentation Scope](#documentation-scope)
- [Learning Philosophy](#learning-philosophy)
- [Core Documents](#core-documents)


---

## Roadmap

![Homelab Roadmap](assets/roadmap.png)

See [Roadmap](roadmap.md)


---

## Equipment

The homelab is built using a combination of repurposed hardware, networking equipment, and storage systems that support ongoing infrastructure, networking, virtualization, and automation projects.

See [Equipment Inventory](equipment/README.md)

---

## Current Environment

| Category | Current | Planned |
|----------|----------|----------|
| Router | ASUS RT-AX5400 | OPNsense Firewall |
| Storage | Synology DS718+ | — |
| Servers | Debian Media Server | Proxmox Cluster |
| Switching | ASUS LAN Ports | Cisco Managed Switch |
| Networking | DHCP Reservations, Guest Wi-Fi, WireGuard | VLANs, Internal DNS |
| Documentation | GitHub + Markdown | Continue expanding documentation |

---

## Architecture Overview

The homelab is organized into several infrastructure domains. 

- Network Infrastructure
- Virtualization
- Identity & Access Management
- Security Operations
- Infrastructure Monitoring
- Media Services
- Automation & DevOps

Each domain is documented as an independent project while contributing to the overall enterprise environment.

---


## Areas of Focus

### Infrastructure

- Systems Administration
- Linux Administration
- Microsoft 365 & Entra ID
- Azure Administration

### Networking

- Enterprise Networking
- Network Security
- Virtualization
- Containerization & Kubernetes

### Automation

- Infrastructure as Code
- CI/CD
- Automation

### Operations

- Infrastructure Monitoring
- Backup & Disaster Recovery
- Security Operations
- Documentation

---

## Project Portfolio

>[!NOTE]
>Projects are documented independently and may progress at different rates depending on current learning objectives and infrastructure priorities.


| Project | Focus Area | Status |
|----------|----------|----------|
| [Active Directory Lab](projects/active-directory-lab/) | Windows Server, AD DS, Group Policy | 📋 Planned |
| [Azure Administration Lab](projects/azure-administration-lab/) | Azure infrastructure, RBAC, governance | 📋 Planned |
| [Backup & Disaster Recovery](projects/backup-disaster-recovery/) | Backup strategy, restore testing, DR runbooks | 📋 Planned |
| [CI/CD Pipelines](projects/ci-cd-pipelines/) | GitHub Actions, automated build & deploy | 📋 Planned |
| [Docker & Self-Hosted Services](projects/docker-self-hosted-services/) | Containerized self-hosted applications | 🔨 In Progress |
| [Home Network Security](projects/home-network-security/) | Firewalls, segmentation, hardening, VPN | 🔨 In Progress |
| [Infrastructure Automation](projects/infrastructure-automation/) | Terraform, Ansible, Infrastructure as Code | 📋 Planned |
| [Infrastructure Monitoring](projects/infrastructure-monitoring/) | Prometheus, Grafana, alerting, observability | 🔨 In Progress |
| [Kubernetes Lab](projects/kubernetes-lab/) | k3s, container orchestration, AKS | 📋 Planned |
| [Media Services Platform](projects/media-services-platform/) | Linux administration, storage, service deployment | 🟢 Operational |
| [Microsoft 365 & Entra ID Lab](projects/microsoft-365-entra-id/) | M365 administration, Entra ID, hybrid identity | 📋 Planned |
| [Network Infrastructure](projects/network-infrastructure/) | Routing, switching, VLANs, DNS/DHCP | 🟢 Operational |
| [Security Operations Lab](projects/security-operations-lab/) | SIEM, detection engineering, incident response | 📋 Planned |
| [Virtualization Lab](projects/virtualization-lab/) | Proxmox, VM lifecycle, lab foundation | 🔨 In Progress |


The homelab is organized into independent project areas. Each project contains its own documentation, architecture, objectives, and lessons learned.

➡️ **[Browse All Projects](./projects/README.md)**

---

## Documentation Scope

This repository is used to document:

- Project Objectives
- Architecture Diagrams
- Build Notes
- Configuration Examples
- Lessons Learned
- Troubleshooting Procedures
- Future Enhancements

---

## Learning Philosophy

The primary goal of this homelab is to demonstrate that enterprise IT skills can be developed using affordable hardware, thoughtful design, and consistent documentation.

Rather than focusing solely on deploying software, this repository emphasizes understanding how systems are planned, implemented, documented, and maintained.

---

## Core Documents

| Document | Description |
|---|---|
| `docs/homelab-decisions.md` | Architecture decisions and reasoning |
| `docs/reference/` | Quick reference guides and cheat sheets |
| `docs/standards/` | Baseline configs, naming conventions, documentation standards |

---

## EC-Builds

This repository is part of the EC-Builds project, where I document technical projects, infrastructure builds, and lessons learned while continuing to develop skills in enterprise IT and systems administration.

Follow along as the lab continues to grow.
