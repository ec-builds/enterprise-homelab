# DHCP Infrastructure

## Overview

DHCP services were migrated from the network gateway to Windows Server to provide centralized address management, Active Directory integration, and service redundancy.

The current environment uses two Windows Server DHCP servers configured with a failover relationship. Together they provide dynamic client addressing and distribute the network configuration required for clients to reach the gateway, internal DNS services, and the Active Directory domain.

This design removes DHCP as a dependency of the consumer gateway and places the service within the Windows infrastructure where it can be centrally managed and monitored.

> [!NOTE]
> Implementation-specific IP addresses, DHCP ranges, server addresses, and infrastructure assignments are intentionally omitted or generalized in public documentation.

## Architecture

```text
                         Client
                           │
                     DHCP Request
                           │
                           ▼
                Windows DHCP Infrastructure
                           │
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
          DHCP Server 01        DHCP Server 02
                │                     │
                └──────────┬──────────┘
                           │
                  Failover Relationship
                           │
                           ▼
                  DHCP Configuration
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
         IP Address      Gateway    Internal DNS
```

Both DHCP servers participate in the same DHCP service design and provide redundancy for client address assignment.

## DHCP Scope Design

The DHCP scope provides dynamically assigned addresses for client systems while keeping infrastructure addressing outside the dynamic allocation range.

```text
Private Network
│
├── Infrastructure Address Space
│   └── Static infrastructure systems
│
├── Dynamic Client Range
│   └── DHCP-assigned endpoints
│
└── Reserved Capacity
    └── Infrastructure growth and reservations
```

This approach keeps infrastructure addressing predictable while allowing client endpoints to receive their configuration automatically.

DHCP reservations can be used where a client requires consistent addressing without configuring a static address directly on the endpoint.

## DHCP Options

The DHCP infrastructure distributes the primary network configuration required by client devices.

| Configuration | Purpose |
|---|---|
| IP Address | Provides the client with an address from the configured scope |
| Subnet Mask | Defines the local network boundary |
| Default Gateway | Provides access outside the local network |
| DNS Servers | Directs clients to the internal Active Directory DNS servers |
| DNS Domain | Provides the internal domain suffix |

Clients receive the Active Directory DNS servers rather than querying AdGuard Home or public DNS resolvers directly.

This preserves internal domain resolution and Active Directory service discovery.

## DNS Integration

DHCP and DNS are designed as complementary infrastructure services.

```text
DHCP Client
     │
     │ Receives DNS Configuration
     ▼
Active Directory DNS
     │
     ├── Internal Query
     │       │
     │       └── Resolved Internally
     │
     └── External Query
             │
             ▼
       AdGuard Home
             │
             ▼
     Public DNS Resolver
```

DHCP provides clients with the internal DNS server addresses.

Active Directory DNS handles internal domain resolution and forwards external requests to the redundant AdGuard Home infrastructure.

This keeps Active Directory DNS authoritative for the internal environment while allowing external DNS traffic to receive filtering and encrypted upstream resolution.

## Active Directory Authorization

The Windows DHCP servers are authorized within Active Directory before providing DHCP services.

This allows DHCP to remain integrated with the Windows domain infrastructure and helps prevent unauthorized Windows DHCP servers from providing addresses within the domain environment.

```text
Active Directory
      │
      ├── Authorized DHCP Server 01
      │
      └── Authorized DHCP Server 02
```

Both DHCP servers are authorized as part of the deployed infrastructure.

## DHCP Failover

The two DHCP servers are configured with a failover relationship to reduce dependency on a single DHCP server.

```text
                    DHCP Scope
                        │
             ┌──────────┴──────────┐
             │                     │
             ▼                     ▼
       DHCP Server 01        DHCP Server 02
             │                     │
             └────── Failover ─────┘
```

The failover relationship allows DHCP service to remain available when one of the participating servers is unavailable.

This provides greater resilience than the original gateway-hosted DHCP configuration.

## Failure Testing

DHCP availability was validated through controlled failure testing.

The objective was to verify that the loss of an individual DHCP server would not prevent clients from obtaining network configuration.

| Test | Expected Result | Result |
|---|---|:---:|
| Both DHCP servers available | Client receives DHCP configuration | Pass |
| DHCP Server 01 unavailable | DHCP service remains available | Pass |
| DHCP Server 02 unavailable | DHCP service remains available | Pass |
| Internal DNS distributed through DHCP | Client uses AD DNS | Pass |
| Default gateway distributed through DHCP | Client receives gateway configuration | Pass |

Testing confirmed that DHCP service remains available when either individual DHCP server is unavailable.

## Migration from Gateway DHCP

DHCP was originally provided by the ASUS network gateway.

The service was migrated to Windows Server as the Active Directory environment matured.

```text
Original Design

Clients
   │
   ▼
ASUS Gateway
   │
   └── DHCP


Current Design

Clients
   │
   ▼
Windows DHCP
   │
   ├── DHCP Server 01
   └── DHCP Server 02
          │
          ▼
     Failover
```

Moving DHCP away from the gateway provided:

- Centralized Windows-based DHCP administration
- Integration with Active Directory
- Redundant DHCP services
- Better separation of infrastructure responsibilities
- Greater flexibility for future network expansion
- A foundation for future segmented network scopes

The original migration process is retained separately in the project archive for historical reference.

## Service Dependencies

DHCP is part of a larger network-services architecture.

```text
                    Network Clients
                          │
                          ▼
                         DHCP
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
         IP / Gateway             AD DNS
                                      │
                         ┌────────────┴────────────┐
                         │                         │
                         ▼                         ▼
                   Internal DNS              External DNS
                                                   │
                                                   ▼
                                             AdGuard Home
                                                   │
                                                   ▼
                                                  DoH
```

The DHCP service does not perform DNS filtering itself. Its role is to direct clients toward the appropriate internal DNS infrastructure.

## Operational Considerations

The current design follows several operational principles:

- Infrastructure systems use predictable addressing.
- Dynamic client addressing is centrally managed through Windows Server.
- Clients receive internal Active Directory DNS servers through DHCP.
- Redundant DHCP servers reduce dependence on a single Windows Server.
- DHCP and DNS roles remain logically separate.
- DHCP configuration is maintained independently from the Internet gateway.
- Failure testing is performed to verify redundancy rather than assuming failover works.

## Current State

| Component | Status |
|---|:---:|
| Windows Server DHCP | 🟢 Operational |
| Active Directory Authorization | 🟢 Operational |
| DHCP Scope | 🟢 Operational |
| DHCP Options | 🟢 Operational |
| Internal DNS Distribution | 🟢 Operational |
| DHCP Failover | 🟢 Operational |
| Failover Testing | 🟢 Validated |

## Future Improvements

Future VLAN-based segmentation will require DHCP services to support multiple logical networks.

Potential future work includes:

- Dedicated DHCP scopes for each network segment
- DHCP relay across routed VLAN interfaces
- Segment-specific DNS and gateway options
- Additional DHCP monitoring and alerting
- Validation of DHCP availability across segmented networks

These changes will be documented when the VLAN architecture is implemented.
