# Network Design

**Status:** 🟢 Operational (Phase 1)

> **Note:** IP addresses shown in this document have been sanitized for public release. The production environment uses a different private IP addressing scheme.

## Overview

This document provides a high-level overview of the homelab network. The current environment uses an ASUS RT-AX5400 router for routing, DHCP, wireless networking, and VPN access. The design emphasizes simplicity today while leaving room for future expansion.

## Current Environment

### Core Components

- ASUS RT-AX5400 Router
- Synology NAS
- Debian Media Server
- Wireless Clients
- Guest Wi-Fi for IoT Devices

### Services

- DHCP
- DNS Forwarding
- WireGuard VPN
- Guest Network Isolation
- DHCP Reservations

## Network Topology

![Network Topology](../diagrams/network-topology.png)

## Logical Design

| Network | Purpose |
|----------|---------|
| Primary LAN | Trusted devices and infrastructure |
| Guest Wi-Fi | IoT devices and guest access |
| WireGuard VPN | Secure remote access |

## Addressing

The network uses a structured private addressing scheme.

| Setting | Value |
|----------|-------|
| Network | 10.0.0.0/24 |
| Gateway | 10.0.0.1 |
| DHCP | 10.0.0.150 – 10.0.0.249 |

For the complete addressing plan, see **ip-addressing-plan.md**.

## Current Design Principles

- Infrastructure uses DHCP reservations.
- IoT devices remain on the guest network.
- Wired infrastructure receives predictable IP addresses.
- Public documentation is sanitized.
- Changes are documented as the lab evolves.

## Future Improvements

Planned enhancements include:

- Cisco managed switch
- VLAN segmentation
- OPNsense firewall
- Internal DNS
- Centralized IP address management (IPAM)

## Related Documentation

- ip-addressing-plan.md
- wireless-design.md
- port-map.md
- dhcp-reservations.md
- lessons-learned.md
