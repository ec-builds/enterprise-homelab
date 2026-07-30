# Homelab Tool Catalog

A quick reference of the technologies used throughout the homelab, organized by infrastructure layer.

## Navigation

- [Physical Infrastructure](#physical-infrastructure)
- [Networking & Security](#networking--security)
- [Operating Systems](#operating-systems)
- [Container Platform](#container-platform)
- [Windows Infrastructure](#windows-infrastructure)
- [Windows Administration & Automation](#windows-administration--automation)
- [Linux Administration & Automation](#linux-administration--automation)
- [Monitoring & Observability](#monitoring--observability)
- [Documentation & Asset Management](#documentation--asset-management)
- [Storage & Backup](#storage--backup)
- [Self-Hosted Applications](#self-hosted-applications)

---

### Physical Infrastructure

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Dell OptiPlex Micro** | Compute Host | Enterprise desktop platform used as virtualization hosts. | Runs Proxmox virtual machines and containers. |
| **ASUS RT-AX5400** | Router | Wireless router and edge gateway. | Provides routing, firewall, VPN, and Internet connectivity. |
| **Cisco Catalyst Switch** | Managed Switch | Enterprise Layer 2 managed switch. | Provides switching, VLANs, and network segmentation. |
| **CyberPower UPS** | Power Protection | Uninterruptible power supply. | Protects infrastructure from power loss and enables graceful shutdowns. |

---

### Networking & Security

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **OPNsense** | Firewall | Open-source firewall and router platform. | Provides routing, firewalling, VPN, and network security. |
| **WireGuard** | VPN | Modern VPN protocol. | Provides secure remote access to the homelab. |
| **Technitium DNS** | DNS Server | Recursive and authoritative DNS server. | Provides internal DNS resolution and DNS filtering. |
| **VLAN (802.1Q)** | Network Segmentation | IEEE standard for virtual LANs. | Segments network traffic into logical security zones. |
| **SNMP** | Monitoring Protocol | Standard protocol for network device monitoring. | Collects health and performance metrics from infrastructure devices. |
| **NTP** | Time Synchronization | Network Time Protocol service. | Synchronizes system clocks across servers and network devices. |
| **Suricata** | IDS/IPS | Intrusion detection and prevention engine. | Detects and blocks malicious network traffic. |

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

### Container Platform

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Docker** | Container Platform | Runs applications in isolated containers. | Hosts lightweight infrastructure services. |
| **Docker Compose** | Container Orchestration | Defines and deploys multi-container applications. | Deploys and manages container stacks. |
| **Portainer** | Container Management | Web interface for Docker administration. | Manages containers, images, volumes, networks, and Compose stacks. |
| **Nginx Proxy Manager** | Reverse Proxy | Web-based reverse proxy and SSL management platform. | Publishes internal web services securely and manages TLS certificates. |
| **Let's Encrypt** | Certificate Authority | Free automated TLS certificate provider. | Issues and renews trusted HTTPS certificates. |
| **Vaultwarden** | Secrets Management | Self-hosted Bitwarden-compatible password manager. | Securely stores passwords, API keys, and infrastructure secrets. |

---

### Windows Infrastructure

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Active Directory Domain Services (AD DS)** | Identity | Windows directory service for centralized identity management. | Authenticates users, computers, and manages domain resources. |
| **DNS Server** | Name Resolution | Windows DNS service integrated with Active Directory. | Resolves hostnames and supports Active Directory functionality. |
| **DHCP Server** | IP Address Management | Dynamic Host Configuration Protocol server. | Automatically assigns IP addresses and network configuration to clients. |
| **Group Policy (GPO)** | Configuration Management | Centralized policy management for Windows devices and users. | Enforces security settings, software deployment, and system configuration. |
| **Microsoft Entra ID** | Cloud Identity | Microsoft's cloud identity and access management platform. | Provides cloud authentication, SSO, and hybrid identity integration. |
| **Active Directory Certificate Services (AD CS)** | Public Key Infrastructure | Microsoft's enterprise certificate authority. | Issues certificates for users, computers, VPNs, and internal services. |
| **Windows Server Update Services (WSUS)** | Patch Management | Centralized Windows Update management platform. | Approves and deploys Microsoft updates to Windows systems. |

---

### Windows Administration & Automation

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **PowerShell** | Automation | Microsoft's scripting and automation language. | Automates Windows administration, configuration, and management tasks. |
| **Windows Admin Center** | Server Management | Browser-based Windows Server management console. | Centrally manages Windows Servers without Remote Desktop. |
| **Remote Desktop Connection Manager (RDCMan)** | Remote Administration | Microsoft tool for organizing multiple Remote Desktop connections. | Provides centralized management of Windows servers and administrative sessions. |
| **Remote Server Administration Tools (RSAT)** | Administration | Windows feature providing management consoles and PowerShell modules. | Administers Active Directory, DNS, DHCP, Group Policy, and other Windows Server roles remotely. |

---

### Linux Administration & Automation

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **SSH** | Remote Access | Secure remote administration protocol. | Secure command-line access to Linux servers. |
| **Ansible** | Configuration Management | Agentless automation platform. | Automates Linux and Windows server configuration. |
| **Python** | Programming | General-purpose programming language. | Develops automation scripts and API integrations. |
| **VS Code Remote SSH** | Remote Development | VS Code extension for remote editing. | Develops and administers Linux systems over SSH. |

---

### Monitoring & Observability

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Grafana** | Dashboard | Visualization and dashboard platform. | Displays infrastructure metrics and dashboards. |
| **Prometheus** | Metrics | Time-series metrics database. | Collects and stores infrastructure metrics. |
| **Node Exporter** | Metrics Exporter | Linux metrics exporter for Prometheus. | Reports Linux system metrics. |
| **Windows Exporter** | Metrics Exporter | Windows metrics exporter for Prometheus. | Reports Windows Server metrics. |
| **SNMP Exporter** | Metrics Exporter | Prometheus SNMP collector. | Collects metrics from switches, routers, UPSes, and other network devices. |
| **cAdvisor** | Container Monitoring | Docker metrics exporter. | Monitors container resource utilization. |
| **Loki** | Logging | Centralized log aggregation platform. | Stores infrastructure and application logs. |
| **Promtail** | Log Collection | Log shipping agent for Loki. | Collects and forwards logs to Loki. |
| **Alertmanager** | Alerting | Prometheus alert routing service. | Sends notifications when monitoring alerts are triggered. |
| **Uptime Kuma** | Availability Monitoring | Uptime monitoring application. | Monitors service availability and endpoint health. |

---

### Documentation & Asset Management

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Obsidian** | Documentation | Markdown knowledge base. | Stores notes, runbooks, architecture, and learning documentation. |
| **NetBox** | Infrastructure Documentation | Source of truth and IPAM/DCIM platform. | Documents devices, IPs, VLANs, racks, cables, and virtual infrastructure. |
| **Snipe-IT** | Asset Management | IT asset inventory platform. | Tracks hardware, software licenses, warranties, and asset assignments. |
| **Git** | Version Control | Distributed version control system. | Tracks changes to code and documentation. |
| **Gitea** | Git Server | Self-hosted Git repository platform. | Hosts infrastructure code and documentation repositories. |

---

### Storage & Backup

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Synology DSM** | NAS Platform | Network-attached storage operating system. | Provides centralized storage, file sharing, and backups. |
| **Active Backup for Business** | Backup | Synology backup platform. | Protects PCs, servers, and virtual machines. |
| **Proxmox Backup Server** | VM Backup | Enterprise backup platform for Proxmox VE. | Performs deduplicated backups of virtual machines and containers. |

---

### Self-Hosted Applications

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Homepage** | Dashboard | Self-hosted service dashboard. | Provides a central landing page for homelab services. |
| **Jellyfin** | Media Server | Open-source media streaming platform. | Streams and manages personal media libraries. |
