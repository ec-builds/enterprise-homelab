# 🌐 Network Infrastructure

**Status:** 🟢 Operational

The physical and logical network foundation of the homelab, including routing, switching, wireless connectivity, IP addressing, DHCP, DNS, DNS filtering, encrypted upstream resolution, and core network services.

![Current Logical Network Architecture](./diagrams/current-logical-network-architecture.png)

*Current logical architecture showing routing, switching, virtualization, Active Directory services, redundant DNS filtering, storage, wireless connectivity, and remote access.*

> [!NOTE]
> Implementation-specific network addresses, allocation ranges, VLAN identifiers, credentials, and device assignments are intentionally omitted or generalized in public documentation.

## Architecture Overview

The Cisco managed switch provides centralized Ethernet connectivity for wired infrastructure. The ASUS RT-AX5400 currently provides routing, firewall, WireGuard VPN, and wireless services.

Windows Server provides redundant DHCP and Active Directory-integrated DNS. External DNS queries are forwarded through redundant AdGuard Home instances for filtering and encrypted upstream resolution using DNS-over-HTTPS (DoH).

Dedicated firewall services and VLAN segmentation are planned for a future deployment.

## Current Environment

- ASUS RT-AX5400 gateway, firewall, VPN, and wireless router
- Cisco Catalyst managed switch
- Three-node Proxmox VE cluster
- Redundant Active Directory-integrated DNS
- Redundant Windows Server DHCP with failover
- Redundant AdGuard Home DNS filtering
- DNS-over-HTTPS upstream resolution
- Static infrastructure addressing
- DHCP-managed client devices
- Synology NAS for storage and backups
- Ethernet-connected infrastructure and lab systems
- Trusted wireless network
- Isolated guest and IoT wireless network

## Core Network Services

| Service | Implementation | Redundancy |
|---|---|---|
| DHCP | Windows Server DHCP | Two-server failover |
| Internal DNS | Active Directory-integrated DNS | Two domain controllers |
| External DNS Filtering | AdGuard Home | Two instances |
| Upstream DNS | DNS-over-HTTPS | Multiple public resolvers |
| Remote Access | WireGuard VPN | Router-hosted |
| Network Storage | SMB / Synology NAS | NAS-hosted |
| Availability Monitoring | Uptime Kuma | Dedicated monitoring host |

## Objectives

- Design and document a structured network topology
- Maintain predictable infrastructure addressing
- Provide redundant DHCP and DNS services
- Centralize wired connectivity through managed switching
- Provide redundant DNS filtering and encrypted upstream resolution
- Isolate guest and IoT devices from the trusted network
- Maintain documentation sufficient to rebuild and troubleshoot the environment
- Prepare the network for dedicated firewall and VLAN deployment

## Technologies

### Current

- ASUS RT-AX5400
- Cisco Catalyst Managed Switch
- Proxmox VE
- Windows Server DHCP
- DHCP Failover
- Active Directory-integrated DNS
- AdGuard Home
- DNS-over-HTTPS (DoH)
- Cloudflare DNS
- Google Public DNS
- Static Infrastructure Addressing
- DHCP Client Addressing
- WireGuard VPN
- Guest Network Isolation
- Synology NAS

### Planned

- OPNsense Firewall
- VLAN Segmentation
- Inter-VLAN Firewall Policies
- Configuration Backups
- IP Address Management (IPAM)

## Key Tasks

### Completed

- [x] Define IP addressing strategy
- [x] Deploy Cisco managed switch
- [x] Configure switch management access
- [x] Deploy redundant internal DNS services
- [x] Deploy Windows Server DHCP
- [x] Authorize DHCP servers in Active Directory
- [x] Configure DHCP scope options
- [x] Configure DHCP failover
- [x] Validate DHCP failover relationship
- [x] Migrate DHCP service from ASUS router to Windows Server
- [x] Validate DHCP client migration
- [x] Test DHCP service continuity with individual DHCP servers offline
- [x] Configure static addressing for infrastructure systems
- [x] Deploy redundant AdGuard Home instances
- [x] Configure both DNS servers to use both AdGuard instances as forwarders
- [x] Configure encrypted upstream DNS using DoH
- [x] Configure network-wide DNS filtering
- [x] Separate AdGuard instances across Proxmox failure domains
- [x] Validate AdGuard failover in both directions
- [x] Configure internal reverse DNS resolution for AdGuard
- [x] Implement guest network isolation
- [x] Document current network architecture

### In Progress

- [ ] Create physical port maps
- [ ] Build device inventory
- [ ] Document cabling layout

### Planned

- [ ] Deploy OPNsense firewall
- [ ] Implement VLAN segmentation
- [ ] Configure VLAN trunks
- [ ] Map wireless networks to VLANs
- [ ] Implement inter-VLAN firewall policies
- [ ] Implement automated configuration backups
- [ ] Deploy IPAM solution
- [ ] Evaluate encrypted DNS closer to client endpoints

## Addressing Strategy

The current environment uses a single trusted internal network while separating infrastructure addressing from DHCP-managed client addressing.

```text
Private Address Space
│
├── Infrastructure
│   └── Static addressing
│
├── Client Address Space
│   ├── Dynamic DHCP
│   └── DHCP reservations where required
│
└── Reserved Capacity
    └── Future expansion
```

Foundational infrastructure and persistent server systems use static addressing where independence from DHCP is appropriate.

Client systems receive network configuration through redundant Windows Server DHCP services.

Specific address ranges and device assignments are intentionally excluded from public documentation.

See [`ip-addressing-plan.md`](./ip-addressing-plan.md) for additional design information.

## DHCP and DNS

DHCP is provided by two Windows Server systems configured with a failover relationship. Client addressing, gateway information, internal DNS servers, and DNS domain configuration are distributed centrally.

Internal name resolution is provided by redundant Active Directory-integrated DNS servers. Domain clients query these servers directly, preserving Active Directory service discovery and internal namespace resolution.

External DNS resolution follows a separate forwarding path:

```text
Internal Clients
      │
      ▼
Active Directory DNS
  dc-lab-01 / dc-lab-02
      │
      │ External DNS forwarding
      ▼
    AdGuard Home
adguard-lab-01 / adguard-lab-02
      │
      │ DNS Filtering
      │ DNS-over-HTTPS
      ▼
Cloudflare / Google
      │
      ▼
   Internet DNS
```

Both Active Directory DNS servers are configured to use both AdGuard instances as forwarders. The AdGuard instances are hosted in separate Proxmox failure domains to avoid introducing a single virtualization-host dependency.

Controlled failure testing confirmed that external DNS resolution continues when either AdGuard instance is unavailable.

See [`dns-filtering-adguard-home.md`](./dns-filtering-adguard-home.md) for the DNS filtering and encrypted upstream resolution architecture.

Historical DHCP migration and validation documentation is retained in the [`archive/`](./archive/) directory.

## DNS Architecture

The DNS design intentionally separates internal name resolution from external filtering.

**Active Directory DNS** remains authoritative for the internal domain and provides the DNS functionality required by domain services.

**AdGuard Home** provides:

- Network-wide DNS filtering
- Redundant external DNS forwarding
- Encrypted upstream DNS using DoH
- Internal PTR resolution for domain-controller identification

Because client queries pass through Active Directory DNS first, AdGuard identifies the forwarding domain controller rather than the original endpoint. This reduced per-client visibility is an accepted design tradeoff that preserves the Active Directory DNS architecture.

DoH currently protects the upstream connection between AdGuard and public DNS resolvers. DNS traffic between internal clients, Active Directory DNS, and AdGuard remains standard DNS within the trusted network.

## Current Network Segmentation

The trusted wired and wireless environment currently operates as a single internal network.

Guest and IoT devices use the ASUS guest wireless network and are isolated from the trusted internal environment.

Full infrastructure segmentation has not yet been implemented.

## Future Segmentation

The target network architecture will introduce OPNsense and VLAN-based segmentation to separate systems by function.

Planned logical zones include:

- Management infrastructure
- Trusted endpoints
- Servers and services
- IoT devices
- Guest devices

Each zone can receive dedicated addressing, DHCP services where appropriate, and firewall policies controlling communication between network segments.

Specific VLAN identifiers, subnet assignments, and firewall policies are intentionally excluded from public documentation.

## Related Projects

- [proxmox-virtualization-lab](../proxmox-virtualization-lab/) — Proxmox cluster, VMs, and lab workloads
- [network-security](../network-security/) — Firewall and segmentation strategy
- [media-services-platform](../media-services-platform/) — Self-hosted media services
- [infrastructure-monitoring](../infrastructure-monitoring/) — Monitoring and observability stack

## Related Documentation

- [`cisco-switch-deployment.md`](./cisco-switch-deployment.md) — Managed switch deployment and configuration
- [`dns-filtering-adguard-home.md`](./dns-filtering-adguard-home.md) — Redundant DNS filtering and encrypted upstream resolution
- [`ip-addressing-plan.md`](./ip-addressing-plan.md) — Address allocation strategy
- [`opnsense-firewall-mac-mini.md`](./opnsense-firewall-mac-mini.md) — Planned dedicated firewall deployment
- [`port-map.md`](./port-map.md) — Physical and logical network port mapping
- [`wireless-design.md`](./wireless-design.md) — Wireless network design
- [`lessons-learned.md`](./lessons-learned.md) — Implementation lessons and troubleshooting findings

Historical implementation and migration documentation is retained under [`archive/`](./archive/).

## Folder Structure

```text
network-infrastructure/
├── README.md
├── cisco-switch-deployment.md
├── dns-filtering-adguard-home.md
├── ip-addressing-plan.md
├── lessons-learned.md
├── opnsense-firewall-mac-mini.md
├── port-map.md
├── wireless-design.md
├── archive/
│   └── ...
└── diagrams/
    ├── current-logical-network-architecture.png
    └── ...
```
