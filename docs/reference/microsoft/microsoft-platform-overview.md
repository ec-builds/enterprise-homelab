# 🔷 Microsoft Platform Overview

Microsoft infrastructure spans several interconnected platforms covering cloud infrastructure, identity, endpoint management, productivity services, and traditional Windows infrastructure.

This reference provides a high-level view of how the major Microsoft technologies relate to each other within the homelab.

## Platform Overview

| Area | Microsoft Platform | Primary Administration |
|---|---|---|
| ☁️ **Cloud Infrastructure** | **Microsoft Azure** | Virtual machines, virtual networks, storage, cloud resources, monitoring, and RBAC |
| 👤 **Identity & Access** | **Microsoft Entra ID** | Users, groups, authentication, MFA, Conditional Access, SSO, and identity governance |
| 💻 **Endpoint Management** | **Microsoft Intune** | Device enrollment, configuration profiles, compliance, applications, and updates |
| 🏢 **Productivity / SaaS** | **Microsoft 365** | Exchange Online, Teams, SharePoint, OneDrive, and licensing |
| 🖥️ **Traditional Infrastructure** | **Windows Server / Active Directory** | AD DS, DNS, DHCP, Group Policy, and domain-joined systems |

These platforms overlap and integrate with each other rather than operating as completely separate environments.

Microsoft Entra ID provides the central cloud identity layer used across Azure, Microsoft 365, and Intune.

## Target Lab Architecture

The eventual Microsoft lab will combine traditional Active Directory infrastructure with Microsoft's cloud identity, endpoint, productivity, and infrastructure platforms.

                        Microsoft Entra ID
                        Users / Groups / MFA
                        Conditional Access
                               │
                 ┌─────────────┼─────────────┐
                 │             │             │
                 ▼             ▼             ▼
               Azure         Intune      Microsoft 365
                 │             │             │
             VMs/VNets      Devices       Exchange
             Storage        Policies      Teams
             Monitor        Apps          SharePoint
             RBAC           Compliance    OneDrive
                 │
                 │ Hybrid Connectivity
                 ▼
            Proxmox Homelab
                 │
            Active Directory
             DC01 / DC02

## Technology Roles

**Windows Server / Active Directory** provides the traditional on-premises infrastructure and directory environment.

**Microsoft Entra ID** extends identity into the cloud and provides authentication and access control across Microsoft cloud services.

**Microsoft Intune** manages endpoints using Entra identities and cloud-based device policies.

**Microsoft 365** provides cloud productivity and collaboration services associated with users and groups in Entra ID.

**Microsoft Azure** provides the cloud infrastructure layer, including compute, networking, storage, monitoring, and resource management.

Together, these technologies form a hybrid Microsoft infrastructure spanning on-premises systems, identity, endpoints, productivity services, and cloud computing.
