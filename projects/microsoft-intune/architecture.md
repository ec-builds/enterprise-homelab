# Architecture

The Microsoft Intune lab uses Microsoft Entra ID for cloud identity and device identity, with Microsoft Intune providing endpoint enrollment, management, security policy, and compliance evaluation.

The current environment is cloud-only and uses Microsoft Entra joined Windows endpoints.

## Architecture

```text
                    Microsoft Entra ID
                           │
                 ┌─────────┴─────────┐
                 │                   │
              Users /             Groups
              Identity                │
                 │                    │
                 └─────────┬──────────┘
                           │
                           ▼
                 Microsoft Entra Join
                           │
                           ▼
                  Windows 11 Endpoint
                           │
                           │ MDM Enrollment
                           ▼
                   Microsoft Intune
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
      Enrollment       Device          Compliance
      Controls         Management       Policies
          │                │                │
          └────────────────┼────────────────┘
                           │
                           ▼
                  Compliance Evaluation
                           │
                    ┌──────┴──────┐
                    │             │
                    ▼             ▼
                Compliant     Noncompliant
                                  │
                                  ▼
                              Remediate
                                  │
                                  ▼
                             Re-evaluate
```

## Components

| Component | Role |
|---|---|
| Microsoft Entra ID | Cloud identities, groups, device objects, and device join |
| Microsoft Intune | MDM enrollment, endpoint management, security policy, and compliance |
| Windows 11 Endpoints | Microsoft Entra joined and Intune-managed test devices |
| Microsoft Graph | Programmatic administration, automation, and reporting |

## Device Management and Enrollment

Microsoft Entra ID establishes the device's cloud identity, while Microsoft Intune provides device management. Entra join state, Intune management state, and Intune ownership classification are separate properties.

The current enrollment workflow is:

```text
Windows 11
    ↓
Microsoft Entra Join
    ↓
Manual Intune MDM Enrollment
    ↓
Intune Device Record
    ↓
Corporate Ownership Validation
    ↓
Compliance Evaluation
```

The manual MDM enrollment method initially classified tested endpoints as Personal. Verified organization-owned lab devices are therefore changed to Corporate after enrollment.

Corporate Windows endpoints are assigned to the `Intune-corporate-devices` security group, which provides a defined scope for applicable Intune policies.

## Compliance

The `Windows Corporate Device Compliance` policy evaluates managed corporate endpoints against the established Windows security and operating-system baseline.

```text
Intune-corporate-devices
          │
          ▼
Windows Corporate Device Compliance
          │
          ▼
   Endpoint Evaluation
          │
     ┌────┴────┐
     │         │
     ▼         ▼
 Compliant  Noncompliant
               │
               ▼
       Identify Failed Control
               │
               ▼
           Remediate
               │
               ▼
          Intune Sync
               │
               ▼
          Re-evaluate
```

The lab has validated this lifecycle by identifying and remediating failed requirements and confirming that the affected endpoint returned to a Compliant state.

## Design Decisions

| Decision | Rationale |
|---|---|
| Cloud-only identity | Focuses the current environment on cloud-native Windows management |
| Microsoft Entra join | Provides cloud-based device identity without requiring on-premises Active Directory integration |
| Group-based policy assignment | Provides controlled policy scope and supports future expansion |
| Remediation before policy relaxation | Preserves the intended security baseline while correcting endpoint or configuration issues |

