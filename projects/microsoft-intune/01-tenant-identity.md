# 01 · Tenant & Identity

## Intune Trial and Tenant Setup

I used Microsoft's **30-day Microsoft Intune Plan 1 trial** to create a dedicated Microsoft Entra tenant and Intune environment for the lab. For the most part, I followed Microsoft's documented **Sign up for a free trial** process, and the initial tenant setup was straightforward.

![Intune Sign Up](./diagrams/trial-sign-up-01.png)

### Setup Process

The trial signup created the Microsoft Entra tenant and Intune subscription used throughout the lab. The initial setup consisted of:

1. Starting the Microsoft Intune Plan 1 trial.
2. Creating a new organizational account.
3. Providing the required organization and verification information.
4. Selecting the initial `.onmicrosoft.com` tenant domain and administrator username.
5. Completing account verification and trial activation.
6. Signing in to the Microsoft Intune admin center with the newly created tenant account.

![Intune Sign Up](./diagrams/trial-sign-up-02.png)

The account used to create the subscription was automatically assigned the **Microsoft Entra Global Administrator** role. Because this role provides significantly more access than required for routine Intune administration, I separated privileged tenant administration from day-to-day Intune management.

## Administrative Access

The original **Global Administrator** account is reserved for tenant-level tasks that require elevated permissions.

For routine lab administration, I use a dedicated account with the Microsoft Entra **Intune Administrator** role. This provides the access required to configure and validate the full endpoint management lifecycle while keeping the time-limited lab focused on hands-on Intune administration.

In a production environment, Microsoft recommends applying **least privilege** by delegating routine responsibilities through narrower Microsoft Entra and Intune RBAC roles rather than relying on highly privileged administrative accounts.

### Entra RBAC vs. Intune RBAC

During setup, I identified an important distinction between the two administrative permission systems:

| RBAC System | Scope | Examples |
|---|---|---|
| **Microsoft Entra RBAC** | Directory and tenant-level administration | Global Administrator, Intune Administrator, User Administrator |
| **Microsoft Intune RBAC** | Granular Intune administration | Application Manager, Intune Role Administrator, Policy and Profile Manager |

Microsoft Entra roles provide broader directory or service-level administrative privileges, while Intune RBAC can delegate specific endpoint-management responsibilities and limit where those permissions apply.

To validate this model, I configured a scoped **Application Manager** role assignment using:

- **Admin Group:** `Intune-App-Admins`
- **Scope Groups:** `Intune-Lab-Users`, `Intune-Lab-Devices`
- **Scope Tags:** `None`

![Intune Application Manager RBAC Assignment](./diagrams/intune-rbac-application-manager.png)

This demonstrated how Intune can delegate a specific administrative function without granting full Intune administrative access. For the remainder of the initial lab, I use the broader Intune Administrator role rather than creating separate administrative identities for every Intune function.

Additional delegated roles, scopes, and administrative separation can be implemented later as an expansion of the IAM/RBAC portion of the lab.

> For a deeper breakdown of Intune role assignments, Admin Groups, Scope Groups, Scope Tags, and delegated administration, see [Intune RBAC Role Assignments](./docs/intune-rbac-role-assignments.md).

## Multifactor Authentication

Multifactor authentication was configured for administrative access.

Microsoft requires MFA for users signing in to administrative services including:

- Microsoft Intune admin center
- Microsoft Entra admin center
- Microsoft Azure portal

Administrative accounts therefore require an additional authentication factor before accessing the management environment.

## MDM Authority

After activating the trial, I verified the tenant's **Mobile Device Management (MDM) authority** in the Intune admin center.

```text
Tenant administration
└── Tenant details
    └── MDM authority: Microsoft Intune
```

![Intune Dashboard](./diagrams/intune-dashboard.png)

The trial configured Microsoft Intune as the MDM authority automatically, so no additional configuration was required.

## Results

At the end of the tenant and identity setup:

- Microsoft Entra tenant created and Intune Plan 1 trial activated.
- Privileged Global Administrator access separated from routine Intune administration.
- Dedicated Intune Administrator account established for the initial lab.
- Entra and Intune RBAC models explored, including a scoped Application Manager assignment.
- MFA configured for administrative access.
- MDM authority confirmed as Microsoft Intune.
- Tenant prepared for users, groups, licensing, and endpoint enrollment.

## References

- [Microsoft Learn — Sign up for a free trial and configure a Microsoft Intune tenant](https://learn.microsoft.com/en-us/intune/fundamentals/free-trial-sign-up)
- [Microsoft Learn — Assign Microsoft Intune roles for role-based access control](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control/assign-role)
