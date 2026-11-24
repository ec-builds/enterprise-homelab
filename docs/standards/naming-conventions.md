# Naming Conventions & Sanitization Guidelines

**Status: 🟢 Operational**

## Overview

This document defines the placeholder names, domains, and addresses used in the public EC-Builds repository. Documentation should accurately represent the environment without exposing operational details from the live homelab.

File naming rules are in [Documentation Standards](./documentation-standards.md#file-naming).

## Sanitization Requirements

Before publishing, remove or replace:

- Hostnames
- Usernames
- IP addresses
- Internal domain names and DNS records
- Network share names and storage paths
- VPN endpoints
- API keys, tokens, passwords, and other credentials
- Other environment-specific identifiers

Replace operational values with the placeholders below. Placeholders are fixed and reused across documents, so the same system has the same name everywhere.

## Hostnames

Use the pattern:

```text
<role>-lab-NN
```

- `<role>` is a short, lowercase description of the system's function.
- `NN` is a two-digit instance number. Use it when more than one instance exists or is planned.
- A single-instance system may use `<role>-lab` without a number.

| Placeholder | System Role |
|---|---|
| `dc-lab-01`, `dc-lab-02` | Active Directory domain controllers |
| `prox-lab-01`, `prox-lab-02`, `prox-lab-03` | Proxmox VE hosts |
| `adguard-lab-01`, `adguard-lab-02` | AdGuard Home DNS filtering |
| `docker-lab-01` | Docker host VM |
| `monitor-lab-01` | Monitoring and observability platform |
| `monitor-lab-02` | Secondary monitoring host (standalone, outside the Proxmox cluster) |
| `media-lab-01` | Media services VM |
| `win11-lab-01`, `win11-lab-02` | Windows 11 endpoint test VMs |
| `security-lab-01`, `utility-lab-01` | Planned security and utility VMs |
| `nas-lab` | Network-attached storage |
| `m365-lab` | Microsoft 365 and Entra ID lab |
| `automation-lab` | Automation and infrastructure tooling |

Add new roles to this table when they first appear in documentation.

## Domains

| Placeholder | Use |
|---|---|
| `lab.example.com` | Active Directory forest, domain, and internal DNS namespace |
| `LAB` | NetBIOS domain name |
| `example.com` | Any other internal or example domain |

`example.com` is reserved for documentation and never resolves to a real service.

Never publish the live internal domain. Public domains that are public by design, such as `ec-builds.com` for the site and GitHub, may be used where they refer to those public services.

## IP Addressing

Documentation uses a fixed placeholder scheme in `10.0.0.0/8`:

| Placeholder | Use |
|---|---|
| `10.0.0.0/24` | Primary LAN |
| `10.0.<VLAN ID>.0/24` | Additional VLANs, for example `10.0.20.0/24` for VLAN 20 |
| `10.0.20.0/24` | Household network (trusted clients) |
| `10.0.100.0/24` | WireGuard VPN tunnel (not a VLAN) |
| `.1` | Default gateway |
| `.10`, `.11` | Domain controllers (`dc-lab-01`, `dc-lab-02`) |
| `.100`–`.199` | DHCP range |

Other statically addressed infrastructure uses addresses outside the DHCP range.

Rules:

- Never publish live addresses, even partially.
- The placeholder scheme must not overlap the live network. If the live addressing changes to overlap it, change the placeholder scheme.
- Replace public, WAN, and VPN endpoint addresses with `<public-ip>`.

## Storage

| Placeholder | Purpose |
|---|---|
| `nas-lab` | Primary NAS platform |
| `media-share` | Media storage |
| `backup-share` | Backup storage |
| `archive-share` | Archival storage |

## Accounts and Credentials

- Replace real usernames with role-based names, for example `lab-admin`.
- Never publish passwords, DSRM passwords, shared secrets, API keys, or tokens. Note where they are stored instead, for example "stored securely outside the repository".

## Diagrams and Screenshots

- Diagrams use the placeholder names and addresses above.
- Crop or blur screenshots that show live hostnames, addresses, domains, usernames, or serial numbers.

## Review Checklist

Before publishing:

- [ ] Hostnames use the `<role>-lab-NN` placeholders
- [ ] Domains use `lab.example.com` or `example.com`
- [ ] Addresses use the placeholder scheme; no live addresses appear
- [ ] Usernames are role-based
- [ ] Network shares and storage paths use the storage placeholders
- [ ] VPN and public endpoints are replaced with `<public-ip>`
- [ ] Credentials, API keys, tokens, and secrets are removed
- [ ] Diagrams and screenshots contain no operational identifiers

## Related Documentation

- [Documentation Standards](./documentation-standards.md)
