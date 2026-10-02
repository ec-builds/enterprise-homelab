# Microsoft Entra User Management

Operational reference for managing Microsoft Entra ID users with Microsoft Graph PowerShell.

> **Scope:** This document covers common user lifecycle operations through Microsoft Graph, including creating, querying, updating, disabling, enabling, password management, and deleting users.

For Microsoft Graph installation, authentication, permissions, domain discovery, and general command discovery, see:

```text
Microsoft-graph-reference.md
```



# Required Microsoft Graph Permissions

User-management operations generally require one or more Microsoft Graph permissions.

Common permissions:

| Permission | Purpose |
|---|---|
| `User.Read.All` | Read users |
| `User.ReadWrite.All` | Read and modify users |
| `Directory.Read.All` | Read directory data |
| `Directory.ReadWrite.All` | Broad directory modification; avoid unless necessary |

Follow the principle of **least privilege**.

For the procedures in this document, connect with:

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
```

Verify the current Graph session:

```powershell
Get-MgContext
```

Before performing write operations, verify the connected organization:

```powershell
Get-MgOrganization |
    Select-Object DisplayName, Id
```



# Verify the Tenant Domain

Before creating users, determine which domains are verified in the tenant.

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

The user principal name must use an appropriate verified domain.

Example:

```text
user1@example.onmicrosoft.com
```

Do not guess the tenant's `onmicrosoft.com` domain.



# Create a User

## Define the Password Profile

Create a password profile:

```powershell
$passwordProfile = @{
    Password = "REPLACE-WITH-TEMPORARY-PASSWORD"
    ForceChangePasswordNextSignIn = $true
}
```

The temporary password must satisfy the tenant's applicable password requirements.

> Do not place real passwords in documentation, Git repositories, screenshots, tickets, or public command examples.



## Create the Account

Example:

```powershell
New-MgUser `
    -DisplayName "Test User" `
    -GivenName "Test" `
    -Surname "User" `
    -MailNickname "testuser" `
    -UserPrincipalName "testuser@example.onmicrosoft.com" `
    -PasswordProfile $passwordProfile `
    -AccountEnabled
```

Important properties:

| Property | Example | Purpose |
|---|---|---|
| Display name | `Test User` | Human-readable name |
| Given name | `Test` | First name |
| Surname | `User` | Last name |
| Mail nickname | `testuser` | Mail alias |
| User principal name | `testuser@example.onmicrosoft.com` | Sign-in identity |
| Password profile | `$passwordProfile` | Initial password configuration |
| Account enabled | `$true` | Allows account authentication |



# Verify User Creation

Query the account directly:

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com"
```

For cleaner output:

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com" |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        AccountEnabled,
        Id
```

Example:

```text
DisplayName       : Test User
UserPrincipalName : testuser@example.onmicrosoft.com
AccountEnabled    : True
Id                : <SANITIZED-OBJECT-ID>
```



# Store the User Object

For repeated operations, store the user in a variable:

```powershell
$user = Get-MgUser -UserId "testuser@example.onmicrosoft.com"
```

View it:

```powershell
$user
```

Retrieve the Entra object ID:

```powershell
$user.Id
```

Inspect available properties:

```powershell
$user | Format-List *
```



# List Users

Retrieve users:

```powershell
Get-MgUser
```

Retrieve all users:

```powershell
Get-MgUser -All
```

Display useful properties:

```powershell
Get-MgUser -All |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        AccountEnabled
```

Sort alphabetically:

```powershell
Get-MgUser -All |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        AccountEnabled |
    Sort-Object DisplayName
```



# Search for a User

## By User Principal Name

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com"
```

This is preferable when the exact user principal name is known.



## Using PowerShell Filtering

For a small lab:

```powershell
Get-MgUser -All |
    Where-Object DisplayName -eq "Test User"
```

Or:

```powershell
Get-MgUser -All |
    Where-Object UserPrincipalName -eq "testuser@example.onmicrosoft.com"
```

For large production directories, server-side Graph filtering should generally be preferred over retrieving every user and filtering locally.



# View Detailed User Information

```powershell
$user = Get-MgUser -UserId "testuser@example.onmicrosoft.com"

$user | Format-List *
```

Microsoft Graph may not return every available property by default.

Specific properties can be requested:

```powershell
Get-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -Property `
        DisplayName,
        GivenName,
        Surname,
        UserPrincipalName,
        AccountEnabled,
        Department,
        JobTitle
```



# Update User Information

Use:

```powershell
Update-MgUser
```

## Change Job Title

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -JobTitle "Systems Administrator"
```

Verify:

```powershell
Get-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -Property DisplayName,UserPrincipalName,JobTitle |
    Select-Object DisplayName, UserPrincipalName, JobTitle
```



# Set Department

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -Department "Information Technology"
```



# Set Office Location

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -OfficeLocation "Main Office"
```



# Set Multiple Properties

Multiple properties can be updated in one operation:

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -JobTitle "Systems Administrator" `
    -Department "Information Technology" `
    -OfficeLocation "Main Office"
```

Verify:

```powershell
Get-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -Property `
        DisplayName,
        UserPrincipalName,
        JobTitle,
        Department,
        OfficeLocation |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        JobTitle,
        Department,
        OfficeLocation
```



# Disable a User

Disabling an account prevents normal user authentication while preserving the Entra user object.

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -AccountEnabled:$false
```

Verify:

```powershell
Get-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -Property DisplayName,UserPrincipalName,AccountEnabled |
    Select-Object DisplayName, UserPrincipalName, AccountEnabled
```

Expected:

```text
AccountEnabled : False
```

For normal offboarding, disabling the account is generally safer as an initial action than immediately deleting the identity.

Additional offboarding steps may still be required for sessions, licenses, groups, devices, mailbox access, applications, and organizational data.



# Enable a User

Re-enable an account:

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -AccountEnabled:$true
```

Verify:

```powershell
Get-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -Property DisplayName,UserPrincipalName,AccountEnabled |
    Select-Object DisplayName, UserPrincipalName, AccountEnabled
```



# Reset a User Password

Create a new password profile:

```powershell
$passwordProfile = @{
    Password = "REPLACE-WITH-NEW-TEMPORARY-PASSWORD"
    ForceChangePasswordNextSignIn = $true
}
```

Apply it:

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -PasswordProfile $passwordProfile
```

The user will be required to change the temporary password at the next applicable sign-in.

Treat temporary passwords as credentials.

Do not:

- Commit them to Git
- Store them in plaintext documentation
- Publish them in screenshots
- Leave them in shared scripts
- Send them through insecure channels



# Force Password Change at Next Sign-In

When setting a password profile:

```powershell
$passwordProfile = @{
    Password = "REPLACE-WITH-TEMPORARY-PASSWORD"
    ForceChangePasswordNextSignIn = $true
}
```

Setting:

```text
ForceChangePasswordNextSignIn = True
```

prevents the temporary administrative password from remaining the user's normal long-term password.



# Change Display Name

```powershell
Update-MgUser `
    -UserId "testuser@example.onmicrosoft.com" `
    -DisplayName "Updated Test User"
```

Verify:

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com" |
    Select-Object DisplayName, UserPrincipalName
```



# Delete a User

> **Destructive operation:** Verify the identity and tenant before deleting a user.

First inspect the target:

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com" |
    Select-Object DisplayName, UserPrincipalName, Id
```

Then delete:

```powershell
Remove-MgUser `
    -UserId "testuser@example.onmicrosoft.com"
```

Verify:

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com"
```

Deletion should be treated differently from disabling an account.

For offboarding, consider first:

```text
Disable account
        |
        v
Revoke sessions
        |
        v
Review group membership
        |
        v
Review application access
        |
        v
Review licenses
        |
        v
Review mailbox/data requirements
        |
        v
Delete when appropriate
```



# Safer Administrative Pattern

For important user changes, retrieve the target first.

```powershell
$user = Get-MgUser -UserId "testuser@example.onmicrosoft.com"

$user |
    Select-Object DisplayName, UserPrincipalName, Id
```

Confirm that `$user` represents the intended identity before performing the write operation.

Then use the immutable object ID:

```powershell
Update-MgUser `
    -UserId $user.Id `
    -Department "Information Technology"
```

This reduces reliance on repeatedly typing the user principal name.



# Confirm Tenant Before Destructive Operations

Check the Graph context:

```powershell
Get-MgContext |
    Select-Object Account, TenantId
```

Check the organization:

```powershell
Get-MgOrganization |
    Select-Object DisplayName, Id
```

Then verify the target:

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com" |
    Select-Object DisplayName, UserPrincipalName, Id
```

This is especially important when an administrator works with multiple tenants.



# Example User Provisioning Workflow

A basic account provisioning workflow is:

```text
Verify Graph connection
        |
        v
Verify tenant
        |
        v
Verify tenant domain
        |
        v
Determine username / UPN
        |
        v
Create temporary password profile
        |
        v
Create user
        |
        v
Verify user
        |
        v
Configure user attributes
        |
        v
Assign groups
        |
        v
Assign licensing
        |
        v
Configure required access
```

Group and license management should be documented separately.



# Basic Provisioning Example

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Verify organization
Get-MgOrganization |
    Select-Object DisplayName, Id

# Verify available domains
Get-MgDomain |
    Select-Object Id, IsVerified, IsDefault

# Configure temporary password
$passwordProfile = @{
    Password = "REPLACE-WITH-TEMPORARY-PASSWORD"
    ForceChangePasswordNextSignIn = $true
}

# Create user
New-MgUser `
    -DisplayName "Test User" `
    -GivenName "Test" `
    -Surname "User" `
    -MailNickname "testuser" `
    -UserPrincipalName "testuser@example.onmicrosoft.com" `
    -PasswordProfile $passwordProfile `
    -AccountEnabled

# Verify user
Get-MgUser -UserId "testuser@example.onmicrosoft.com" |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        AccountEnabled,
        Id
```



# Bulk User Creation

For multiple users, CSV-based provisioning can be used.

Example sanitized CSV structure:

```csv
GivenName,Surname,DisplayName,MailNickname,UserPrincipalName
Jane,Doe,Jane Doe,jdoe,jdoe@example.onmicrosoft.com
John,Smith,John Smith,jsmith,jsmith@example.onmicrosoft.com
```

Import:

```powershell
$users = Import-Csv ".\users.csv"
```

Review the data **before** creating accounts:

```powershell
$users | Format-Table
```

A production bulk-provisioning script should include:

- Input validation
- Duplicate detection
- Verified-domain validation
- Password handling
- Error handling
- Logging
- `try` / `catch`
- Verification after creation
- A dry-run or review stage

Avoid immediately piping unvalidated CSV data into account-creation commands.



# Error Handling

For automation, wrap write operations in `try` / `catch`.

Example pattern:

```powershell
try {
    # Microsoft Graph write operation

    Write-Host "Operation completed successfully."
}
catch {
    Write-Error "Operation failed: $($_.Exception.Message)"
}
```

For bulk operations, logging failures separately makes troubleshooting easier than terminating the entire provisioning process after the first failed account.



# Common Errors

## Authentication Needed

```text
Authentication needed. Please call Connect-MgGraph.
```

Check:

```powershell
Get-MgContext
```

Reconnect:

```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
```



## Invalid User Principal Name Domain

```text
The domain portion of the userPrincipalName property is invalid.
You must use one of the verified domain names in your organization.
```

Check the tenant domains:

```powershell
Get-MgDomain |
    Select-Object Id, IsVerified, IsDefault
```

Use a verified domain.

Do not assume the organization's initial Microsoft domain contains the same punctuation or spelling as its public DNS domain.



## Insufficient Privileges

Possible errors:

```text
Authorization_RequestDenied
```

or:

```text
403 Forbidden
```

Check current permissions:

```powershell
Get-MgContext
```

Review the scopes.

If necessary, reconnect with the required permission:

```powershell
Disconnect-MgGraph

Connect-MgGraph -Scopes "User.ReadWrite.All"
```

The signed-in administrator must also be authorized to perform the requested operation.



## User Already Exists

Before provisioning a known user principal name, check whether it already exists.

```powershell
Get-MgUser -UserId "testuser@example.onmicrosoft.com"
```

For bulk provisioning, duplicate checking should occur before any write operation.



# Useful User Commands

| Task | Command |
|---|---|
| List users | `Get-MgUser` |
| List all users | `Get-MgUser -All` |
| Get specific user | `Get-MgUser -UserId <UPN>` |
| Create user | `New-MgUser` |
| Update user | `Update-MgUser` |
| Disable user | `Update-MgUser -AccountEnabled:$false` |
| Enable user | `Update-MgUser -AccountEnabled:$true` |
| Delete user | `Remove-MgUser` |
| Find user commands | `Get-Command *MgUser*` |
| User command examples | `Get-Help <Command> -Examples` |



# Security Practices

When administering Microsoft Entra users:

- Follow least privilege.
- Verify the tenant before write operations.
- Verify the target identity before destructive operations.
- Do not hardcode production credentials.
- Do not commit passwords to Git.
- Do not publish access tokens.
- Sanitize tenant IDs and object IDs from public documentation when appropriate.
- Require users to change temporary passwords.
- Prefer disabling before deleting during offboarding.
- Use controlled automation for bulk provisioning.
- Log administrative automation appropriately.
- Protect scripts capable of modifying directory identities.
- Use stronger non-interactive authentication methods for production automation rather than embedding administrator credentials.



Keep this document focused on the **Microsoft Entra user lifecycle**.

Group membership, license assignment, administrative roles, Intune enrollment, and application access should remain separate procedures so each workflow can be tested and maintained independently.
