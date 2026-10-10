# 🔐 Network Security

**Status: 🟢 Operational**

A hands-on network security lab focused on implementing and documenting layered security controls across the enterprise homelab.

The current environment uses perimeter firewalling, encrypted remote access, DNS filtering, wireless isolation, managed switching, and hardened administrative access. Additional segmentation and security controls are planned as the environment evolves.

## Overview

The ASUS RT-AX5400 currently provides the primary Internet security boundary, including stateful firewalling, NAT, WireGuard VPN, and wireless security.

A Cisco managed switch provides centralized wired connectivity. The current wired environment operates as a flat Layer 2 network using VLAN 1, while guest and IoT wireless devices are isolated from trusted internal systems.

```text
                           Internet
                              │
                              ▼
                       ASUS RT-AX5400
                    Firewall / NAT / VPN
                              │
               ┌──────────────┴──────────────┐
               │                             │
               ▼                             ▼
        Trusted Network                Guest / IoT
               │                        Wireless
               ▼                             │
      Cisco Managed Switch                   ▼
               │                       Internet Access
               ▼
             VLAN 1
               │
       Trusted Wired Systems
```

See [Network Security Architecture](./architecture.md) for the detailed security boundaries, trust model, current limitations, and planned segmented architecture.

## Current Security Controls

| Security Area | Implementation | Status |
|---|---|:---:|
| Perimeter Firewall | ASUS stateful firewall | 🟢 |
| Network Address Translation | ASUS NAT | 🟢 |
| Remote Access | WireGuard VPN | 🟢 |
| DNS Filtering | Redundant AdGuard Home | 🟢 |
| Upstream DNS Encryption | DNS-over-HTTPS | 🟢 |
| Guest / IoT Isolation | Isolated wireless environment | 🟢 |
| Managed Switching | Cisco Catalyst managed switch | 🟢 |
| SSH Hardening | Key-based access where implemented | 🟡 |
| Wired Segmentation | Flat VLAN 1 network | 🟡 |
| Dedicated Firewall | OPNsense | ⚪ Planned |
| VLAN Security Zones | Management, server, trusted, IoT, and guest | ⚪ Planned |
| IDS / IPS | Future implementation | ⚪ Planned |
| Centralized Security Logging | Future implementation | ⚪ Planned |

## Security Controls

### Perimeter Security

The ASUS gateway provides the current security boundary between the Internet and internal network.

Stateful firewalling and NAT protect internal systems from unsolicited inbound connections, while unnecessary direct exposure of internal services is avoided.

### Remote Access

WireGuard provides encrypted remote access to trusted internal resources.

Remote administration is performed through the VPN rather than exposing individual management interfaces directly to the Internet.

### DNS Security

Active Directory DNS provides internal domain resolution while redundant AdGuard Home instances provide external DNS filtering.

```text
Internal Clients
      ↓
Active Directory DNS
      ↓
Redundant AdGuard Home
      ↓
DNS-over-HTTPS
      ↓
Public DNS Resolvers
```

This separates internal DNS authority from external filtering and encrypts upstream DNS traffic.

Detailed DNS implementation is maintained in the Network Infrastructure project.

### Wireless Security

Trusted wireless devices connect to the internal network.

Guest and IoT devices use an isolated guest wireless environment that restricts access to trusted internal resources.

### Wired Network Security

The current wired network operates as a flat Layer 2 environment using VLAN 1.

Servers, hypervisors, storage, infrastructure management systems, and other trusted wired devices currently share this network.

This is a known security limitation. VLAN-based segmentation is planned to establish separate security zones and allow firewall policy to control communication between them.

### Administrative Access

SSH key-based authentication is used where implemented to reduce reliance on password-based administrative access.

Broader SSH hardening remains in progress and is not represented as universally deployed across the environment.

## Security Design Goals

The network security environment is designed around:

- Minimizing direct Internet exposure
- Using encrypted VPN access for remote administration
- Filtering external DNS requests
- Encrypting upstream DNS traffic
- Isolating guest and IoT wireless devices
- Hardening administrative access
- Documenting known security limitations
- Validating security controls before considering them operational
- Moving toward explicit network trust zones and least-privilege communication

## Documentation

| Document | Focus |
|---|---|
| [Architecture](./architecture.md) | Security boundaries, trust model, current limitations, and target architecture |
| [Perimeter Firewall](./firewall.md) | Internet-facing firewall and exposure controls |
| [WireGuard VPN](./wireguard-vpn.md) | Encrypted remote-access implementation |
| [Wireless Security](./wireless-security.md) | Trusted and guest/IoT wireless controls |
| [SSH Hardening](./ssh-hardening.md) | Administrative-access hardening |
| [Lessons Learned](./lessons-learned.md) | Security implementation and troubleshooting findings |

## Current Limitations

The current environment intentionally documents several security gaps that will be addressed during later implementation phases:

- Wired infrastructure remains on VLAN 1.
- Management systems are not isolated on a dedicated management network.
- Servers and trusted endpoints do not yet have separate security zones.
- Inter-network traffic is not governed by dedicated zone-based firewall policies.
- OPNsense has not yet replaced the current gateway.
- IDS/IPS has not yet been deployed.
- Centralized network-security logging remains planned.
- SSH hardening is not yet universally deployed.

## Planned Improvements

The next major security phase will introduce a dedicated OPNsense firewall and VLAN-based network segmentation.

Planned improvements include:

1. Deploy OPNsense as the primary gateway and firewall
2. Create management, server, trusted, IoT, and guest security zones
3. Configure VLAN trunking through the managed switch
4. Apply controlled inter-VLAN firewall policies
5. Isolate infrastructure management interfaces
6. Migrate remote-access VPN services to the dedicated firewall
7. Expand centralized security logging
8. Evaluate IDS/IPS capabilities

These controls remain planned and will be documented as operational only after implementation and validation.

## Related Projects

Network security controls build on and protect the broader enterprise homelab environment, including:

- Network infrastructure
- Proxmox virtualization
- Active Directory
- Microsoft Entra ID and Intune
- Infrastructure monitoring
- Docker and self-hosted services
- Backup and disaster recovery