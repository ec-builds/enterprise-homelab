# Homelab Decisions

This document records major architectural, operational, and strategic decisions made throughout the lifecycle of the homelab.

The goal is to document **why** decisions were made so future changes can be evaluated against previous assumptions and requirements.

> [!NOTE]
> If this document becomes difficult to navigate, consider moving individual decisions into a dedicated `docs/decisions/` directory and retaining this file as a high-level index.

## Decision Log

| Date | Decision | Status |
|------|----------|--------|
| 2026-06-13 | GitHub becomes documentation source of truth | Active |
| 2026-07-30 | OPNsense as primary firewall; Cisco switch remains Layer 2 | Active |
| 2026-07-30 | Prioritize security, identity, and cloud over deep networking | Active |

## 2026-06-13 — GitHub Becomes Documentation Source of Truth

### Status
Active

### Context
Network and homelab documentation was originally maintained in Obsidian. As project documentation matured and multiple projects were created, maintaining documentation in both Obsidian and GitHub introduced duplicated effort and increased the risk of documentation drift.

### Decision
GitHub repositories will serve as the authoritative source of documentation for the homelab.

### Alternatives Considered
- Continue using Obsidian as the primary documentation platform.
- Maintain both Obsidian and GitHub documentation.
- Move entirely to GitHub documentation.

### Rationale
- Eliminates duplicate documentation maintenance.
- Provides version control for all documentation changes.
- Keeps documentation close to the infrastructure it describes.
- Enables documentation review through Git history.
- Creates a public portfolio demonstrating technical documentation practices.
- Simplifies disaster recovery and backup procedures.

### Consequences

#### Positive
- Single source of truth.
- Better organization and discoverability.
- Documentation evolves alongside projects.
- Historical change tracking through Git.

#### Negative
- Less flexibility for quick note-taking.
- Draft ideas may require additional organization before publication.

### Implementation

#### GitHub
Used for:
- Project documentation
- Architecture diagrams
- Build guides
- Runbooks
- IP addressing plans
- Device inventories
- Lessons learned
- Screenshots
- Configuration examples

#### Vaultwarden
Used for:
- Passwords
- API keys
- Recovery codes
- Sensitive configuration values
- Network secrets

#### Temporary Notes
May be stored elsewhere until mature enough for inclusion in GitHub documentation.

### Related Projects
- network-infrastructure
- virtualization-lab
- media-services-platform
- network-security
- infrastructure-monitoring

## 2026-07-30 — OPNsense as Primary Firewall; Cisco Switch Remains Layer 2

### Status
Active

### Context
The homelab currently uses a SOHO router (ASUS RT-AX5400) for routing, firewalling, and VPN. The environment also includes a Layer 3-capable Cisco Catalyst switch. As segmentation and security became priorities, a decision was needed on where routing, inter-VLAN routing, and firewall policy should live: on the L3 switch, on a dedicated firewall, or split between them.

### Decision
OPNsense will serve as the primary router and firewall. Inter-VLAN routing and firewall policy will be handled at OPNsense (router-on-a-stick). The Cisco switch will remain Layer 2, providing VLANs, trunking, and access ports only.

### Alternatives Considered
- Use the Cisco L3 switch for inter-VLAN routing with ACLs for policy.
- Split routing across both devices (switch for some VLANs, OPNsense for others).
- Retain the SOHO router as the primary firewall.

### Rationale
- Routing a traffic path and enforcing its rules must live on the same device; splitting them across the switch and OPNsense risks silent drops, return-path asymmetry, and gaps in policy.
- OPNsense provides **stateful** firewalling, which cleanly expresses directional rules (trusted VLANs may initiate outward; untrusted VLANs cannot initiate inward). Switch ACLs are stateless and handle this poorly.
- Centralizing inter-VLAN traffic at OPNsense forces all cross-segment traffic through a single, logged, inspectable control point (IDS/IPS via Suricata).
- Keeps all security policy in one place — a single source of truth — rather than split between switch ACLs and firewall rules.
- Inter-VLAN traffic volume at homelab scale does not justify the switch's hardware-routing performance advantage.

### Consequences

#### Positive
- Stateful, logged, inspectable control over all inter-VLAN traffic.
- Security policy centralized on one device.
- Directional segmentation (trusted vs. untrusted) is straightforward to enforce.
- Matches the security-focused direction of the lab.

#### Negative
- Inter-VLAN traffic hairpins through OPNsense rather than routing at wire speed on the switch (negligible at current scale).
- Defers hands-on experience with Cisco L3 routing and ACLs.

### Implementation
- OPNsense configured as the gateway for all VLANs, with firewall rules governing inter-VLAN and internet-bound traffic.
- Cisco switch configured for VLANs, 802.1Q trunking to OPNsense, and access-port VLAN assignment.
- SOHO router (ASUS) to be repurposed as a wireless access point once OPNsense assumes routing/firewall duties.

### Related Projects
- network-infrastructure
- network-security

## 2026-07-30 — Prioritize Security, Identity, and Cloud Over Deep Networking

### Status
Active

### Context
The homelab has finite build time, and multiple directions were possible — deep Cisco IOS / networking mastery, or a security-, identity-, and cloud-focused path. A clear prioritization was needed to keep effort aligned with long-term goals rather than spread across every available technology.

### Decision
The homelab prioritizes security, identity, and cloud technologies, sequenced as: network-security foundation (OPNsense) → identity (Active Directory / Entra ID) → cloud (Azure). Deep Cisco IOS work is deferred and learned at concept level for now.

See the full reasoning and phase breakdown in `docs/homelab-direction.md`.

### Alternatives Considered
- Invest first in deep Cisco IOS / CCNA-depth networking using the Catalyst switch.
- Pursue all directions in parallel without a defined sequence.

### Rationale
- Security, identity, and cloud technologies align most closely with long-term career goals and remote/hybrid-friendly roles.
- Each phase builds the mental model the next reuses: on-prem firewall/segmentation concepts transfer to cloud; identity underpins cloud IAM.
- Deep networking serves a career direction the lab is not targeting; the Cisco switch functions as foundational infrastructure rather than a learning centerpiece.
- Concentrating effort produces demonstrable depth in the target areas rather than shallow breadth across all.

### Consequences

#### Positive
- Build effort stays aligned with a defined career direction.
- Skills compound across phases (security → identity → cloud).
- Repository tells a coherent, intentional story rather than a tool collection.

#### Negative
- Hands-on Cisco IOS / networking depth is deferred.
- Requires discipline to avoid scope creep into unrelated technologies.

### Related Projects
- network-security
- active-directory-lab
- microsoft-365-entra-id
- azure-administration-lab

## Decision Template

See:
- `templates/homelab-decision-template.md`
