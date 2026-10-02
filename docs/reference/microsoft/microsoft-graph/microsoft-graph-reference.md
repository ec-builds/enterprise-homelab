# Microsoft Graph PowerShell Reference

Reference guide for installing, connecting to, and working with Microsoft Graph through PowerShell in the lab environment.

> **Scope:** This document covers Microsoft Graph setup, authentication, permissions, tenant/domain discovery, and command discovery. Procedures for creating and managing users are documented separately.



## Overview

Microsoft Graph provides a unified API for administering Microsoft cloud services, including:

- Microsoft Entra ID
- Microsoft Intune
- Microsoft 365
- Users and groups
- Devices
- Applications
- Authentication
- Licensing
- Security services

For PowerShell administration, use the **Microsoft Graph PowerShell SDK**.

Typical management path:

```text
PowerShell
    |
    v
Microsoft Graph PowerShell SDK
    |
    v
Microsoft Graph API
    |
    +-- Microsoft Entra ID
    +-- Microsoft Intune
    +-- Microsoft 365
    +-- Other Microsoft cloud services
```



# Initial Setup

## Requirements

Recommended:

- PowerShell 7+
- Microsoft Graph PowerShell SDK
- Microsoft Entra account with the required permissions
- Internet access to Microsoft Graph

Check the PowerShell version:

```powershell
$PSVersionTable.PSVersion
```



## Install Microsoft Graph

Install the Microsoft Graph PowerShell SDK for the current user:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

If PowerShell reports that `PSGallery` is an untrusted repository, review the repository and approve the installation when appropriate.

Check registered PowerShell repositories:

```powershell
Get-PSRepository
```

Example:

```text
Name       InstallationPolicy
----       ------------------
PSGallery  Untrusted
```

An `Untrusted` installation policy does not necessarily mean that the PowerShell Gallery itself is malicious. It means PowerShell requires confirmation before installing modules from that repository.

For administrative systems, leaving the repository as `Untrusted` provides an additional confirmation step before module installation.



## Verify Microsoft Graph Installation

Check whether the Microsoft Graph module is installed:

```powershell
Get-InstalledModule Microsoft.Graph
```

You can also locate Graph commands:

```powershell
Get-Command Connect-MgGraph
```



# Connecting to Microsoft Graph

Microsoft Graph uses OAuth-based authentication.

The standard interactive connection command is:

```powershell
Connect-MgGraph
```

In practice, request only the permissions required for the administrative task.

Example:

```powershell
Connect-MgGraph -Scopes "User.Read.All"
```

This opens an interactive Microsoft authentication prompt.



# Microsoft Graph Permissions

Graph permissions are expressed as **scopes**.

Examples include:

| Scope | Purpose |
|---|---|
| `User.Read.All` | Read users |
| `User.ReadWrite.All` | Read and modify users |
| `Group.Read.All` | Read groups |
| `Group.ReadWrite.All` | Read and modify groups |
| `Domain.Read.All` | Read tenant domain information |
| `Device.Read.All` | Read Microsoft Entra device information |
| `DeviceManagementManagedDevices.Read.All` | Read Intune managed devices |
| `DeviceManagementManagedDevices.ReadWrite.All` | Manage Intune managed devices |
| `DeviceManagementConfiguration.Read.All` | Read Intune configuration |
| `DeviceManagementConfiguration.ReadWrite.All` | Manage Intune configuration |
| `DeviceManagementApps.Read.All` | Read Intune applications |
| `DeviceManagementApps.ReadWrite.All` | Manage Intune applications |

Use the principle of **least privilege**.

Do not request broad permissions unless they are necessary for the task being performed.



# Connect with Multiple Scopes

Multiple permissions can be requested during authentication.

Example:

```powershell
Connect-MgGraph -Scopes `
    "User.ReadWrite.All",
    "Domain.Read.All"
```

PowerShell's backtick character allows a command to continue onto the next line.

The same command can also be written on one line:

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All","Domain.Read.All"
```



# Check Current Graph Session

Use:

```powershell
Get-MgContext
```

Important fields include:

```text
Account
TenantId
ClientId
Scopes
AuthType
```

For a cleaner view:

```powershell
Get-MgContext |
    Select-Object Account, TenantId, AuthType, Scopes
```

## Security Note

Tenant IDs, account names, client IDs, tokens, and other organization-specific identifiers should generally be sanitized before publishing screenshots, documentation, or command output publicly.



# Determine Whether Graph Is Connected

Run:

```powershell
Get-MgContext
```

If no active context exists, authenticate again:

```powershell
Connect-MgGraph
```

A common error is:

```text
Authentication needed. Please call Connect-MgGraph.
```

This means there is no usable Microsoft Graph authentication context for the current PowerShell session.

Reconnect with the required scopes.

Example:

```powershell
Connect-MgGraph -Scopes "User.Read.All"
```



# Disconnect from Microsoft Graph

Explicitly terminate the current Graph session with:

```powershell
Disconnect-MgGraph
```

This is useful when:

- Switching tenants
- Switching administrator accounts
- Testing permissions
- Finishing an administrative session
- Troubleshooting authentication problems



# Tenant Information

## View Organization Information

Retrieve organization information:

```powershell
Get-MgOrganization
```

For a cleaner output:

```powershell
Get-MgOrganization |
    Select-Object DisplayName, Id
```

Do not publish the real tenant ID in public lab documentation unless there is a specific reason to do so.



# Tenant Domains

Microsoft Entra user principal names must use domains recognized by the tenant.

List the tenant's domains:

```powershell
Get-MgDomain
```

Cleaner output:

```powershell
Get-MgDomain |
    Select-Object Id, IsVerified, IsDefault
```

Example sanitized output:

```text
Id                          IsVerified IsDefault
--                          ---------- ---------
example.onmicrosoft.com           True      True
example.com                       True     False
```

The domain marked:

```text
IsDefault = True
```

is the tenant's default domain.



## Required Permission

Reading tenant domains may require:

```text
Domain.Read.All
```

Connect with:

```powershell
Connect-MgGraph -Scopes "Domain.Read.All"
```

Or combine it with another required permission:

```powershell
Connect-MgGraph -Scopes `
    "User.Read.All",
    "Domain.Read.All"
```



# The onmicrosoft.com Domain

Every Microsoft Entra tenant receives an initial Microsoft domain similar to:

```text
example.onmicrosoft.com
```

Do not assume that the initial domain exactly matches the organization's public DNS domain.

Always verify the actual tenant domain with:

```powershell
Get-MgDomain |
    Select-Object Id, IsVerified, IsDefault
```

This prevents errors caused by guessing the tenant's `onmicrosoft.com` name.



# Custom Domains

Organizations can add and verify custom domains such as:

```text
example.com
```

Once properly configured and verified, they can be used for Microsoft Entra user principal names and other Microsoft 365 services as appropriate.

Check verification status with:

```powershell
Get-MgDomain |
    Select-Object Id, IsVerified, IsDefault
```

Only use domains that show:

```text
IsVerified = True
```

when an operation requires a verified tenant domain.



# Command Discovery

The Microsoft Graph SDK contains a large number of commands. It is usually better to discover commands than attempt to memorize them.

## Search All Graph Commands

```powershell
Get-Command *Mg*
```

This can produce a very large result set.

Use narrower searches whenever possible.



## Search User Commands

```powershell
Get-Command *MgUser*
```



## Search Group Commands

```powershell
Get-Command *MgGroup*
```



## Search Device Commands

```powershell
Get-Command *MgDevice*
```



## Search Intune Device Management Commands

```powershell
Get-Command *MgDeviceManagement*
```



# Find Graph Commands by API Endpoint

Microsoft Graph PowerShell includes command-discovery functionality.

Example:

```powershell
Find-MgGraphCommand -Uri "/users"
```

For Intune managed devices:

```powershell
Find-MgGraphCommand -Uri "/deviceManagement/managedDevices"
```

This is useful for translating Microsoft Graph REST API documentation into PowerShell commands.



# Find Required Permissions

`Find-MgGraphCommand` can also help determine which permissions are associated with a command.

Example:

```powershell
Find-MgGraphCommand -Command Get-MgUser
```

This is useful when troubleshooting:

```text
403 Forbidden
```

or:

```text
Authorization_RequestDenied
```



# Get Command Help

Use standard PowerShell help:

```powershell
Get-Help Get-MgUser
```

Detailed help:

```powershell
Get-Help Get-MgUser -Detailed
```

Examples:

```powershell
Get-Help Get-MgUser -Examples
```

Full help:

```powershell
Get-Help Get-MgUser -Full
```



# Microsoft Graph REST Requests

The Graph PowerShell SDK can also make direct Microsoft Graph API requests.

This is useful when:

- A dedicated PowerShell cmdlet is difficult to locate
- An API feature is newer than the corresponding cmdlet
- Learning Microsoft Graph REST
- Testing API endpoints
- Building automation

General syntax:

```powershell
Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/RESOURCE"
```

Example:

```powershell
Invoke-MgGraphRequest `
    -Method GET `
    -Uri "https://graph.microsoft.com/v1.0/organization"
```

Authentication is still handled by:

```powershell
Connect-MgGraph
```



# Microsoft Graph API Versions

Microsoft Graph primarily exposes:

```text
v1.0
```

and:

```text
beta
```

Example stable endpoint:

```text
https://graph.microsoft.com/v1.0/
```

Beta endpoint:

```text
https://graph.microsoft.com/beta/
```

Prefer:

```text
v1.0
```

for normal administrative automation.

Use beta endpoints only when the required feature is unavailable in the stable API and the risks are understood.

Beta APIs can change without the same compatibility guarantees as stable APIs.



# Microsoft Entra vs Intune

Microsoft Graph provides access to both Microsoft Entra and Microsoft Intune, but they manage different resources.

## Microsoft Entra

Common resources include:

```text
Users
Groups
Devices
Applications
Service principals
Roles
Authentication
Domains
```

Example Graph paths:

```text
/users
/groups
/devices
/applications
/organization
/domains
```

## Microsoft Intune

Common resources include:

```text
Managed devices
Compliance policies
Configuration policies
Applications
Enrollment
Device actions
```

Common Graph path:

```text
/deviceManagement/
```

For example:

```text
/deviceManagement/managedDevices
```



# Useful Intune Query

After connecting with the appropriate permission:

```powershell
Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
```

Retrieve Intune-managed devices:

```powershell
Get-MgDeviceManagementManagedDevice
```

Retrieve all managed devices:

```powershell
Get-MgDeviceManagementManagedDevice -All
```

Cleaner output:

```powershell
Get-MgDeviceManagementManagedDevice -All |
    Select-Object `
        DeviceName,
        OperatingSystem,
        OSVersion,
        ComplianceState,
        UserPrincipalName
```



# Common Troubleshooting

## Authentication Needed

Error:

```text
Authentication needed. Please call Connect-MgGraph.
```

Check:

```powershell
Get-MgContext
```

Reconnect:

```powershell
Connect-MgGraph -Scopes "REQUIRED.PERMISSION"
```



## Invalid Domain

Example error:

```text
The domain portion of the userPrincipalName property is invalid.
You must use one of the verified domain names in your organization.
```

Do not guess the tenant domain.

Check:

```powershell
Get-MgDomain |
    Select-Object Id, IsVerified, IsDefault
```

Use a domain where:

```text
IsVerified = True
```



## Permission Denied

Possible errors include:

```text
403 Forbidden
```

or:

```text
Authorization_RequestDenied
```

First check the current scopes:

```powershell
Get-MgContext
```

Then determine the required permission:

```powershell
Find-MgGraphCommand -Command <GraphCommand>
```

Reconnect with the required scope if necessary:

```powershell
Disconnect-MgGraph

Connect-MgGraph -Scopes "REQUIRED.PERMISSION"
```



## Check Current Account and Tenant

Before making administrative changes, verify the current Graph context:

```powershell
Get-MgContext |
    Select-Object Account, TenantId, AuthType
```

This is especially important when administering multiple Microsoft Entra tenants.



# Useful Session Workflow

A simple Graph administration workflow is:

```powershell
# Connect
Connect-MgGraph -Scopes "REQUIRED.PERMISSION"

# Verify context
Get-MgContext

# Perform administrative work
# ...

# Disconnect
Disconnect-MgGraph
```

For higher-impact administrative work, explicitly checking the tenant before making changes is recommended:

```powershell
Get-MgOrganization |
    Select-Object DisplayName, Id
```



# Security Practices

For Microsoft Graph administration:

- Follow least privilege.
- Request only necessary Graph scopes.
- Verify the tenant before performing write operations.
- Avoid hardcoding credentials.
- Never publish access tokens.
- Sanitize tenant IDs from public documentation.
- Sanitize administrator user principal names where appropriate.
- Review scripts before granting broad Graph permissions.
- Prefer stable `v1.0` Graph endpoints.
- Disconnect administrative sessions when finished.
- Use app-based authentication rather than interactive administrator authentication for production automation where appropriate.
- Protect certificates and secrets used for unattended automation.



# Quick Reference

| Task | Command |
|---|---|
| Install Graph | `Install-Module Microsoft.Graph -Scope CurrentUser` |
| Connect | `Connect-MgGraph` |
| Connect with scopes | `Connect-MgGraph -Scopes "User.Read.All"` |
| Check session | `Get-MgContext` |
| Disconnect | `Disconnect-MgGraph` |
| View organization | `Get-MgOrganization` |
| View domains | `Get-MgDomain` |
| Find Graph commands | `Get-Command *Mg*` |
| Find user commands | `Get-Command *MgUser*` |
| Find Intune commands | `Get-Command *MgDeviceManagement*` |
| Find command by API | `Find-MgGraphCommand -Uri "/users"` |
| Command examples | `Get-Help <Command> -Examples` |
| Direct Graph request | `Invoke-MgGraphRequest` |



# Related Lab Documentation

Maintain separate procedure documents for individual administrative workflows.

Recommended structure:

```text
Microsoft-graph-reference.md
Microsoft-entra-user-management.md
Microsoft-entra-group-management.md
Microsoft-entra-license-management.md
Microsoft-intune-device-management.md
Microsoft-intune-application-management.md
Microsoft-intune-compliance-management.md
Microsoft-graph-automation.md
```

This reference should remain focused on **Microsoft Graph fundamentals and connectivity**, while operational procedures are maintained separately.
