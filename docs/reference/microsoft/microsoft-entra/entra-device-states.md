# Microsoft Entra Device States

Quick reference for understanding device identity and management states in Microsoft Entra ID and Microsoft Intune.

## Device States

| State | Meaning | Typical Use |
|---|---|---|
| **Entra Registered** | Personal/local device associated with a work account | BYOD, personal devices |
| **Entra Joined** | Device belongs to the organization and uses Entra authentication | Corporate/cloud-managed PCs |
| **Hybrid Entra Joined** | Device is joined to on-premises Active Directory and registered with Entra | Traditional AD environments |
| **Intune Managed** | Device is enrolled into Intune MDM | Policies, apps, compliance, security |

These states can overlap. For example, an **Entra Joined** device can also be **Intune Managed**.

---

## Microsoft Entra Registered

Usually occurs when a user adds a work or school account to an existing Windows installation.

```text
Personal/Local Windows Device
          +
     Work Account
          ↓
    Entra Registered
```

Check:

```powershell
dsregcmd /status
```

Typical result:

```text
AzureAdJoined  : NO
DomainJoined   : NO
WorkplaceJoined: YES
```

The user can continue signing into Windows with their existing local or Microsoft account.

---

## Microsoft Entra Joined

The computer itself belongs to the Entra organization.

```text
Windows Device
      ↓
Microsoft Entra ID
```

Typical result:

```text
AzureAdJoined : YES
DomainJoined  : NO
```

Users can sign into Windows using their organizational Entra identity.

Common for modern cloud-managed corporate Windows devices.

---

## Hybrid Entra Joined

The computer is joined to traditional Active Directory while also having an identity in Microsoft Entra.

```text
Windows Device
     ↓
Active Directory
     +
Microsoft Entra ID
```

Typical result:

```text
AzureAdJoined : YES
DomainJoined  : YES
```

Common in organizations transitioning from traditional Active Directory to cloud management.

---

## Intune Managed

Intune management is separate from the Entra join state.

```text
Device Identity
      ↓
Microsoft Entra
      +
MDM Enrollment
      ↓
Microsoft Intune
```

Intune can provide:

- Configuration policies
- Compliance policies
- Application deployment
- Security settings
- Device inventory
- Remote administrative actions

A device appearing in Entra does **not** automatically mean it is managed by Intune.

---

## Common Combinations

```text
Entra Registered
└── Unmanaged

Entra Registered
└── Intune Managed

Entra Joined
└── Unmanaged

Entra Joined
└── Intune Managed        ← Common cloud corporate deployment

Hybrid Entra Joined
└── Intune Managed        ← Common hybrid enterprise deployment
```

---

## Quick Diagnostic

Run:

```powershell
dsregcmd /status
```

Key fields:

| Field | Meaning |
|---|---|
| `AzureAdJoined : YES` | Microsoft Entra joined |
| `DomainJoined : YES` | Traditional Active Directory joined |
| `WorkplaceJoined : YES` | Microsoft Entra registered |
| `AzureAdPrt : YES` | User has an Entra Primary Refresh Token for SSO |

For Intune management status, also verify the device in the **Microsoft Intune admin center**.

---

## Simple Mental Model

```text
Entra Registered = Entra knows about the device

Entra Joined     = Device belongs to the Entra organization

Intune Managed   = Intune manages the device

Hybrid Joined    = AD + Entra device identity
```
