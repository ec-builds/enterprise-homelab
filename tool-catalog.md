# Homelab Tool Catalog

A quick reference of the technologies used throughout the homelab, organized by ecosystem.

## Navigation

- [Virtualization](#virtualization)
- [Docker Ecosystem](#docker-ecosystem)
- [Monitoring & Observability](#monitoring--observability)
- [Windows Infrastructure](#windows-infrastructure)
- [Linux Administration & Automation](#linux-administration--automation)
- [Networking & Security](#networking--security)
- [Documentation & Asset Management](#documentation--asset-management)
- [Storage & Backup](#storage--backup)
- [Applications](#applications)

---

### Virtualization

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Proxmox VE** | Hypervisor | Enterprise virtualization platform. | Hosts and manages virtual machines and Linux containers. |
| **Debian** | Operating System | Stable Linux server distribution. | Base OS for Docker and infrastructure services. |
| **Windows Server** | Server OS | Microsoft enterprise server platform. | Hosts Active Directory, DNS, Group Policy, and other Windows services. |

---

### Docker Ecosystem

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Docker** | Container Platform | Runs applications in isolated containers. | Hosts lightweight services without dedicated VMs. |
| **Docker Compose** | Container Orchestration | Defines and deploys multi-container applications. | Deploys and manages multi-container applications. |
| **Portainer** | Docker Management | Web interface for Docker administration. | Manages containers, images, volumes, networks, and Compose stacks. |

---

### Monitoring & Observability

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Grafana** | Dashboard | Visualization and dashboard platform. | Displays infrastructure metrics and dashboards. |
| **Prometheus** | Metrics | Time-series metrics database. | Collects and stores infrastructure metrics. |
| **Node Exporter** | Metrics Exporter | Linux system metrics exporter. | Reports CPU, memory, disk, and system statistics. |
| **cAdvisor** | Container Monitoring | Docker metrics exporter. | Monitors container resource utilization. |
| **Loki** | Logging | Log aggregation platform. | Stores centralized logs from servers and containers. |
| **Promtail** | Log Collection | Log shipping agent for Loki. | Collects and forwards logs to Loki. |
| **Alertmanager** | Alerting | Prometheus notification service. | Routes and delivers monitoring alerts. |
| **Uptime Kuma** | Availability Monitoring | Uptime monitoring application. | Monitors service availability and sends alerts. |

---

### Windows Infrastructure

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Active Directory (AD DS)** | Identity | Windows directory service. | Centralized authentication and computer management. |
| **Microsoft Entra ID** | Cloud Identity | Microsoft's cloud identity platform. | Cloud authentication, SSO, and identity management. |
| **PowerShell** | Automation | Microsoft scripting language. | Automates Windows administration tasks. |

---

### Linux Administration & Automation

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **SSH** | Remote Access | Secure remote administration protocol. | Secure command-line access to Linux servers. |
| **Ansible** | Automation | Agentless configuration management platform. | Automates server configuration and deployments. |
| **Python** | Programming | General-purpose programming language. | Automation, scripting, and API integration. |
| **VS Code Remote SSH** | Remote Development | VS Code extension for remote editing. | Develops and administers Linux systems over SSH. |

---

### Networking & Security

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **OPNsense** | Firewall | Open-source firewall and router. | Provides routing, firewalling, VPN, and network security. |
| **Technitium DNS** | DNS Server | Recursive and authoritative DNS server. | Provides internal DNS resolution and DNS filtering. |
| **WireGuard** | VPN | Modern VPN protocol. | Provides secure remote access to the homelab. |

---

### Documentation & Asset Management

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Obsidian** | Documentation | Markdown knowledge base. | Stores notes, runbooks, architecture, and learning documentation. |
| **NetBox** | Infrastructure Documentation | Source of truth and IPAM/DCIM platform. | Documents devices, IPs, VLANs, racks, cables, and virtual infrastructure. |
| **Snipe-IT** | Asset Management | IT asset inventory platform. | Tracks hardware, software licenses, warranties, and asset assignments. |
| **Gitea** | Git Server | Self-hosted Git repository platform. | Stores documentation, code, and infrastructure repositories. |
| **Git** | Version Control | Distributed version control system. | Tracks changes to code and documentation. |

---

### Storage & Backup

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Synology DSM** | NAS Platform | Network-attached storage operating system. | Provides centralized storage, file sharing, and backups. |
| **Active Backup for Business** | Backup | Synology backup platform. | Protects PCs, servers, and virtual machines. |

---

### Applications

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Homepage** | Dashboard | Self-hosted service dashboard. | Central landing page for homelab services. |
| **Jellyfin** | Media Server | Open-source media streaming platform. | Streams and manages personal media libraries. |
