# 🐧 Linux Server Standard

## Purpose

Establish a consistent baseline for Linux servers deployed within the homelab.

This standard defines the minimum configuration and validation requirements for persistent Linux systems. Distribution-specific procedures are maintained separately in the reference documentation.

## Standard

Linux servers should:

- Follow established [naming conventions](./naming-conventions.md).
- Use a supported and maintained operating system release.
- Receive current operating system and security updates during deployment.
- Use a named administrative account with `sudo` for routine administration.
- Limit direct `root` usage to maintenance or recovery scenarios.
- Use SSH for remote administration.
- Install the QEMU Guest Agent when running as a Proxmox VM.
- Use a unique hostname and system identity.
- Maintain only the packages and services required for the server's role.
- Use persistent and documented network configuration where required.
- Complete baseline validation before workload deployment.

## Debian Baseline

Debian is the primary Linux distribution used for general-purpose servers within the homelab.

Implementation procedures are maintained in the Debian reference documentation:

- [Debian Installation](../reference/debian/debian-install.md)
- [Debian Base System Configuration](../reference/debian/debian-baseline.md)
- [Debian Post-Clone Configuration](../reference/debian/debian-post-clone-config.md)
- [Debian Hostname Change](../reference/debian/debian-hostname-change.md)

## Validation

Before a Linux server is considered operational, verify:

- Operating system updates are complete
- Hostname and system identity are unique
- Network connectivity and DNS resolution function correctly
- Administrative access is working
- Required services are running
- QEMU Guest Agent is functioning when applicable
- Workload-specific configuration has been tested

## Related Documentation

- [Virtual Machine Deployment Standard](./vm-deployment-standard.md)
- [Naming Conventions](./naming-conventions.md)
- [Debian Base System Configuration](../reference/debian/debian-baseline.md)
