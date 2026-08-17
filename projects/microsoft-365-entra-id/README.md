# 🪪 Microsoft 365 & Entra ID Lab

**Status: ⚪ Planned**

A hands-on Microsoft 365 and Microsoft Entra ID lab focused on cloud identity, access management, and tenant administration, including hybrid identity integration with the on-premises Active Directory lab.

**Scope note:** This project covers the Microsoft 365 and identity control plane — users, groups, licensing, authentication, Conditional Access, and Microsoft 365 services. Endpoint management is covered in the dedicated [Microsoft Intune Lab](../microsoft-intune/), while Azure infrastructure such as subscriptions, VMs, and VNets is covered in [azure-administration-lab](../azure-administration-lab/).

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

- [ ] Set up tenant and configure custom domain
- [ ] Create users and groups and assign licenses
- [ ] Automate user and group administration with Microsoft Graph PowerShell
- [ ] Configure MFA and protect privileged administrative accounts
- [ ] Build Conditional Access policies
- [ ] Block legacy authentication
- [ ] Deploy Microsoft Entra Connect Sync
- [ ] Synchronize the [Active Directory Lab](../active-directory-lab/) with Entra ID
- [ ] Validate hybrid identities and authentication
- [ ] Document synchronization conflicts and troubleshooting
- [ ] Integrate Intune device compliance with Conditional Access
- [ ] Review sign-in and audit logs
- [ ] Review security recommendations and remediate findings

## Folder Structure

```text
microsoft-365-entra-id/
├── README.md
├── docs/
├── configs/
├── scripts/
└── screenshots/
```
