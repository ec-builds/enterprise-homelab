# 💻 Microsoft Intune Lab

**Status: 🟡 In Progress**

A hands-on Microsoft Intune lab extending my systems administration experience into cloud-native endpoint management, security, automation, and Identity and Access Management.

## Overview

With my background primarily in hybrid Microsoft environments, managing on-premises Active Directory synchronized with Microsoft Entra ID alongside Group Policy and Windows endpoint administration, I’m using this lab to extend that experience into cloud-native endpoint management with Microsoft Intune.

The goal is to understand not only how Intune is configured, but how endpoints are enrolled and managed, how policies and applications reach devices, how security and compliance controls interact with identity, how deployments are validated, and how failures are investigated and remediated.

The lab follows the endpoint management lifecycle:

```text
Identity
   ↓
Enroll
   ↓
Configure
   ↓
Secure
   ↓
Deploy
   ↓
Validate
   ↓
Monitor
   ↓
Remediate
   ↓
Retire
```

## Lab Environment

| Component | Platform |
|---|---|
| **Endpoint Management** | Microsoft Intune Plan 1 |
| **Identity** | Microsoft Entra ID |
| **Endpoints** | Windows 11 |
| **Virtualization** | Microsoft Hyper-V |
| **Test Devices** | Windows 11 VMs / physical Dell OptiPlex |
| **Automation** | PowerShell |
| **License** | [30-day Microsoft Intune trial](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/free-trial-sign-up) |

## Lab Areas

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned

| Area | Focus | Status |
|---|---|:---:|
| Tenant & Identity | Tenant foundation, users, groups, roles and administrative access | 🟡 |
| Device Management | Enrollment, Entra join, inventory and device lifecycle | ⚪ |
| Configuration Management | Settings Catalog, configuration profiles and endpoint settings | ⚪ |
| Application Management | Microsoft Store and Win32 application deployment | ⚪ |
| Compliance | Device requirements, compliance evaluation and remediation | ⚪ |
| Identity & Access | Compliance integration and Conditional Access testing | ⚪ |
| Endpoint Security | Defender, Firewall, BitLocker and security baselines | ⚪ |
| Update Management | Windows Update rings and staged deployment | ⚪ |
| Automation | PowerShell-based endpoint administration | ⚪ |
| Monitoring & Reporting | Deployment status, reporting and troubleshooting | ⚪ |
| Device Lifecycle | Remote actions, retire, wipe and reprovisioning | ⚪ |

## 01 · Tenant & Identity

Establish the Microsoft Entra and Intune foundation used throughout the lab.

### Planned Labs

- Intune trial and tenant setup
- MDM authority
- Administrative accounts
- Test users and license assignment
- Microsoft Entra groups
- Multifactor authentication
- Microsoft Entra administrative roles
- Microsoft Intune RBAC
- Least-privilege administration

## 02 · Device Management

Enroll and manage Windows endpoints through Microsoft Intune.

### Planned Labs

- Automatic MDM enrollment
- Microsoft Entra join
- Windows 11 enrollment
- VM enrollment
- Physical endpoint enrollment
- Device inventory
- Primary user validation
- Device groups
- Remote device actions

### Validation

```text
Windows 11
     ↓
Microsoft Entra ID
     ↓
Intune Enrollment
     ↓
Managed Device
```

## 03 · Configuration Management

Centrally configure Windows endpoints rather than managing settings individually.

### Planned Labs

- Settings Catalog
- Windows configuration profiles
- Device restrictions
- Microsoft Edge policies
- OneDrive policies
- Policy assignments
- User versus device targeting
- Configuration deployment validation
- Configuration troubleshooting

## 04 · Application Management

Package, deploy and manage Windows applications remotely.

### Planned Labs

- Microsoft Store applications
- Win32 application packaging
- Required applications
- Available applications
- Application assignments
- Detection rules
- Application uninstall
- Deployment monitoring
- Failed deployment troubleshooting

### Deployment Workflow

```text
Package
   ↓
Configure
   ↓
Assign
   ↓
Deploy
   ↓
Detect
   ↓
Validate
```

## 05 · Compliance & Identity

Define endpoint requirements and integrate device state with identity controls.

### Planned Labs

- Compliance policies
- Compliant and noncompliant device states
- Noncompliance notifications
- Grace periods
- Device remediation
- Compliance reporting
- Conditional Access testing
- Require compliant device
- Multifactor authentication policy testing

### Compliance Workflow

```text
Compliant
    ↓
Introduce Configuration Failure
    ↓
Noncompliant
    ↓
Investigate
    ↓
Remediate
    ↓
Compliant
```

## 06 · Endpoint Security

Apply and validate security controls through Microsoft Intune.

### Planned Labs

- Microsoft Defender Antivirus
- Windows Firewall
- BitLocker
- Recovery key management
- Security baselines
- Endpoint security policies
- Security policy assignments
- Security configuration validation

## 07 · Update Management

Manage Windows updates centrally and model a staged enterprise deployment strategy.

### Planned Labs

- Windows Update rings
- Pilot update group
- Broad deployment group
- Update deadlines
- Restart behavior
- Update reporting
- Update troubleshooting

### Deployment Model

```text
Pilot
  ↓
Validate
  ↓
Broad Deployment
```

## 08 · Automation

Use PowerShell to automate endpoint configuration and administration.

### Planned Labs

- PowerShell script deployment
- Configuration automation
- Device inventory
- Script logging
- Exit codes
- Deployment monitoring
- Failure handling
- Script troubleshooting

## 09 · Monitoring & Reporting

Use Intune reporting and deployment information to validate management operations and investigate failures.

### Planned Labs

- Device inventory reporting
- Configuration profile status
- Application deployment status
- Compliance reporting
- Update reporting
- Script deployment status
- Failed deployment investigation
- Troubleshooting workflow

## 10 · Device Lifecycle

Manage endpoints through their complete administrative lifecycle.

### Planned Labs

- Device onboarding
- Remote synchronization
- Remote actions
- Retire
- Wipe
- Fresh Start
- Device deletion
- Re-enrollment
- Offboarding validation

### Lifecycle

```text
Provision
   ↓
Enroll
   ↓
Configure
   ↓
Operate
   ↓
Maintain
   ↓
Offboard
   ↓
Retire / Wipe
```

## Procedures

Individual procedures document repeatable administrative tasks performed during the lab.

Each procedure should include:

- Objective
- Prerequisites
- Configuration
- Assignment / targeting
- Validation
- Screenshots
- Troubleshooting
- Result

Planned procedures include:

| Procedure | Status |
|---|:---:|
| Enroll a Windows 11 device | ⚪ |
| Microsoft Entra join a Windows 11 device | ⚪ |
| Create and deploy a configuration profile | ⚪ |
| Deploy a Windows security baseline | ⚪ |
| Configure BitLocker | ⚪ |
| Create a Windows Update ring | ⚪ |
| Package and deploy a Win32 application | ⚪ |
| Configure Win32 application detection rules | ⚪ |
| Create a compliance policy | ⚪ |
| Investigate a noncompliant device | ⚪ |
| Require a compliant device for access | ⚪ |
| Deploy a PowerShell script | ⚪ |
| Troubleshoot a failed application deployment | ⚪ |
| Retire a managed device | ⚪ |
| Wipe and re-enroll a managed device | ⚪ |

## End-to-End Scenario

The final lab combines the individual components into a simulated endpoint lifecycle.

```text
Create User
    ↓
Assign License / Group
    ↓
Microsoft Entra Join
    ↓
Intune Enrollment
    ↓
Configuration Policies
    ↓
Endpoint Security
    ↓
Application Deployment
    ↓
Update Management
    ↓
Compliance Evaluation
    ↓
Access Control
    ↓
Monitoring / Troubleshooting
    ↓
Retire / Wipe
```

The objective is to demonstrate how identity, endpoint management, application deployment, security, compliance, and automation operate together rather than as isolated Intune features.

## Directory Structure

```text
intune-lab/
│
├── README.md
├── architecture.md
├── lab-build.md
├── future-improvements.md
│
├── 01-tenant-identity/
├── 02-device-management/
├── 03-configuration-management/
├── 04-application-management/
├── 05-compliance-identity/
├── 06-endpoint-security/
├── 07-update-management/
├── 08-automation/
├── 09-monitoring-reporting/
├── 10-device-lifecycle/
│
├── procedures/
│   ├── enroll-windows-device.md
│   ├── deploy-configuration-profile.md
│   ├── deploy-win32-application.md
│   ├── investigate-noncompliance.md
│   └── ...
│
├── scripts/
│   ├── inventory.ps1
│   └── ...
│
└── diagrams/
    └── ...
```

## Documentation Approach

The repository separates architecture, implementation, and operational procedures.

| Document | Purpose |
|---|---|
| `README.md` | Project overview, capabilities and progress |
| `architecture.md` | Intune, Entra ID and endpoint architecture |
| `lab-build.md` | Initial environment and tenant build |
| Area directories | Configuration and implementation notes for each technology area |
| `procedures/` | Repeatable administrative runbooks |
| `scripts/` | PowerShell automation developed during the lab |
| `future-improvements.md` | Planned extensions and future lab capabilities |

Sensitive tenant information, user identities, device identifiers and other environment-specific information are excluded or sanitized from public documentation.

## Future Expansion

### Windows Autopilot

Windows Autopilot is intentionally outside the initial lab scope so the project can first focus on day-to-day Intune administration and endpoint management.

Potential additions include:

- Windows Autopilot device registration
- Deployment profiles
- Out-of-Box Experience (OOBE)
- Enrollment Status Page (ESP)
- Automated provisioning
- Device reprovisioning

### Additional Expansion

Future lab development may also include:

- Advanced Conditional Access scenarios
- Windows LAPS
- Endpoint Privilege Management
- Proactive remediation scenarios
- Additional application packaging
- Mobile device management
- Mobile application management
- Expanded reporting and automation

## Resources

- [Microsoft Intune 30-day trial](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/free-trial-sign-up)
- [Microsoft Intune documentation](https://learn.microsoft.com/en-us/intune/)
