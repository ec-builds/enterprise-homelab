# Microsoft Entra ID Device Join

Microsoft Entra ID device joining was configured to provide centralized identity for company-owned Windows devices in the lab.

The deployment allows authorized users to join Windows devices to Microsoft Entra ID and sign in to those devices using their organizational credentials.

> **Note:** Intune enrollment is documented separately. The licensing used in this lab does not provide the Microsoft Entra ID Premium functionality required for automatic MDM enrollment, so Intune enrollment is performed manually.

## Deployment

The following configuration was deployed:

| Component | Configuration |
|---|---|
| Device Identity | Microsoft Entra Joined |
| Authorized Join Group | `GRP-Entra-Device-Join-Users` |
| Group Type | Security |
| Membership | Assigned |
| Users Allowed to Join | Selected group only |
| MFA for Device Join | Required |
| Maximum Devices per User | 10 |
| Intune Enrollment | Manual |

## Device Join Access

A dedicated security group was created:

```text
GRP-Entra-Device-Join-Users
```

Users who are authorized to provision company devices are added to this group.

**Screenshot Placeholder**

`[IMAGE: GRP-Entra-Device-Join-Users membership]`

Microsoft Entra device settings were then configured so that only members of the selected group are permitted to join devices.

```text
Users may join devices to Microsoft Entra:
    Selected

Authorized group:
    GRP-Entra-Device-Join-Users

Require MFA to register or join:
    Yes

Maximum devices per user:
    10
```

**Screenshot Placeholder**

`[IMAGE: Microsoft Entra device join settings]`

This prevents general tenant users from joining devices unless they have been explicitly granted permission.

## Registered vs. Joined Testing

During initial testing, a Windows VM was connected using a work or school account. This resulted in the device becoming **Microsoft Entra registered**.

| Entra Registered | Entra Joined |
|---|---|
| Primarily BYOD | Primarily company-owned devices |
| Existing local Windows account remains primary | Entra identity can be used for Windows sign-in |
| Provides access to organizational resources | Device becomes part of the organization's Entra environment |
| `WorkplaceJoined : YES` | `AzureAdJoined : YES` |

Registration would be appropriate for a BYOD scenario where a user needs access to company applications and data from a personal computer.

Because this lab is designed around company-owned endpoints, the registered connection was removed and the device was instead Microsoft Entra joined.

**Screenshot Placeholder**

`[IMAGE: Test device shown as Microsoft Entra registered]`

**Screenshot Placeholder**

`[IMAGE: Removing the registered work or school account]`

## Device Join

Authorized users can join company Windows devices using their organizational credentials.

The resulting deployment flow is:

```text
GRP-Entra-Device-Join-Users
            │
            ▼
Authorized User
            │
            ▼
Windows Device
            │
            ▼
Microsoft Entra Join
            │
            ▼
MFA
            │
            ▼
Microsoft Entra Joined Device
```

## Verification

Device join status can be verified from Windows with:

```powershell
dsregcmd /status
```

The expected state for a cloud-only Entra joined device is:

```text
AzureAdJoined : YES
EnterpriseJoined : NO
DomainJoined : NO
```

The device can also be verified in the Microsoft Entra admin center with a **Join type** of:

```text
Microsoft Entra joined
```

**Screenshot Placeholder**

`[IMAGE: Microsoft Entra joined device verification]`

## Intune Enrollment

Microsoft Entra device identity and Intune device management are treated as separate components of the lab.

Automatic MDM enrollment is unavailable with the licensing currently used in the lab.

**Screenshot Placeholder**

`[IMAGE: Automatic MDM enrollment requiring Microsoft Entra ID Premium]`

Entra-joined Windows devices are therefore enrolled into Intune manually.

The Intune enrollment process and subsequent configuration of device groups, policies, compliance, applications, and endpoint security are documented separately.
