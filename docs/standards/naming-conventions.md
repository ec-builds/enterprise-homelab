# Naming Conventions & Sanitization Guidelines

## Purpose

This repository is intended for public documentation and portfolio purposes. To protect the security and privacy of the homelab environment, certain infrastructure details are intentionally sanitized.

Examples include:

- Hostnames
- IP addresses
- Domain names
- Usernames
- Network share names
- VPN endpoints
- Internal DNS records
- Storage paths

The goal is to accurately document architecture, processes, and technical concepts without exposing operational details from the live environment.

---

## Hostname Sanitization

Documentation uses generic hostnames that represent system roles rather than actual production hostnames.

### Current Naming Map

| Documentation Name | System Role |
|----------|----------|
| media-server-lab | Media Services Platform host |
| nas-lab | Network Attached Storage (NAS) platform |
| proxmox-lab | Future virtualization host |
| ad-lab | Active Directory lab environment |
| m365-lab | Microsoft 365 & Entra ID lab environment |
| monitoring-lab | Monitoring and observability platform |
| automation-lab | Automation and infrastructure tooling |

---

## Network Information

Network information shown in documentation may be modified from the live environment.

Examples include:

- RFC 5737 documentation IP ranges
- Simplified network diagrams
- Generic VLAN identifiers
- Example DNS records

This ensures diagrams remain educational while protecting operational details.

---

## Storage Naming

Storage systems are documented using descriptive role-based names.

### Current Naming Map

| Documentation Name | Purpose |
|----------|----------|
| nas-lab | Primary NAS platform |
| media-share | Media content storage |
| backup-share | Backup storage location |
| archive-share | Long-term archival storage |

---

## Diagram Standards

Architecture diagrams should use sanitized names that describe system function rather than specific implementation details.

### Preferred

```text
proxmox-lab
media-server-lab
nas-lab
monitoring-lab
```

### Avoid

```text
actual-hostname
actual-domain-name
actual-ip-address
```

---

## Documentation Philosophy

This repository focuses on demonstrating:

- Systems administration skills
- Infrastructure design
- Networking concepts
- Automation workflows
- Security practices
- Technical documentation

Specific operational details are intentionally abstracted where appropriate to maintain security while preserving technical accuracy.

---

## Review Checklist

Before publishing documentation, verify that the following have been removed or sanitized:

- Real hostnames
- Real usernames
- Public IP addresses
- Internal IP addresses
- Domain names
- API keys
- Access tokens
- VPN endpoints
- Authentication secrets

When in doubt, replace environment-specific information with a descriptive role-based name.

---

## Related Documentation

- [Equipment Inventory](../../equipment/README.md)
- [Network Infrastructure](../../projects/network-infrastructure/)
- [Virtualization Lab](../../projects/virtualization-lab/)
