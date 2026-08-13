# 01 · Enrollment

## Intune Trial and Tenant Setup

I used Microsoft's **30-day Microsoft Intune Plan 1 trial** to create a dedicated tenant for the lab. For the most part, I followed Microsoft's documented **Sign up for a free trial** process, and the initial tenant setup was straightforward.

### Setup Process

The trial signup created the Microsoft Entra tenant and Intune subscription used throughout the lab. The initial process consisted of:

1. Starting the Microsoft Intune Plan 1 trial.
2. Creating a new organizational account.
3. Providing the required organization and verification information.
4. Selecting the initial `.onmicrosoft.com` tenant domain and administrator username.
5. Completing account verification and trial activation.
6. Signing in to the Microsoft Intune admin center with the newly created tenant account.

The subscription-creation account was initially assigned the **Microsoft Entra Global Administrator** role. Rather than using this highly privileged account for routine Intune administration, I separated administrative access and used more appropriate roles for day-to-day lab tasks.

## Administrative Access

The lab uses role-based access control to separate tenant-level administration from Intune administration.

Microsoft Entra roles and Microsoft Intune RBAC roles are separate permission systems:

- **Microsoft Entra roles** provide directory and tenant-level administrative permissions.
- **Microsoft Intune roles** provide granular permissions for Intune-specific resources and operations.

The Global Administrator account is reserved for tenant-level configuration where elevated permissions are required. Routine Intune administration is performed using an account with the **Intune Administrator** role or narrower Intune RBAC roles where practical.

## MFA

Multifactor authentication was configured for administrative access. Microsoft requires MFA for users signing in to the Intune, Azure, and Microsoft Entra administrative portals.

## MDM Authority

After activating the trial, I verified the tenant's **Mobile Device Management (MDM) authority** in the Intune admin center.

```text
Tenant administration
└── Tenant details
    └── MDM authority: Microsoft Intune
```

The trial configured Microsoft Intune as the MDM authority automatically, so no additional configuration was required.

## Result

At the end of the initial setup:

- Microsoft Entra tenant created.
- Microsoft Intune trial activated.
- Intune admin center access verified.
- Administrative identities and RBAC separation established.
- MFA configured for administrative access.
- MDM authority confirmed as Microsoft Intune.
- Tenant ready for user creation, group configuration, licensing, and Windows device enrollment.

## Reference

Microsoft Learn — Step 1: Sign up for a free trial and configure a Microsoft Intune tenant  
https://learn.microsoft.com/en-us/intune/fundamentals/free-trial-sign-up
