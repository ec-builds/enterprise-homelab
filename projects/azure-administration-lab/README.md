# ☁️ Azure Administration Lab

**Status: ⚪ Planned**

Microsoft Azure infrastructure administration lab focused on core cloud infrastructure, security, governance, and hybrid connectivity with the Proxmox homelab.

**Scope note:** Microsoft Entra ID and Microsoft 365 administration are documented separately in [Microsoft 365 & Entra ID](../microsoft-365-entra-id/).

## Objectives

- Deploy and manage core Azure infrastructure
- Configure Azure networking and secure resource access
- Manage access using Azure RBAC and Microsoft Entra identities
- Apply basic governance and cost controls
- Monitor Azure resources
- Establish hybrid connectivity with the homelab
- Develop practical skills aligned with **AZ-104**

## Technologies

- Azure Portal
- Azure CLI / PowerShell
- Resource Groups
- Virtual Networks and NSGs
- Azure Virtual Machines
- Azure Storage
- Azure RBAC
- Azure Policy
- Azure Monitor
- Microsoft Entra ID

## Key Tasks

- [ ] Configure resource groups, naming conventions, and tags
- [ ] Configure budget and cost alerts
- [ ] Deploy a VNet with segmented subnets and NSG rules
- [ ] Deploy and securely administer an Azure VM
- [ ] Configure an Azure Storage Account and access controls
- [ ] Assign Azure RBAC roles using Entra users and groups
- [ ] Apply basic Azure Policy governance
- [ ] Configure Azure Monitor and review resource logs
- [ ] Establish temporary hybrid connectivity with the Proxmox homelab
- [ ] Document costs and remove unused resources

## Lab Integration

    Proxmox Homelab
    │
    ├── Active Directory
    │
    └── Lab Workloads
            │
            │ Hybrid Connectivity
            ▼
        Microsoft Azure
            │
            ├── Networking
            ├── Compute
            ├── Storage
            └── Monitoring

Microsoft Entra identities from the Microsoft 365 lab will be used for Azure authentication and RBAC.

## Cost Strategy

The lab will prioritize free and low-cost resources. Billable services will be deployed temporarily when required for testing and removed after validation.

## Related Projects

- [Proxmox Virtualization Lab](../proxmox-virtualization-lab/) — hosts the on-premises lab infrastructure
- [Active Directory Lab](../active-directory-lab/) — provides on-premises directory services
- [Microsoft 365 & Entra ID](../microsoft-365-entra-id/) — provides cloud identity and Microsoft 365 administration
- [Infrastructure Automation](../infrastructure-automation/) — future Terraform/Bicep automation
- [Security Operations Lab](../security-operations-lab/) — future Microsoft Sentinel integration

## Folder Structure

    azure-administration-lab/
    ├── docs/
    ├── configs/
    ├── scripts/
    └── screenshots/
