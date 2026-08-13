# 💻 Microsoft Intune Lab

**Status: 🟡 In Progress**

A hands-on Intune lab — part of my transition from traditional systems administration into Identity and Access Management.

## Overview

My systems administration background is primarily in hybrid Microsoft environments, managing on-premises Active Directory synchronized with Microsoft Entra ID alongside Group Policy and Windows endpoint administration. This lab extends that experience into cloud-native endpoint management with Microsoft Intune, with a focus on the MDM, security, automation, and identity integrations relevant to modern Systems Administrator and IAM roles.

I’m using the **30-day Microsoft Intune Plan 1 trial** to build and validate the endpoint lifecycle hands-on rather than only studying the platform conceptually. The goal is to understand not just how Intune is configured, but how policies reach endpoints, how they are validated, where deployments fail, and how those failures are troubleshot.

The lab follows the core endpoint management lifecycle:

```text
Enroll → Configure → Validate → Deploy → Patch → Secure → Automate
```

| Environment | |
|---|---|
| **MDM** | Microsoft Intune Plan 1 |
| **Identity** | Microsoft Entra ID |
| **Endpoints** | Windows 11 |
| **Virtualization** | Microsoft Hyper-V |
| **Test Devices** | Windows 11 VMs / physical Dell OptiPlex |
| **License** | [30-day Intune Trial](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/free-trial-sign-up) |

## Lab Setup

- Intune trial and MDM authority
- Users and license assignment
- Entra ID groups
- Intune roles and permissions
- Hyper-V Windows 11 test VMs
- Device enrollment
- Physical Windows endpoint where useful

## 01 · Enroll

Connect Windows 11 endpoints to Intune and establish MDM management.

- Entra ID join / registration
- MDM enrollment
- Device inventory
- Remote actions
- VM and physical endpoint enrollment

## 02 · Configure

Centrally manage Windows endpoint settings and restrictions instead of configuring devices individually.

- Settings Catalog
- Windows configuration profiles
- Microsoft Edge / OneDrive policies
- Device restrictions
- Policy assignments and targeting

## 03 · Validate

Define device requirements and use compliance policies to identify endpoints that fall outside the expected configuration.

- Compliance policies
- Compliant / noncompliant states
- Noncompliance notifications
- Remediation
- Policy reporting

```text
Compliant → Noncompliant → Remediate → Compliant
```

## 04 · Deploy

Deploy and manage Windows applications remotely through Intune.

- Microsoft Store apps
- Win32 applications
- App assignments
- Detection rules
- Application deployment monitoring

## 05 · Patch

Manage Windows updates through centralized policies and model a staged deployment strategy.

- Windows Update rings
- Update deadlines
- Restart behavior
- Update reporting

```text
Pilot → Validate → Broad Deployment
```

## 06 · Secure

Apply and validate endpoint security controls through Intune.

- Microsoft Defender Antivirus
- Windows Firewall
- BitLocker
- Security baselines
- Device security policies

## 07 · Automate

Use PowerShell to automate endpoint configuration and administration through Intune.

- PowerShell script deployment
- Configuration automation
- Inventory / reporting
- Logging and exit codes
- Script deployment monitoring

## Troubleshooting

| Issue | Root Cause | Resolution |
|---|---|---|
| | | |

## Key Learnings

> Running notes as I go — mistakes, surprises, things that didn't work the first time, and differences between virtual and physical Windows endpoints.

- **[Date] –**
- **[Date] –**
- **[Date] –**

## Directory Structure

```text
intune-lab/
│
├── README.md
├── 01-enrollment.md
├── 02-configuration.md
├── 03-compliance.md
├── 04-app-deployment.md
├── 05-update-management.md
├── 06-endpoint-security.md
├── 07-automation.md
│
├── scripts/
│   ├── inventory.ps1
│   └── ...
│
└── screenshots/
    ├── enrollment/
    ├── configuration/
    ├── compliance/
    ├── apps/
    ├── updates/
    ├── security/
    └── automation/
```

## Future Expansion

### Windows Autopilot

Autopilot is intentionally outside the initial lab scope so the project can focus on day-to-day Intune administration. It can be added later as an extension covering automated device provisioning.

Potential additions:

- Windows Autopilot device registration
- Deployment profiles
- Out-of-Box Experience (OOBE)
- Enrollment Status Page (ESP)
- Automated provisioning and reprovisioning

## Resources

- [Microsoft Intune 30-day trial](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/free-trial-sign-up)
- [Microsoft Intune documentation](https://learn.microsoft.com/en-us/intune/)
