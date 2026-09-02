# 🔷 Microsoft Platform Overview

Microsoft infrastructure spans several interconnected platforms covering cloud infrastructure, identity, endpoint management, productivity services, security, and traditional Windows infrastructure.

This reference provides a high-level view of how the major Microsoft technologies relate to each other within the homelab.

## Platform Overview

| Area | Microsoft Platform | Primary Administration |
|---|---|---|
| ☁️ **Cloud Infrastructure** | **Microsoft Azure** | Virtual machines, virtual networks, storage, cloud resources, monitoring, and RBAC |
| 👤 **Identity & Access** | **Microsoft Entra ID** | Users, groups, authentication, MFA, Conditional Access, SSO, and identity governance |
| 🔄 **Hybrid Identity** | **Microsoft Entra Connect / Cloud Sync** | Synchronization of on-premises Active Directory identities with Microsoft Entra ID |
| 💻 **Endpoint Management** | **Microsoft Intune** | Device enrollment, configuration profiles, compliance, applications, and updates |
| 🏢 **Productivity / SaaS** | **Microsoft 365** | Exchange Online, Teams, SharePoint, OneDrive, and licensing |
| 🛡️ **Security & Monitoring** | **Microsoft Defender / Sentinel** | Endpoint protection, identity protection, threat detection, log analytics, and incident response |
| 🖥️ **Traditional Infrastructure** | **Windows Server / Active Directory** | AD DS, DNS, DHCP, Group Policy, and domain-joined systems |
| 💻 **Client Endpoints** | **Windows 11** | AD domain join, Entra join, device configuration, applications, security policies, and user endpoints |

These platforms overlap and integrate with each other rather than operating as completely separate environments.

Microsoft Entra ID provides the central cloud identity layer used across Azure, Microsoft 365, Intune, and other Microsoft cloud services.

## Target Lab Architecture

The eventual Microsoft lab will combine traditional Active Directory infrastructure with Microsoft's cloud identity, endpoint, productivity, security, and infrastructure platforms.

```text
                         Microsoft Entra ID
                         Users / Groups / MFA
                         Conditional Access
                                │
                  ┌─────────────┼─────────────┐
                  │             │             │
                  ▼             ▼             ▼
                Azure         Intune      Microsoft 365
                  │             │             │
              VMs/VNets     Windows 11     Exchange
              Storage       Policies       Teams
              Monitor       Apps           SharePoint
              RBAC          Compliance     OneDrive
                                │
                                ▼
                         Managed Endpoints


                    Entra Connect / Cloud Sync
                                │
                                ▼
                         Proxmox Homelab
                                │
                      Windows Server / AD DS
                           DC01 / DC02
                                │
                  ┌─────────────┴─────────────┐
                  │                           │
                  ▼                           ▼
              DNS / DHCP                 Windows 11
              Group Policy              Domain Clients


                    Defender / Sentinel
                  Security & Monitoring
                  Across the Environment
```

## Technology Roles

**Windows Server / Active Directory** provides the traditional on-premises infrastructure and directory environment, including AD DS, DNS, DHCP, and Group Policy.

**Microsoft Entra Connect / Cloud Sync** provides the hybrid identity bridge between on-premises Active Directory and Microsoft Entra ID by synchronizing identities into the cloud.

**Microsoft Entra ID** provides the cloud identity layer used for authentication and access control across Microsoft cloud services.

**Microsoft Intune** manages endpoints using Entra identities and cloud-based device policies, applications, compliance requirements, and update controls.

**Windows 11** represents the client endpoint layer. Devices can participate in traditional Active Directory environments, Microsoft Entra environments, or hybrid configurations and can be managed through Intune.

**Microsoft 365** provides cloud productivity and collaboration services associated with users and groups in Entra ID.

**Microsoft Azure** provides the cloud infrastructure layer, including compute, networking, storage, monitoring, and resource management. Access to Azure resources can be controlled using Entra identities and Azure RBAC.

**Microsoft Defender** provides security capabilities across endpoints, identities, Microsoft 365, and cloud resources.

**Microsoft Sentinel** provides cloud-based SIEM and security analytics by collecting and correlating security data for detection, investigation, and incident response.

Together, these technologies form a hybrid Microsoft infrastructure spanning on-premises systems, cloud identity, endpoints, productivity services, security operations, and cloud computing.

> [!NOTE]
> **Active Directory** provides traditional directory services → **Entra Connect / Cloud Sync** synchronizes identities → **Microsoft Entra ID** provides cloud identity → **Microsoft Intune** uses that identity for endpoint management → **Microsoft 365** uses it for productivity services → **Microsoft Azure** uses it to control access to cloud infrastructure.
>
> **Microsoft Defender** and **Microsoft Sentinel** provide security, detection, monitoring, and visibility across these layers.
