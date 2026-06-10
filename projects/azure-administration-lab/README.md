# ☁️ Azure Administration Lab

**Status: 📋 Planned**

Microsoft Azure infrastructure administration — deploying, securing, and governing cloud resources, with hybrid connectivity back to the homelab.

**Scope note:** This project covers Azure *infrastructure* — subscriptions, compute, networking, storage, RBAC, and governance. Tenant/identity administration lives in [microsoft-365-entra-id](../microsoft-365-entra-id/).

## 🎯 Objectives

- Manage subscriptions, resource groups, and tagging strategy
- Deploy and harden Azure compute, networking, and storage
- Implement RBAC with least-privilege custom roles
- Apply governance: Azure Policy, budgets, and cost alerts
- Establish hybrid connectivity between the homelab and Azure
- Skills alignment: **AZ-104** certification objectives

## 🛠️ Technologies

- Azure portal, Azure CLI, Azure Cloud Shell
- Virtual Networks, NSGs, Azure Bastion
- Azure VMs, Storage Accounts, Entra ID RBAC
- Azure Policy, Cost Management, Azure Monitor
- VPN Gateway or WireGuard for hybrid connectivity

## 📋 Key Tasks

- [ ] Establish subscription structure with budget alerts (avoid bill surprises)
- [ ] Define naming convention and tagging standards
- [ ] Deploy a VNet with segmented subnets and NSG rules
- [ ] Deploy and harden a VM (no public RDP/SSH — use Bastion)
- [ ] Configure storage with proper access controls and lifecycle rules
- [ ] Create custom RBAC roles following least privilege
- [ ] Apply Azure Policy (e.g., allowed regions, required tags)
- [ ] Establish site-to-site connectivity to the homelab
- [ ] Tear down unused resources; document cost findings

## 🔗 Related Projects

- [infrastructure-automation](../infrastructure-automation/) — these resources get rebuilt with Terraform/Bicep
- [kubernetes-lab](../kubernetes-lab/) — AKS deployment lands here once k3s fundamentals are done
- [security-operations-lab](../security-operations-lab/) — Microsoft Sentinel integration

## 📁 Folder Structure

```
azure-administration-lab/
├── docs/            # Build notes, cost findings, lessons learned
├── configs/         # Exported templates and policy definitions
├── scripts/         # Azure CLI / PowerShell scripts
└── screenshots/     # Visual documentation
```
