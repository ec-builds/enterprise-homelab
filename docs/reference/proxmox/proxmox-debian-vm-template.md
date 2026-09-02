# Debian VM Template

## Overview

This reference documents the workflow used to create a reusable Debian VM template in Proxmox VE.

The template provides a standardized Linux baseline for deploying infrastructure VMs such as Docker hosts, monitoring servers, and other Linux services.

Detailed Debian configuration procedures are maintained separately under `docs/reference/debian/`. This document defines how those procedures and validation scripts are combined to create and deploy the Proxmox template.

```text
Debian Installation
        ↓
Debian Base System Configuration
        ↓
Template Readiness Validation
        ↓
Template Preparation
        ↓
Hostname Preparation
        ↓
Shutdown
        ↓
Proxmox Template
        ↓
Full Clone
        ↓
Post-Clone Configuration
        ↓
Unique Debian Server
        ↓
Role-Specific Configuration
```

## Build the Baseline

Install Debian and apply the standard system baseline.

Follow:

- [Debian Base System Configuration](../debian/debian-baseline.md)

Complete the baseline configuration before preparing the VM for use as a template.

## Prepare the Template

Use the Debian baseline check script to validate the system and prepare it for templating.

- [Debian Baseline Check](../../../scripts/debian/debian-baseline-check.sh)

Run the standard readiness check:

```bash
sudo ./debian-baseline-check.sh
```

Then run the template-specific validation:

```bash
sudo ./debian-baseline-check.sh --template
```

The `--template` option performs additional template readiness checks and provides instructions for removing machine-specific state before the VM is converted into a Proxmox template.

Complete the recommended preparation steps and rerun the check as needed before shutting down the VM.

The template should remain general-purpose and should not contain workload-specific services or configuration.

Examples of configuration that should occur **after deployment** include:

- Server hostname
- Network-specific configuration
- Docker workloads
- Monitoring services
- Application configuration
- Service credentials
- Role-specific firewall rules

## Hostname Management

The hostname used while building the source VM does not need to become part of the reusable template.

If the source VM was originally created for another purpose, rename the Debian hostname before converting it into a template when the existing hostname should be preserved for a future deployment.

For example:

```text
docker-vm-lab
      ↓
Rename Source Host
      ↓
debian-template
      ↓
Convert to Template
      ↓
Full Clone
      ↓
Assign New Hostname
```

In this example, the original `docker-vm-lab` hostname remains available for a future Docker host deployed from the template rather than being retained by the template itself.

Follow:

- [Debian Hostname Change](../debian/debian-hostname-change.md)

The same procedure can be used after cloning to assign each deployed VM its intended hostname.

> [!NOTE]
> The **Proxmox VM name** and the **Debian hostname** are separate values. Renaming the VM in Proxmox does not automatically change the hostname configured inside Debian.

## Convert to Template

After the template preparation checks and any required hostname changes are complete:

1. Shut down the Debian VM.
2. Verify that the VM is stopped.
3. Rename the Proxmox VM to a descriptive template name if needed.
4. Right-click the VM.
5. Select **Convert to template**.

Example:

```text
debian-template
```

The resulting template should remain powered off and serve as the source for future Debian deployments.

## Deploy a Server

Create a **Full Clone** of `debian-template` for permanent infrastructure VMs.

```text
debian-template
      │
      ├── Full Clone → Docker Host
      ├── Full Clone → Monitoring Server
      └── Full Clone → Future Linux Server
```

After cloning, complete the system-specific configuration.

Follow:

- [Debian Post-Clone Configuration](../debian/debian-post-clone-config.md)
- [Debian Hostname Change](../debian/debian-hostname-change.md) — assign the intended hostname when required

The post-clone process establishes the unique identity and configuration required for the newly deployed server before role-specific services are installed.

## Validation

After deploying and configuring a clone, verify:

- The VM boots successfully.
- The hostname is unique.
- Network connectivity is working.
- SSH access is working.
- The QEMU Guest Agent is running.
- The system has unique machine-specific identifiers.
- The Debian baseline remains intact.
- No configuration specific to the template source was inherited.
- The system is ready for role-specific configuration.

The Debian baseline check can also be used to validate the deployed system:

```bash
sudo ./debian-baseline-check.sh
```

## Deployment Model

The template provides only the common operating system baseline. Individual server roles are configured after deployment.

```text
                    debian-template
                          │
              ┌───────────┼───────────┐
              │           │           │
              ▼           ▼           ▼
         Docker Host   Monitoring   Future Server
              │          Server         │
              ▼           ▼             ▼
          Docker       Monitoring    Role-Specific
        Configuration   Services     Configuration
```

This keeps the base template independent of individual workloads and allows the same standardized Debian image to support multiple infrastructure roles.

## Updating the Template

The template should remain a known-good deployment source rather than being routinely modified.

When significant baseline changes are required, create a new template version from a temporary clone:

```text
debian-template-v1
        ↓
Temporary Clone
        ↓
Baseline Updates
        ↓
Readiness Check
        ↓
Template Preparation
        ↓
debian-template-v2
```

Keeping previous template versions provides a rollback point if an updated baseline introduces problems.

For major Debian releases or substantial baseline changes, rebuilding the template from a clean installation may be preferable to repeatedly modifying an older image.

## Future Improvements

The current workflow combines a reusable Proxmox template with standardized Debian configuration and validation.

Future automation can further reduce manual deployment steps through:

- Cloud-init
- Ansible
- Terraform / OpenTofu
- Automated baseline validation
- Automated server configuration

The longer-term deployment model is:

```text
Proxmox Template
        ↓
VM Provisioning
        ↓
Cloud-init
        ↓
Ansible
        ↓
Role-Specific Services
```

> [!NOTE]
> **Build the Debian baseline → validate and prepare the system with the baseline check script → prepare the hostname if required → convert to a Proxmox template → full clone → complete post-clone configuration → assign the intended hostname → deploy the server role.**
