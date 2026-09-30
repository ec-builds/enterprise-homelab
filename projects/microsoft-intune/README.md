# 💻 Microsoft Intune Lab

**Status: 🟡 In Progress**

A hands-on lab for managing Windows endpoints with Microsoft Intune and Microsoft Entra ID, built around the tasks an enterprise endpoint team handles day to day.

## Overview

My background is in hybrid Microsoft environments: on-premises Active Directory synchronized with Microsoft Entra ID, Group Policy, and Windows endpoint administration. This lab extends that experience into cloud-native endpoint management.

The lab follows a device through its working life — from identity and provisioning, through configuration, security, and access control, to troubleshooting — and focuses on how those pieces depend on each other rather than touring Intune feature by feature.

Each area has its own folder with implementation notes, validation, and lessons learned. This page is the map.

## Design Choice: Cloud-Native

The lab is intentionally **cloud-only**. Identities live in Microsoft Entra ID, and devices are **Microsoft Entra joined** rather than hybrid joined.

This reflects Microsoft's recommended approach for new Windows deployments and keeps the lab focused on modern endpoint management instead of the additional infrastructure that hybrid join requires. On-premises experience still plays a role: existing Group Policy is used as the starting point for building equivalent cloud-based configuration.

## Lab Environment

| Component | Platform |
|---|---|
| Endpoint management | Microsoft Intune |
| Identity | Microsoft Entra ID (cloud-only) |
| Device join | Microsoft Entra join |
| Endpoints | Windows 11 (Hyper-V VMs and a physical Dell OptiPlex) |
| Automation | PowerShell and Microsoft Graph |

Some Intune capabilities, such as Conditional Access, depend on license tier. Requirements are noted in each area where they apply.

## Lab Areas

**Legend:** 🟢 Complete · 🟡 In Progress · ⚪ Planned

| # | Area | Focus | Status |
|---|---|---|:---:|
| 01 | [Identity & Access](01-identity-access/) | Tenant foundation, administration, and access based on device compliance | 🟡 |
| 02 | [Provisioning & Enrollment](02-provisioning-enrollment/) | Getting a new device from first boot to managed with Windows Autopilot | ⚪ |
| 03 | [Group Policy to Intune](03-gpo-to-intune/) | Translating representative Group Policy settings into Intune configuration | ⚪ |
| 04 | [Endpoint Security](04-endpoint-security/) | Core protections expected on a corporate device | ⚪ |
| 05 | [Applications & Updates](05-apps-updates/) | Delivering software and keeping Windows current | ⚪ |
| 06 | [Automation & Reporting](06-automation-reporting/) | Working with the tenant through Microsoft Graph and PowerShell | ⚪ |
| 07 | [Troubleshooting](07-troubleshooting/) | Realistic failures and how they were diagnosed and resolved | ⚪ |
| 08 | [Lessons Learned](08-lessons-learned.md/) | Lessons learned through the course of the lab | ⚪ |


### 01 · Identity & Access

Everything in Intune starts with identity. This area sets up the tenant, groups, and least-privilege administration, then connects device health to access decisions so that only compliant devices reach company resources.

### 02 · Provisioning & Enrollment

How a new device goes from first boot to managed with minimal hands-on effort, using a user-driven Windows Autopilot deployment with Microsoft Entra join.

### 03 · Group Policy to Intune

Most organizations move to Intune from Group Policy rather than starting fresh. Using policy backups from an on-premises domain, this area assesses what translates to Intune and rebuilds a representative set of settings as cloud-based configuration.

### 04 · Endpoint Security

Applying and verifying the protections expected on a managed device, including antivirus, disk encryption, and local administrator account management.

### 05 · Applications & Updates

Packaging and delivering an application, and keeping Windows current through a staged rollout that limits the impact of a problematic update.

### 06 · Automation & Reporting

Using Microsoft Graph and PowerShell to manage and report on the tenant, treating configuration as something that can be exported, versioned, and reviewed.

### 07 · Troubleshooting

Case studies built from deliberately broken scenarios, each written up as an investigation: symptoms, evidence, root cause, and resolution.

### 08 · Lessons Learned

A recorded list of any lessons learned, useful for reference

## How It Fits Together

Once the individual areas are in place, they come together in a single device lifecycle:

```text
New user & device → Autopilot → Configuration & security → Apps & updates
      → Compliance & access → Monitoring & troubleshooting → Retire
```

The goal is to show identity, endpoint management, security, and automation working as one system rather than as isolated features.

## Repository Structure

```text
intune-lab/
├── README.md
├── architecture.md          # How Entra ID, Intune, and endpoints connect
├── lab-build.md             # Tenant and environment setup
├── 01-identity-access/
├── 02-provisioning-enrollment/
├── 03-gpo-to-intune/
├── 04-endpoint-security/
├── 05-apps-updates/
├── 06-automation-reporting/
├── 07-troubleshooting/
├── 08-lessons-learned/
├── procedures/              # Repeatable runbooks
├── scripts/                 # PowerShell and Graph automation
└── diagrams/
```

Tenant details, user identities, and device identifiers are sanitized or excluded from public documentation.

## Future Expansion

- Hybrid identity and hybrid join scenarios
- Endpoint Privilege Management
- Advanced Conditional Access scenarios
- Mobile device and application management

## Resources

- [Microsoft Intune documentation](https://learn.microsoft.com/en-us/intune/)
- [Microsoft Intune free trial](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/free-trial-sign-up)
