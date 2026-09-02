# 🌐 Static IP vs. DHCP

This reference defines when homelab systems should use a manually configured static IP address, a DHCP reservation, or a dynamic DHCP address.

Specific address assignments and subnet ranges are documented separately in the [IP Addressing Plan](./ip-addressing-plan.md).

## Addressing Methods

| Method | Use Case |
|---|---|
| **Static IP** | Foundational infrastructure that should not depend on DHCP |
| **DHCP Reservation** | Persistent systems that need a predictable address |
| **DHCP** | Clients and temporary systems |

The general strategy is:

> **Foundational infrastructure → Static**  
> **Persistent services → DHCP reservation**  
> **Clients → DHCP**

## Static IP

A static IP is configured directly on the device rather than assigned by a DHCP server.

Use static addressing when the system provides a service required for basic infrastructure operation.

Typical examples:

- Routers and firewalls
- Managed switch management interfaces
- Proxmox hypervisors
- Domain controllers
- DNS servers
- DHCP servers
- VPN gateways

These systems should remain reachable even when DHCP is unavailable.

## DHCP Reservation

A DHCP reservation assigns a predictable IP address while keeping network configuration centrally managed by DHCP.

Use reservations for persistent systems that benefit from a consistent address but do not need to operate independently of DHCP.

Typical examples:

- NAS / storage
- Docker hosts
- Monitoring servers
- Backup servers
- Application servers
- Printers
- Security monitoring systems

Reservations simplify changes to DNS servers, gateways, and other DHCP-provided network settings.

## Dynamic DHCP

Dynamic DHCP should be used for systems that do not require a predictable address.

Typical examples:

- Windows client systems
- Laptops
- Phones and tablets
- IoT devices
- Guest devices
- Temporary test VMs

## Decision Guide

```text
Does the system provide foundational
network or infrastructure services?
             │
        ┌────┴────┐
       YES        NO
        │          │
        ▼          ▼
     STATIC     Does it need a
                predictable IP?
                     │
                ┌────┴────┐
               YES        NO
                │          │
                ▼          ▼
          DHCP RESERVATION DHCP
```

## Homelab Examples

| System | Recommended Method |
|---|---|
| Router / Firewall | **Static** |
| Managed Switch | **Static** |
| Proxmox Host | **Static** |
| Domain Controller / DNS | **Static** |
| DHCP Server | **Static** |
| NAS | **Reservation or Static** |
| Docker Host | **DHCP Reservation** |
| Monitoring Server | **DHCP Reservation** |
| Backup Server | **DHCP Reservation** |
| Printer | **DHCP Reservation** |
| Windows Client | **DHCP** |
| Temporary VM | **DHCP** |

> [!NOTE]
> A server does not automatically require a static IP. Static addressing is primarily reserved for systems where a dependency on DHCP could affect core infrastructure. DHCP reservations remain preferred for most persistent workloads.
