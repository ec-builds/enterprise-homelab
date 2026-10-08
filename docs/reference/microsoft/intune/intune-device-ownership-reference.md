# Microsoft Intune Device Ownership Reference

Reference guide for understanding Microsoft Entra device join types, Microsoft Intune ownership classifications, and the enrollment methods tested in the EC-Builds lab.

This document also outlines supported corporate enrollment methods and the current approach used to classify organization-owned Windows devices.

## Device Identity vs. Ownership

Microsoft Entra device identity and Microsoft Intune device ownership are separate properties.

- **Microsoft Entra join type** identifies how a device is connected to the organization's identity environment.
- **Microsoft Intune ownership** identifies whether a managed device is classified as Corporate or Personal.
- **Microsoft Intune enrollment** determines how the device becomes managed and can influence its initial ownership classification.

A device can be Microsoft Entra joined while still being classified as Personal in Intune.

### Microsoft Entra Device Types

| Device Type | Description | Typical Use |
|---|---|---|
| Microsoft Entra Registered | Device registered with an organizational identity without fully joining the organization | BYOD and personal devices |
| Microsoft Entra Joined | Device joined directly to Microsoft Entra ID | Cloud-managed corporate endpoints |
| Microsoft Entra Hybrid Joined | Device joined to on-premises Active Directory and registered with Microsoft Entra ID | Existing domain-joined corporate endpoints |

### Microsoft Intune Ownership

| Classification | Description |
|---|---|
| Corporate | Device identified as organization-owned |
| Personal | Device identified as personally owned or enrolled without a recognized corporate ownership signal |

Corporate ownership can provide additional device management and inventory capabilities.

Ownership can also be used when targeting policies through Intune assignment filters.

> [!Important]
> Microsoft Entra Joined does not automatically guarantee Corporate ownership in Intune. The enrollment method and available corporate ownership signals determine how Intune initially classifies the device.

## Windows Enrollment Methods

Microsoft Intune supports multiple Windows enrollment methods, each with different ownership classification behavior.

| Enrollment Method | Typical Ownership |
|---|---|
| Enroll only in device management | Personal | 
| Microsoft Entra Join followed by manual MDM-only enrollment | Personal | 
| Microsoft Entra Join with automatic MDM enrollment | Corporate under supported conditions | 
| Windows Autopilot | Corporate | 
| Group Policy automatic enrollment of hybrid-joined devices | Corporate | 
| Bulk enrollment through provisioning package | Corporate | 
| Configuration Manager co-management enrollment | Corporate | 
| Intune Company Portal enrollment | Personal unless a supported corporate classification method applies |

These classifications describe the normal behavior documented by Microsoft. Enrollment restrictions and corporate device identifiers can affect the result.

## EC-Builds Tested Enrollment Method

The current EC-Builds lab uses Microsoft Entra joined Windows 11 devices with manual Intune enrollment.

The tested workflow is:

```text
Windows 11
    │
    ▼
Microsoft Entra Join
    │
    ▼
Enroll Only in Device Management
    │
    ▼
Microsoft Intune Enrollment
    │
    ▼
Ownership = Personal
    │
    ▼
Administrator Verifies Device Ownership
    │
    ▼
Ownership Manually Changed to Corporate
```

### Observed Results

| Test | Result |
|---|---|
| Microsoft Entra Join | Successful |
| Manual Intune Enrollment | Successful |
| Initial Intune Ownership | Personal |
| Personal Windows Enrollment Blocked | Enrollment rejected |
| Personal Windows Enrollment Allowed | Enrollment successful |
| Manual Ownership Change | Corporate ownership selected |
| Device Compliance | Compliant |
| Policy Synchronization | Successful |

The device was successfully enrolled and managed despite initially being classified as Personal.

This confirmed that Microsoft Entra device identity and Intune ownership classification are independent.

## Enrollment Restrictions

The intended EC-Builds enrollment baseline is:

| Platform | Restriction |
|---|---|
| Windows MDM | Allow |
| Personally Owned Windows | Block |
| Android | Block |
| iOS/iPadOS | Block |
| macOS | Block |
| Other unsupported platforms | Block |

During testing, personally owned Windows enrollment was blocked.

The manual enrollment attempt failed with:

```text
0x80180014
Your organization does not support this version of Windows.
```

Temporarily allowing personally owned Windows devices permitted the same endpoint to enroll successfully.

Intune subsequently classified the device as Personal.

This demonstrated that the ownership restriction was enforced during enrollment.

> **Important:** Changing a device's ownership to Corporate after enrollment does not bypass enrollment restrictions. The device must first successfully enroll before its ownership can be manually corrected.

## Manually Changing Device Ownership

Until a corporate enrollment workflow is implemented and tested, EC-Builds uses manual ownership classification for known organization-owned Windows devices.

The process is:

1. Temporarily allow personally owned Windows enrollment when required.
2. Enroll the Windows device into Microsoft Intune.
3. Verify that the device is organization-owned.
4. Open the device properties in the Intune admin center.
5. Change Ownership from Personal to Corporate.
6. Save the changes and verify the resulting classification.

### Intune Admin Center

Navigate to:

```text
Devices
  → Windows
    → Select Device
      → Properties
        → Edit
          → Ownership
```

### Current EC-Builds Approach

```text
Manual MDM Enrollment
        │
        ▼
Initial Ownership = Personal
        │
        ▼
Verify Organization Ownership
        │
        ▼
Change Ownership = Corporate
        │
        ▼
Continue Intune Management
```

This approach is practical for the current lab because the number of endpoints is limited and their ownership is known.

However, it is not the preferred long-term enterprise deployment method.

Manually correcting ownership requires additional administrative effort and does not establish corporate ownership before enrollment restrictions are evaluated.

## Corporate Device Identifiers

Microsoft Intune supports corporate device identifiers that help identify organization-owned endpoints during enrollment.

For supported Windows devices, corporate identifiers consist of:

- Manufacturer
- Model
- Serial number

These identifiers can be imported into Intune before device enrollment.

When the device matches the registered identifiers, Intune can recognize it as corporate-owned during enrollment.

However, Windows corporate identifiers primarily affect enrollment-time classification. Depending on the enrollment method, a device may still appear as Personal after enrollment.

Corporate identifiers are therefore not a universal replacement for a supported corporate enrollment workflow.

For more information, see:

[Microsoft Learn — Identify devices as corporate-owned](https://learn.microsoft.com/en-us/intune/device-enrollment/add-corporate-identifiers)

## Future Hybrid Join Enrollment

A future phase of the EC-Builds lab will evaluate Microsoft Entra Connect Sync to integrate the existing on-premises Active Directory environment with Microsoft Entra ID.

The objective is to test Microsoft Entra hybrid joined Windows devices and automatic Intune enrollment through Group Policy.

The proposed workflow is:

```text
On-Premises Active Directory
            │
            ▼
Microsoft Entra Connect Sync
            │
            ▼
Microsoft Entra Hybrid Join
            │
            ▼
Group Policy Automatic MDM Enrollment
            │
            ▼
Microsoft Intune
            │
            ▼
Ownership = Corporate
```

Microsoft documents Group Policy-based automatic enrollment of hybrid-joined Windows devices as a corporate-owned enrollment method.

Hybrid join alone does not enroll a device into Intune. The appropriate MDM enrollment configuration, licensing, and Group Policy must also be implemented.

### Future Validation

The hybrid enrollment test will verify:

1. On-premises Active Directory synchronization with Microsoft Entra ID.
2. Successful Microsoft Entra hybrid join.
3. Automatic Intune enrollment through Group Policy.
4. Corporate ownership classification without manual correction.
5. Successful enrollment while personally owned Windows devices remain blocked.

Until this workflow is implemented and validated, **EC-Builds will continue manually changing the Intune ownership classification of verified organization-owned devices from Personal to Corporate after enrollment**.

## Microsoft Documentation

- [Identify devices as corporate-owned](https://learn.microsoft.com/en-us/intune/device-enrollment/add-corporate-identifiers)
- [Windows device enrollment guide](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/deployment-guide-enrollment-windows)
- [Enroll devices in Microsoft Intune](https://learn.microsoft.com/en-us/intune/device-enrollment/enroll-devices)
- [Diagnose MDM enrollment failures](https://learn.microsoft.com/en-us/windows/client-management/mdm-diagnose-enrollment)
