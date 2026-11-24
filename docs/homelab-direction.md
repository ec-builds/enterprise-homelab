# 🧭 Homelab Direction

## Overview

What the homelab is for, which areas get the most attention, and why. Sequencing and progress are tracked in the [Homelab Roadmap](roadmap.md).

## Goal

The homelab focuses on **security, identity, cloud and modern infrastructure engineering**, aimed at **remote or hybrid infrastructure roles**.

Deep network engineering (extensive Cisco IOS work, routing protocols, CCNA-level switching) is deliberately **not** a primary goal.

## Guiding Principle

Build a solid **infrastructure and security** base, develop **identity** alongside it, then carry both into the **cloud**. Monitoring, automation, backup and documentation grow with the lab instead of being a single phase.

The areas build on each other:

- Firewall and segmentation concepts carry over to cloud security groups, network ACLs and virtual networks.
- Active Directory, Entra ID, RBAC and least privilege underpin both on-premises security and cloud IAM.
- Monitoring and logging cover infrastructure, identity, applications and security alike.
- Automation keeps the lab repeatable as it grows.
- Cloud platforms implement the same segmentation, identity, access-control, monitoring and automation ideas with their own services.

## Priorities

### Infrastructure & Network Security

The base everything else runs on. In place today:

- Three-node Proxmox VE virtualization
- Managed switching
- Perimeter firewall and NAT on the SOHO router, which also handles wireless and WireGuard remote access
- Trusted and isolated guest/IoT wireless networks
- Redundant Windows Server DHCP, Active Directory-integrated DNS and AdGuard Home DNS filtering
- DNS-over-HTTPS for upstream resolution
- Centralized storage and backup
- Availability monitoring and observability

Next comes **OPNsense** as the dedicated router and firewall:

- Edge routing and firewalling
- VLAN segmentation with stateful inter-VLAN policy
- Network security policy in one place
- More network logging and security monitoring
- IDS/IPS evaluation

The Cisco switch stays a **Layer 2** device (VLANs, trunks, access ports). OPNsense routes between VLANs in a router-on-a-stick setup, so all traffic crossing a security boundary passes through one stateful, logged control point and the switching layer stays simple.

### Identity & Access Management

A major focus, with a working on-premises base: Active Directory Domain Services, AD-integrated DNS, Windows Server DHCP, Group Policy, users, groups and OU structure, role-based access, domain-joined Windows clients, and troubleshooting. Two domain controllers on separate virtualization hosts provide redundant directory, DNS, Global Catalog and DHCP services.

Next is **Microsoft 365 and Microsoft Entra ID**: cloud identity, single sign-on, RBAC, Conditional Access, identity security and hybrid identity. Identity is the bridge between the on-premises lab and cloud work.

### Cloud

Cloud work extends the lab's infrastructure, security, identity, monitoring and automation into Azure: Azure administration, Entra ID, cloud IAM and RBAC, virtual networks, cloud security controls, monitoring and governance, hybrid identity, and Infrastructure as Code.

| On-Premises Concept | Cloud Equivalent |
|---|---|
| Network segmentation | Virtual Networks and subnets |
| Firewall policy | Network Security Groups and cloud firewall controls |
| Active Directory / RBAC | Entra ID and Azure RBAC |
| Infrastructure monitoring | Azure Monitor and Log Analytics |
| Centralized logging | Cloud-native logging and SIEM integration |
| Automation | Infrastructure as Code and cloud automation |

### Monitoring & Observability

Monitoring runs across the whole lab: Uptime Kuma for availability and synthetic checks, Prometheus for metrics, Grafana for dashboards, Loki and Grafana Alloy for logs, Alertmanager for alerts, plus Linux host and endpoint monitoring.

Coverage will expand to physical and virtual infrastructure, Linux systems, containers, network devices, DNS, infrastructure services, applications, logs and alerts. Monitoring is built alongside each new system, not added afterward.

### Automation

Tools in use or planned: **PowerShell, Python, Bash, Ansible, Terraform, GitHub Actions** and Infrastructure as Code generally.

Automation is added where it saves real effort: repeatable deployment, configuration, validation, administration and documentation. New technologies are set up by hand first to learn them; repeatable processes are automated later.

### Security Operations

Security work extends from preventive controls into detection and response.

In place: perimeter firewalling, WireGuard remote access, wireless isolation, Active Directory security controls, DNS filtering, encrypted upstream DNS, infrastructure monitoring and centralized logging.

Planned: security monitoring, vulnerability management, detection engineering, security event analysis, IDS/IPS, incident response, hardening and recovery testing.

## Lower Priority: Deep Cisco IOS

The switch provides the Layer 2 features the lab needs, including VLANs, trunking and access ports for segmentation. Routing protocols, advanced Layer 3 switching, complex ACL design and spanning-tree tuning stay mostly conceptual unless another project needs them. The hardware remains available if networking becomes more relevant later.

## Direction Summary

| Area | Direction | Current State |
|---|---|---|
| Infrastructure | Reliable compute, storage, networking and core services | **Operational / Expanding** |
| Network Security | Firewalling, remote access, DNS security, segmentation | **Operational / Expanding** |
| Identity | Active Directory, Group Policy, Entra ID | **Operational / Expanding** |
| Monitoring & Observability | Availability, metrics, logging, visualization, alerting | **Operational / Expanding** |
| Automation | Scripting, configuration management, IaC | **Developing** |
| Security Operations | Detection, vulnerability management, response | **Developing** |
| Cloud | Azure, Entra ID, RBAC, hybrid infrastructure | **Planned** |
| Deep Networking | Advanced Cisco IOS and Layer 3 networking | **Lower Priority** |

In short: **build reliable infrastructure, secure it, make identity the central control plane, add monitoring and automation, then extend it all into the cloud.**
