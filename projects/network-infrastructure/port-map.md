# Port Map

## Overview

This document records the physical connections between network devices. It serves as a quick reference when troubleshooting, expanding the network, or moving equipment.

> **Note:** This document reflects the current environment. Planned devices are included for future reference.

## ASUS RT-AX5400

| Port | Connected Device | Status |
|------|------------------|--------|
| WAN | ISP Modem / ONT | Active |
| LAN 1 | Synology NAS | Active |
| LAN 2 | Media Server | Active |
| LAN 3 | Cisco Managed Switch | Planned |
| LAN 4 | Available | Unused |

## Cisco Managed Switch (Planned)

| Port | Connected Device | Status |
|------|------------------|--------|
| 1 | ASUS Router (Uplink) | Planned |
| 2 | Media Server | Planned |
| 3+ | Lab Equipment | Planned |
| Remaining | Future Expansion | Planned |

## Current Layout

```text
Internet
    │
ISP Modem / ONT
    │
ASUS RT-AX5400
├── Synology NAS
├── Media Server
├── Wireless Clients
└── Guest / IoT Devices
```

## Future Layout

```text
Internet
    │
ISP Modem / ONT
    │
ASUS RT-AX5400
    │
Cisco Managed Switch
├── Synology NAS
├── Media Server
├── Hypervisor Hosts
├── Lab Equipment
└── Additional Infrastructure
```

## Cabling Notes

- Core infrastructure uses wired Ethernet whenever possible.
- Wireless is reserved primarily for mobile and IoT devices.
- Future infrastructure devices will connect through the managed switch instead of directly to the router.

## Related Documentation

- network-design.md
- ip-addressing-plan.md
- wireless-design.md
- future-roadmap.md
