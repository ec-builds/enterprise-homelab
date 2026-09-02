# Windows VM Templates

## Overview

This reference documents the process used to create reusable Windows VM templates in Proxmox VE.

The current template strategy supports:

- **Windows 11** — workstation and domain client deployments
- **Windows Server 2025** — domain controllers and other Windows Server workloads

The templates provide consistent operating system baselines while using Windows Sysprep to remove machine-specific information before cloning. Each deployed VM can then be assigned its own hostname, network configuration, and system role without carrying over the identity of the original system.

```text
Windows Baseline
        ↓
Updates + VirtIO Guest Tools
        ↓
Sysprep /generalize
        ↓
Shutdown
        ↓
Proxmox Template
        ↓
Full Clone
        ↓
Unique Windows VM
        ↓
Role-Specific Configuration
```

## Template Strategy

Separate templates are maintained for Windows client and server operating systems.

| Template | Operating System | Purpose |
|---|---|---|
| `win11-template` | Windows 11 | Workstations and domain clients |
| `win-server-2025-template` | Windows Server 2025 Standard Evaluation | Domain controllers and Windows Server workloads |

The templates contain only configuration that should be common to every deployment. Machine-specific configuration and server roles are applied after cloning.

### Windows 11

```text
win11-template
      ↓
   Full Clone
      ↓
Windows Client
      ↓
Client Configuration
```

### Windows Server 2025

```text
win-server-2025-template
          ↓
      Full Clone
          ↓
    Windows Server
          ↓
Hostname + Networking
          ↓
Server Role Configuration
```

The Windows Server template does **not** contain Active Directory Domain Services, DNS, DHCP, or other workload-specific server roles.

For example:

```text
win-server-2025-template
          │
          ├── Clone → Domain Controller
          ├── Clone → Additional Domain Controller
          └── Clone → Future Windows Server
```

## Template Preparation

An existing Windows VM can be used as the starting point as long as machine-specific configuration is removed before it becomes the template.

Before generalizing the VM:

- Install all current Windows updates.
- Verify VirtIO drivers are installed and working.
- Verify the QEMU Guest Agent is installed and running.
- Enable QEMU Guest Agent support in the Proxmox VM options.
- Configure the network adapter for DHCP.
- Verify BitLocker is disabled and the OS volume is fully decrypted.
- Remove temporary files and system-specific configuration.
- Remove saved credentials and signed-in accounts.
- Do not domain join, Entra join, or Intune enroll the template.
- Do not configure static IP addressing in the template.
- Do not install deployment-specific server roles in the Windows Server template.

The Proxmox VM can be renamed to something descriptive such as `win11-template` or `win-server-2025-template`.

The Proxmox VM name is separate from the hostname configured inside Windows.

## Baseline Software

Software included in a template should be limited to applications, drivers, and utilities that are appropriate for every VM deployed from that image.

### Windows 11

Example workstation baseline:

- Adobe Acrobat Reader
- 7-Zip
- Web browser
- PowerShell 7
- VirtIO Guest Tools

Applications should be installed but left in a user-neutral state. Personal accounts, browser profiles, saved credentials, and application-specific user configuration should not be included in the template.

Role-specific applications and administrative tools can be installed after deployment or delivered through centralized management rather than becoming part of the base image.

### Windows Server 2025

The Windows Server template uses a more minimal baseline:

- Current Windows updates
- VirtIO drivers
- QEMU Guest Agent
- PowerShell
- Common administrative utilities, where appropriate

Server roles and workload-specific applications are installed after deployment rather than included in the base template.

This allows the same Windows Server template to provide the starting point for multiple server roles.

## Sysprep

Windows Sysprep is used before converting a VM into a Proxmox template.

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

### BitLocker and Sysprep

Sysprep validation failed during the initial Windows 11 template build because the Windows OS volume was encrypted even though BitLocker showed **Waiting for activation** in Control Panel.

The Sysprep log identified the issue:

```text
SYSPRP BitLocker-Sysprep: BitLocker is on for the OS volume.
Turn BitLocker off to run Sysprep. (0x80310039)
```

BitLocker status was verified with:

```powershell
manage-bde -status C:
```

The OS volume was then decrypted before attempting Sysprep again:

```powershell
manage-bde -off C:
```

Decryption progress was checked with:

```powershell
manage-bde -status C:
```

Before running Sysprep again, the OS volume was verified as:

```text
Conversion Status:    Fully Decrypted
Percentage Encrypted: 0.0%
```

BitLocker was intentionally left disabled in the generalized template. Encryption can be enabled after a new VM is deployed so each system establishes its own encryption and TPM state.

## Convert to Template

After Sysprep completes and the VM shuts down:

1. Locate the VM in the Proxmox VE interface.
2. Verify that the VM is stopped.
3. Rename the Proxmox VM to the appropriate template name if needed.
4. Right-click the VM.
5. Select **Convert to template**.

Example template names:

```text
win11-template
win-server-2025-template
```

The resulting templates should remain powered off and serve only as sources for future Windows deployments.

## Deploy a VM

To deploy a new Windows system:

1. Right-click the appropriate template.
2. Select **Clone**.
3. Enter the new Proxmox VM name.
4. Select **Full Clone**.
5. Select the destination node and storage.
6. Create the clone.
7. Start the new VM.
8. Complete Windows OOBE.
9. Assign the intended Windows hostname.
10. Apply the required network configuration.
11. Apply client- or server-specific configuration.

### Windows 11 Example

```text
win11-template
      ↓
   Full Clone
      ↓
win11-client-03
      ↓
 Windows OOBE
      ↓
Unique Client VM
```

### Windows Server Example

```text
win-server-2025-template
          ↓
      Full Clone
          ↓
    dc-lab-01-vm
          ↓
 Windows Configuration
          ↓
     dc-lab-01
          ↓
   AD DS / DNS / DHCP
```

A full clone is preferred for permanent lab VMs because the cloned virtual disk is independent of the template.

## Identity and Networking

The Proxmox VM name and Windows hostname are separate values. Renaming a VM in Proxmox does not rename the Windows computer.

Sysprep is used to generalize Windows before cloning rather than relying only on manually changing the hostname after deployment.

Proxmox should also assign a new MAC address to the virtual network adapter when the VM is cloned. This should be verified under:

**VM → Hardware → Network Device**

Templates should use DHCP rather than contain static IP addresses.

After deployment:

- Client systems can continue using DHCP.
- Persistent systems can receive DHCP reservations where appropriate.
- Foundational infrastructure such as domain controllers can be assigned static addressing.

See the network addressing documentation for the lab's static, reservation, and DHCP strategy.

## Server Deployment Considerations

Windows Server clones should remain general-purpose until after the individual VM has been deployed.

Configuration such as the following should occur after cloning:

- Server hostname
- Static network addressing
- DNS configuration
- Domain membership
- Active Directory Domain Services
- DNS and DHCP roles
- Other Windows Server roles
- Workload-specific applications
- Service accounts and credentials

For the Active Directory lab, the deployment model is:

```text
Windows Server 2025 Template
            ↓
        Full Clone
            ↓
    Primary Domain Controller
            ↓
       AD DS + DNS
            │
            │
            └──────────────┐
                           │
Windows Server 2025 Template
            ↓              │
        Full Clone         │
            ↓              │
  Additional Domain        │
      Controller           │
            ↓              │
       AD DS + DNS         │
            │              │
            └──── Replication
```

This keeps the reusable Windows Server image independent of the Active Directory environment itself.

## Validation

After deploying a test clone:

- Confirm Windows completes OOBE successfully.
- Assign and verify a unique Windows hostname.
- Confirm the VM received a unique MAC address.
- Confirm network connectivity.
- Verify VirtIO devices are working.
- Verify the QEMU Guest Agent is running.
- Confirm baseline software is available.
- Confirm no accounts, credentials, or system-specific configuration were inherited from the source VM.

For Windows 11 clients:

- Confirm the VM receives its own DHCP lease.
- Confirm client applications are available.
- Confirm the system is ready for domain, Entra ID, or Intune onboarding.

For Windows Server:

- Confirm the server can be assigned its intended network configuration.
- Confirm no server roles were inherited from the template.
- Confirm the system is ready for role-specific configuration.

## Updating Templates

The original generalized templates should be kept as known-good images rather than routinely booted and modified.

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

The same strategy can be used for Windows Server:

```text
win-server-2025-template-v1
             ↓
       Temporary Clone
             ↓
      Updates / Changes
             ↓
      Sysprep /generalize
             ↓
win-server-2025-template-v2
```

Versioning templates provides a rollback point if an updated image introduces problems.

For major Windows releases or after multiple rounds of image maintenance, rebuilding the template from a clean Windows installation may be preferable to repeatedly modifying and generalizing an older image.

## Future Improvements

The initial templates use Windows OOBE for post-clone configuration.

Future versions can use an `unattend.xml` answer file to automate parts of Windows setup and provide more consistent VM deployment.

Additional automation could include:

- Automated computer naming
- OOBE configuration
- Regional and language settings
- Local account provisioning
- PowerShell bootstrap scripts
- Automated application deployment
- Domain or Entra ID onboarding
- Windows Server role deployment

The longer-term provisioning model can combine templates with infrastructure and configuration automation:

```text
Proxmox Template
        ↓
VM Provisioning
        ↓
Windows Configuration
        ↓
PowerShell / Automation
        ↓
Client or Server Role
```

This moves the workflow from reusable golden images toward standardized and repeatable Windows infrastructure deployment.
