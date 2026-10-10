# Network Security Architecture

## Overview

The network security architecture provides layered protection for the enterprise homelab through perimeter firewalling, secure remote access, DNS filtering, wireless isolation, and hardened administrative access.

The current environment uses the ASUS RT-AX5400 as the Internet-facing gateway and security boundary. Wired infrastructure is centralized through a Cisco managed switch and currently operates as a flat Layer 2 network using VLAN 1.

Guest and IoT devices are isolated from the trusted internal network through the router's guest wireless environment.

> [!NOTE]
> Implementation-specific IP addresses, credentials, VPN configuration, and exact infrastructure assignments are intentionally omitted or generalized in public documentation.

## Current Security Architecture

```text
                           Internet
                              │
                              ▼
                       ASUS RT-AX5400
                    ┌───────────────────┐
                    │ Stateful Firewall │
                    │ NAT               │
                    │ WireGuard VPN     │
                    │ Wireless Security │
                    └─────────┬─────────┘
                              │
               ┌──────────────┴──────────────┐
               │                             │
               ▼                             ▼
        Trusted Network                Guest / IoT
               │                        Wireless
               │                             │
               ▼                             ▼
      Cisco Managed Switch            Internet Access
               │                             │
               │                      Internal Access
               │                         Restricted
               ▼
             VLAN 1
               │
      ┌────────┼─────────┐
      │        │         │
      ▼        ▼         ▼
   Servers   Network   Trusted
             Devices   Systems
```

The current design provides perimeter protection, encrypted remote access, DNS filtering, and wireless isolation, but does not yet provide VLAN-based segmentation between trusted wired systems.

## Security Layers

| Layer | Current Control |
|---|---|
| Internet Perimeter | Stateful firewall and NAT |
| Inbound Exposure | Internal services not directly exposed unless required |
| Remote Access | WireGuard encrypted VPN |
| DNS | AdGuard Home filtering and encrypted upstream DNS |
| Wireless | Trusted and isolated guest/IoT networks |
| Administrative Access | SSH key-based access where implemented |
| Switching | Cisco managed switching |
| Wired Segmentation | Flat VLAN 1 network — segmentation planned |
| Monitoring | Infrastructure and service availability monitoring |

## Network Security Boundaries

### Perimeter and Remote Access

The ASUS RT-AX5400 currently provides the primary security boundary between the Internet and internal network.

Stateful firewalling and NAT protect internal systems from unsolicited inbound connections, while unnecessary direct exposure of internal services is avoided.

WireGuard provides encrypted remote access to trusted internal resources without requiring individual management services to be exposed directly to the Internet.

```text
Remote Device
      │
      │ WireGuard
      ▼
   Internet
      │
      ▼
ASUS RT-AX5400
      │
      ▼
Trusted Internal Network
```

Detailed firewall and VPN implementation is documented separately.

### DNS Security

DNS filtering is provided by redundant AdGuard Home instances integrated behind Active Directory DNS.

```text
Internal Client
      │
      ▼
Active Directory DNS
      │
      │ External Queries
      ▼
Redundant AdGuard Home
      │
      ├── DNS Filtering
      │
      └── DNS-over-HTTPS
              │
              ▼
       Public DNS Resolvers
```

Active Directory DNS remains responsible for internal domain resolution and service discovery, while AdGuard Home filters external DNS requests and uses encrypted DNS-over-HTTPS for upstream resolution.

The AdGuard instances are distributed across separate Proxmox failure domains to reduce dependency on a single virtualization host.

Detailed DNS implementation is maintained in the Network Infrastructure project.

### Wireless Isolation

Wireless connectivity is separated between trusted devices and guest/IoT devices.

```text
                     ASUS RT-AX5400
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
       Trusted Wireless           Guest / IoT
              │                         │
              ▼                         ▼
       Internal Network           Internet Access
                                        │
                                 Internal Access
                                    Restricted
```

The guest wireless environment provides the primary current isolation mechanism for untrusted and IoT wireless devices.

Additional segmentation is planned as part of the future VLAN architecture.

### Wired Network

The current wired network operates as a flat Layer 2 environment using VLAN 1.

```text
Cisco Managed Switch
        │
        ▼
      VLAN 1
        │
   ┌────┼─────────────┐
   │    │             │
   ▼    ▼             ▼
Servers Management  Trusted
        Systems     Devices
```

Management systems, servers, hypervisors, storage, and other trusted wired devices currently share the same Layer 2 network.

This provides centralized connectivity but does not provide security segmentation between wired device classes.

The lack of wired segmentation is a known limitation and is intentionally documented rather than representing the planned VLAN architecture as already deployed.

## Current Trust Model

| Trust Area | Examples | Current Isolation |
|---|---|---|
| Trusted Wired | Servers, hypervisors, NAS, infrastructure management | Shared VLAN 1 |
| Trusted Wireless | Authorized user endpoints | Internal network access |
| Guest / IoT | Guest and IoT wireless devices | Router-based wireless isolation |

Administrative services are intended to remain accessible only from trusted networks or through secure remote-access paths.

SSH key-based administrative access is implemented where configured, with broader SSH hardening still in progress.

## Current Limitations

The current architecture has several known limitations:

- Wired infrastructure remains on VLAN 1.
- Management systems are not yet isolated on a dedicated management network.
- Servers and trusted endpoints do not yet have separate security zones.
- Inter-network traffic is not yet governed by dedicated zone-based firewall policies.
- OPNsense has not yet replaced the current gateway.
- IDS/IPS has not yet been deployed.
- Centralized network-security logging remains a future capability.
- SSH hardening is not yet universally deployed.

These limitations define the next phase of the network security lab.

## Target Architecture

The planned architecture introduces OPNsense as the primary firewall and uses VLANs to establish security zones.

```text
                            Internet
                               │
                               ▼
                            OPNsense
                    Firewall / VPN / Security
                               │
                               │ 802.1Q
                               ▼
                     Cisco Managed Switch
                               │
          ┌────────────┬───────┼───────┬────────────┐
          │            │       │       │            │
          ▼            ▼       ▼       ▼            ▼
     Management      Servers Trusted   IoT         Guest
        VLAN           VLAN    VLAN    VLAN         VLAN
```

The target design will move security enforcement from a primarily flat trusted network toward explicit security zones.

Communication between zones will be governed by firewall policy rather than unrestricted Layer 2 connectivity.

## Planned Security Zones

| Zone | Purpose |
|---|---|
| Management | Hypervisors, switches, firewalls, and infrastructure management |
| Servers | Internal infrastructure and application services |
| Trusted | Authorized user endpoints |
| IoT | Smart devices and other lower-trust systems |
| Guest | Internet access for untrusted guest devices |

Specific VLAN IDs, subnets, firewall rules, and access policies will be documented only after implementation and validation.

