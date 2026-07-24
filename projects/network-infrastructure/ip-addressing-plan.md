# IP Addressing Plan

**Status: 🟢 Active**

> **Note:** The IP addresses shown in this document have been sanitized for public release. The production network uses a different private IP addressing scheme, but the addressing strategy remains the same.

This document defines the IP addressing strategy for the homelab environment. The goal is to provide predictable device placement, simplify troubleshooting, and reserve capacity for future growth.

## Network Information

| Setting | Value |
|----------|-------|
| Network | 10.0.0.0/24 |
| Subnet Mask | 255.255.255.0 |
| Gateway | 10.0.0.1 |
| DHCP Pool | 10.0.0.150 - 10.0.0.249 |
| DNS | ASUS RT-AX5400 |
| Address Space | 254 Usable Hosts |

## Address Allocation Strategy

| Range | Purpose |
|---------|---------|
| 10.0.0.1 | Gateway |
| 10.0.0.2 - 10.0.0.49 | Core Infrastructure |
| 10.0.0.50 - 10.0.0.99 | Future Infrastructure |
| 10.0.0.100 - 10.0.0.149 | Servers and Lab Systems |
| 10.0.0.150 - 10.0.0.249 | DHCP Client Pool |
| 10.0.0.250 - 10.0.0.254 | Reserved |

## Core Infrastructure

| IP Address | Device | Notes |
|------------|--------|-------|
| 10.0.0.1 | ASUS RT-AX5400 | Gateway and DHCP Server |
| 10.0.0.10 | Synology NAS | Primary Storage |
| 10.0.0.20 | Cisco Managed Switch | Planned |
| 10.0.0.30 | Printer | Future |
| 10.0.0.40 | Access Point | Future |

## Server and Lab Allocation

The following range is reserved for servers, hypervisors, virtual machines, and lab infrastructure.

**Range:** `10.0.0.100 - 10.0.0.149`

### Planned Assignments

| IP Address | Device |
|------------|--------|
| 10.0.0.100 | Primary Hypervisor |
| 10.0.0.105 | Media Server |
| 10.0.0.110 | Docker Host |
| 10.0.0.115 | Monitoring Server |
| 10.0.0.120 | Active Directory Lab |
| 10.0.0.125 | Kubernetes Lab |
| 10.0.0.130 | Backup Services |
| 10.0.0.135 | Future Service |
| 10.0.0.140 | Future Service |
| 10.0.0.145 | Future Service |

## DHCP Client Pool

The DHCP pool is reserved for end-user devices and temporary systems.

**Range:** `10.0.0.150 - 10.0.0.249`

Examples:

- Laptops
- Phones
- Tablets
- Guest Devices
- Temporary Test Systems

## DHCP Reservations

Infrastructure devices should receive DHCP reservations rather than manually configured static IP addresses.

Benefits:

- Centralized management
- Easier device replacement
- Consistent addressing
- Reduced configuration drift

Reserved devices include:

- Router
- NAS
- Media Server
- Switches
- Hypervisors
- Printers
- Infrastructure Appliances

## Guest and IoT Network

The ASUS Guest Network currently isolates IoT devices from the primary LAN.

Characteristics:

- Internet access only
- No access to internal resources
- No access to servers or NAS
- Device isolation enabled where supported

Examples:

- Smart TVs
- Streaming Devices
- Smart Home Equipment
- Guest Devices

## Future VLAN Plan

| VLAN | Name | Purpose |
|------|------|---------|
| 10 | Management | Infrastructure Management |
| 20 | Trusted | Workstations and Laptops |
| 30 | Servers | Homelab Services |
| 40 | IoT | Smart Devices |
| 50 | Guest | Guest Wireless Access |

*Planned for future managed switch and firewall deployment.*

## Change Management

When adding new infrastructure:

1. Assign a reserved IP address.
2. Update the device inventory.
3. Update the network topology.
4. Include the device in configuration backups.

## Maintenance

Update this document whenever:

- A reservation is created or changed
- A server is deployed
- Network ranges change
- VLANs are introduced
- Infrastructure devices are added or removed
