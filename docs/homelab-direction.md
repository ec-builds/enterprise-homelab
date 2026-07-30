# Homelab Direction

## Overview

This document defines the strategic direction of the homelab: what it is being built to demonstrate, the order in which capabilities are developed, and the reasoning behind that sequence. It exists to keep build effort aligned with a clear goal rather than accumulating technology for its own sake.


## Goal

The homelab is oriented toward **security, identity, and cloud technologies**, in support of **remote or hybrid roles**. Deep network engineering (Cisco IOS mastery, routing protocols, CCNA-depth switching) is intentionally **not** a primary objective.

This focus shapes every sequencing decision below. Security, identity, and cloud technologies form the primary focus of this homelab because they align most closely with my long-term career goals.


## Guiding Principle

Build the **network-security foundation first**, then layer **identity** and **cloud** on top of it. Each phase builds the mental model the next phase reuses:

- On-prem firewall and segmentation concepts transfer directly to cloud security groups, network ACLs, and virtual networks.
- Identity concepts (AD, Entra ID, RBAC) underpin both on-prem security and cloud IAM.
- Cloud reimplements the same segmentation, identity, and filtering concepts in cloud-native form.

The Cisco switch is plumbing, not the point. Its job is Layer 2 connectivity and segmentation — enabling secure networking for everything above it. Deep IOS work is deferred; it points toward a networking track this lab isn't pursuing.


## Sequencing

### Phase 1 — Network-Security Foundation (OPNsense)

The core infrastructure everything else sits on.

- Migrate routing and firewall services from the existing SOHO router to **OPNsense**, providing edge routing, firewalling, NAT, DHCP, and VPN services.
- Cisco switch remains **Layer 2** — minimal VLAN and trunking configuration only, not deep IOS.
- Capabilities to build: **segmentation (VLANs), firewall rules, WireGuard VPN, IDS/IPS (Suricata), logging.**

Inter-VLAN routing and firewall policy are handled at OPNsense (router-on-a-stick) so that all traffic crossing between segments passes through a single, stateful, logged, inspectable control point. This keeps security policy in one place and provides the visibility that the lab is meant to demonstrate.

### Phase 2 — Identity (Active Directory / Entra ID)

A distinct skill set OPNsense does not cover, central to both security and remote-friendly roles.

- **Active Directory Lab** — AD DS, DNS, Group Policy, RBAC.
- **Microsoft 365 & Entra ID** — cloud identity, SSO, hybrid identity, Conditional Access.
- Identity and access management (IAM) is foundational to cloud security, making this a natural bridge between the security foundation and the cloud phase.

### Phase 3 — Cloud (Azure)

Where on-prem concepts reimplement as cloud-native.

- **Azure Administration** — cloud infrastructure, RBAC, governance.
- On-prem concepts map directly to cloud equivalents:
  - Firewall / segmentation → **Security Groups, Network ACLs, Virtual Networks**
  - Directory / RBAC → **Cloud IAM**
- This phase focuses on developing hands-on Azure administration and cloud security experience. The earlier phases build the mental model; this phase builds direct cloud experience.

### Deferred — Cisco IOS (Concept-Level for Now)

Explicitly **not** a current priority, given the security/cloud direction.

- The switch performs its minimal **Layer 2** role (VLANs, trunking, access ports) — enough to enable the Phase 1 segmentation, no more.
- Deep IOS (routing protocols, inter-VLAN routing on the switch, ACL mastery, spanning-tree tuning) is learned **by concept** for now rather than through extensive lab work.
- The hardware remains in the rack and available. Nothing is lost by deferring: the concepts are already documented in networking study notes, and hands-on IOS work can be picked up later if a networking direction ever becomes relevant.


## Summary

| Phase | Focus | Primary Tools | Priority |
|-------|-------|---------------|----------|
| 1 | Network Security | OPNsense (firewall, VPN, IDS/IPS), Cisco switch (Layer 2) | Now |
| 2 | Identity | Active Directory, Entra ID | Next |
| 3 | Cloud | Azure, Entra ID, Cloud IAM | After Identity |
| — | Deep Networking (Cisco IOS) | Catalyst switch (Layer 3, routing, ACLs) | Deferred / Concept-Level |

The through-line is straightforward: build the security foundation, extend into identity, then cloud — each phase reinforcing the next. Networking infrastructure enables that foundation without becoming the primary focus, keeping the homelab aligned with my long-term goals in security, identity, and cloud engineering.
