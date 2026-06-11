# 🪪 Microsoft 365 & Entra ID Lab

**Status: 📋 Planned**

Cloud identity and tenant administration with Microsoft 365 and Microsoft Entra ID, including hybrid identity with the on-prem Active Directory lab.

**Scope note:** This project covers the *tenant* — users, licensing, identity, Conditional Access, and M365 services. Azure *infrastructure* (subscriptions, VMs, VNets) lives in [azure-administration-lab](../azure-administration-lab/).

## Objectives

- Administer a Microsoft 365 tenant (users, licenses, groups, services)
- Implement identity security: MFA, Conditional Access, privileged role hygiene
- Configure hybrid identity by syncing on-prem AD with Entra Connect
- Automate administration with Microsoft Graph PowerShell
- Explore device management with Intune

## Technologies

- Microsoft 365 admin center / Entra admin center
- Microsoft Entra Connect (directory synchronization)
- Conditional Access policies
- Microsoft Graph PowerShell SDK
- Microsoft Intune

## Key Tasks

- [ ] Set up tenant and configure custom domain
- [ ] Create users/groups and assign licenses (portal and Graph PowerShell)
- [ ] Enforce MFA for all users; protect admin roles
- [ ] Build Conditional Access policies (block legacy auth, require MFA)
- [ ] Deploy Entra Connect and sync the [AD lab](../active-directory-lab/) domain
- [ ] Verify hybrid sign-in; document sync conflict troubleshooting
- [ ] Enroll a test device in Intune with a compliance policy
- [ ] Review sign-in logs and Identity Secure Score; remediate findings

## Folder Structure

```
microsoft-365-entra-id/
├── docs/            # Build notes, CA policy documentation, lessons learned
├── configs/         # Exported policy definitions (sanitized)
├── scripts/         # Graph PowerShell scripts
└── screenshots/     # Visual documentation
```
