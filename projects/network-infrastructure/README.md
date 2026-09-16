# 🌐 Network Infrastructure

**Status:** 🟢 Operational (Phase 1)

The physical and logical foundation of the homelab, including routing, switching, wireless connectivity, IP addressing, DHCP, DNS, and core network services.

> [!NOTE]
> Implementation-specific network addresses, allocation ranges, VLAN identifiers, and device assignments are intentionally omitted or generalized in public documentation.

## Objectives

- Design and document a structured network topology
- Maintain predictable infrastructure addressing
- Deploy redundant DHCP and DNS services
- Establish centralized Ethernet connectivity
- Segment trusted, guest, IoT, server, and management traffic
- Maintain documentation sufficient to rebuild and troubleshoot the environment
- Prepare the network for dedicated firewall and VLAN deployment

## Logical Network Topology

![network topology](./diagrams/current-logical-network-architecture.png)

> [!NOTE]
> The Cisco managed switch provides centralized Ethernet connectivity for wired infrastructure. The ASUS RT-AX5400 currently remains responsible for routing, firewall, VPN, and wireless services.
>
> DHCP has been deployed on redundant Windows Server infrastructure and is being migrated from the ASUS router. Dedicated firewall services and VLAN segmentation are planned for a future phase.

## Current Environment

- ASUS RT-AX5400 gateway and wireless router
- Cisco Catalyst managed switch
- Redundant Active Directory-integrated DNS
- Redundant Windows Server DHCP with failover
- Statically addressed infrastructure and server systems
- DHCP-managed client devices
- Synology NAS
- Proxmox virtualization hosts
- Ethernet-connected infrastructure and lab systems
- Guest wireless isolation for guest and IoT devices

## Technologies

### Current

- ASUS RT-AX5400
- Cisco Catalyst Managed Switch
- Windows Server DHCP
- DHCP Failover
- Active Directory-integrated DNS
- Static Infrastructure Addressing
- DHCP Client Addressing
- Guest Network Isolation
- Synology NAS
- Proxmox VE

### Planned

- VLAN Segmentation
- OPNsense Firewall
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
- [x] Configure static addressing for infrastructure systems
- [x] Implement guest network isolation
- [x] Document current network architecture

### In Progress

- [ ] Migrate DHCP from ASUS RT-AX5400 to Windows Server
- [ ] Validate DHCP client migration
- [ ] Test DHCP service failover
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

## Addressing Strategy

The environment separates infrastructure addressing from DHCP-managed client addressing.

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

See [`ip-addressing-strategy.md`](./ip-addressing-strategy.md) for additional design information.

## DHCP and DNS

DHCP is provided by two Windows Server systems configured with a failover relationship. The environment centrally distributes client addressing, gateway information, internal DNS servers, and DNS domain configuration.

Internal name resolution is provided by redundant Active Directory-integrated DNS services.

The previous DHCP service provided by the ASUS RT-AX5400 is being retired through a controlled DHCP server migration.

See [`dhcp-server-migration.md`](./dhcp-server-migration.md) for the migration process.

## Future Segmentation

Future segmentation will use VLANs to separate systems by function, with dedicated subnets, DHCP scopes where appropriate, and firewall policies controlling inter-VLAN communication.

Planned segmentation includes:

- Management infrastructure
- Trusted endpoints
- Servers and services
- IoT devices
- Guest devices

Specific VLAN identifiers, subnet assignments, and firewall policies are intentionally excluded from public documentation.

## Related Projects

- [proxmox-virtualization-lab](../proxmox-virtualization-lab/) — Proxmox cluster, VMs, and lab workloads connected to this network
- [network-security](../network-security/) — Firewall policies and segmentation strategy
- [media-services-platform](../media-services-platform/) — Media services hosted on network infrastructure
- [infrastructure-monitoring](../infrastructure-monitoring/) — Monitoring and observability stack

## Folder Structure

```text
network-infrastructure/
├── README.md
├── network-design.md
├── ip-addressing-strategy.md
├── dhcp-server-migration.md
├── device-inventory.md
├── lessons-learned.md
├── configs/
├── scripts/
└── diagrams/
```
