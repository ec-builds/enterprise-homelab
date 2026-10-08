# Microsoft Entra Device Join and Registration Reference

Reference guide for Microsoft Entra device registration, Microsoft Entra join, verification, disconnection, and recovery on Windows.

> Examples in this document are sanitized. Replace example tenant names, usernames, and domains with the appropriate values for the environment.

## 1. Core Concepts

Windows can establish different relationships with Microsoft Entra ID.

The two most important for cloud-managed Windows environments are:

| State | Scope | Typical Ownership | Windows Sign-In | Typical Use |
|---|---|---|---|---|
| Microsoft Entra Registered | Per-user relationship | Personal / BYOD | Existing local or personal account | Access organizational resources from a personal device |
| Microsoft Entra Joined | Device-wide relationship | Organization-owned | Microsoft Entra account | Corporate Windows endpoint |
| Microsoft Entra Hybrid Joined | Device-wide | Organization-owned | Active Directory account | AD + Entra environment |

Microsoft Entra registration and Microsoft Entra join are not the same operation.

A single Windows installation can expose both device-level and user-level Microsoft Entra relationships.

## 2. Mental Model

### Microsoft Entra Registered

Registration associates a work or school account with the current Windows user.

Conceptually:

    Windows Device
    │
    └── Local User
        │
        └── Microsoft Entra Registered
            └── Work/School Account

Registration is commonly associated with personally owned / BYOD devices.

The device owner continues using the existing Windows account.

### Microsoft Entra Joined

Joining establishes a Microsoft Entra identity for the Windows device itself.

Conceptually:

    Windows Device
    │
    └── Microsoft Entra Joined
        │
        ├── Device identity
        ├── Device certificate
        ├── TPM-backed key when available
        └── Microsoft Entra users can sign in to Windows

The relationship exists at the device level rather than belonging only to a particular Windows user.

Microsoft Entra joined Windows devices are normally organization-owned.

## 3. GUI — Microsoft Entra Registration

Use registration when connecting an existing Windows profile to a work or school account without converting the computer into a Microsoft Entra joined corporate endpoint.

Navigate to:

    Settings
      → Accounts
      → Access work or school
      → Connect

Enter the organizational account.

Do NOT select:

    Join this device to Microsoft Entra ID

when the goal is registration only.

Depending on the organization's configuration, Windows may ask whether the account should be used by other applications or whether the organization can manage the device.

## 4. Verify Microsoft Entra Registration

Run:

    dsregcmd /status

Look under:

    User State

A registered account normally appears as:

    WorkplaceJoined : YES

while the device itself may show:

    AzureAdJoined : NO
    DomainJoined  : NO

Example:

    Device State

    AzureAdJoined : NO
    DomainJoined  : NO

    User State

    WorkplaceJoined : YES

Interpretation:

    Device itself       → Not Microsoft Entra joined
    Current user        → Microsoft Entra registered

`WorkplaceJoined` represents Microsoft Entra registration.

## 5. GUI — Remove Microsoft Entra Registration

Sign in to the Windows profile containing the registered organizational account.

Navigate to:

    Settings
      → Accounts
      → Access work or school

Select the organizational account.

Choose:

    Disconnect

Confirm the operation.

Afterward run:

    dsregcmd /status

The current user's state should normally show:

    WorkplaceJoined : NO

Removing a registered work account does not necessarily remove a separate device-wide Microsoft Entra join.

## 6. GUI — Microsoft Entra Join

For an existing Windows installation:

    Settings
      → Accounts
      → Access work or school
      → Connect

In the account setup window choose:

    Join this device to Microsoft Entra ID

Enter the organizational account:

    user@example.onmicrosoft.com

Authenticate and verify the organization information.

Select:

    Join

Windows establishes a device-level Microsoft Entra relationship.

The device may require sign-out or restart before the new sign-in experience is fully available.

## 7. Microsoft Entra Join During Windows Setup

A new organization-owned Windows device can also be joined during the Windows Out-of-Box Experience (OOBE).

During setup choose:

    Set up for work or school

Authenticate using the organizational account.

Depending on tenant configuration, this process can:

- Join the device to Microsoft Entra ID
- Create the user's Windows profile
- Establish Microsoft Entra authentication
- Enroll the device into Microsoft Intune
- Apply organizational configuration

This is common for organization-owned Windows endpoints.

Windows Autopilot builds on this process for automated corporate deployment.

## 8. Verify Microsoft Entra Join

Run:

    dsregcmd /status

A cloud-only Microsoft Entra joined device normally shows:

    AzureAdJoined : YES
    DomainJoined  : NO

A healthy device should also show:

    DeviceAuthStatus : SUCCESS

Example:

    Device State

    AzureAdJoined    : YES
    DomainJoined     : NO

    Device Details

    DeviceAuthStatus : SUCCESS

Interpretation:

    AzureAdJoined : YES
        Windows contains a Microsoft Entra device join.

    DomainJoined : NO
        The device is not joined to traditional Active Directory.

    DeviceAuthStatus : SUCCESS
        Microsoft Entra recognizes and accepts the device identity.

## 9. Verify the Current Microsoft Entra User

When signed into Windows using a Microsoft Entra account, `dsregcmd /status` can show:

    Executing Account Name : AzureAD\user1

and:

    IsUserAzureAD : YES

Windows continues to use the historical `AzureAD\` prefix internally even though Azure Active Directory was renamed Microsoft Entra ID.

This does not indicate an Active Directory domain named `AzureAD`.

## 10. Primary Refresh Token

When a Microsoft Entra user signs into a healthy joined device, check:

    AzureAdPrt : YES

The Primary Refresh Token (PRT) provides Microsoft Entra single sign-on for the Windows user.

Typical healthy state:

    AzureAdJoined    : YES
    DeviceAuthStatus : SUCCESS
    AzureAdPrt       : YES

These values answer different questions:

    AzureAdJoined
        Is Windows configured as Microsoft Entra joined?

    DeviceAuthStatus
        Does Microsoft Entra currently recognize the device?

    AzureAdPrt
        Does the current user have Microsoft Entra SSO state?

## 11. Microsoft Entra Join vs Registration in dsregcmd

Quick reference:

| `dsregcmd` Value | Meaning |
|---|---|
| `AzureAdJoined : YES` | Device is Microsoft Entra joined |
| `DomainJoined : YES` | Device is Active Directory domain joined |
| Both above = `YES` | Microsoft Entra hybrid joined |
| `WorkplaceJoined : YES` | Current user/device relationship is Microsoft Entra registered |
| `DeviceAuthStatus : SUCCESS` | Entra recognizes the joined device identity |
| `AzureAdPrt : YES` | Current user has an Entra Primary Refresh Token |

Important:

`Device State` and `User State` describe different things.

For example:

    AzureAdJoined   : YES
    WorkplaceJoined : NO

is valid.

It means:

    Device
        → Microsoft Entra Joined

    Current Windows user
        → Does not have a separate Microsoft Entra Registered relationship

## 12. GUI — Leave Microsoft Entra Join

Before removing a Microsoft Entra join, ensure a working local administrator account exists.

For example:

    .\LocalAdmin

Do not rely exclusively on a Microsoft Entra account to regain access after the device leaves Microsoft Entra ID.

Navigate to:

    Settings
      → Accounts
      → Access work or school

Select the connection that identifies the organization.

A joined connection may appear similar to:

    Connected by user@example.onmicrosoft.com
    Connected to Example Organization's Entra ID

Choose:

    Disconnect

Follow the prompts.

Windows may request local administrator credentials.

Restart the computer after disconnecting.

## 13. CLI — Leave Microsoft Entra Join

Open PowerShell or Command Prompt with administrative privileges.

Run:

    dsregcmd /leave

Restart Windows.

Verify afterward:

    dsregcmd /status

For a standalone machine with no remaining registration:

    AzureAdJoined   : NO
    DomainJoined    : NO
    WorkplaceJoined : NO

## 14. GUI vs CLI Leave

Both methods ultimately remove the local Microsoft Entra device relationship, but the GUI provides a guided workflow.

GUI:

    Settings
      → Accounts
      → Access work or school
      → Organization connection
      → Disconnect

CLI:

    dsregcmd /leave

The CLI is particularly useful for:

- Troubleshooting
- Stale joins
- Recovery
- Automation
- Situations where the GUI does not expose the relationship clearly

## 15. Local Administrator Requirements

Leaving Microsoft Entra ID is a local device configuration operation.

A working local administrator can remove the local Microsoft Entra join.

A traditional Active Directory Domain Administrator is not required for a cloud-only Microsoft Entra joined device.

Example:

    Local Administrator
           │
           ▼
    dsregcmd /leave
           │
           ▼
    Local Entra configuration removed

This is one reason maintaining an appropriate recovery administrator account can be important.

## 16. Local Administrators on Microsoft Entra Joined Devices

Check local administrator membership:

    net localgroup administrators

A Microsoft Entra identity might appear as:

    AzureAD\user1

Example:

    Administrator
    AzureAD\user1
    LocalAdmin

`AzureAD\user1` represents a Microsoft Entra identity that has local administrator privileges on this Windows device.

It does NOT mean the user has an administrative Microsoft Entra tenant role.

Local Windows administrator privileges and Microsoft Entra administrative roles are separate authorization systems.

## 17. Remove an Entra User from Local Administrators

From an elevated PowerShell session:

    Remove-LocalGroupMember `
        -Group "Administrators" `
        -Member "AzureAD\user1"

Alternative:

    net localgroup administrators "AzureAD\user1" /delete

Verify:

    net localgroup administrators

Removing local administrator membership does not remove the user's Microsoft Entra identity or device join.

## 18. Deleted Entra Device Object

Deleting a device from the Microsoft Entra admin center is NOT the same as making Windows locally leave Microsoft Entra ID.

For example, after deleting the cloud device object, Windows may still show:

    AzureAdJoined : YES

while also showing:

    DeviceAuthStatus : FAILED. Device is either disabled or deleted

This creates a stale/broken relationship:

    Windows
    └── Entra configuration exists
             │
             X
             │
    Microsoft Entra
    └── Device object missing

`AzureAdJoined : YES` only confirms the local join configuration exists.

It does not prove that the cloud-side device identity is healthy.

## 19. Cached Sign-In After Device Deletion

A Microsoft Entra user who previously signed into Windows may still be able to sign in after the Entra device object is deleted.

Windows supports cached sign-in.

Therefore:

    Device deleted from Entra
             │
             ├── Existing Windows profile remains
             ├── Local files remain
             ├── Cached Windows sign-in may continue
             │
             └── Device authentication to Entra fails

Access to organizational resources protected by device-based Conditional Access can fail even though the user can still reach the Windows desktop.

## 20. Stale Join Example

A stale join can look like:

    AzureAdJoined    : YES
    DomainJoined     : NO
    DeviceAuthStatus : FAILED

Interpretation:

    Windows believes the device is joined
                +
    Entra no longer accepts the device identity

This can occur when:

- The device object was deleted from Microsoft Entra
- The device was disabled
- Device identity/trust is otherwise broken

Do not use `AzureAdJoined : YES` by itself as a complete device-health check.

## 21. Recovering a Deleted Entra Joined Device

Microsoft provides a recovery operation for Microsoft Entra joined Windows devices whose cloud device object has been deleted.

Run from an elevated command prompt:

    dsregcmd /forcerecovery

Complete the Microsoft Entra sign-in dialog.

Then sign out and sign back in.

This is different from deliberately removing the join with:

    dsregcmd /leave

Use `/forcerecovery` when the objective is to recover the Microsoft Entra relationship.

Use `/leave` when the objective is to remove the relationship.

## 22. Duplicate Device Objects

Duplicate entries can appear in Microsoft Entra when the same Windows computer establishes multiple device relationships.

Examples include:

- A user first Microsoft Entra registers a device
- The same computer is later Microsoft Entra joined
- Multiple Windows users register work accounts
- A computer is repeatedly unjoined and rejoined
- Windows is reinstalled and joined again using the same hostname

Two entries with the same device name do not necessarily represent the same device identity.

Always examine:

- Join type
- Device ID
- Owner
- Registration date
- Activity
- MDM state

rather than relying only on the device name.

## 23. Registration and Join Can Coexist

A useful troubleshooting scenario is:

    DEVICE
    └── Microsoft Entra Joined
        └── Device-wide relationship

    LOCAL USER
    └── Microsoft Entra Registered
        └── Per-user relationship

The Windows **Access work or school** GUI might not make both relationships equally obvious.

Use:

    dsregcmd /status

to distinguish them.

## 24. Useful dsregcmd Commands

### Display Status

    dsregcmd /status

Primary diagnostic command.

### Leave Microsoft Entra

    dsregcmd /leave

Removes the local Microsoft Entra join.

Administrative privileges are required.

Restart afterward.

### Recover Microsoft Entra Join

    dsregcmd /forcerecovery

Attempts recovery of an existing Microsoft Entra joined Windows device.

Useful when the corresponding cloud device identity was deleted or otherwise requires recovery.

## 25. Useful Windows GUI Shortcut

Open **Access work or school** directly:

    ms-settings:workplace

This can be entered into:

    Win + R

or launched from PowerShell:

    Start-Process "ms-settings:workplace"

## 26. Common Device States

### Standalone Windows Device

    AzureAdJoined   : NO
    DomainJoined    : NO
    WorkplaceJoined : NO

### Microsoft Entra Registered

    AzureAdJoined   : NO
    DomainJoined    : NO
    WorkplaceJoined : YES

Typical use:

    Personal / BYOD

### Microsoft Entra Joined

    AzureAdJoined    : YES
    DomainJoined     : NO
    DeviceAuthStatus : SUCCESS

Typical use:

    Organization-owned cloud-managed Windows endpoint

### Microsoft Entra Hybrid Joined

    AzureAdJoined : YES
    DomainJoined  : YES

Typical use:

    Organization using both Active Directory and Microsoft Entra ID

### Broken / Stale Microsoft Entra Join

    AzureAdJoined    : YES
    DeviceAuthStatus : FAILED

Typical causes:

    Device deleted
    Device disabled
    Device trust problem

## 27. Registration vs Join Decision

Use Microsoft Entra Registration when the organization primarily needs to recognize a personal device or provide organizational access without making the device a corporate Windows endpoint.

Typical model:

    Personal Device
          │
          ▼
    Entra Registered
          │
          ▼
    Organizational Access

Use Microsoft Entra Join when the computer is intended to operate as an organization-controlled Windows endpoint.

Typical model:

    Corporate Device
          │
          ▼
    Microsoft Entra Joined
          │
          ▼
    Microsoft Intune
          │
          ▼
    Corporate Management

## 28. Microsoft Intune Is Separate

Microsoft Entra Join does not automatically mean Microsoft Intune management is active.

A device can be:

    Microsoft Entra Joined
             +
    Not Intune Managed

Check the Microsoft Entra device record for MDM state.

Locally, `dsregcmd /status` may show MDM-related URLs when MDM configuration is available.

Conceptually:

    Microsoft Entra
        = Device identity

    Microsoft Intune
        = Device management

These systems integrate closely but perform different functions.

## 29. Troubleshooting Workflow

When investigating a Microsoft Entra Windows device:

1. Determine the currently logged-in account.

       whoami

2. Check Microsoft Entra state.

       dsregcmd /status

3. Examine:

       AzureAdJoined
       DomainJoined
       WorkplaceJoined
       DeviceAuthStatus
       AzureAdPrt
       Executing Account Name

4. Check local administrators.

       net localgroup administrators

5. Check:

       Settings
         → Accounts
         → Access work or school

6. Compare the local Device ID with:

       Microsoft Entra admin center
         → Entra ID
         → Devices
         → All devices

Do not troubleshoot based solely on the hostname.

## 30. Quick Reference

| Task | GUI | CLI |
|---|---|---|
| Check device relationship | Access work or school | `dsregcmd /status` |
| Register work account | Connect → enter work account | Normally performed through Windows/account workflow |
| Join existing Windows device | Connect → Join this device to Microsoft Entra ID | Prefer supported Windows join/provisioning workflows |
| Leave Entra join | Organization connection → Disconnect | `dsregcmd /leave` |
| Remove per-user registration | Work account → Disconnect | Prefer GUI/account workflow |
| Recover deleted joined device | — | `dsregcmd /forcerecovery` |
| Open work/school settings | Settings navigation | `Start-Process "ms-settings:workplace"` |
| Check local admins | Settings / Computer Management | `net localgroup administrators` |

## 31. Key Takeaways

Microsoft Entra Registered
    = The organization knows about the user's device relationship.

Microsoft Entra Joined
    = The Windows device belongs to the organization's Entra environment.

Microsoft Entra Hybrid Joined
    = The device belongs to both Active Directory and Microsoft Entra.

Microsoft Intune Managed
    = The organization manages configuration of the endpoint.

Remember:

    Registration is primarily user-scoped.

    Join is device-scoped.

    Intune management is separate from Entra device identity.

    AzureAdJoined : YES does not by itself prove the device trust is healthy.

For a healthy Microsoft Entra joined device, verify:

    AzureAdJoined    : YES
    DeviceAuthStatus : SUCCESS

For an Entra user's SSO session, also verify:

    AzureAdPrt : YES
