# Debian VM Template

## Overview

This reference documents the workflow used to create a reusable Debian VM template in Proxmox VE.

The template provides a standardized Linux baseline for deploying infrastructure VMs such as Docker hosts, monitoring servers, and other Linux services.

Detailed Debian configuration procedures are maintained separately under `reference/debian/`. This document defines how those procedures are combined to create and deploy the Proxmox template.

## Template Workflow

```text
Debian Installation
        ↓
Debian Base System Configuration
        ↓
Debian Readiness Validation
        ↓
Template Preparation
        ↓
Shutdown
        ↓
Proxmox Template
        ↓
Full Clone
        ↓
Unique Debian Server
        ↓
Role-Specific Configuration
```

## Build the Baseline

Install Debian and apply the standard system baseline.

Follow:

- [Debian Base System Configuration](../debian/debian-baseline.md)
- [Debian Readiness Check](../../../scripts/debian/debian-baseline-check.sh)

The readiness check should complete successfully before preparing the VM for templating.

## Prepare the Template

After the baseline has been configured and validated, prepare the system for use as a reusable Proxmox template.

Follow:

- [Debian Post-Clone Configuration](../debian/debian-post-clone-configuration.md)

The template should remain general-purpose and should not contain workload-specific services or configuration.

Examples of configuration that should occur **after deployment** include:

- Server hostname
- Network-specific configuration
- Docker workloads
- Monitoring services
- Application configuration
- Service credentials
- Role-specific firewall rules

## Convert to Template

After template preparation is complete:

1. Shut down the Debian VM.
2. Verify that the VM is stopped.
3. Rename the Proxmox VM to a descriptive template name if needed.
4. Right-click the VM in Proxmox.
5. Select **Convert to template**.

Example:

```text
debian-template
```

The resulting template should remain powered off and be used as the source for future Debian deployments.

## Deploy a Server

Create a **Full Clone** of `debian-template` for permanent infrastructure VMs.

```text
debian-template
      │
      ├── Full Clone → Docker Host
      ├── Full Clone → Monitoring Server
      └── Full Clone → Future Linux Server
```

After cloning:

1. Start the new VM.
2. Complete the post-clone configuration.
3. Assign the intended hostname.
4. Configure networking as required.
5. Verify the system has a unique identity.
6. Apply role-specific configuration.

Follow the applicable Debian deployment references under:

```text
reference/debian/
```

## Validation

After deploying a clone, verify:

- The VM boots successfully.
- The hostname is unique.
- Network connectivity is working.
- SSH access is working.
- The QEMU Guest Agent is running.
- The system has unique machine-specific identifiers.
- The Debian baseline remains intact.
- No configuration specific to the template source was inherited.

> [!NOTE]
> **Build the Debian baseline → validate readiness → prepare the system for templating → convert to a Proxmox template → clone → apply server-specific configuration.**
