# 💻 Microsoft Intune Lab

**Status: 🟢 Operational**

<img src="./diagrams/Intune-banner.png" alt="Microsoft Intune Lab Banner" width="700">

A hands-on lab for managing Windows endpoints with Microsoft Intune and Microsoft Entra ID, focused on cloud-native device identity, enrollment, compliance, configuration management, application deployment, Windows servicing, PowerShell automation, and troubleshooting.

## Overview

This lab implements a cloud-native Windows endpoint-management lifecycle using Microsoft Entra ID and Microsoft Intune.

Windows endpoints progress from Microsoft Entra join through Intune enrollment, ownership classification, compliance evaluation, configuration management, application deployment, Windows Update management, and endpoint validation.

The lab emphasizes both **Intune management-plane reporting** and **direct Windows endpoint verification**.

## Design Choice: Cloud-Native

The environment is intentionally **cloud-only**. Identities reside in Microsoft Entra ID, and Windows endpoints are **Microsoft Entra joined** rather than hybrid joined.

Microsoft Entra ID provides device identity while Microsoft Intune provides endpoint management. Device identity, MDM enrollment, ownership classification, Windows user context, compliance, and policy enforcement are treated as separate management states.

## Lab Environment

| Component | Platform |
|---|---|
| Endpoint Management | Microsoft Intune |
| Identity | Microsoft Entra ID |
| Device Join | Microsoft Entra Join |
| Endpoints | Windows 11 |
| Configuration Management | Intune Settings Catalog |
| Application Management | Intune Win32 Applications |
| Windows Servicing | Update Rings and Feature Updates |
| Administration & Automation | PowerShell and Microsoft Graph |

## Implementation Status

**Legend:** 🟢 Implemented · 🟡 Validation Pending · ⚪ Future

| Area | Focus | Status |
|---|---|:---:|
| Microsoft Entra Device Join | Cloud-based Windows device identity | 🟢 |
| Intune Device Enrollment | MDM enrollment, restrictions, and ownership | 🟢 |
| Compliance Policy | Corporate Windows security baseline | 🟢 |
| Noncompliance Testing | Controlled validation of failed requirements | 🟢 |
| Compliance Remediation | Endpoint remediation and re-evaluation | 🟢 |
| Application Deployment | Win32 packaging, deployment, detection, and uninstall | 🟢 |
| Configuration Profiles | Device- and user-scoped Windows configuration | 🟢 |
| Windows Update Management | Update Ring and Windows 11 feature-update deployment | 🟡 |
| PowerShell Script Deployment | SYSTEM-context endpoint automation | 🟢 |
| Troubleshooting | Enrollment, policy, compliance, and deployment investigations | 🟢 |
| Lessons Learned | Findings recorded throughout implementation | 🟢 |

## Device Management Workflow

```text
Microsoft Entra ID
        ↓
Microsoft Entra Join
        ↓
Windows 11 Endpoint
        ↓
Intune MDM Enrollment
        ↓
Corporate Ownership
        ↓
 ┌──────┼────────────┬──────────────┐
 │      │            │              │
 ▼      ▼            ▼              ▼
Compliance   Configuration   Applications   Updates
 │              Profiles          │           │
 ▼                 │              │           │
Evaluate           └──────┬───────┴───────────┘
 │                        │
 ├── Compliant            ▼
 │                 Endpoint Validation
 └── Noncompliant
         ↓
    Troubleshoot
         ↓
     Remediate
         ↓
     Intune Sync
         ↓
    Re-evaluate
```

The lifecycle has been validated through enrollment, deliberate compliance failures, remediation, configuration enforcement, Win32 application deployment and removal, PowerShell execution, and Windows Update policy deployment.

## Implemented Capabilities

### Compliance & Security

Corporate Windows endpoints are evaluated against a compliance baseline covering controls including BitLocker, device encryption, Secure Boot, TPM, Windows Firewall, Microsoft Defender protections, password requirements, and minimum Windows version.

Controlled testing intentionally produced compliance failures, identified the responsible controls through per-setting reporting, remediated the endpoints, and confirmed their return to **Compliant** status.

### Configuration Management

Intune Settings Catalog profiles manage both device- and user-scoped Windows configuration.

Implemented controls include Windows Widgets, lock-screen widgets, Microsoft Edge InPrivate browsing, Advertising ID, AutoRun, AutoPlay, and user access to Control Panel and Windows Settings.

Selected policies were validated through both Intune reporting and direct endpoint testing.

### Application Management

7-Zip was packaged as a Win32 application and used to validate the managed application lifecycle from required deployment through detection and uninstall.

Testing also confirmed that outstanding Required assignments are processed when an offline managed endpoint reconnects to Intune.

### PowerShell & Windows Servicing

PowerShell deployment was validated across managed endpoints using the Windows **SYSTEM** context, with endpoint-side verification of the resulting state.

A Windows Update Ring and Windows 11 feature-update policy were also deployed to a dedicated pilot group. Policy deployment is operational, with final feature-update endpoint validation pending.

## Notable Troubleshooting

Troubleshooting was treated as part of the implementation rather than documenting only successful configurations.

Testing included enrollment error `0x80180014`, Windows Pro Settings Catalog applicability, compliance failures, application reporting behavior, and user-scoped configuration enforcement.

The most significant investigation involved a user-scoped policy that was processed against the wrong Windows account. The original manual MDM enrollment authenticated with the intended organizational account but was associated with the local administrator's Windows SID.

The issue was isolated through registry inspection, MDM event logs, SID correlation, enrollment metadata, and controlled re-enrollment. Re-enrolling from the intended Entra user session associated the enrollment with the correct SID and allowed the user-scoped policy to apply successfully.

Additional details are documented in [`troubleshooting.md`](./troubleshooting.md).

## Enrollment Architecture

The lab uses manual **Enroll only in device management** enrollment because the Microsoft Entra ID Premium capabilities required for automatic MDM enrollment were unavailable under the lab licensing.

Manual enrollment allowed the Intune management lifecycle to be tested but also exposed limitations of that provisioning method.

A production implementation would evaluate **Windows Autopilot, Microsoft Entra Join, and automatic Intune enrollment** to provide a repeatable corporate provisioning workflow.

These capabilities remain production design recommendations rather than lab-validated implementations.

## Repository Structure

```text
microsoft-intune/
├── 01-intune-device-enrollment.md
├── 02-compliance-policy.md
├── 03-noncompliance-testing.md
├── 04-noncompliance-remediation.md
├── 05-application-deployment.md
├── 06-windows-update-management.md
├── 07-powershell-script-deploy.md
├── 08-windows-configuration-profiles.md
├── architecture.md
├── diagrams/
├── lessons-learned.md
├── README.md
└── troubleshooting.md
```

Tenant identifiers, device identifiers, enrollment identifiers, certificate information, credentials, recovery keys, and other sensitive information are sanitized or excluded from public documentation.

## Future Expansion

- Microsoft Entra Conditional Access requiring compliant devices
- Windows Autopilot corporate provisioning
- Automatic Intune MDM enrollment
- Hybrid identity and Microsoft Entra hybrid join
- Endpoint Privilege Management
- Additional PowerShell and Microsoft Graph automation

## Key Outcomes

This lab demonstrates practical experience with:

- Microsoft Entra joined Windows endpoints and Intune MDM enrollment
- Enrollment restrictions and device ownership classification
- Windows compliance policy and security remediation
- Device- and user-scoped configuration profiles
- Win32 application packaging and lifecycle management
- Windows Update Rings and feature updates
- PowerShell deployment through Intune
- Endpoint-side policy validation
- Intune and Windows troubleshooting
- Windows identity and MDM enrollment-context analysis

The implementation emphasizes **deploying controls, testing failure conditions, identifying root causes, validating endpoint behavior, and documenting production design improvements**.
