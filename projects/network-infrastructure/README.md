# 🌐 Network Infrastructure

**Status: 🟢 Operational (Phase 1)**

The physical and logical foundation of the homelab — routing, switching, wireless, IP design, and core network services.

The current environment is built around an ASUS RT-AX5400 router with DHCP reservations for infrastructure devices and guest network isolation for IoT devices. Future phases will introduce managed switching, VLAN segmentation, and a dedicated firewall platform.

## Objectives

- Design and document a structured network topology
- Implement a scalable IP addressing scheme
- Establish reliable DHCP and DNS services
- Segment trusted, guest, and lab traffic
- Maintain documentation sufficient to rebuild the network from scratch

## Current Environment

- ASUS RT-AX5400 Router
- 10.10.10.0/24 Network
- DHCP Reservations for infrastructure devices
- Synology NAS connected via Ethernet
- Media Server connected via Ethernet
- Guest Wi-Fi used for IoT isolation
- Cisco Managed Switch planned for expansion

## Technologies

### Current

- ASUS RT-AX5400
- DHCP Reservations
- Guest Network Isolation
- Synology NAS
- Ethernet-connected Media Server

### Planned

- Cisco Managed Switch
- VLAN Segmentation
- Internal DNS Services
- Configuration Backups
- NetBox IPAM
- pfSense or OPNsense Firewall

## Key Tasks

### Completed

- [x] Define IP addressing plan
- [x] Configure DHCP reservations
- [x] Implement guest network isolation
- [x] Document current network architecture

### In Progress

- [ ] Deploy Cisco managed switch
- [ ] Create physical port maps
- [ ] Build device inventory
- [ ] Document cabling layout

### Planned

- [ ] Implement VLAN segmentation
- [ ] Configure VLAN trunks
- [ ] Map SSIDs to VLANs
- [ ] Deploy internal DNS services
- [ ] Implement automated configuration backups
- [ ] Deploy IPAM solution (NetBox)

## Current Network Design

### LAN

| Setting | Value |
|----------|----------|
| Network | 10.10.10.0/24 |
| Gateway | 10.10.10.1 |
| DHCP Pool | 10.10.10.150 - 10.10.10.249 |

### Address Allocation

| Range | Purpose |
|---------|---------|
| 10.10.10.2 - 10.10.10.49 | Infrastructure |
| 10.10.10.50 - 10.10.10.99 | Future Infrastructure |
| 10.10.10.100 - 10.10.10.149 | Servers and Lab Systems |
| 10.10.10.150 - 10.10.10.249 | DHCP Clients |
| 10.10.10.250 - 10.10.10.254 | Reserved |

See [`ip-addressing-plan.md`](./ip-addressing-plan.md) for detailed assignments.

## Related Projects

- [virtualization-lab](../virtualization-lab/) — Hypervisors, VMs, and lab workloads connected to this network
- [home-network-security](../home-network-security/) — Firewall policies and segmentation strategy
- [media-services-platform](../media-services-platform/) — Media services hosted on network infrastructure
- [infrastructure-monitoring](../infrastructure-monitoring/) — Monitoring and observability stack

## Folder Structure

```text
network-infrastructure/
├── README.md
├── network-design.md
├── ip-addressing-plan.md
├── device-inventory.md
├── lessons-learned.md
├── configs/
├── scripts/
└── screenshots/
```
