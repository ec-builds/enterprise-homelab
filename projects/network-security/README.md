# 🔒 Network Security

**Status:** 🟢 Operational

This project documents the preventive security controls used to protect the homelab network, including perimeter firewalling, secure remote access, DNS filtering, encrypted upstream DNS, wireless isolation, and infrastructure hardening.

Phase 1 establishes the current security baseline. Future phases will introduce a dedicated OPNsense firewall, VLAN-based segmentation, inter-VLAN security policies, and IDS/IPS capabilities.

**Scope:** Detection and response workflows are documented separately in [security-operations](../security-operations/). This project focuses on preventive network controls and security architecture.

## Network Security Architecture

<p align="left">
  <img src="./diagrams/network-security-architecture.png" alt="Network Security Architecture" width="750">
</p>

> [!NOTE]
> The current environment uses the ASUS router as the perimeter firewall and routing platform. OPNsense and full VLAN segmentation are planned for a future phase and are not represented as currently deployed controls.

## Current Security Architecture

The current environment uses layered controls across the network edge, remote access, DNS infrastructure, and wireless networks.

```text
Internet
   │
   ▼
ASUS Perimeter Router / Firewall
   │
   ├── Stateful Firewall / NAT
   ├── WireGuard Remote Access
   ├── Trusted Wireless
   └── Isolated Guest / IoT Wireless
   │
   ▼
Cisco Managed Switch
   │
   ▼
Trusted Internal Network
   │
   ├── Active Directory DNS
   │      │
   │      ▼
   │   Redundant AdGuard Home
   │      │
   │      ├── DNS Filtering
   │      └── DNS-over-HTTPS
   │             │
   │             ▼
   │      Public DNS Resolvers
   │
   ├── Proxmox VE Cluster
   ├── Infrastructure Services
   └── Synology NAS
```

## Current Security Controls

| Security Area | Current Implementation |
|---|---|
| Perimeter Security | Stateful firewall and NAT at the network edge |
| Inbound Protection | Unsolicited inbound connections blocked unless explicitly permitted |
| Remote Access | WireGuard VPN |
| DNS Security | Redundant AdGuard Home filtering |
| Upstream DNS Privacy | DNS-over-HTTPS to public resolvers |
| Internal DNS | Redundant Active Directory-integrated DNS |
| Wireless Security | WPA2/WPA3 with separate guest/IoT isolation |
| Network Switching | Managed Cisco switching |
| Service Exposure | Internal services kept private unless explicitly required |
| Infrastructure Resilience | Redundant DNS, DHCP, and DNS filtering services |

## Objectives

- Maintain a secure network perimeter
- Minimize externally exposed services
- Provide encrypted remote administration through WireGuard
- Filter malicious, advertising, and tracking domains at the DNS layer
- Encrypt upstream DNS resolution using DoH
- Isolate guest and IoT wireless devices from trusted systems
- Introduce VLAN-based security zones
- Implement least-privilege communication between network segments
- Deploy IDS/IPS capabilities
- Centralize security-relevant network logging

## DNS Security

Internal clients use Active Directory-integrated DNS rather than querying public resolvers directly.

External queries are forwarded through two redundant AdGuard Home instances:

```text
Internal Clients
      │
      ▼
Active Directory DNS
dc-lab-01 / dc-lab-02
      │
      ▼
   AdGuard Home
adguard-lab-01 / adguard-lab-02
      │
      ├── DNS Filtering
      │
      └── DNS-over-HTTPS
             │
             ▼
     Cloudflare / Google
```

AdGuard evaluates DNS filtering rules before forwarding permitted external queries to public resolvers.

Both Active Directory DNS servers use both AdGuard instances as forwarders. The AdGuard instances are hosted across separate Proxmox failure domains to reduce the impact of an individual virtualization-host failure.

Failover testing confirmed that external DNS resolution continues when either AdGuard instance is unavailable.

DNS-over-HTTPS currently protects the connection between AdGuard and public DNS resolvers. DNS communication between internal clients, Active Directory DNS, and AdGuard remains standard DNS within the trusted network.

Detailed implementation documentation is maintained in the [Network Infrastructure](../network-infrastructure/) project.

## Remote Access Security

WireGuard provides encrypted remote access to the internal environment without exposing individual management interfaces directly to the Internet.

The current deployment follows several basic security principles:

- VPN access instead of direct administrative service exposure
- Key-based WireGuard authentication
- Minimal externally exposed services
- Router administration restricted from the WAN
- Remote management performed through the trusted VPN path

Additional implementation details are documented in [`wireguard-vpn.md`](./wireguard-vpn.md) and [`wireguard-security.md`](./wireguard-security.md).

## Wireless Isolation

Trusted systems use the primary wireless network.

Guest and IoT devices use isolated guest wireless connectivity provided by the current router platform. These devices are separated from the trusted internal environment.

This provides basic trust separation before the deployment of full VLAN-based segmentation.

## Design Principles

- Least privilege
- Defense in depth
- Secure by default
- Minimize exposed services
- Use VPN access for remote administration
- Separate trusted and untrusted devices
- Avoid unnecessary single points of failure
- Keep critical routing and firewall infrastructure independent of general-purpose virtualization where practical
- Document security architecture and configuration decisions
- Validate redundancy through controlled failure testing

## Current Limitations

The current security architecture provides a functional baseline but does not yet provide full internal network segmentation.

The trusted wired and wireless environment currently operates as a single internal network. Guest and IoT wireless devices are isolated separately through the router.

The following capabilities are not yet deployed:

- Dedicated OPNsense firewall
- VLAN-based infrastructure segmentation
- Least-privilege inter-VLAN firewall policies
- Suricata IDS/IPS
- Centralized firewall and IDS logging

These capabilities are planned for subsequent phases.

## Target Architecture

A future phase will introduce OPNsense on dedicated hardware as the primary routing and firewall platform.

```text
Internet
   │
   ▼
OPNsense
   │
   ▼
Cisco Managed Switch
   │
   ├── Management Zone
   ├── Trusted Zone
   ├── Server / Services Zone
   ├── IoT Zone
   └── Guest Zone
```

The dedicated firewall will remain outside the Proxmox virtualization cluster. This keeps routing and firewall availability independent of virtualization-host maintenance, reboots, and lab experimentation.

OPNsense will provide the foundation for VLAN routing, stateful inter-VLAN firewall policies, and additional security controls.

## Current Status

### Completed

- [x] Deploy perimeter firewall and NAT
- [x] Update router firmware
- [x] Disable UPnP
- [x] Restrict router administration from the WAN
- [x] Deploy WireGuard VPN
- [x] Enable secure remote administration through VPN
- [x] Implement guest and IoT wireless isolation
- [x] Deploy redundant Active Directory DNS
- [x] Deploy redundant AdGuard Home instances
- [x] Configure network-wide DNS filtering
- [x] Configure encrypted upstream DNS using DoH
- [x] Configure both DNS servers to use both AdGuard instances
- [x] Separate AdGuard instances across virtualization failure domains
- [x] Validate AdGuard failover in both directions
- [x] Select OPNsense as the target firewall platform
- [x] Design dedicated firewall deployment outside the virtualization cluster
- [x] Document current network security architecture

### Planned

- [ ] Deploy OPNsense on dedicated hardware
- [ ] Configure WAN and LAN interfaces
- [ ] Implement VLAN segmentation
- [ ] Configure VLAN trunks
- [ ] Implement least-privilege inter-VLAN firewall rules
- [ ] Map wireless networks to security zones
- [ ] Migrate secure remote access to the target firewall architecture
- [ ] Enable Suricata IDS/IPS
- [ ] Centralize firewall and IDS logs
- [ ] Evaluate encrypted DNS closer to client endpoints

## Folder Structure

```text
network-security/
│
├── diagrams/
├── README.md
├── firewall.md
├── wireguard-vpn.md
├── wireguard-security.md
├── network-segmentation.md (Planned)
├── dns-filtering.md (Planned)
├── ids-ips.md (Planned)
└── security-policies.md (Planned)
```

| Document | Primary Question |
|---|---|
| `firewall.md` | How are perimeter firewall controls implemented and how will OPNsense extend them? |
| `wireguard-vpn.md` | How is secure remote access provided? |
| `wireguard-security.md` | How is the WireGuard deployment hardened? |
| `network-segmentation.md` | How will the network be divided into security zones? |
| `dns-filtering.md` | How is DNS filtering and upstream encryption implemented? |
| `ids-ips.md` | How will network threats be detected and prevented? |
| `security-policies.md` | What security principles guide the environment? |

## Related Projects

- [network-infrastructure](../network-infrastructure/) — Routing, switching, DHCP, DNS, and network architecture
- [active-directory-lab](../active-directory-lab/) — Identity services and Active Directory-integrated DNS
- [security-operations](../security-operations/) — Detection, investigation, and response
- [infrastructure-monitoring](../infrastructure-monitoring/) — Infrastructure availability and observability

## Security Note

Public documentation intentionally omits or generalizes sensitive implementation details.

Never commit public IP addresses, VPN private keys, certificates, passwords, API credentials, administrative usernames, internal addressing details, or other secrets to the repository.
