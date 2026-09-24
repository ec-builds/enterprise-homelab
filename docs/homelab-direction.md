# 🧭 Homelab Direction

## Overview

This document defines the strategic direction of the homelab: what it is being built to demonstrate, which capabilities receive the greatest emphasis, and the reasoning behind those priorities.

It exists to keep build effort aligned with clear technical and professional goals rather than accumulating technology for its own sake.

Implementation sequencing and progress are maintained separately in the [Homelab Roadmap](roadmap.md).

## Goal

The homelab is oriented toward **security, identity, cloud, and modern infrastructure engineering**, in support of **remote or hybrid infrastructure roles**.

Deep network engineering, including extensive Cisco IOS administration, routing protocols, and CCNA-depth switching, is intentionally **not** a primary objective.

The environment instead emphasizes practical infrastructure capabilities that support security, identity, cloud administration, automation, and reliable operations.

## Guiding Principle

Build a strong **infrastructure and security foundation**, develop **identity** alongside it, and extend those concepts into the **cloud**.

Monitoring, automation, backup, documentation, and security mature alongside the environment rather than belonging to a single stage of development.

Each area reinforces concepts reused by the others:

- On-premises firewall and segmentation concepts transfer to cloud security groups, network ACLs, and virtual networks.
- Identity concepts such as Active Directory, Entra ID, RBAC, and least privilege underpin both on-premises security and cloud IAM.
- Monitoring and logging provide visibility across infrastructure, identity, applications, and security systems.
- Automation makes the environment more repeatable as the number of systems and services increases.
- Cloud platforms reimplement many of the same segmentation, identity, access-control, monitoring, and automation concepts using cloud-native services.

The Cisco switch is infrastructure plumbing rather than the primary learning objective. Its role is to provide reliable managed connectivity and eventually support segmentation for the services built above it.

Deep IOS work remains a lower priority because the homelab is not intended to become a dedicated network-engineering lab.

## Strategic Priorities

### Infrastructure & Network Security

The current environment provides the infrastructure and security foundation upon which the rest of the homelab is built.

Current capabilities include:

- Three-node Proxmox VE virtualization
- Managed switching
- Perimeter firewalling and NAT
- WireGuard remote access
- Trusted and isolated guest/IoT wireless networks
- Redundant Windows Server DHCP
- Redundant Active Directory-integrated DNS
- Redundant AdGuard Home DNS filtering
- DNS-over-HTTPS for upstream DNS resolution
- Centralized storage and backup
- Availability monitoring and observability

The existing SOHO router currently provides edge routing, firewalling, NAT, wireless networking, and WireGuard remote access.

The longer-term network-security direction is to introduce **OPNsense** as the dedicated routing and firewall platform.

Planned capabilities include:

- OPNsense edge routing and firewalling
- VLAN segmentation
- Stateful inter-VLAN firewall policy
- Centralized network-security policy
- Expanded network logging
- IDS/IPS evaluation
- Additional security monitoring

The Cisco switch will remain primarily a **Layer 2** platform using VLANs, trunks, and access ports as segmentation is introduced.

Inter-VLAN routing is intended to be handled by OPNsense using a router-on-a-stick architecture so traffic crossing security boundaries passes through a centralized, stateful, and observable control point.

This keeps security policy concentrated at the firewall while allowing the switching layer to remain comparatively simple.

### Identity & Access Management

Identity development is a major focus of the homelab and already has an operational on-premises foundation.

The Active Directory environment provides experience with:

- **Active Directory Domain Services**
- **Active Directory-integrated DNS**
- **Windows Server DHCP**
- **Group Policy**
- **Users, groups, and organizational structure**
- **Role-based access concepts**
- **Windows client domain integration**
- **Domain controller redundancy and replication**
- **Identity administration and troubleshooting**

The environment uses two domain controllers distributed across separate virtualization hosts, providing redundant directory, DNS, Global Catalog, and DHCP services.

The next area of development extends these concepts into **Microsoft 365 and Microsoft Entra ID**, including:

- Cloud identity
- Single sign-on
- Role-based access control
- Conditional Access
- Identity security
- Hybrid identity concepts

Identity and access management is foundational to modern infrastructure and cloud security, making it a natural bridge between the on-premises environment and future cloud work.

### Cloud

Cloud development will extend the infrastructure, security, identity, monitoring, and automation concepts established in the homelab into cloud-native environments.

Primary areas include:

- **Microsoft Azure administration**
- **Microsoft Entra ID**
- **Cloud IAM and RBAC**
- **Virtual Networks**
- **Cloud security controls**
- **Monitoring and governance**
- **Hybrid identity**
- **Infrastructure as Code**
- **Cloud automation**

Many existing concepts map naturally into cloud environments:

| On-Premises Concept | Cloud Equivalent |
|---|---|
| Network segmentation | Virtual Networks and subnets |
| Firewall policy | Network Security Groups and cloud firewall controls |
| Active Directory / RBAC | Entra ID and Azure RBAC |
| Infrastructure monitoring | Azure Monitor and Log Analytics |
| Centralized logging | Cloud-native logging and SIEM integration |
| Automation | Infrastructure as Code and cloud automation |

The existing homelab provides the underlying mental model for implementing these concepts within Azure.

### Monitoring & Observability

Monitoring and observability are supporting capabilities that span the entire environment.

Current work includes:

- Availability and synthetic service monitoring with Uptime Kuma
- Metrics collection with Prometheus
- Visualization with Grafana
- Centralized logging with Loki
- Telemetry and log collection with Grafana Alloy
- Alert management with Alertmanager
- Linux host monitoring
- Service and endpoint monitoring

Monitoring coverage will continue expanding across:

- Physical and virtual infrastructure
- Linux systems
- Containers
- Network devices
- DNS infrastructure
- Infrastructure services
- Applications and endpoints
- Logs and alerts

The objective is to develop operational visibility alongside the systems being deployed rather than treating monitoring as an afterthought.

### Automation

Automation is intended to progressively reduce repetitive administration and improve consistency across the environment.

Current and future tooling includes:

- **PowerShell**
- **Python**
- **Bash**
- **Ansible**
- **Terraform**
- **GitHub Actions**
- **Infrastructure as Code**

Automation will be introduced where it provides meaningful operational value, particularly for repeatable deployment, configuration, validation, administration, and documentation workflows.

The goal is not to automate every task simply because automation is possible. Manual deployment remains valuable when learning a technology for the first time, while repeatable processes become candidates for automation as the environment matures.

### Security Operations

Security capabilities will expand beyond preventive infrastructure controls into monitoring, detection, vulnerability management, and response.

Current security controls include:

- Perimeter firewalling
- WireGuard remote access
- Wireless isolation
- Active Directory security controls
- DNS filtering
- Encrypted upstream DNS
- Infrastructure monitoring
- Centralized logging capabilities

Future development will include:

- Security monitoring
- Vulnerability management
- Detection engineering
- Centralized security event analysis
- IDS/IPS
- Incident response workflows
- Security hardening
- Recovery validation

This allows the homelab to demonstrate both preventive infrastructure security and operational security practices.

## Lower Priority — Deep Cisco IOS

Deep Cisco IOS administration is explicitly **not** a current priority given the security, identity, cloud, and infrastructure direction.

The managed switch provides the Layer 2 capabilities required by the environment and will support VLANs, trunking, and access ports as network segmentation is introduced.

Topics such as:

- Routing protocols
- Advanced Layer 3 switching
- Complex ACL design
- Advanced spanning-tree tuning

remain primarily conceptual unless deeper implementation becomes useful to another homelab objective.

The hardware remains available for additional experimentation if network engineering becomes more relevant later.

The objective is to understand the networking concepts required to build, operate, and secure infrastructure without turning the homelab into a dedicated networking certification lab.

## Direction Summary

| Area | Direction | Current State |
|---|---|---|
| Infrastructure | Reliable compute, storage, networking, and core services | **Operational / Expanding** |
| Network Security | Firewalling, remote access, DNS security, segmentation | **Operational / Expanding** |
| Identity | Active Directory, Group Policy, Entra ID | **Operational / Expanding** |
| Monitoring & Observability | Availability, metrics, logging, visualization, alerting | **Operational / Expanding** |
| Automation | Scripting, configuration management, IaC | **Developing** |
| Security Operations | Detection, vulnerability management, response | **Developing** |
| Cloud | Azure, Entra ID, RBAC, hybrid infrastructure | **Planned** |
| Deep Networking | Advanced Cisco IOS and Layer 3 networking | **Lower Priority** |

## Summary

The direction of the homelab is straightforward: **build reliable infrastructure, secure it, establish identity as a central control plane, improve operational visibility and automation, and extend those concepts into cloud environments.**

Networking provides the foundation but is not the end goal. Monitoring, automation, security, and documentation mature alongside the infrastructure, while identity and cloud capabilities provide the longer-term direction.

Detailed implementation sequencing and progress are maintained in the [Homelab Roadmap](roadmap.md), allowing this document to remain focused on **why the environment is being built and where it is going**.
