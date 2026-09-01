# Naming Conventions & Sanitization Guidelines

**Status: 🟢 Operational**

## Purpose

This document defines naming and sanitization conventions for the public EC-Builds repository.

Documentation should accurately represent the environment without exposing operational details from the live homelab.

## Sanitization Requirements

Before publishing, remove or sanitize:

- Hostnames
- Usernames
- IP addresses
- Domain names
- Network share names
- VPN endpoints
- Internal DNS records
- Storage paths
- API keys and tokens
- Passwords and credentials
- Other environment-specific identifiers

When in doubt, replace operational information with a descriptive role-based name or documentation-safe example.

## Documentation Naming

Use generic names that describe system roles rather than actual hostnames or infrastructure identifiers.

### Hostname Map

| Documentation Name | System Role |
|---|---|
| `media-server-lab` | Media services host |
| `nas-lab` | Network attached storage |
| `proxmox-lab` | Proxmox virtualization host |
| `docker-lab` | Docker host VM |
| `ad-lab` | Active Directory lab |
| `m365-lab` | Microsoft 365 and Entra ID lab |
| `monitoring-lab` | Monitoring and observability platform |
| `automation-lab` | Automation and infrastructure tooling |

### Storage Map

| Documentation Name | Purpose |
|---|---|
| `nas-lab` | Primary NAS platform |
| `media-share` | Media storage |
| `backup-share` | Backup storage |
| `archive-share` | Archival storage |

## Network and Diagram Examples

Network information and diagrams should use sanitized values while preserving the technical design.

Use:

- RFC 5737 documentation IP ranges
- Generic VLAN identifiers
- Example DNS records
- Role-based hostnames
- Simplified network diagrams where appropriate

Example:

```text
proxmox-lab
media-server-lab
nas-lab
monitoring-lab
```

Avoid:

```text
actual-hostname
actual-domain-name
actual-ip-address
```

## Review Checklist

Before publishing:

- [ ] Hostnames are sanitized
- [ ] Usernames are sanitized
- [ ] IP addresses and domains are sanitized
- [ ] Network shares and storage paths are sanitized
- [ ] VPN and DNS information is sanitized
- [ ] Credentials, API keys, tokens, and secrets are removed
- [ ] Diagrams and screenshots contain no operational identifiers

## Related Documentation

- [Documentation Standards](./documentation-standards.md)
- [Equipment Inventory](../../equipment/README.md)
- [Network Infrastructure](../../projects/network-infrastructure/)
- [Virtualization Lab](../../projects/virtualization-lab/)
