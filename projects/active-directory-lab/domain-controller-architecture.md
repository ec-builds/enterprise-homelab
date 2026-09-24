# 🖥️ Domain Controller Architecture

This document defines the current deployment architecture for the Active Directory domain controllers used in the homelab.

> [!NOTE]
> Hostnames and infrastructure identifiers shown in this document have been sanitized for public release.

## Platform

The domain controllers are deployed as virtual machines on the existing **Proxmox VE cluster**.

Proxmox provides the virtualization foundation for the homelab and allows the domain controllers to be distributed across separate physical hosts.

```text
Proxmox VE Cluster
      │
      ├── prox-lab-01
      │     └── dc-lab-01
      │
      └── prox-lab-02
            └── dc-lab-02
```

The environment uses two domain controllers distributed across separate Proxmox hosts. This provides directory, DNS, and DHCP redundancy while reducing dependency on a single virtual machine or virtualization host.

For additional information about the virtualization platform, architecture, and resource strategy, see the [Proxmox Virtualization Lab](../proxmox-virtualization-lab/).

## Operating System

The domain controllers use:

**Windows Server 2025 Standard Evaluation (Desktop Experience)**

Desktop Experience was selected to provide the full graphical Windows Server administration environment while building and learning the Active Directory environment.

The graphical installation provides access to tools such as:

- Server Manager
- Active Directory Users and Computers
- Group Policy Management
- DNS Manager
- DHCP Manager
- Event Viewer
- Active Directory Administrative Center

PowerShell is also used for administration, validation, and automation.

## Domain Controller Configuration

### Primary Domain Controller

`dc-lab-01` is deployed as a virtual machine on `prox-lab-01`.

| Setting | Configuration |
|---|---|
| **VM** | `dc-lab-01` |
| **Server Hostname** | `dc-lab-01` |
| **Proxmox Host** | `prox-lab-01` |
| **Operating System** | Windows Server 2025 Standard Evaluation |
| **Installation** | Desktop Experience |
| **vCPU** | 2 |
| **Memory** | 2 GB |
| **System Disk** | 64 GB |
| **Machine Type** | q35 |
| **Firmware** | OVMF (UEFI) |
| **Storage Controller** | VirtIO SCSI |
| **Network Adapter** | VirtIO |
| **QEMU Guest Agent** | Enabled |
| **Network Addressing** | Static |

### Secondary Domain Controller

`dc-lab-02` is deployed as an additional domain controller on `prox-lab-02`.

The second domain controller provides replicated directory and DNS services and participates in DHCP failover with `dc-lab-01`.

Both domain controllers are configured as Global Catalog servers.

The virtual machines use intentionally modest resources because their workloads primarily consist of Active Directory Domain Services, DNS, and DHCP.

Resources can be increased if monitoring indicates additional capacity is required.

## Domain Controller Roles

### `dc-lab-01`

```text
dc-lab-01
├── Active Directory Domain Services
├── DNS
├── DHCP
└── Global Catalog
```

`dc-lab-01` provides directory, DNS, and DHCP services for the lab.

### `dc-lab-02`

```text
dc-lab-02
├── Active Directory Domain Services
├── DNS
├── DHCP
└── Global Catalog
```

`dc-lab-02` operates as an additional domain controller and provides redundant directory, DNS, and DHCP services.

The two DHCP servers participate in a failover relationship, allowing DHCP service to continue when either individual DHCP server is unavailable.

## Redundancy Strategy

The two domain controllers are distributed across separate Proxmox hosts.

```text
             Active Directory Domain
                       │
            ┌──────────┴──────────┐
            │                     │
            ▼                     ▼
       dc-lab-01 ◄── AD/DNS ──► dc-lab-02
            │       Replication    │
            │                      │
            └──── DHCP Failover ───┘
            │                      │
            ▼                      ▼
       prox-lab-01            prox-lab-02
```

This design reduces dependency on any individual domain controller or virtualization host for core directory, DNS, and DHCP services.

The multi-domain-controller environment also provides hands-on experience with:

- Active Directory replication
- DNS redundancy
- DHCP failover
- Global Catalog redundancy
- FSMO role management
- Domain controller maintenance
- Active Directory Sites and Services
- Domain controller failure and recovery

## DNS Architecture

Both domain controllers host Active Directory-integrated DNS and replicate the internal DNS zones through Active Directory.

Domain controller DNS client configuration uses the peer domain controller as the preferred DNS server and the local DNS service as the alternate. This reduces dependency on a single DNS server while retaining local DNS availability.

Clients receive both domain controllers as DNS servers through DHCP.

External DNS queries are forwarded from the Active Directory DNS servers to two redundant AdGuard Home instances for filtering and encrypted upstream resolution.

```text
                    Internal Clients
                           │
                ┌──────────┴──────────┐
                ▼                     ▼
           dc-lab-01              dc-lab-02
             AD DNS                 AD DNS
                │                     │
                └──────────┬──────────┘
                           ▼
                 Redundant AdGuard Home
                   │               │
                   ▼               ▼
             adguard-lab-01   adguard-lab-02
                   │               │
                   └───────┬───────┘
                           │
                  DNS Filtering + DoH
                           │
                           ▼
                  Public DNS Resolvers
```

Both Active Directory DNS servers are configured with both AdGuard Home instances as external DNS forwarders.

The AdGuard instances are distributed across separate virtualization hosts to reduce dependency on a single failure domain. Individual AdGuard instances have been taken offline during controlled testing while external DNS resolution continued through the remaining instance.

This architecture preserves Active Directory DNS as the authoritative internal DNS layer while adding network-wide filtering and encrypted upstream DNS resolution.

DNS encryption applies to the AdGuard-to-public-resolver portion of the resolution path. DNS traffic between internal clients, Active Directory DNS, and AdGuard remains standard DNS within the trusted internal network.

## DHCP Architecture

DHCP is provided by both domain controllers using Windows Server DHCP failover.

```text
                 Client Network
                       │
            ┌──────────┴──────────┐
            │                     │
            ▼                     ▼
       dc-lab-01              dc-lab-02
         DHCP       ◄────►       DHCP
                    Failover
```

The DHCP servers distribute:

- IPv4 addressing
- Default gateway information
- Both Active Directory DNS servers
- Internal DNS domain information

The two DHCP servers operate in a load-balanced failover relationship.

Controlled failure testing confirmed DHCP service continuity with either individual DHCP server unavailable.

DHCP-managed dynamic DNS registration is intentionally disabled. Domain-joined Windows systems can securely register their own records with Active Directory DNS, while static infrastructure and selected non-domain systems are manually registered when internal name resolution is required.

## Replication and Service Validation

The deployment was validated to confirm that the two-domain-controller architecture operates as intended.

Validation included:

- Active Directory replication between both domain controllers
- Domain, Configuration, Schema, DomainDnsZones, and ForestDnsZones replication
- Active Directory-integrated DNS replication
- Global Catalog availability on both domain controllers
- SYSVOL and NETLOGON availability
- LDAP and Kerberos service discovery through DNS SRV records
- Internal hostname resolution
- External DNS resolution
- DHCP failover operation
- DHCP service continuity with each individual DHCP server unavailable
- Client DNS continuity with an individual Active Directory DNS server unavailable
- AdGuard external DNS continuity with each individual AdGuard instance unavailable

Active Directory replication and DNS diagnostic testing completed successfully without active replication or DNS failures.

## Deployment Strategy

The environment was deployed incrementally so each infrastructure layer could be validated before introducing additional redundancy and dependencies.

```text
Deploy dc-lab-01
      │
      ▼
Configure Windows Server
      │
      ▼
Configure Static Networking
      │
      ▼
Install AD DS + DNS
      │
      ▼
Create Active Directory Forest
      │
      ▼
Validate Initial AD Environment
      │
      ▼
Deploy dc-lab-02
      │
      ▼
Promote Additional Domain Controller
      │
      ▼
Validate AD + DNS Replication
      │
      ▼
Deploy Windows Server DHCP
      │
      ▼
Configure DHCP Failover
      │
      ▼
Validate DHCP Continuity
      │
      ▼
Integrate Redundant AdGuard Forwarders
      │
      ▼
Validate DNS and Forwarder Failover
```

This incremental approach allowed directory services, DNS, DHCP, and external DNS forwarding to be validated independently before relying on the complete architecture.

## Current Deployment State

| Capability | Status |
|---|---|
| `dc-lab-01` | 🟢 Operational |
| `dc-lab-02` | 🟢 Operational |
| Active Directory Domain Services | 🟢 Operational |
| Global Catalog redundancy | 🟢 Operational |
| AD-integrated DNS | 🟢 Operational |
| DNS replication | 🟢 Operational |
| Windows Server DHCP | 🟢 Operational |
| DHCP failover | 🟢 Operational |
| Redundant external DNS forwarding | 🟢 Operational |
| AdGuard DNS filtering | 🟢 Operational |
| DNS-over-HTTPS upstream resolution | 🟢 Operational |

> [!NOTE]
> **The resulting architecture uses two replicated domain controllers distributed across separate Proxmox hosts, providing redundant Active Directory, DNS, and DHCP services while reducing dependency on any single virtual machine or virtualization host.**
