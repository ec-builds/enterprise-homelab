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
| **Dell OptiPlex Micro** | Compute Host | Enterprise desktop platform used as virtualization hosts. | Hosts virtual machines and infrastructure services. |
| **ASUS RT-AX5400** | Router | Wireless router and edge gateway. | Provides Internet connectivity and edge networking. |
| **Cisco Catalyst** | Managed Layer 3 Switch | Enterprise multilayer switch with advanced switching and routing capabilities. | Provides switching, VLANs, inter-VLAN routing, and network segmentation. |
| **CyberPower UPS** | Power Protection | Uninterruptible power supply. | Protects infrastructure from power outages. |
| **Ventoy** | Boot & Recovery Utility | Multiboot USB platform for booting multiple ISO images from a single device. | Provides reusable installation, troubleshooting, and recovery media for physical hosts. |

---

### Networking & Security

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **OPNsense** | Firewall | Open-source firewall and router platform. | Enterprise firewall, routing, and VPN services. |
| **WireGuard** | VPN | Modern VPN protocol. | Secure remote access to the homelab. |
| **Technitium DNS** | DNS Server | Recursive and authoritative DNS server. | Internal DNS resolution and DNS filtering. |
| **VLAN (802.1Q)** | Network Segmentation | IEEE standard for virtual LANs. | Segments the network into security zones. |
| **SNMP** | Monitoring Protocol | Standard protocol for network device monitoring. | Collects infrastructure health and performance data. |
| **NTP** | Time Synchronization | Network Time Protocol service. | Synchronizes infrastructure system clocks. |
| **Suricata** | IDS/IPS | Intrusion detection and prevention engine. | Detects and blocks malicious network traffic. |

---

### Operating Systems

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Proxmox VE** | Hypervisor OS | Debian-based virtualization platform. | Hosts virtual machines and Linux containers. |
| **Debian** | Linux Server OS | Stable Linux server distribution. | Hosts containerized and Linux-based services. |
| **Windows Server** | Server OS | Microsoft enterprise server operating system. | Hosts Windows infrastructure services. |
| **Windows 11 Pro** | Client OS | Microsoft desktop operating system. | Primary administration workstation. |
| **Windows 10 Pro** | Client OS | Microsoft desktop operating system. | Compatibility and legacy client testing. |
| **macOS** | Client OS | Apple operating system (MacBook Pro). | Administration and remote management from macOS. |

---

### Container Platform

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Docker** | Container Platform | Runs applications in isolated containers. | Hosts containerized infrastructure services. |
| **Docker Compose** | Container Orchestration | Defines and deploys multi-container applications. | Deploys and manages container stacks. |
| **Portainer** | Container Management | Web interface for Docker administration. | Centralized Docker management. |
| **Nginx Proxy Manager** | Reverse Proxy | Web-based reverse proxy and SSL management platform. | Publishes internal web services securely. |
| **Let's Encrypt** | Certificate Authority | Free automated TLS certificate provider. | Issues and renews HTTPS certificates. |
| **Vaultwarden** | Secrets Management | Self-hosted Bitwarden-compatible password manager. | Securely stores infrastructure credentials. |

---

### Windows Infrastructure

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Active Directory Domain Services (AD DS)** | Identity | Windows directory service for centralized identity management. | Centralized identity and authentication. |
| **DNS Server** | Name Resolution | Windows DNS service integrated with Active Directory. | Active Directory DNS services. |
| **DHCP Server** | IP Address Management | Dynamic Host Configuration Protocol server. | Automatic IP address assignment. |
| **Group Policy (GPO)** | Configuration Management | Centralized policy management for Windows devices and users. | Centralized Windows configuration management. |
| **Microsoft Entra ID** | Cloud Identity | Microsoft's cloud identity and access management platform. | Cloud identity and single sign-on. |
| **Microsoft Intune** | Endpoint Management | Cloud-based endpoint management platform for devices, applications, and security policies. | Centralized device management and endpoint security. |
| **Active Directory Certificate Services (AD CS)** | Public Key Infrastructure | Microsoft's enterprise certificate authority. | Issues certificates for internal services. |
| **Windows Server Update Services (WSUS)** | Patch Management | Centralized Windows Update management platform. | Centralized Windows patch management. |

---

### Windows Administration & Automation

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **PowerShell** | Automation | Microsoft's scripting and automation language. | Windows automation and administration. |
| **Windows Admin Center** | Server Management | Browser-based Windows Server management console. | Centralized Windows Server administration. |
| **Remote Desktop Connection Manager (RDCMan)** | Remote Administration | Microsoft tool for organizing multiple Remote Desktop connections. | Manages Remote Desktop connections. |
| **Remote Server Administration Tools (RSAT)** | Administration | Windows feature providing management consoles and PowerShell modules. | Remote administration of Windows Server roles. |

---

### Linux Administration & Automation

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **SSH** | Remote Access | Secure remote administration protocol. | Remote Linux administration. |
| **Ansible** | Configuration Management | Agentless automation platform. | Automated server configuration. |
| **Python** | Programming | General-purpose programming language. | Automation and scripting. |
| **VS Code Remote SSH** | Remote Development | VS Code extension for remote editing. | Remote development and administration. |

---

### Monitoring & Observability

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Grafana** | Dashboard | Visualization and dashboard platform. | Infrastructure dashboards and visualization. |
| **Prometheus** | Metrics | Time-series metrics database. | Collects infrastructure metrics. |
| **Node Exporter** | Metrics Exporter | Linux metrics exporter for Prometheus. | Linux system metrics. |
| **Windows Exporter** | Metrics Exporter | Windows metrics exporter for Prometheus. | Windows Server metrics. |
| **SNMP Exporter** | Metrics Exporter | Prometheus SNMP collector. | Network device metrics. |
| **cAdvisor** | Container Monitoring | Docker metrics exporter. | Container performance metrics. |
| **Loki** | Logging | Centralized log aggregation platform. | Centralized infrastructure logging. |
| **Promtail** | Log Collection | Log shipping agent for Loki. | Ships logs to Loki. |
| **Alertmanager** | Alerting | Prometheus alert routing service. | Delivers monitoring notifications. |
| **Uptime Kuma** | Availability Monitoring | Uptime monitoring application. | Monitors service availability. |

---

### Documentation & Asset Management

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Obsidian** | Documentation | Markdown knowledge base. | Infrastructure documentation and runbooks. |
| **NetBox** | Infrastructure Documentation | Source of truth and IPAM/DCIM platform. | Documents infrastructure assets and networks. |
| **Snipe-IT** | Asset Management | IT asset inventory platform. | Tracks IT assets and licenses. |
| **Git** | Version Control | Distributed version control system. | Version control for code and documentation. |
| **Gitea** | Git Server | Self-hosted Git repository platform. | Hosts Git repositories. |

---

### Storage & Backup

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Synology DSM** | NAS Platform | Network-attached storage operating system. | Centralized storage and file services. |
| **Active Backup for Business** | Endpoint & Server Backup | Synology backup platform. | Protects endpoints, servers, and virtual machines. |
| **Hyper Backup** | NAS Backup | Synology backup and disaster recovery solution. | Protects NAS data and configuration. |
| **Time Machine** | macOS Backup | Apple's built-in backup solution for macOS. | Backs up macOS systems to the NAS. |
| **Proxmox Backup Server** | VM Backup | Enterprise backup platform for Proxmox VE. | Backs up virtual machines and containers. |

---

### Self-Hosted Applications

| Tool | Category | Short Definition | Primary Use |
|------|----------|------------------|-------------|
| **Homepage** | Dashboard | Self-hosted service dashboard. | Central dashboard for homelab services. |
| **Jellyfin** | Media Server | Open-source media streaming platform. | Personal media streaming. |
