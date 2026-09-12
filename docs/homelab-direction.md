# 🧭 Homelab Direction

## Overview

This document defines the strategic direction of the homelab: what it is being built to demonstrate, the order in which capabilities are developed, and the reasoning behind that sequence. It exists to keep build effort aligned with a clear goal rather than accumulating technology for its own sake.

## Goal

The homelab is oriented toward **security, identity, and cloud technologies**, in support of **remote or hybrid roles**. Deep network engineering (Cisco IOS mastery, routing protocols, CCNA-depth switching) is intentionally **not** a primary objective.

This focus shapes the sequencing decisions below. Security, identity, and cloud technologies form the primary direction of the homelab because they align most closely with my long-term career goals.

## Guiding Principle

Build a strong **network-security and infrastructure foundation**, develop **identity** alongside it, and then extend those concepts into the **cloud**.

The phases provide direction rather than strict boundaries. Some identity, monitoring, automation, and security work develops in parallel as the infrastructure matures.

Each area reinforces concepts reused by the next:

- On-prem firewall and segmentation concepts transfer to cloud security groups, network ACLs, and virtual networks.
- Identity concepts such as AD, Entra ID, RBAC, and least privilege underpin both on-prem security and cloud IAM.
- Monitoring and logging provide visibility across infrastructure, identity, and security systems.
- Automation makes the environment more repeatable as the number of systems and services increases.
- Cloud platforms reimplement many of the same segmentation, identity, access-control, and monitoring concepts using cloud-native services.

The Cisco switch is plumbing, not the point. Its job is primarily Layer 2 connectivity and segmentation — enabling secure networking for everything above it. Deep IOS work is deferred because it points toward a networking specialization this lab is not currently pursuing.

## Sequencing

### Phase 1 — Network-Security Foundation (OPNsense)

The network-security foundation provides the control plane for segmentation, routing, filtering, remote access, and network visibility.

Current direction:

- Migrate routing and firewall services from the existing SOHO router to **OPNsense**, providing edge routing, firewalling, NAT, DHCP, and VPN services.
- Keep the Cisco switch primarily at **Layer 2**, using VLANs, trunks, and access ports without making deep IOS administration a primary objective.
- Develop **segmentation, firewall policy, WireGuard VPN, IDS/IPS, and centralized logging**.
- Integrate network infrastructure with the broader monitoring environment.

Inter-VLAN routing and firewall policy are handled by OPNsense using a router-on-a-stick design so that traffic crossing security boundaries passes through a centralized, stateful, logged, and inspectable control point.

This keeps security policy concentrated at the firewall while allowing the switching layer to remain comparatively simple.

### Phase 2 — Identity (Active Directory / Entra ID)

Identity development has begun alongside the network-security foundation rather than waiting for every networking component to be completed.

The on-premises Active Directory environment establishes the foundation for:

- **Active Directory Domain Services**
- **DNS**
- **Group Policy**
- **Users, groups, and organizational structure**
- **Role-based access concepts**
- **Windows client domain integration**
- **Identity administration and troubleshooting**

The next stage extends these concepts into **Microsoft 365 and Entra ID**, including:

- Cloud identity
- SSO
- RBAC
- Conditional Access
- Identity security
- Hybrid identity concepts

Identity and access management is foundational to modern infrastructure and cloud security, making this a natural bridge between the on-premises lab and future cloud work.

### Phase 3 — Cloud (Azure)

Cloud development extends the infrastructure, security, and identity concepts established in the earlier phases into cloud-native environments.

Primary areas include:

- **Azure Administration**
- **Entra ID**
- **Cloud IAM and RBAC**
- **Virtual Networks**
- **Cloud security controls**
- **Monitoring and governance**
- **Hybrid identity and infrastructure concepts**

Many existing concepts map naturally into cloud environments:

| On-Premises Concept | Cloud Equivalent |
|---|---|
| Network segmentation | Virtual Networks and subnets |
| Firewall policy | Network Security Groups and cloud firewall controls |
| Active Directory / RBAC | Entra ID and Azure RBAC |
| Infrastructure monitoring | Azure Monitor and Log Analytics |
| Centralized logging | Cloud-native logging and SIEM integration |
| Automation | Infrastructure as Code and cloud automation |

The earlier phases establish the mental model. This phase develops direct experience implementing those concepts within Azure.

### Supporting Track — Monitoring & Automation

Monitoring and automation develop alongside the primary security, identity, and cloud phases rather than existing as a separate end goal.

The monitoring environment provides visibility into:

- Physical and virtual infrastructure
- Linux systems
- Containers
- Network devices
- Services and endpoints
- Logs and alerts

Automation will progressively reduce repetitive administration and improve deployment consistency through technologies such as **PowerShell, Python, Ansible, and Infrastructure as Code**.

These capabilities support every major phase of the homelab.

### Deferred — Cisco IOS (Concept-Level for Now)

Deep Cisco IOS administration is explicitly **not** a current priority given the security, identity, and cloud direction.

- The switch performs its required **Layer 2** role using VLANs, trunking, and access ports.
- Deep IOS topics such as routing protocols, Layer 3 switching, advanced ACL design, and spanning-tree tuning are learned primarily at the conceptual level.
- The hardware remains available for deeper experimentation if networking becomes more relevant later.

The objective is to understand the networking concepts required to design and secure infrastructure without turning the homelab into a dedicated network-engineering lab.

## Summary

| Phase | Focus | Primary Tools | Status |
|---|---|---|---|
| 1 | Network Security | OPNsense, WireGuard, Suricata, Cisco Layer 2 switching | **Active** |
| 2 | Identity | Active Directory, Group Policy, Entra ID | **Active / Expanding** |
| 3 | Cloud | Azure, Entra ID, Azure RBAC, cloud networking | **Planned** |
| Supporting | Monitoring & Automation | Grafana, Prometheus, Loki, PowerShell, Python, Ansible | **Developing** |
| Deferred | Deep Networking | Cisco IOS, Layer 3 switching, routing protocols | **Concept-Level** |

The through-line remains straightforward: build and secure the infrastructure, establish identity as a central control plane, and extend those concepts into cloud environments.

Networking provides the foundation, while monitoring and automation mature alongside the environment. This keeps the homelab aligned with the larger objective of developing practical experience in **security, identity, cloud, and modern infrastructure engineering**.
