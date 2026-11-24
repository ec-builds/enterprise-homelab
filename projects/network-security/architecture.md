# Network Security Architecture

## Overview

The security boundaries, trust model and known gaps of the homelab network today, and the segmented design it's moving toward.

The ASUS RT-AX5400 is the internet-facing gateway and security boundary. Wired systems connect through a Cisco managed switch on a flat VLAN 1 network, and guest and IoT devices are isolated on the router's guest wireless network.

> [!NOTE]
> Real IP addresses, credentials, VPN configuration and exact infrastructure assignments are omitted or generalized in public documentation.

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
               ▼                             ▼
        Trusted Network                Guest / IoT
               │                        Wireless
               ▼                             │
      Cisco Managed Switch                   ▼
               │                      Internet only;
               ▼                      internal access
             VLAN 1                     restricted
               │
      ┌────────┼─────────┐
      ▼        ▼         ▼
   Servers  Management  Trusted
            Systems     Devices
```

| Layer | Current Control |
|---|---|
| Internet Perimeter | Stateful firewall and NAT |
| Inbound Exposure | Internal services not exposed unless required |
| Remote Access | WireGuard VPN |
| DNS | AdGuard Home filtering and encrypted upstream DNS |
| Wireless | Trusted and isolated guest/IoT networks |
| Administrative Access | SSH key-based access where implemented |
| Switching | Cisco managed switching |
| Wired Segmentation | Flat VLAN 1 network; segmentation planned |
| Monitoring | Infrastructure and service availability monitoring |

## Security Boundaries

**Perimeter and remote access.** The ASUS stateful firewall and NAT block unsolicited inbound connections, and internal services aren't exposed directly. Remote administration goes through WireGuard on the ASUS instead of exposing management interfaces.

```text
Remote Device ──WireGuard──► Internet ──► ASUS RT-AX5400 ──► Trusted Internal Network
```

**DNS.** Clients query Active Directory DNS, which forwards external lookups to two AdGuard Home instances. They filter requests and resolve upstream over DNS-over-HTTPS, and they run on separate Proxmox hosts so one host failure doesn't stop DNS. Implementation details are in [DNS Filtering with AdGuard Home](../network-infrastructure/04-dns-filtering-adguard-home.md).

**Wireless.** Trusted devices join the internal network. Guest and IoT devices use the isolated guest network, which allows internet access but blocks internal resources. This is the main isolation for untrusted devices until VLANs exist.

**Wired network.** Servers, hypervisors, storage, management interfaces and other trusted wired devices all share VLAN 1. That gives simple connectivity but no segmentation between device types, and it's documented here as a known limitation, not presented as the target design.

## Current Trust Model

| Trust Area | Examples | Current Isolation |
|---|---|---|
| Trusted Wired | Servers, hypervisors, NAS, infrastructure management | Shared VLAN 1 |
| Trusted Wireless | Authorized user endpoints | Internal network access |
| Guest / IoT | Guest and IoT wireless devices | Router-based wireless isolation |

Administrative services should be reachable only from trusted networks or over the VPN. SSH key-based access is in place where configured; broader hardening is in progress.

## Current Limitations

- Wired infrastructure is still on VLAN 1.
- Management systems aren't isolated on their own network.
- Servers and trusted endpoints don't have separate zones.
- No zone-based firewall policy controls internal traffic.
- OPNsense hasn't replaced the current gateway for the homelab.
- IDS/IPS isn't deployed.
- Centralized network-security logging is still planned.
- SSH hardening isn't deployed everywhere.

These gaps define the next phase of the lab.

## Target Architecture

OPNsense becomes the homelab's firewall behind the ASUS, which stays the internet gateway for household devices. VLANs on a trunk to the Cisco switch create the security zones, and traffic between zones passes through OPNsense firewall policy instead of flowing freely on one Layer 2 network.

```text
                            Internet
                               │
                               ▼
                        ASUS RT-AX5400
                     Household network / Wi-Fi
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
          ▼            ▼       ▼       ▼            ▼
     Management      Servers Trusted   IoT         Guest
        VLAN           VLAN    VLAN    VLAN         VLAN
```

| Zone | Purpose |
|---|---|
| Management | Hypervisors, switches, firewalls and infrastructure management |
| Servers | Internal infrastructure and application services |
| Trusted | Authorized user endpoints |
| IoT | Smart devices and other lower-trust systems |
| Guest | Internet access for untrusted guest devices |

Proposed VLAN IDs are in the [VLAN Implementation](./TODO-vlan-implementation-plan.md) plan, and the firewall design is in the [OPNsense Firewall Deployment](./TODO-opnsense-deployment-plan.md) plan. Final firewall rules and access policies will be documented after implementation and testing.
