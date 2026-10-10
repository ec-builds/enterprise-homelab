# IP Addressing Strategy

**Status: 🟢 Active**

> **Note:** Network addresses, allocation ranges, VLAN identifiers, and implementation-specific details have been intentionally omitted or generalized for public documentation.

This document describes the addressing principles used to organize the homelab environment. The design emphasizes predictable infrastructure addressing, centralized client configuration, service availability, and capacity for future network segmentation.

## Addressing Model

The environment uses a combination of static addressing and DHCP based on system role and infrastructure dependencies.

| System Type | Addressing Method |
|---|---|
| Foundational infrastructure | Static |
| Persistent infrastructure services | Static where appropriate |
| User endpoints | DHCP |
| IoT and general client devices | DHCP |
| Temporary lab systems | DHCP |
| Devices requiring a predictable DHCP address | DHCP Reservation |

Foundational systems are configured so that essential network services do not depend on DHCP for their own addressing.

DHCP is used to centrally distribute network configuration to client systems and simplify endpoint management.

## Static Infrastructure

Static addressing is used for systems where predictable addressing or independence from DHCP is operationally important.

Examples may include:

- Routing and firewall infrastructure
- Network management interfaces
- Directory and name-resolution services
- DHCP infrastructure
- Hypervisors
- Storage
- Persistent infrastructure services

Static assignments are documented separately from DHCP lease information to prevent address conflicts and maintain an authoritative inventory.

## DHCP

DHCP provides centralized network configuration for endpoints and temporary systems.

The DHCP environment supports:

- Dynamic address allocation
- Scope options
- Default gateway distribution
- DNS server distribution
- DNS domain configuration
- Lease management
- Reservations
- DHCP failover

DHCP reservations may be used when a DHCP-managed device requires a predictable address without requiring locally configured static addressing.

## DHCP Availability

DHCP services are deployed redundantly using Windows Server DHCP failover.

This provides continued DHCP availability if an individual DHCP server becomes unavailable and allows DHCP configuration to be maintained across the failover relationship.

Foundational infrastructure remains statically addressed and does not depend on DHCP availability for its own network configuration.

## DNS Integration

Internal name resolution is provided through redundant Active Directory-integrated DNS services.

DHCP clients receive the appropriate internal DNS configuration through DHCP scope options. Statically addressed infrastructure is configured with the appropriate DNS settings directly.

This provides consistent internal name resolution while maintaining redundancy for core DNS services.

## Address Management

DHCP manages only address space delegated for dynamic allocation or reservations.

Static infrastructure is managed separately through the addressing plan and device inventory.

```text
Private Address Space
│
├── Infrastructure
│   └── Static addressing
│
├── Client Address Space
│   ├── Dynamic DHCP
│   └── DHCP reservations
│
└── Reserved Capacity
    └── Future expansion
```

A dedicated IP Address Management (IPAM) platform may be introduced as the environment grows to provide centralized visibility into:

- Subnets
- Static assignments
- DHCP-managed address space
- Reservations
- VLANs
- Address utilization

## Network Segmentation

The current addressing model is designed to support migration toward a segmented network architecture.

Future segmentation will use VLANs to separate systems by function, with dedicated subnets, DHCP scopes where appropriate, and firewall policies controlling inter-VLAN communication.

Planned segmentation may separate systems such as:

- Management infrastructure
- Trusted endpoints
- Servers and services
- IoT devices
- Guest devices

Each VLAN will operate as a separate Layer 3 network with its own subnet. DHCP scopes will be deployed where dynamic addressing is required, while infrastructure requiring DHCP independence may continue to use static addressing.

Inter-VLAN communication will be controlled through firewall policy rather than relying solely on logical address organization for separation.

Specific VLAN identifiers, subnet assignments, and firewall policies are intentionally excluded from public documentation.

## Change Management

Addressing changes should follow a documented process:

1. Verify that the proposed address is available.
2. Assign the address using the appropriate static or DHCP method.
3. Update the device inventory.
4. Update network documentation where applicable.
5. Validate DNS and network connectivity.
6. Include infrastructure configuration in backup procedures where applicable.

## Maintenance

Review the addressing strategy when:

- Infrastructure systems are added or removed
- DHCP scopes change
- Reservations are introduced or retired
- New subnets or VLANs are deployed
- DNS or DHCP architecture changes
- Network segmentation is introduced
