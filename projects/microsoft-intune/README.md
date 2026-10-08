# 💻 Microsoft Intune Lab

**Status: 🟡 In Progress**

A hands-on lab for managing Windows endpoints with Microsoft Intune and Microsoft Entra ID, focused on cloud-native device identity, enrollment, compliance, security, and troubleshooting.

## Overview

The current implementation follows Windows endpoints from Microsoft Entra join through Intune enrollment, ownership classification, compliance evaluation, troubleshooting, and remediation.

## Design Choice: Cloud-Native

The lab is intentionally **cloud-only**. Identities live in Microsoft Entra ID, and Windows endpoints are **Microsoft Entra joined** rather than hybrid joined.

Microsoft Entra ID provides device identity while Microsoft Intune provides endpoint management. Device join state, Intune management state, and Intune ownership classification are treated as separate properties throughout the lab.

## Lab Environment

| Component | Platform |
|---|---|
| Endpoint Management | Microsoft Intune |
| Identity | Microsoft Entra ID |
| Device Join | Microsoft Entra Join |
| Endpoints | Windows 11 |
| Administration & Automation | PowerShell and Microsoft Graph |

## Current Implementation

**Legend:** 🟢 Implemented · 🟡 In Progress · ⚪ Planned

| Area | Focus | Status |
|---|---|:---:|
| Tenant & Identity | Tenant foundation, users, groups, and administration | 🟢 |
| Microsoft Entra Device Join | Cloud-based Windows device identity | 🟢 |
| Intune Device Enrollment | MDM enrollment, restrictions, and ownership | 🟢 |
| Compliance Policy | Corporate Windows security baseline | 🟢 |
| Noncompliance Testing | Validation of failed compliance requirements | 🟢 |
| Compliance Remediation | Endpoint remediation and compliance re-evaluation | 🟢 |
| Troubleshooting | Enrollment and management troubleshooting cases | 🟡 |
| Lessons Learned | Findings recorded throughout the lab | 🟡 |
| Conditional Access | Require compliant devices for cloud access | ⚪ |
| Windows Autopilot | Automated corporate device provisioning | ⚪ |
| Configuration Profiles | Cloud-based Windows configuration management | ⚪ |
| Applications & Updates | Application deployment and Windows servicing | ⚪ |

## Device Management Workflow

The currently validated device lifecycle is:

```text
Microsoft Entra ID
        ↓
Microsoft Entra Join
        ↓
Windows 11 Endpoint
        ↓
Intune MDM Enrollment
        ↓
Corporate Ownership Validation
        ↓
Compliance Policy
        ↓
Compliance Evaluation
        ↓
  ┌─────┴─────┐
  │           │
  ▼           ▼
Compliant  Noncompliant
                ↓
          Troubleshoot
                ↓
            Remediate
                ↓
           Intune Sync
                ↓
           Re-evaluate
```

This lifecycle has been tested through successful enrollment, deliberate compliance failures, remediation, and confirmation that an affected endpoint returned to a Compliant state.

## Implemented Security Baseline

Corporate Windows endpoints are assigned to the `Intune-corporate-devices` security group and evaluated by the `Windows Corporate Device Compliance` policy.

The baseline evaluates endpoint security requirements including BitLocker, Secure Boot, TPM, firewall, Microsoft Defender protections, device encryption, password requirements, and minimum Windows version.

Devices that fail required controls are marked Noncompliant for investigation and remediation.


## Repository Structure

```text
microsoft-intune/
├── README.md
├── architecture.md
├── 01-tenant-identity.md
├── 02-entra-device-join.md
├── 03-intune-device-enrollment.md
├── 04-compliance-policy.md
├── 05-noncompliance-testing.md
├── 06-noncompliance-remediation.md
├── 07-troubleshooting.md
├── 08-lessons-learned.md
└── diagrams/
```

Tenant identifiers, device identifiers, credentials, recovery keys, and other sensitive information are sanitized or excluded from public documentation.

## Next Steps

The next stage will extend the existing compliance architecture into identity-based access control and additional endpoint-management capabilities:

1. Microsoft Entra Conditional Access requiring a compliant device
2. Windows configuration profiles
3. Application deployment
4. Windows update management
5. Windows Autopilot provisioning
6. PowerShell and Microsoft Graph automation

## Future Expansion

- Hybrid identity and Microsoft Entra hybrid join scenarios
- Endpoint Privilege Management
- Advanced Conditional Access scenarios
- Mobile device and application management
