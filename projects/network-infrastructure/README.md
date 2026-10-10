# 🌐 Network Infrastructure

**Status: 🟢 Operational**

A hands-on network infrastructure lab focused on building and documenting reliable core network services for the enterprise homelab.

The environment includes managed switching, centralized DHCP, Active Directory-integrated DNS, redundant DNS filtering, wireless networking, remote access, and service redundancy across the Proxmox virtualization environment.

## Overview

The network provides connectivity and core services for the wider homelab environment.

The current design uses an ASUS RT-AX5400 as the Internet gateway, a Cisco managed switch for centralized wired connectivity, Windows Server for DHCP and internal DNS, and redundant AdGuard Home instances for external DNS filtering.

```text
                         Internet
                            │
                            ▼
                     ASUS RT-AX5400
                Routing / Firewall / NAT
                  WireGuard / Wireless
                            │
                            ▼
                  Cisco Managed Switch
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
      Proxmox VE        Synology NAS     Wired Systems
       Cluster
          │
          ├─────────────┬─────────────┐
          │             │             │
          ▼             ▼             ▼
     AD / DNS / DHCP  AdGuard Home  Lab Services
```

See [Architecture](./architecture.md) for the detailed network design, service relationships, redundancy, and planned segmentation architecture.

## Current Environment

| Component | Implementation | Status |
|---|---|:---:|
| Internet Gateway | ASUS RT-AX5400 | 🟢 |
| Managed Switching | Cisco Catalyst managed switch | 🟢 |
| Wired Network | Flat Layer 2 network using VLAN 1 | 🟢 |
| DHCP | Redundant Windows Server DHCP | 🟢 |
| Internal DNS | Active Directory-integrated DNS | 🟢 |
| DNS Filtering | Redundant AdGuard Home | 🟢 |
| Upstream DNS Security | DNS-over-HTTPS | 🟢 |
| Wireless | Trusted and isolated guest/IoT wireless | 🟢 |
| Remote Access | WireGuard VPN | 🟢 |
| Network Storage | Synology NAS | 🟢 |
| Infrastructure Monitoring | Uptime Kuma and monitoring stack | 🟢 |
| Dedicated Firewall | OPNsense | ⚪ Planned |
| VLAN Segmentation | Management, server, trusted, IoT, and guest zones | ⚪ Planned |

## Core Network Services

### DHCP

DHCP is provided by two Windows Server systems configured with a failover relationship.

The servers centrally provide client addressing, gateway configuration, internal DNS configuration, and domain information.

DHCP failover has been tested to confirm that address assignment remains available when either individual DHCP server is unavailable.

### DNS

Active Directory DNS remains authoritative for internal domain resolution and service discovery.

External DNS queries follow this path:

```text
Clients
   ↓
Active Directory DNS
   ↓
Redundant AdGuard Home
   ↓
DNS-over-HTTPS
   ↓
Public DNS Resolvers
```

The two AdGuard instances are hosted across separate Proxmox failure domains. External DNS resolution has been tested with either individual AdGuard instance unavailable.

### Switching

A Cisco managed switch provides centralized Ethernet connectivity for physical infrastructure.

The current wired environment operates as a flat Layer 2 network using VLAN 1. VLAN-based segmentation has not yet been implemented and is planned as part of the future OPNsense architecture.

Exact physical port assignments are maintained in private infrastructure documentation, while the public port map uses representative device assignments.

### Wireless

The ASUS gateway currently provides wireless connectivity.

Trusted wireless devices connect to the internal network, while guest and IoT devices use an isolated guest wireless environment that prevents access to trusted internal resources.

### Remote Access

WireGuard provides encrypted remote access to the internal network without requiring direct Internet exposure of internal management services.

## Design Goals

The network infrastructure is designed around:

- Reliable core DHCP and DNS services
- Redundancy for critical network services
- Predictable infrastructure addressing
- Centralized managed switching
- Separation of internal DNS authority and external DNS filtering
- Distribution of redundant services across virtualization failure domains
- Isolation of guest and IoT wireless devices
- Secure remote access
- Monitoring and documented failure testing
- A clear migration path toward dedicated firewalling and VLAN segmentation

## Documentation

| Document | Focus |
|---|---|
| [Architecture](./architecture.md) | Overall logical architecture, service relationships, redundancy, and future design |
| [IP Addressing Plan](./ip-addressing-plan.md) | Address allocation and infrastructure addressing strategy |
| [Cisco Switch Deployment](./cisco-switch-deployment.md) | Managed switch deployment and configuration |
| [DHCP Infrastructure](./dhcp-infrastructure.md) | Windows Server DHCP, failover, DNS integration, and validation |
| [DNS Filtering with AdGuard Home](./dns-filtering-adguard-home.md) | DNS filtering, DoH, redundancy, and failure testing |
| [Wireless Design](./wireless-design.md) | Trusted and guest/IoT wireless architecture |
| [Port Map](./port-map.md) | Physical connections and current VLAN configuration |
| [OPNsense Firewall](./opnsense-firewall-mac-mini.md) | Planned dedicated firewall deployment |
| [Lessons Learned](./lessons-learned.md) | Implementation findings and troubleshooting lessons |

## Planned Improvements

The next major architecture phase will introduce a dedicated OPNsense firewall and VLAN-based network segmentation.

Planned improvements include:

1. Deploy OPNsense as the primary gateway and firewall
2. Create separate management, server, trusted, IoT, and guest network zones
3. Configure VLAN trunking through the managed switch
4. Apply controlled inter-network firewall policies
5. Migrate remote-access VPN services to the dedicated firewall
6. Expand network monitoring and security visibility

These capabilities remain planned and are not represented as part of the currently deployed architecture.

## Related Projects

This network provides the foundation for the broader enterprise homelab, including:

- Proxmox virtualization
- Active Directory
- Microsoft Entra ID and Intune
- Infrastructure monitoring
- Docker and self-hosted services
- Backup and disaster recovery
- Network security