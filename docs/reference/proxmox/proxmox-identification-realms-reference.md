# 🔐 Proxmox Authentication Realms Reference

> Examples use generic usernames, domains, and realm names. Values do not
> represent the internal configuration of the documented environment.

## Overview

An authentication **realm** defines where Proxmox VE verifies a user's
identity.

A Proxmox username therefore consists of both a user and a realm:

    username@realm

Examples:

    root@pam
    admin@pve
    jsmith@corp-ad
    user@example-oidc

The realm answers the question:

> "Where should Proxmox authenticate this user?"

Authentication and authorization are separate concepts:

- **Authentication** — Who are you?
- **Authorization** — What are you allowed to do?

A realm authenticates the user. Proxmox permissions, roles, groups, and ACLs
determine what that authenticated user can access.

# Realm Types

## 1. Linux PAM

Typical realm:

    pam

Example:

    root@pam

PAM stands for **Pluggable Authentication Modules**.

This realm authenticates against accounts recognized by the underlying
Debian Linux operating system.

The default Proxmox administrative account is typically:

    root@pam

### Use PAM When

- Authenticating the Linux `root` account
- Using Linux system accounts
- Administrative or recovery access is required
- Managing a small standalone environment

### Advantages

- Available by default
- Directly tied to the underlying Linux system
- Useful for emergency and recovery administration
- Does not depend on an external identity provider

### Considerations

PAM users are operating-system accounts, so creating unnecessary PAM users
also creates additional Linux identities on the Proxmox hosts.

For routine Proxmox administration, it can be preferable to use another
realm and reserve `root@pam` for privileged or recovery operations.

# 2. Proxmox VE Authentication Server

Typical realm:

    pve

Example:

    admin@pve

The **PVE realm** is Proxmox's built-in authentication database.

Users created here exist within Proxmox rather than as Linux system users.

### Use PVE When

- Running a small environment without centralized identity
- Creating Proxmox-only administrators
- Creating lab accounts
- Creating service-specific accounts
- Separating Proxmox identities from Linux accounts

### Advantages

- Simple to configure
- No external authentication infrastructure required
- Accounts do not need to exist as Linux users
- Managed directly through Proxmox

### Example

Instead of using:

    root@pam

for everyday administration, an administrator could create:

    admin@pve

and assign the appropriate Proxmox permissions.

# 3. LDAP

Example realm:

    company-ldap

Example user:

    jsmith@company-ldap

LDAP allows Proxmox to authenticate users against an external
**Lightweight Directory Access Protocol** directory.

Examples of LDAP-compatible directory services include:

- OpenLDAP
- FreeIPA
- Other enterprise LDAP directories

### Use LDAP When

- An organization already maintains an LDAP directory
- Users should authenticate using centralized credentials
- Multiple systems use the same directory
- Centralized user lifecycle management is desired

### Advantages

- Centralized authentication
- Reduces duplicate local accounts
- Supports centralized user management
- LDAP users and groups can be synchronized into Proxmox

### Conceptual Flow

    User
      │
      ▼
    Proxmox
      │
      ▼
    LDAP Directory
      │
      ▼
    Authentication Result

Proxmox still controls authorization to its resources.

Successfully authenticating through LDAP does not automatically give the
user administrative access.

# 4. Microsoft Active Directory

Example realm:

    corp-ad

Example user:

    jsmith@corp-ad

The **Active Directory realm** integrates Proxmox with Microsoft Active
Directory.

This is particularly useful in organizations already using AD for
centralized identity management.

### Use Active Directory When

- Windows Active Directory already exists
- Employees should use their domain credentials
- Proxmox access should follow centralized account management
- AD groups will be used to organize administrators or users

### Advantages

- Existing domain credentials can be reused
- Centralized password and account management
- Users and groups can be synchronized
- Fits naturally into Microsoft-oriented enterprise environments

### Example Architecture

    Proxmox Cluster
          │
          │ Authentication
          ▼
    Active Directory
          │
          ├── Administrators
          ├── Infrastructure Team
          └── Help Desk

Proxmox permissions can then determine what those identities are allowed
to manage.

For example:

    Infrastructure Team
            │
            ▼
      Proxmox Group
            │
            ▼
      Assigned Role
            │
            ▼
       VM / Node / Storage

This separates identity management from Proxmox resource permissions.

# 5. OpenID Connect (OIDC)

Example realm:

    company-oidc

Example user:

    user@company-oidc

OpenID Connect allows Proxmox to delegate authentication to an external
identity provider.

OIDC is commonly used for modern Single Sign-On (SSO).

Possible identity providers include services implementing the OpenID
Connect standard.

### Use OIDC When

- Implementing Single Sign-On
- Using a modern cloud identity provider
- Centralizing authentication outside Proxmox
- Users should authenticate through an organization's identity platform

### Conceptual Flow

    User
      │
      ▼
    Proxmox Login
      │
      ▼
    Identity Provider
      │
      ├── Authentication
      ├── MFA
      └── Identity Policies
      │
      ▼
    Authentication Token
      │
      ▼
    Proxmox

Proxmox trusts the configured identity provider to authenticate the user.

Authorization remains controlled by Proxmox.

# Realm Comparison

| Realm | Authentication Source | Typical Use |
|---|---|---|
| PAM | Linux operating system | Root / recovery / Linux accounts |
| PVE | Proxmox internal database | Local Proxmox users |
| LDAP | LDAP directory | Centralized enterprise identity |
| Active Directory | Microsoft AD | Windows domain environments |
| OpenID Connect | External identity provider | SSO / modern identity platforms |

# Authentication vs Authorization

Realms should not be confused with Proxmox roles and permissions.

A realm determines:

    WHO ARE YOU?

Permissions determine:

    WHAT CAN YOU DO?

For example:

    jsmith@corp-ad
          │
          │ authenticated by
          ▼
    Active Directory
          │
          ▼
    Proxmox Group
          │
          ▼
    PVEVMAdmin Role
          │
          ▼
    /vms/production

The identity originates from Active Directory, while Proxmox determines
which resources that identity can manage.

# Multiple Realms

A Proxmox environment can use multiple realms simultaneously.

For example:

    root@pam
        │
        └── Emergency / system administration

    admin@pve
        │
        └── Local Proxmox administrator

    jsmith@corp-ad
        │
        └── Enterprise administrator

    user@company-oidc
        │
        └── SSO authenticated user

This provides flexibility and prevents the environment from depending on
only one authentication source.

# Practical Design

A more mature environment might use:

    PAM
     └── Break-glass / root administration

    PVE
     └── Limited local accounts

    AD / LDAP / OIDC
     └── Normal administrator authentication

This provides centralized identity management while retaining a local
authentication method if the external identity provider becomes
unavailable.

# Homelab Progression

A useful learning progression is:

    Stage 1
    PAM + PVE
        │
        ▼
    Stage 2
    Active Directory / LDAP
        │
        ▼
    Stage 3
    Groups + RBAC
        │
        ▼
    Stage 4
    MFA / SSO
        │
        ▼
    Stage 5
    Test identity-provider failure and recovery

This demonstrates not only virtualization administration but also
identity, authentication, authorization, and least-privilege concepts.

# Key Takeaways

- A realm identifies the authentication source for a Proxmox user.
- `root@pam` authenticates through Linux PAM.
- `@pve` users authenticate against Proxmox's internal user database.
- LDAP and Active Directory provide centralized directory authentication.
- OpenID Connect enables modern identity-provider and SSO integration.
- Authentication does not automatically grant access to Proxmox resources.
- Roles, groups, and ACLs control authorization.
- Multiple realms can coexist within the same Proxmox cluster.
- Maintaining an appropriate local administrative path can provide
  recovery access if external authentication becomes unavailable.
