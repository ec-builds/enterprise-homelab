# 🏢 Active Directory Lab

**Status: ⚪ Planned**

Enterprise identity and access management environment built with Windows Server and Active Directory Domain Services, hosted across the Proxmox virtualization lab.

## Architecture

The Active Directory environment will use two domain controllers distributed across separate Proxmox hosts.

    Proxmox Cluster
    │
    ├── prox01
    │   └── DC01
    │       ├── Active Directory Domain Services
    │       ├── DNS
    │       └── DHCP
    │
    └── prox02
        └── DC02
            ├── Active Directory Domain Services
            └── DNS
                 │
                 ▼
          AD Replication

Separating the domain controllers across Proxmox hosts provides continued directory and DNS availability if a virtualization host is unavailable.

## Objectives

- Deploy a multi-domain-controller Active Directory environment
- Distribute domain controllers across separate Proxmox hosts
- Configure and validate Active Directory replication
- Design an OU structure modeling a real business
- Implement Group Policy for security baselines and configuration management
- Manage users, groups, and computers at scale with PowerShell
- Configure AD-integrated DNS
- Configure DHCP services and document scopes
- Establish the on-premises identity foundation for future Microsoft Entra ID integration

## Technologies

- Proxmox VE
- Windows Server
- Active Directory Domain Services
- Active Directory-integrated DNS
- DHCP
- Group Policy Management Console
- Active Directory Sites and Services
- PowerShell
- Windows 10/11 domain-joined clients

## Domain Controllers

| Server | Proxmox Host | Roles |
|---|---|---|
| DC01 | prox01 | AD DS, DNS, DHCP |
| DC02 | prox02 | AD DS, DNS |

Both domain controllers will provide directory and DNS services while residing on separate virtualization hosts.

FSMO roles will initially reside on DC01 and will be documented as part of the deployment.

## Key Tasks

- [ ] Deploy DC01 Windows Server VM on prox01
- [ ] Configure static network addressing
- [ ] Install AD DS and create the Active Directory forest
- [ ] Configure AD-integrated DNS
- [ ] Configure DHCP and document scopes
- [ ] Build OU structure for departments, users, workstations, and servers
- [ ] Create security groups using AGDLP best practices
- [ ] Configure GPOs for password policy, account lockout, drive mappings, and workstation restrictions
- [ ] Bulk-create users with PowerShell
- [ ] Join Windows client VMs to the domain
- [ ] Verify Group Policy application
- [ ] Deploy DC02 on prox02
- [ ] Promote DC02 as an additional domain controller
- [ ] Configure DNS on DC02
- [ ] Verify AD DS and DNS replication between DC01 and DC02
- [ ] Document FSMO role placement
- [ ] Configure and document Active Directory Sites and Services
- [ ] Generate user and group audit reports with PowerShell
- [ ] Validate directory services following simulated DC or Proxmox host failure

## Future Integration

The Active Directory environment will provide the on-premises identity foundation for the Microsoft cloud labs.

    Active Directory
          │
          │ Entra Connect
          ▼
    Microsoft Entra ID
          │
          ├── Microsoft 365
          └── Microsoft Intune

Future phases will include hybrid identity synchronization, Microsoft Entra authentication, Conditional Access, and endpoint management.

## Related Projects

- [Proxmox Virtualization Lab](../proxmox-virtualization-lab/) — virtualization platform hosting the domain controllers and client VMs
- [Microsoft 365 & Entra ID](../microsoft-365-entra-id/) — future hybrid identity and Microsoft cloud integration
- [Microsoft Intune Lab](../intune-lab/) — endpoint enrollment, configuration, compliance, and management
- [Security Operations Lab](../security-operations-lab/) — future collection and analysis of Active Directory security events

## Folder Structure

```text
    active-directory-lab/
    ├── docs/            # Architecture, build documentation, GPOs, and lessons learned
    ├── configs/         # GPO reports and DNS/DHCP documentation
    ├── scripts/         # PowerShell provisioning and reporting
    └── diagrams/        # Visual documentation
```
