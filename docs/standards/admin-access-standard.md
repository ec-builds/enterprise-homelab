# 🔐 Administrative Access Standard

## Purpose

Establish consistent administrative access practices across homelab infrastructure.

This standard defines how privileged access should be separated, authenticated, and documented across Linux, Windows, Proxmox, and other infrastructure platforms.

## Standard

Administrative access should:

- Use named administrative accounts rather than shared accounts where supported.
- Separate routine user access from privileged administrative access where practical.
- Use `sudo` for routine Linux privilege escalation.
- Limit direct `root` usage to maintenance, recovery, or troubleshooting scenarios.
- Prefer SSH key authentication for Linux and infrastructure administration.
- Use multi-factor authentication where supported.
- Assign only the permissions required for the administrative role.
- Separate service accounts from interactive administrator accounts.
- Remove or disable administrative access when it is no longer required.
- Avoid exposing administrative interfaces directly to the Internet.

## Credential Management

Administrative credentials must not be stored in the public repository.

This includes:

- Passwords
- Private SSH keys
- API keys and tokens
- Application passwords
- Recovery credentials
- VPN credentials
- Authentication configuration containing secrets

Public documentation should also sanitize administrative usernames and other environment-specific identifiers.

## Linux Administration

Linux systems should use a named administrative account with `sudo` for normal administration.

Direct `root` access should remain available only where required for recovery or system maintenance.

See:

- [Linux Server Standard](./linux-server-standard.md)
- [Configure sudo Access](../reference/linux/linux-configure-sudo.md)

## Validation

Administrative access should be verified after deployment or configuration changes:

- Named administrator account can authenticate
- Privilege escalation functions correctly
- Required management interfaces are reachable
- MFA functions where configured
- Service accounts cannot be used interactively unless specifically required
- No credentials or private authentication material are present in public documentation

## Related Documentation

- [Linux Server Standard](./linux-server-standard.md)
- [Virtual Machine Deployment Standard](./vm-deployment-standard.md)
- [Naming Conventions](./naming-conventions.md)
