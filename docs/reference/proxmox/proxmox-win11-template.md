# Windows VM Template

## Overview

This reference documents the process used to create a reusable Windows 11 VM template in Proxmox VE.

The template provides a consistent workstation baseline while using Windows Sysprep to remove machine-specific information before cloning. Each deployed VM can then be assigned its own hostname and configuration without carrying over the identity of the original system.

```text
Windows 11 Baseline
        ↓
Sysprep /generalize
        ↓
Shutdown
        ↓
Proxmox Template
        ↓
Full Clone
        ↓
Windows OOBE
        ↓
Unique Client VM
```

## Template Preparation

An existing Windows 11 VM can be used as the starting point as long as machine-specific configuration is removed before it becomes the template.

Before generalizing the VM:

- Install all current Windows updates.
- Verify VirtIO drivers are installed and working.
- Verify the QEMU Guest Agent is installed and running.
- Enable QEMU Guest Agent support in the Proxmox VM options.
- Configure the network adapter for DHCP.
- Remove temporary files and client-specific configuration.
- Remove saved credentials and signed-in accounts.
- Do not domain join, Entra join, or Intune enroll the template.

The Proxmox VM can be renamed to something descriptive such as `win11-template`. The Proxmox VM name is separate from the hostname configured inside Windows.

## Application Baseline

Applications that should be available on every workstation can be installed before the image is generalized.

Example baseline:

- Adobe Acrobat Reader
- 7-Zip
- Web browser
- PowerShell 7
- VirtIO Guest Tools
- QEMU Guest Agent

Applications should be installed but left in a user-neutral state. Personal accounts, browser profiles, saved credentials, and application-specific user configuration should not be included in the template.

Role-specific applications and administrative tools can be installed after deployment or delivered through centralized management rather than becoming part of the base image.

## Sysprep

Windows Sysprep is used before converting the VM into a Proxmox template.

Run:

```cmd
C:\Windows\System32\Sysprep\Sysprep.exe
```

Configure Sysprep with:

- **System Cleanup Action:** Enter System Out-of-Box Experience (OOBE)
- **Generalize:** Enabled
- **Shutdown Options:** Shutdown

The same operation can be started from the command line:

```cmd
C:\Windows\System32\Sysprep\Sysprep.exe /generalize /oobe /shutdown
```

The `/generalize` option removes machine-specific information from the Windows installation so the image can be reused for new systems.

Once Sysprep shuts down the VM, the source VM should **not be booted again** before being converted into a template.

## Convert to Template

After Sysprep completes and the VM shuts down:

1. Locate the VM in the Proxmox VE interface.
2. Verify that the VM is stopped.
3. Rename the Proxmox VM to `win11-template` if needed.
4. Right-click the VM.
5. Select **Convert to template**.

The resulting template should remain powered off and serve only as the source for future Windows deployments.

## Deploy a VM

To deploy a new Windows client:

1. Right-click `win11-template`.
2. Select **Clone**.
3. Enter the new Proxmox VM name.
4. Select **Full Clone**.
5. Select the destination node and storage.
6. Create the clone.
7. Start the new VM.
8. Complete Windows OOBE.
9. Assign the intended Windows hostname.
10. Apply any client-specific configuration.

Example:

```text
win11-template
      ↓
   Full Clone
      ↓
win11-client-03
      ↓
 Windows OOBE
      ↓
WIN11-CLIENT-03
```

A full clone was preferred for permanent lab VMs because the cloned virtual disk is independent of the template.

## Identity and Networking

The Proxmox VM name and Windows hostname are separate values. Renaming a VM in Proxmox does not rename the Windows computer.

Sysprep was used to generalize Windows before cloning rather than relying only on manually changing the hostname after deployment.

Proxmox should also assign a new MAC address to the virtual network adapter when the VM is cloned. This should be verified under:

**VM → Hardware → Network Device**

The template should use DHCP rather than contain a static IP address. Static addressing or DHCP reservations can be assigned after the new VM has been deployed.

## Validation

After deploying a test clone:

- Confirm Windows completes OOBE successfully.
- Assign and verify a unique Windows hostname.
- Confirm the VM received a unique MAC address.
- Confirm the VM received its own DHCP lease.
- Verify network connectivity.
- Verify VirtIO devices are working.
- Verify the QEMU Guest Agent is running.
- Confirm baseline applications are available.
- Confirm no accounts, credentials, or client-specific configuration were inherited from the source VM.

## Updating the Template

The original generalized template should be kept as a known-good image rather than routinely booted and modified.

When significant changes are needed, a new version can be created from a clone:

```text
win11-template-v1
        ↓
   Temporary Clone
        ↓
Updates / Changes
        ↓
Sysprep /generalize
        ↓
win11-template-v2
```

Versioning the template provides a rollback point if an updated image introduces problems.

For major Windows releases or after many rounds of image maintenance, rebuilding the template from a clean Windows installation may be preferable to repeatedly modifying and generalizing an older image.

## Future Improvements

The initial template uses Windows OOBE for post-clone configuration.

A future version can use an `unattend.xml` answer file to automate parts of Windows setup and provide more consistent VM deployment.

Additional automation could include:

- Automated computer naming
- OOBE configuration
- Regional and language settings
- Local account provisioning
- PowerShell bootstrap scripts
- Automated application deployment
- Domain or Entra ID onboarding

This would move the workflow from a reusable golden image toward a more automated Windows provisioning process.
