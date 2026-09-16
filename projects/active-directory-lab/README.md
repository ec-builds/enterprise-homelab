# 🏢 Active Directory Lab

**Status: 🟡 In Progress**

Enterprise identity and access management environment built with Windows Server and Active Directory Domain Services, hosted across the Proxmox virtualization lab.

The environment provides redundant directory, DNS, and DHCP services and serves as the on-premises identity foundation for future Microsoft Entra ID and endpoint management labs.

<p align="left">
  <img src="./diagrams/dc-lab-01-desktop.png" alt="Windows Server 2025 domain controller running Active Directory Domain Services" width="1000">
</p>

*Windows Server 2025 domain controller with Active Directory Domain Services deployed.*


## Architecture

The Active Directory environment uses two domain controllers distributed across separate Proxmox hosts.

```text
Proxmox Cluster
│
├── prox-lab-01
│   └── dc-lab-01
│       ├── Active Directory Domain Services
│       ├── DNS
│       ├── DHCP
│       └── Global Catalog
│
└── prox-lab-02
    └── dc-lab-02
        ├── Active Directory Domain Services
        ├── DNS
        ├── DHCP
        └── Global Catalog
             │
             ▼
      AD Replication
```

Both domain controllers provide Active Directory-integrated DNS and participate in a load-balanced DHCP failover relationship.

Separating the domain controllers across Proxmox hosts provides continued directory, DNS, and DHCP availability if a domain controller or virtualization host becomes unavailable.


## Objectives

- Deploy a multi-domain-controller Active Directory environment
- Distribute domain controllers across separate Proxmox hosts
- Configure and validate Active Directory replication
- Deploy redundant AD-integrated DNS
- Deploy redundant Windows DHCP using load-balanced failover
- Design an OU structure modeling a real business
- Implement users, groups, and role-based access using AGDLP principles
- Implement Group Policy for security baselines and configuration management
- Manage users, groups, and computers at scale with PowerShell
- Deploy and manage Windows domain clients
- Implement service account management
- Apply Active Directory security and auditing controls
- Develop backup and recovery procedures
- Establish the on-premises identity foundation for future Microsoft Entra ID integration


## Technologies

- Proxmox VE
- Windows Server
- Active Directory Domain Services
- Active Directory-integrated DNS
- Windows Server DHCP
- DHCP Failover
- Group Policy Management Console
- Active Directory Sites and Services
- PowerShell
- Windows 10/11 domain-joined clients


## Domain Controllers

| Server | Proxmox Host | Roles | Status |
|---|---|---|---|
| `dc-lab-01` | `prox-lab-01` | AD DS, DNS, DHCP, Global Catalog | ✅ Active |
| `dc-lab-02` | `prox-lab-02` | AD DS, DNS, DHCP, Global Catalog | ✅ Active |

Both domain controllers provide directory and DNS services. DHCP is configured using a 50/50 load-balanced failover relationship.

Active Directory replication, DNS redundancy, DHCP redundancy, and single-server failure recovery have been validated.

FSMO role placement will be documented as part of the continuing Active Directory administration phase.


## Identity Management Roadmap

With the core directory infrastructure operational, the next phase focuses on Active Directory administration, access management, policy enforcement, and security.

```text
Directory Infrastructure
        │
        ├── AD DS
        ├── DNS
        ├── DHCP
        └── Replication
              │
              ▼
        OU Structure
              │
              ▼
       Users and Groups
              │
              ▼
      Access Assignment
          (AGDLP)
              │
              ▼
        Group Policy
              │
              ▼
    Windows Client Management
              │
              ▼
      Service Accounts
              │
              ▼
     AD Security / Auditing
              │
              ▼
      Backup / Recovery
              │
              ▼
       Hybrid Identity
              │
              ▼
      Microsoft Entra ID
```

This sequence builds identity administration and security capabilities on top of the redundant directory services foundation before introducing hybrid cloud identity.


## Key Tasks

### Completed

- [x] Deploy `dc-lab-01` Windows Server VM on `prox-lab-01`
- [x] Configure static network addressing
- [x] Install Active Directory Domain Services
- [x] Create the Active Directory forest and domain
- [x] Promote `dc-lab-01` as the first domain controller
- [x] Configure and validate AD-integrated DNS
- [x] Deploy `dc-lab-02` on a separate Proxmox host
- [x] Promote `dc-lab-02` as an additional domain controller
- [x] Enable DNS and Global Catalog services on both domain controllers
- [x] Validate bidirectional Active Directory replication
- [x] Validate `DomainDnsZones` and `ForestDnsZones` replication
- [x] Configure redundant DNS client resolution
- [x] Validate DNS service discovery and external resolution
- [x] Configure Windows DHCP on both domain controllers
- [x] Authorize both DHCP servers in Active Directory
- [x] Configure DHCP scope and client options
- [x] Configure 50/50 load-balanced DHCP failover
- [x] Migrate clients from the previous DHCP service
- [x] Validate DHCP client configuration
- [x] Perform bidirectional DHCP failure testing
- [x] Validate DNS continuity during a domain controller outage
- [x] Validate recovery to normal operation following server restoration

### Next Phase

- [ ] Design organizational unit structure
- [ ] Create users, groups, and administrative structure
- [ ] Implement AGDLP-based access assignment
- [ ] Join and organize Windows client systems
- [ ] Configure and validate Group Policy
- [ ] Automate user and group administration with PowerShell

### Planned

- [ ] Implement service account management
- [ ] Configure Active Directory security and auditing controls
- [ ] Generate identity and group membership audit reports with PowerShell
- [ ] Document FSMO role placement
- [ ] Configure and document Active Directory Sites and Services
- [ ] Develop Active Directory backup and recovery procedures
- [ ] Validate directory recovery procedures
- [ ] Integrate the environment with Microsoft Entra ID


## Deployment Progress

```text
dc-lab-01 Deployment           ██████████  Complete
Forest / Domain Creation       ██████████  Complete
AD DS Deployment               ██████████  Complete
dc-lab-02 Deployment           ██████████  Complete
AD Replication                 ██████████  Complete
DNS Configuration              ██████████  Complete
DNS Redundancy Testing         ██████████  Complete
DHCP Configuration             ██████████  Complete
DHCP Failover                  ██████████  Complete
DHCP Failure Testing           ██████████  Complete
OU Design                      ░░░░░░░░░░  Next
Users / Groups / Access        ░░░░░░░░░░  Planned
Group Policy                   ░░░░░░░░░░  Planned
Client Management              ░░░░░░░░░░  Planned
AD Security / Auditing         ░░░░░░░░░░  Planned
Backup / Recovery              ░░░░░░░░░░  Planned
Hybrid Identity                ░░░░░░░░░░  Future
```

The redundant directory services foundation is complete. The next phase moves from infrastructure deployment into identity administration, beginning with OU design, users and groups, access assignment, and Group Policy.


## Lab Documentation

Detailed implementation documentation is maintained separately from this project overview.

```text
active-directory-lab/
├── diagrams/
├── README.md
├── domain-controller-architecture.md
├── domain-controller-deployment.md
├── active-directory-DNS.md
├── active-directory-DHCP.md
│
├── organizational-unit-design.md
├── users-groups-and-access.md
├── group-policy.md
├── windows-client-management.md
├── service-accounts.md
├── active-directory-security.md
└── active-directory-backup-recovery.md
```

Completed lab documents describe the deployed environment and validation results. Planned documents are added as the corresponding capabilities are implemented.


## Future Integration

The Active Directory environment will provide the on-premises identity foundation for the Microsoft cloud labs.

```text
Active Directory
      │
      │ Entra Connect
      ▼
Microsoft Entra ID
      │
      ├── Microsoft 365
      └── Microsoft Intune
```

Future phases will include hybrid identity synchronization, Microsoft Entra authentication, Conditional Access, and endpoint management.

The goal is to extend the identity concepts implemented on premises into Microsoft cloud identity rather than treating the environments as unrelated labs.


## Related Projects

- [Proxmox Virtualization Lab](../proxmox-virtualization-lab/) — virtualization platform hosting the domain controllers and client VMs
- [Microsoft 365 & Entra ID](../microsoft-365-entra-id/) — future hybrid identity and Microsoft cloud integration
- [Microsoft Intune Lab](../microsoft-intune/) — endpoint enrollment, configuration, compliance, and management
- [Security Operations Lab](../security-operations/) — future collection and analysis of Active Directory security events
