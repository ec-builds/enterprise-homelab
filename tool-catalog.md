# Homelab Tool Catalog

A quick reference of the technologies used throughout the homelab, organized by ecosystem.

## Navigation

- [Operating Systems](#operating-systems)
- [Docker Ecosystem](#docker-ecosystem)
- [Monitoring & Observability](#monitoring--observability)
- [Windows Infrastructure](#windows-infrastructure)
- [Windows Administration & Automation](#windows-administration--automation)
- [Linux Administration & Automation](#linux-administration--automation)
- [Networking & Security](#networking--security)
- [Documentation & Asset Management](#documentation--asset-management)
- [Storage & Backup](#storage--backup)
- [Applications](#applications)

---

### Operating Systems

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Proxmox VE** | Hypervisor OS | Debian-based virtualization platform. | Hosts and manages virtual machines and Linux containers. |
| **Debian** | Linux Server OS | Stable Linux server distribution. | Hosts Docker and Linux-based infrastructure services. |
| **Windows Server** | Server OS | Microsoft enterprise server operating system. | Hosts Active Directory, DNS, Group Policy, and other Windows services. |
| **Windows 11 Pro** | Client OS | Microsoft desktop operating system. | Primary administrative workstation for managing the homelab and testing enterprise tools. |
| **Windows 10 Pro** | Client OS | Microsoft desktop operating system. | Secondary workstation for compatibility testing and legacy client scenarios. |

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
| **Active Directory Domain Services (AD DS)** | Identity | Windows directory service for centralized identity management. | Authenticates users, computers, and manages domain resources. |
| **DNS Server** | Name Resolution | Windows DNS service integrated with Active Directory. | Resolves hostnames and supports Active Directory functionality. |
| **DHCP Server** | IP Address Management | Dynamic Host Configuration Protocol server. | Automatically assigns IP addresses and network configuration to clients. |
| **Group Policy (GPO)** | Configuration Management | Centralized policy management for Windows devices and users. | Enforces security settings, software deployment, and system configuration. |
| **Microsoft Entra ID** | Cloud Identity | Microsoft's cloud identity and access management platform. | Provides cloud authentication, SSO, and hybrid identity integration. |
| **Active Directory Certificate Services (AD CS)** *(Planned)* | Public Key Infrastructure | Microsoft's enterprise certificate authority. | Issues certificates for users, computers, VPNs, and internal services. |
| **Windows Server Update Services (WSUS)** *(Planned)* | Patch Management | Centralized Windows Update management platform. | Approves and deploys Microsoft updates to Windows systems. |

---

### Windows Administration & Automation

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **PowerShell** | Automation | Microsoft's scripting and automation language. | Automates Windows administration, configuration, and management tasks. |
| **Windows Admin Center** *(Planned)* | Server Management | Browser-based Windows Server management console. | Centrally manages Windows Servers without Remote Desktop. |
| **Remote Desktop Connection Manager (RDCMan)** | Remote Administration | Microsoft tool for organizing multiple Remote Desktop connections. | Provides centralized management of Windows servers and administrative sessions. |
| **Remote Server Administration Tools (RSAT)** | Administration | Windows feature providing management consoles and PowerShell modules. | Administers Active Directory, DNS, DHCP, Group Policy, and other Windows Server roles remotely. |
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
