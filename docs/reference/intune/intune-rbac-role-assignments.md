# Microsoft Intune RBAC Role Assignments

## Overview
>Verified: 2026-08-13 · Intune service release 2607

Microsoft Intune uses role-based access control (RBAC) to delegate administrative permissions without giving every administrator full Intune access.

Unlike assigning a Microsoft Entra administrative role, Intune RBAC separates the **role** from the **role assignment**.

```text
Role
└── What can the administrator do?

Role Assignment
├── Who receives the permissions?
├── Who or what can they manage?
└── Which Intune resources can they see?
```

This allows the same Intune role to be reused across different administrative teams while limiting each team to the resources it is responsible for.

## Core Components

| Component | Purpose | Example |
|---|---|---|
| **Role** | Defines what actions an administrator can perform. | Application Manager |
| **Role Assignment** | Connects a role to administrators and an administrative scope. | Application Manager - Intune App Admins |
| **Admin Groups** | Security groups containing the administrators who receive the role permissions. | `Intune-App-Admins` |
| **Scope Groups** | Users or devices the administrators are allowed to manage. | `Intune-Lab-Users`, `Intune-Lab-Devices` |
| **Scope Tags** | Restrict which Intune resources administrators can see and manage. | Default, Department, Location |

## Role Assignment Model

```text
Application Manager
        │
        └── Role Assignment
            │
            ├── Admin Groups
            │   └── Intune-App-Admins
            │       └── Administrator accounts
            │
            ├── Scope Groups
            │   ├── Intune-Lab-Users
            │   └── Intune-Lab-Devices
            │
            └── Scope Tags
                └── Default
```

### Admin Groups vs. Scope Groups

```text
Admin Group = WHO can administer
Scope Group = WHO or WHAT they can administer
Scope Tags  = WHICH Intune resources they can see
```

Members of a Scope Group do **not** receive the administrative role. Only administrators in the Admin Group receive the permissions.

## Creating an Intune Role Assignment

### 1. Create the Administrative Security Group

Create a Microsoft Entra **security group** containing the administrators who should receive the Intune role.

Example:

```text
Intune-App-Admins
└── intuneadmin
```

Using a group allows administrative access to be managed through group membership instead of individual Intune role assignments.

### 2. Create Resource Scope Groups

Create Microsoft Entra security groups containing the users and devices the delegated administrators should be allowed to manage.

Example:

```text
Intune-Lab-Users
Intune-Lab-Devices
```

These groups establish an administrative boundary around the lab resources.

### 3. Open the Intune Role

In the Microsoft Intune admin center, navigate to:

```text
Tenant administration
└── Roles
    └── All roles
```

Select the required built-in or custom Intune role.

Example:

```text
Application Manager
```

### 4. Create the Role Assignment

Open:

```text
Assignments
└── + Assign
```

Provide a descriptive assignment name.

Example:

```text
Application Manager - Intune App Admins
```

The assignment name identifies this specific combination of role, administrators, and scope.

A single role can have multiple assignments for different administrative teams or boundaries.

### 5. Configure Admin Groups

Under **Admin Groups**, select the security group containing the administrators who should receive the role.

Example:

```text
Intune-App-Admins
```

Members of this group receive the permissions defined by the Application Manager role.

### 6. Configure Scope Groups

Under **Scope (Groups)**, select the users and devices the administrators should be allowed to manage.

Example:

```text
Intune-Lab-Users
Intune-Lab-Devices
```

Intune also provides broad virtual groups such as **All users** and **All devices**. These should be selected intentionally because they can significantly expand the administrative scope of an assignment.

### 7. Configure Scope Tags

Select the appropriate **Scope Tags**.

Scope tags provide another layer of administrative separation by controlling which Intune resources an administrator can see.

They can be used to separate resources by:

- Department
- Location
- Business unit
- Administrative team
- Other organizational boundaries

For a simple lab, the default scope is sufficient.

> [!IMPORTANT]
> Having no scope tags does **not** mean an administrator has no visibility. An administrator whose role assignment has no scope tags can effectively see objects across all scope tags, subject to the permissions and other scopes of the role assignment.

### 8. Review and Create

Review the assignment and select **Create**.

The resulting relationship is:

```text
Administrator
      │
      ▼
Admin Security Group
      │
      ▼
Intune Role Assignment
      │
      ├── Role permissions
      ├── Scope groups
      └── Scope tags
```

## Why Intune Uses This Model

A simple user-to-role assignment answers:

> What can this administrator do?

Intune also needs to answer:

> Where can this administrator do it?

Separating roles from assignments allows the same permission set to be reused while changing the administrators and resources to which those permissions apply.

For example:

```text
Application Manager
│
├── Assignment: Corporate App Admins
│   ├── Admin Group: Corporate-App-Admins
│   └── Scope: Corporate users/devices
│
├── Assignment: West Coast App Admins
│   ├── Admin Group: WestCoast-App-Admins
│   └── Scope: West Coast users/devices
│
└── Assignment: Europe App Admins
    ├── Admin Group: Europe-App-Admins
    └── Scope: Europe users/devices
```

The **Application Manager permissions remain consistent**, while each assignment establishes a different administrative boundary.

## How This Helps at Scale

- **Least privilege** — administrators receive only the permissions required for their responsibilities.
- **Delegated administration** — different teams can manage different populations without tenant-wide access.
- **Group-based administration** — access can be changed through security group membership instead of individual role assignments.
- **Reusable roles** — one role definition can support multiple administrative teams and scopes.
- **Consistent onboarding and offboarding** — administrators gain or lose delegated access when their group membership changes.
- **Administrative boundaries** — Scope Groups and Scope Tags can separate management by department, location, business unit, or function.
- **Reduced privileged access** — routine administration can use narrowly scoped Intune roles rather than broad Microsoft Entra administrative roles.

## Intune RBAC vs. Microsoft Entra Roles

An important distinction is that **Intune RBAC does not restrict permissions granted through Microsoft Entra administrative roles**.

Microsoft Entra roles such as **Global Administrator** and **Intune Administrator** provide broad permissions within Intune independently of Intune role assignments and scope tags.

```text
Microsoft Entra Intune Administrator
        │
        └── Broad Intune administrative access
            └── Intune scope tags do not constrain it


Intune RBAC Administrator
        │
        └── Intune Role Assignment
            ├── Role permissions
            ├── Scope Groups
            └── Scope Tags
```

> [!IMPORTANT]
> Assigning an administrator a broad Microsoft Entra role can bypass the administrative boundaries established through Intune RBAC. Microsoft recommends using Intune built-in or custom RBAC roles for routine Intune administration and limiting privileged Microsoft Entra roles to tasks that require them.

This is why an account used to configure the tenant initially might hold the Microsoft Entra **Intune Administrator** role, while day-to-day administrators should use narrower Intune RBAC roles where possible.

## Cumulative Permissions

Intune permissions from multiple role assignments can be cumulative.

An administrator who belongs to multiple administrative groups can therefore receive broader effective permissions than expected.

```text
Assignment A
Read Apps
        +
Assignment B
Manage Apps
        ↓
Effective permissions can expand
```

Scope tags across multiple assignments can also interact in ways that broaden access.

For this reason:

- Keep administrative groups purpose-specific.
- Review group membership regularly.
- Avoid unnecessary overlapping role assignments.
- Use narrowly scoped roles for routine administration.
- Review effective permissions when troubleshooting unexpected administrative access.

## Unlicensed Administrator Access

Intune supports administrative accounts that don't have an Intune license assigned.

For tenants created after **July 2021**, unlicensed administrator access is enabled by default.

This means an account used only to administer Intune doesn't necessarily need to consume an Intune user license.

The setting can be found under:

```text
Tenant administration
└── Roles
    └── Administrator Licensing
        └── Allow access to unlicensed admins
```

For older tenants where this feature must be enabled manually, enabling it is **irreversible**.

Intune also supports a maximum of **1,000 unlicensed administrators per security group**. Larger delegated-administration environments require additional security groups.

Unlicensed administrator access only removes the Intune license requirement for administrative access. It does not provide licenses for other Microsoft services or features that independently require licensing.

## Lab Example

The lab uses the following structure to demonstrate delegated application administration:

```text
Role
└── Application Manager

Role Assignment
└── Application Manager - Intune App Admins

Admin Group
└── Intune-App-Admins
    └── Limited administrator account

Scope Groups
├── Intune-Lab-Users
└── Intune-Lab-Devices

Scope Tags
└── Default
```

This demonstrates how Intune can delegate a specific administrative function to a security group while limiting administration to a defined set of users and devices.

A limited administrator can then be used to validate that the RBAC boundary works as intended rather than relying only on the configuration shown in the admin portal.

## Key Takeaway

Intune RBAC is designed around more than assigning permissions:

```text
WHAT can you do?
        +
WHO can do it?
        +
WHERE can they do it?
        =
Delegated Administration
```

This additional complexity allows Intune administration to scale across teams, locations, departments, and responsibilities while maintaining least-privilege access.

## References

- [Role-based access control with Microsoft Intune](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/role-based-access-control/)
- [Use RBAC and scope tags for distributed IT](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/scope-tags)
- [Microsoft Intune licensing](https://learn.microsoft.com/en-us/intune/intune-service/fundamentals/licenses)
