# Port Map

## Overview

The physical Ethernet connections and current switch-port configuration. Device-to-port assignments here are representative; exact assignments are kept in private documentation.

> [!NOTE]
> Every active switch port is on **VLAN 1**. VLAN segmentation is planned but not yet implemented.

## ASUS RT-AX5400

| Port | Connected Device | Status |
|---|---|---|
| WAN | ISP ONT | Active |
| LAN | Cisco Managed Switch | Active |
| Remaining | Direct-connected devices / available | As deployed |

## Cisco Managed Switch

Gi1–Gi9 are illustrative assignments for the devices currently connected.

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

## Current Physical Layout

```text
Internet
    │
ISP ONT
    │
ASUS RT-AX5400
    │
    ├── Wireless Clients
    ├── Guest / IoT Wireless
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

VLAN 1 currently provides connectivity only, with no segmentation between device types.

## Current Network Roles

| Device | Role |
|---|---|
| ISP ONT | ISP handoff |
| ASUS RT-AX5400 | Gateway, routing, firewall, NAT, wireless and WireGuard |
| Cisco Managed Switch | Layer 2 Ethernet connectivity |
| Proxmox Hosts | Virtualization infrastructure |
| Synology NAS | Network storage and backups |
| Mac mini | Lab infrastructure |
| Printer / Scanner | Network peripherals |
| Wireless Clients | Trusted wireless endpoints |
| Guest / IoT Devices | Isolated wireless devices |

## Cabling Guidelines

- Core infrastructure is wired, through the Cisco switch.
- Wi-Fi is mainly for mobile, guest and IoT devices.
- Public docs use representative port mappings; exact assignments stay private.
- Port and VLAN assignments will be updated when segmentation is implemented.

## Planned VLAN Segmentation

Devices will move off VLAN 1 into zones by function and trust level, with OPNsense controlling traffic between them:

```text
Internet
    │
ASUS RT-AX5400
    │
OPNsense
    │ 802.1Q trunk
Cisco Managed Switch
    │
    ├── Management VLAN
    ├── Server VLAN
    ├── Trusted VLAN
    ├── IoT VLAN
    └── Guest VLAN
```

Proposed VLAN IDs are in the [VLAN Implementation](../network-security/TODO-vlan-implementation-plan.md) plan. Final port assignments, trunk configuration and firewall rules will be documented after implementation.
