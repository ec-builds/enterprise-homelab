# 🪪 Microsoft 365 & Entra ID Lab

**Status: 🟡 In Progress**

<img src="./diagrams/m365-entra-banner.png" alt="Microsoft 365 & Entra ID Lab Banner" width="1000">

## Overview

A hands-on Microsoft 365 and Microsoft Entra ID lab focused on cloud identity, access management, and tenant administration, including hybrid identity integration with the on-premises Active Directory lab.

**Scope note:** This project covers the Microsoft 365 and identity control plane — users, groups, licensing, authentication, Conditional Access, and Microsoft 365 services. Endpoint management is covered in the dedicated [Microsoft Intune Lab](../microsoft-intune/).

## Objectives

- Administer a Microsoft 365 tenant, including users, groups, licenses, and services
- Implement identity security using MFA, Conditional Access, and least-privilege administration
- Configure hybrid identity using Microsoft Entra Connect Sync
- Manage and troubleshoot directory synchronization between on-premises AD and Entra ID
- Automate identity and tenant administration with Microsoft Graph PowerShell
- Integrate Entra Conditional Access with Microsoft Intune device compliance

## Technologies

- Microsoft 365 admin center
- Microsoft Entra admin center
- Microsoft Entra Connect Sync
- Microsoft Entra Conditional Access
- Microsoft Graph PowerShell SDK
- Microsoft Intune integration

## Key Tasks

- [x] Set up tenant and configure custom domain
- [x] Create users and groups and assign licenses
- [x] Automate user and group administration with Microsoft Graph PowerShell
- [x] Configure MFA and protect privileged administrative accounts
- [ ] Build Conditional Access policies
- [ ] Block legacy authentication
- [ ] Deploy Microsoft Entra Connect Sync
- [ ] Synchronize the [Active Directory Lab](../active-directory-lab/) with Entra ID
- [ ] Validate hybrid identities and authentication
- [ ] Document synchronization conflicts and troubleshooting
- [ ] Integrate Intune device compliance with Conditional Access
- [ ] Review sign-in and audit logs
- [ ] Review security recommendations and remediate findings

> [!NOTE]
> Conditional Access, including the Intune compliance integration, requires Microsoft Entra ID P1, which the current tenant doesn't include. Those tasks are on hold until a P1 license is added. Entra Connect Sync doesn't need P1.

## Documentation

Lab docs:

1. [Identity & Access](./01-tenant-identity.md)
2. [Microsoft Entra ID Device Join](./02-entra-device-join.md)

Reference:

- [Microsoft Platform Overview](../../docs/reference/microsoft/microsoft-platform-overview.md)
- [Microsoft Graph Reference](../../docs/reference/microsoft/graph/microsoft-graph-reference.md)
- [Microsoft Entra User Management](../../docs/reference/microsoft/graph/microsoft-entra-user-management.md)
- [Entra Device Join and Registration](../../docs/reference/microsoft/entra/entra-device-join-and-registration.md)
- [Entra Device States](../../docs/reference/microsoft/entra/entra-device-states.md)
- [Intune RBAC Role Assignments](../../docs/reference/microsoft/intune/intune-rbac-role-assignments.md)

## Folder Structure

```text
microsoft-365-entra-id/
├── README.md
├── docs/
├── configs/
├── scripts/
└── screenshots/
```
