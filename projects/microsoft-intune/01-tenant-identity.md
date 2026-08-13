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

### Trial Licensing

The Intune free trial also provisions a trial **Enterprise Mobility + Security (EMS)** subscription, which includes Microsoft Intune and Microsoft Entra ID Premium capabilities.

This distinction is important because some capabilities used with Intune depend on Microsoft Entra licensing rather than Intune Plan 1 alone. For example, **automatic MDM enrollment** requires Microsoft Entra ID P1 or P2, and Entra Premium also enables identity capabilities such as Conditional Access.

Understanding this licensing relationship is important when translating the lab configuration to a production environment, where Intune and Microsoft Entra licensing may be purchased or bundled differently.

## Administrative Access

The original administrative account retains the **Global Administrator** role and is reserved for tenant-level tasks that require elevated permissions.

For routine lab administration, I use a dedicated account with the Microsoft Entra **Intune Administrator** role. This provides the access required to configure and validate the full endpoint management lifecycle while keeping the time-limited lab focused on hands-on Intune administration.

In a production environment, Microsoft recommends applying **least privilege** by delegating routine responsibilities through narrower Microsoft Entra and Intune RBAC roles rather than relying on highly privileged administrative accounts.

### Entra RBAC vs. Intune RBAC

During setup, I initially looked for the **Application Manager** role among Microsoft Entra directory roles. When it wasn't available there, I identified an important distinction between the two administrative permission systems:

| RBAC System | Scope | Examples |
|---|---|---|
| **Microsoft Entra RBAC** | Directory and tenant-level administration | Global Administrator, Intune Administrator, User Administrator |
| **Microsoft Intune RBAC** | Granular Intune administration | Application Manager, Intune Role Administrator, Policy and Profile Manager |

Microsoft Entra roles provide broader directory or service-level administrative privileges, while Intune RBAC can delegate specific endpoint-management responsibilities and limit where those permissions apply.

To validate this model, I configured an **Application Manager** role assignment with dedicated administrative and resource scope groups:

- **Admin Group:** `Intune-App-Admins`
- **Scope Groups:** `Intune-Lab-Users`, `Intune-Lab-Devices`
- **Scope Tags:** `None`

![Intune Application Manager RBAC Assignment](./diagrams/intune-rbac-application-manager.png)

This demonstrated how Intune can delegate a specific administrative function without granting full Intune administrative access. For the remainder of the initial lab, I use the broader Intune Administrator role rather than creating separate administrative identities for every Intune function.

Additional delegated roles, scopes, and administrative separation can be implemented later as an expansion of the IAM/RBAC portion of the lab.

> For a deeper breakdown of Intune role assignments, Admin Groups, Scope Groups, Scope Tags, and delegated administration, see [Intune RBAC Role Assignments](../../docs/reference/intune/intune-rbac-role-assignments.md)

## Multifactor Authentication

During initial administrative sign-in, Microsoft's mandatory MFA requirement was enforced and required the administrative account to register an additional authentication method.

I registered **Microsoft Authenticator** and verified successful MFA-protected access to the Microsoft Intune and Entra administrative portals.

This was a platform-enforced requirement rather than an MFA policy I created within the lab. Conditional Access and additional identity security controls are outside the initial tenant setup and can be explored separately.

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

- Microsoft Entra tenant created and Intune trial activated.
- Trial licensing and the relationship between Intune and Microsoft Entra Premium capabilities identified.
- Privileged Global Administrator access separated from routine Intune administration.
- Dedicated Intune Administrator account established for the initial lab.
- Entra and Intune RBAC models explored, including an Application Manager assignment scoped to dedicated lab user and device groups.
- Microsoft's mandatory administrative MFA requirement satisfied using Microsoft Authenticator.
- MDM authority confirmed as Microsoft Intune.
- Tenant prepared for users, groups, licensing, and endpoint enrollment.

## References

- [Microsoft Learn — Sign up for a free trial and configure a Microsoft Intune tenant](https://learn.microsoft.com/en-us/intune/fundamentals/free-trial-sign-up)
- [Microsoft Learn — Microsoft Intune licensing](https://learn.microsoft.com/en-us/intune/fundamentals/licensing)
- [Microsoft Learn — Set up automatic enrollment for Windows devices](https://learn.microsoft.com/en-us/mem/intune/enrollment/quickstart-setup-auto-enrollment)
- [Microsoft Learn — Assign Microsoft Intune roles for role-based access control](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control/assign-role)
