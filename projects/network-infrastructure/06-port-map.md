# Port Map

## Overview

This document records the physical Ethernet connections and current switch-port configuration for the network infrastructure.

The public version intentionally generalizes device-to-port assignments. Exact physical port assignments are maintained in private documentation.

> [!NOTE]
> All currently active switch ports operate on **VLAN 1**. VLAN-based network segmentation is planned but has not yet been implemented.

## ASUS RT-AX5400

| Port | Connected Device | Status |
|---|---|---|
| WAN | ISP ONT | Active |
| LAN | Cisco Managed Switch | Active |
| Remaining | Direct-connected devices / available | As deployed |

The ASUS RT-AX5400 currently provides Internet gateway, routing, firewall, wireless, and WireGuard services.

The Cisco managed switch provides centralized wired connectivity for the infrastructure.

## Cisco Managed Switch

The switch currently operates as a flat Layer 2 network using VLAN 1 for connected infrastructure.

Gi1 is shown accurately as the router uplink. Gi2–Gi9 below are illustrative assignments representing the devices currently connected to the switch; exact port assignments are maintained in private documentation.

| Port | Example Connected Device | VLAN | Status |
|---|---|---:|---|
| Gi1 | ASUS RT-AX5400 — Uplink | 1 | Active |
| Gi2 | Dell Micro — Proxmox Host | 1 | Active |
| Gi3 | HP Pavilion — `prox-lab-03` | 1 | Active |
| Gi4 | Synology NAS | 1 | Active |
| Gi5 | Printer | 1 | Active |
| Gi6 | Scanner | 1 | Active |
| Gi7 | Dell Micro — Proxmox Host | 1 | Active |
| Gi8 | Mac mini | 1 | Active |
| Gi9 | Wired Infrastructure | 1 | Active |
| Remaining | Available / Future Expansion | 1 | Available |

> [!IMPORTANT]
> Gi2–Gi9 are intentionally presented as example assignments for the public repository. Exact device-to-port mappings are recorded in private infrastructure documentation.

## Current VLAN Configuration

The current implementation uses the switch's default VLAN for all active wired connections.

```text
VLAN 1
│
├── Router Uplink
├── Proxmox Hosts
├── Synology NAS
├── Mac mini
├── Printer
├── Scanner
└── Other Wired Infrastructure
```

At this stage, VLAN 1 provides connectivity rather than security segmentation.

Logical separation between management systems, servers, trusted endpoints, and other device classes will be introduced during the planned VLAN deployment.

## Current Physical Layout

```text
Internet
    │
ISP ONT
    │
ASUS RT-AX5400
    │
    ├── Wireless Clients
    │
    ├── Guest / IoT Wireless
    │
    └── Cisco Managed Switch
            │
            └── VLAN 1
                 ├── Proxmox Hosts
                 ├── Synology NAS
                 ├── Mac mini
                 ├── Printer
                 ├── Scanner
                 └── Other Wired Infrastructure
```

## Current Network Roles

| Device | Role |
|---|---|
| ISP ONT | ISP handoff |
| ASUS RT-AX5400 | Gateway, routing, firewall, NAT, wireless, and WireGuard |
| Cisco Managed Switch | Centralized Layer 2 Ethernet connectivity |
| Proxmox Hosts | Virtualization infrastructure |
| Synology NAS | Network storage and backup services |
| Mac mini | Lab infrastructure |
| Printer / Scanner | Network peripherals |
| Wireless Clients | Trusted wireless endpoints |
| Guest / IoT Devices | Isolated wireless devices |

## Cabling Guidelines

- Core infrastructure uses wired Ethernet whenever practical.
- Wired infrastructure is centralized through the Cisco managed switch.
- Wireless connectivity is primarily used for mobile, guest, and IoT devices.
- Exact switch-port assignments are maintained in private documentation.
- Public documentation uses representative mappings where exact physical details are unnecessary.
- Port and VLAN assignments will be updated as the segmented network architecture is implemented.

## Planned VLAN Segmentation

The current flat VLAN 1 network will eventually transition to multiple logical security zones.

```text
Internet
    │
Dedicated Firewall
    │
Cisco Managed Switch
    │
    ├── Management VLAN
    ├── Server VLAN
    ├── Trusted VLAN
    ├── IoT VLAN
    └── Guest VLAN
```

The future design will move devices away from the shared VLAN 1 network and assign them to VLANs based on their function and trust level.

Inter-VLAN communication will then be controlled through firewall policy.

Specific VLAN IDs, subnet assignments, trunk configuration, and firewall rules will be documented after implementation.

## Related Documentation

- [`architecture.md`](./architecture.md) — Overall network architecture
- [`ip-addressing-plan.md`](./ip-addressing-plan.md) — Address allocation strategy
- [`cisco-switch-deployment.md`](./cisco-switch-deployment.md) — Managed switch deployment and configuration
- [`wireless-design.md`](./wireless-design.md) — Wireless network architecture
- [`opnsense-firewall-mac-mini.md`](./opnsense-firewall-mac-mini.md) — Planned dedicated firewall deployment