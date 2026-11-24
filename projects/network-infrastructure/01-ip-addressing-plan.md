# IP Addressing Strategy

**Status: 🟢 Operational**

How addresses are assigned in the homelab: which systems are static, which use DHCP, and how the plan leaves room for VLAN segmentation.

> **Note:** Real subnets, allocation ranges and VLAN IDs are left out of public documentation. Public docs use the placeholder scheme in [Naming Conventions](../../docs/standards/naming-conventions.md#ip-addressing).

## Addressing Model

| System Type | Addressing Method |
|---|---|
| Foundational infrastructure | Static |
| Persistent infrastructure services | Static where needed |
| User endpoints | DHCP |
| IoT and general client devices | DHCP |
| Temporary lab systems | DHCP |
| Devices that need a predictable DHCP address | DHCP reservation |

Systems that other services depend on, such as routing and firewall devices, network management interfaces, directory and DNS servers, DHCP servers, hypervisors, storage and persistent services, are statically addressed so they don't rely on DHCP for their own configuration.

Static assignments are tracked in the address plan and device inventory, separately from DHCP leases, to avoid conflicts.

```text
Private Address Space
├── Infrastructure ── Static addressing
├── Client Address Space
│   ├── Dynamic DHCP
│   └── DHCP reservations
└── Reserved Capacity ── Future expansion
```

DHCP manages only the ranges set aside for dynamic leases and reservations.

## DHCP

Two Windows Server DHCP servers run in a failover pair, so leasing continues if either one is down. They hand out addresses, the default gateway, DNS servers and the DNS domain, and manage leases and reservations. Reservations give a DHCP device a fixed address without configuring it locally.

Details are in [DHCP Infrastructure](./03-dhcp-infrastructure.md).

## DNS Integration

Redundant Active Directory-integrated DNS handles internal name resolution. DHCP clients receive the internal DNS servers through scope options; static systems are configured with them directly.

## Network Segmentation

The addressing plan is built to move to VLANs later. Each VLAN will be its own Layer 3 network with its own subnet, a DHCP scope where clients need one, and firewall rules controlling traffic between VLANs. Planned groups include management, trusted endpoints, servers, IoT and guests. Infrastructure that must not depend on DHCP stays static.

The proposed VLAN layout is in the [VLAN Implementation](../network-security/TODO-vlan-implementation-plan.md) plan.

An IPAM tool may be added later to track subnets, static assignments, DHCP ranges, reservations, VLANs and utilization in one place.

## Change Management

1. Confirm the address is free.
2. Assign it statically or through DHCP, as appropriate.
3. Update the device inventory.
4. Update network documentation if needed.
5. Test DNS and connectivity.
6. Include the configuration in backups if relevant.

## When to Review

- Infrastructure systems are added or removed
- DHCP scopes or reservations change
- New subnets or VLANs are deployed
- DNS or DHCP architecture changes
