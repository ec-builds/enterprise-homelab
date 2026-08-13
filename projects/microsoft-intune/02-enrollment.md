# 02 · Enrollment

## Enrollment Preparation

Before enrolling a Windows endpoint, I created a standard test user in **Microsoft Entra ID** and assigned the Intune trial license required for device enrollment.

Although users can also be created through the Intune admin center, the underlying identities are stored in Microsoft Entra ID. I performed user administration directly through Entra and used Intune for endpoint-management operations.

The test account is a standard user rather than an administrative account, keeping device enrollment separate from privileged administration.

```text
Microsoft Entra User
        ↓
Intune License
        ↓
Automatic MDM Enrollment
        ↓
Windows 11 Endpoint
        ↓
Microsoft Intune
```

### Test User

- Created a standard user in Microsoft Entra ID.
- Assigned the Intune trial license.
- Added the user to the appropriate lab security group.
- Reserved administrative accounts for management rather than device enrollment.

## Automatic Enrollment

<!-- Configure MDM user scope and document automatic enrollment here. -->

## Windows Device Enrollment

<!-- Entra join and enroll the Windows 11 test endpoint here. -->

## Enrollment Validation

<!-- Verify the device, primary user, ownership, compliance state, and management status here. -->


## Results

<!-- Summarize the completed enrollment workflow here. -->
