# Wireless Design

## Overview

The wireless network is divided into two logical networks:

- **Trusted Wi-Fi** for personal devices and administration
- **Guest Wi-Fi** for IoT and guest devices

This separation helps reduce risk while keeping the network simple to manage.

## Trusted Wireless Network

### Purpose

The trusted network is used for devices that require access to the internal LAN and infrastructure.

### Typical Devices

- Laptops
- Desktop PCs
- Smartphones
- Tablets
- Administrative workstations

### Access

- Full LAN access
- NAS access
- Server access
- Management interface access
- Internet access

## Guest / IoT Wireless Network

### Purpose

The guest network is dedicated to devices that do not require access to the internal network.

### Typical Devices

- Smart TVs
- Streaming devices
- Smart home devices
- Guest devices

### Access

- Internet access only
- No access to trusted LAN devices
- Client isolation enabled (where supported)

## Current Configuration

| Setting | Configuration |
|---------|---------------|
| Wireless Router | ASUS RT-AX5400 |
| Primary Network | Trusted Devices |
| Guest Network | IoT & Guest Devices |
| Security | WPA2/WPA3 Personal |
| Device Assignment | DHCP Reservations (Infrastructure Only) |

## Design Goals

The wireless network is designed to:

- Separate trusted devices from IoT devices
- Reduce lateral movement between networks
- Keep administration simple
- Support secure remote access through WireGuard
- Provide a foundation for future VLAN implementation

## Future Improvements

As the homelab grows, wireless networking will be expanded with:

- VLAN-backed SSIDs
- Dedicated Management VLAN
- Dedicated IoT VLAN
- Dedicated Lab VLAN
- Guest VLAN
- Multiple wireless access points for improved coverage

## Related Documentation

- network-design.md
- ip-addressing-plan.md
- dhcp-reservations.md
- future-roadmap.md
