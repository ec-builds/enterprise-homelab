# Microsoft Device Management Reference

Reference for selecting Microsoft Entra and Microsoft Intune
device-management models based on device ownership and security
requirements.

## Core Principle

Device ownership should influence the level of administrative
control assigned to the organization.

- Company-owned device → organization manages the endpoint.
- Personally owned device → organization primarily protects
  organizational access and data.

## Microsoft Management Layers

| Layer | Primary Purpose |
|---|---|
| Microsoft Entra ID | Identity and device identity |
| Conditional Access | Controls access to resources |
| Microsoft Intune MDM | Manages the device |
| Intune MAM | Protects organizational application data |
| Windows Autopilot | Provisions organization-owned Windows devices |

## Device Ownership Models

### Company-Owned

Typical architecture:

User
  ↓
Microsoft Entra Joined
  ↓
Microsoft Intune MDM
  ↓
Corporate policies applied

Recommended privilege model:

> **Employee** = Standard User

> **IT** = Administrative control

Typical controls:

- BitLocker
- Microsoft Defender
- Firewall
- Windows Update
- Application deployment
- Configuration policies
- Compliance policies
- Local administrator management
- Conditional Access

## Personally Owned / BYOD

Typical architecture:

Personal Device
  ↓
Microsoft Entra Registered
  ↓
Conditional Access
  ↓
MAM / App Protection

Ownership model:

> **Device owner** = Administrator

> **IT** = Controls access to corporate resources

The organization should generally avoid assuming full
administrative responsibility for a personally owned endpoint
unless business requirements explicitly require MDM enrollment.

## Compliance vs Management

Compliance asks:

> Is this device safe enough to access organizational resources?

Management asks:

> Can the organization configure and control this device?

These are related but separate concepts.

A BYOD policy may block corporate access when requirements are
not satisfied without requiring IT to repair or administer the
personal computer.

## Example Decision Matrix

| Device | Entra State | Management | Local Admin |
|---|---|---|---|
| Corporate Windows laptop | Entra Joined | Intune MDM | User normally Standard |
| Corporate Autopilot laptop | Entra Joined | Intune MDM | User normally Standard |
| Personal Windows laptop | Entra Registered | MAM / Conditional Access | Device owner |
| Personal phone | Entra Registered | MAM or BYOD MDM | Device owner |
| Shared corporate PC | Entra Joined | Intune MDM | IT controlled |

## Administrative Boundary

### Corporate Device

IT manages the endpoint.

IT is responsible for:
- Configuration
- Security controls
- Updates
- Compliance remediation
- Application deployment

### BYOD

IT manages organizational access and data.

The device owner remains responsible for:
- Personal applications
- Personal files
- General device maintenance
- Operating system maintenance where unmanaged

If the device fails organizational requirements, access can be
restricted rather than IT assuming responsibility for repairing
the personal device.

## Mental Model

Entra ID
    = Who are you?
      + What device is this?

Conditional Access
    = Should you be allowed access?

Intune MDM
    = How should this device be configured?

Intune MAM
    = How should organizational data inside applications be protected?

Autopilot
    = How should a corporate Windows device be provisioned?
