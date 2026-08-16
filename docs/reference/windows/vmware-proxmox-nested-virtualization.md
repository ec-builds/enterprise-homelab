# VMware Workstation + Proxmox Nested Virtualization Reference

## Purpose

Configure a Windows host so **VMware Workstation Pro** can access the CPU's hardware virtualization extensions directly and expose them to a **Proxmox VE virtual machine**.

This allows Proxmox itself to run nested KVM virtual machines.

### Target Architecture

```text
Physical CPU
└── Windows Host
    └── VMware Workstation Pro
        └── Proxmox VE
            ├── KVM VM
            ├── KVM VM
            └── KVM VM
```

This requires **nested virtualization**.

The Windows Microsoft hypervisor can interfere with this because VMware may be forced to run through the **Windows Hypervisor Platform (WHP)** instead of directly accessing Intel VT-x or AMD-V.

A warning similar to the following may appear during VMware installation:

```text
VMware Workstation Pro can use either its own hypervisor
or the Windows Hypervisor Platform.

The installer detected that the host has Hyper-V or
Device/Credential Guard enabled, so virtual machines will
be run using Windows Hypervisor Platform.

Nested virtualization will not be available.
```

For a VMware → Proxmox → KVM lab, the important part is:

> **Nested virtualization will not be available.**

---

# Quick Configuration Table

| Step | Action | Setting / Command | Desired State | Purpose |
|---:|---|---|---|---|
| 1 | Disable Hyper-V | Windows Features → **Hyper-V** | Off | Prevent Microsoft Hyper-V from owning the virtualization layer |
| 2 | Disable Windows Hypervisor Platform | Windows Features → **Windows Hypervisor Platform** | Off | Prevent VMware from using WHP compatibility mode |
| 3 | Disable Virtual Machine Platform | Windows Features → **Virtual Machine Platform** | Off | Remove another Windows virtualization dependency |
| 4 | Disable Windows Sandbox | Windows Features → **Windows Sandbox** | Off | Remove Sandbox's dependency on Windows virtualization |
| 5 | Disable Memory Integrity | Windows Security → Device security → Core isolation | Off | Disable HVCI/VBS dependency |
| 6 | Disable hypervisor at boot | `bcdedit /set hypervisorlaunchtype off` | Off | Prevent Microsoft hypervisor from launching |
| 7 | Disable VBS Group Policy | Device Guard → **Turn On Virtualization Based Security** | Disabled | Prevent VBS from starting the hypervisor |
| 8 | Restart Windows | Full reboot | — | Apply virtualization changes |
| 9 | Verify boot configuration | `bcdedit /enum {current}` | `hypervisorlaunchtype Off` | Confirm bootloader configuration |
| 10 | Verify VBS | `msinfo32` | Not Running | Confirm VBS is inactive |
| 11 | Verify Microsoft hypervisor | `msinfo32` | Hypervisor message absent | Confirm Windows hypervisor is inactive |
| 12 | Enable VMware nested virtualization | VMware VM Settings → Processors | Enabled | Pass VT-x/AMD-V through to Proxmox |

---

# Detailed Procedure

## Step 1 — Disable Hyper-V

Open:

```text
Control Panel
→ Programs
→ Programs and Features
→ Turn Windows features on or off
```

Alternatively:

```text
Win + R
optionalfeatures
```

Find:

```text
Hyper-V
```

Uncheck it.

### Why

Hyper-V is Microsoft's Type-1 hypervisor.

When active, Windows itself operates on top of Microsoft's hypervisor:

```text
Hardware
    ↓
Microsoft Hypervisor
    ↓
Windows
    ↓
VMware
```

VMware can coexist with modern Hyper-V configurations, but it may have to use Microsoft's virtualization interfaces rather than directly controlling VT-x/AMD-V.

For ordinary VMware VMs this can work fine.

For this lab, however, we need another virtualization layer:

```text
Hardware
    ↓
VMware
    ↓
Proxmox
    ↓
KVM
```

Therefore, VMware needs access to the hardware virtualization capabilities that it can expose to Proxmox.

---

## Step 2 — Disable Windows Hypervisor Platform

From:

```text
Win + R
optionalfeatures
```

Uncheck:

```text
Windows Hypervisor Platform
```

### Why

Windows Hypervisor Platform provides APIs that third-party virtualization software such as VMware can use when Microsoft's hypervisor is active.

Instead of:

```text
VMware
   ↓
VT-x / AMD-V
```

VMware can operate more like:

```text
VMware
   ↓
Windows Hypervisor Platform
   ↓
Microsoft Hypervisor
   ↓
VT-x / AMD-V
```

This compatibility mode is useful when Hyper-V/VBS must remain enabled, but it is not what we want for this nested Proxmox configuration.

---

## Step 3 — Disable Virtual Machine Platform

From Windows Features, uncheck:

```text
Virtual Machine Platform
```

### Why

Virtual Machine Platform is another component of Microsoft's virtualization stack.

It is notably used by technologies such as:

```text
WSL2
```

If this feature is required for something else on the computer, disabling it may affect that functionality.

For a system being configured primarily as a VMware nested-virtualization host, disabling it helps remove competing Microsoft virtualization components.

---

## Step 4 — Disable Windows Sandbox

From Windows Features, uncheck:

```text
Windows Sandbox
```

### Why

Windows Sandbox relies on Microsoft's virtualization infrastructure.

It isn't necessarily the primary cause of VMware's warning, but disabling it eliminates another feature that can require the Windows virtualization stack.

If Sandbox isn't installed/enabled, nothing needs to be changed.

---

## Step 5 — Disable Memory Integrity

Open:

```text
Windows Security
→ Device security
→ Core isolation
→ Core isolation details
```

Set:

```text
Memory integrity: OFF
```

### Why

Memory Integrity is also known as:

```text
HVCI
Hypervisor-Protected Code Integrity
```

It uses **Virtualization-Based Security (VBS)**.

This means Hyper-V can appear to be removed while Windows is **still running a Microsoft hypervisor** for security purposes.

This is an important distinction:

```text
Hyper-V feature disabled
        ≠
Microsoft hypervisor necessarily stopped
```

Windows security features can use the same underlying virtualization technology even when you aren't running conventional Hyper-V virtual machines.

---

## Step 6 — Prevent the Microsoft Hypervisor from Launching

Open:

```text
Command Prompt
```

or:

```text
Windows Terminal
```

as **Administrator**.

Run:

```cmd
bcdedit /set hypervisorlaunchtype off
```

Expected response:

```text
The operation completed successfully.
```

### Why

This modifies the Windows boot configuration so the Microsoft hypervisor is not automatically launched during startup.

This is separate from simply removing the Hyper-V Windows Feature.

Think of it as:

```text
Windows Feature Configuration
        +
Boot Configuration
        +
VBS/Security Configuration
```

All three can affect whether Microsoft's hypervisor is actually running.

---

## Step 7 — Disable Virtualization-Based Security Through Group Policy

In this case, this was the **final setting that resolved the problem**.

Open:

```text
Win + R
```

Run:

```text
gpedit.msc
```

Navigate to:

```text
Computer Configuration
└── Administrative Templates
    └── System
        └── Device Guard
            └── Turn On Virtualization Based Security
```

Open:

```text
Turn On Virtualization Based Security
```

Set it to:

```text
Disabled
```

Click:

```text
Apply
OK
```

### Why

Even after:

- Hyper-V was removed
- `hypervisorlaunchtype` was set to `Off`
- Memory Integrity was disabled
- Windows was rebooted

`msinfo32` still reported:

```text
Virtualization-based security    Running
```

and:

```text
A hypervisor has been detected.
Features required for Hyper-V will not be displayed.
```

That proved that Microsoft's hypervisor/VBS environment was **still active**.

Disabling:

```text
Turn On Virtualization Based Security
```

through Group Policy stopped VBS from continuing to activate the virtualization environment on this machine.

This was the key final fix.

---

## Step 8 — Restart Windows

Perform a full Windows restart.

### Why

Hypervisor and VBS changes affect the Windows boot process.

Simply:

- Closing VMware
- Signing out
- Restarting VMware
- Disabling the Windows Feature without rebooting

isn't sufficient.

Windows needs to boot again with the new hypervisor/VBS configuration.

---

# Verification

## Step 9 — Verify Hypervisor Boot Configuration

Open an elevated Command Prompt and run:

```cmd
bcdedit /enum {current}
```

Find:

```text
hypervisorlaunchtype
```

Desired result:

```text
hypervisorlaunchtype    Off
```

### Meaning

This confirms that the current Windows boot entry is configured **not to automatically launch Microsoft's hypervisor**.

---

## Step 10 — Verify VBS Status

Run:

```text
Win + R
msinfo32
```

Open:

```text
System Summary
```

Scroll toward the bottom.

Previously, the machine showed:

```text
Virtualization-based security    Running
```

This indicated that VBS was still active despite Hyper-V itself having been removed.

After the successful configuration, VBS should no longer report itself as running.

---

## Step 11 — Verify the Microsoft Hypervisor Is Gone

While still in:

```text
msinfo32
```

check the bottom of System Summary.

Before the fix, Windows displayed:

```text
A hypervisor has been detected.
Features required for Hyper-V will not be displayed.
```

For the desired VMware configuration, this message should **no longer appear**.

### Important

This message:

```text
A hypervisor has been detected
```

does **not** simply mean that CPU virtualization is enabled.

It means Windows detected an active hypervisor underneath the operating system.

We want:

```text
CPU virtualization enabled
Microsoft hypervisor not running
```

Those are two different things.

---

# Step 12 — Enable Nested Virtualization in VMware

Once the Windows hypervisor/VBS conflict is resolved, configure the Proxmox VM.

Shut down the Proxmox VM.

Open:

```text
VMware Workstation
→ Proxmox VM
→ VM Settings
→ Processors
```

Enable:

```text
Virtualize Intel VT-x/EPT or AMD-V/RVI
```

The exact wording depends on the CPU/platform.

### Why

This tells VMware to expose virtualization extensions to the **guest operating system**.

Normally:

```text
Physical CPU
    ↓
VMware
    ↓
Guest OS
```

With nested virtualization:

```text
Physical CPU
    ↓
VMware
    ↓
Virtualized VT-x/AMD-V
    ↓
Proxmox
    ↓
KVM
    ↓
Nested VM
```

Proxmox can now see virtualization capabilities inside its VMware VM and use KVM to run additional VMs.

---

# BIOS / UEFI Configuration

Do **NOT** disable hardware virtualization in the BIOS.

The following should remain enabled:

| BIOS Setting | Desired State | Purpose |
|---|---|---|
| Intel VT-x / AMD-V | **Enabled** | CPU virtualization required by VMware |
| Intel VT-d / AMD IOMMU | **Enabled where applicable** | Hardware-assisted I/O virtualization/passthrough |
| Secure Boot | Can remain enabled | Not the same thing as Hyper-V/VBS |

The distinction is important:

```text
Hardware virtualization
        ↓
KEEP ENABLED

Microsoft Hypervisor / VBS
        ↓
DISABLE for this VMware nested lab
```

If hardware virtualization itself is disabled in BIOS, VMware will lose the capabilities that we're trying to expose to Proxmox.

---

# Troubleshooting Sequence Used

The original VMware installer reported:

```text
The installer detected that the host has Hyper-V or
Device/Credential Guard enabled, so virtual machines
will be run using Windows Hypervisor Platform.

Nested virtualization will not be available.
```

Hyper-V was disabled through Windows Features.

The warning persisted.

The Windows hypervisor boot setting was then disabled:

```cmd
bcdedit /set hypervisorlaunchtype off
```

Windows was rebooted.

The warning still persisted.

`msinfo32` was then checked and showed:

```text
Virtualization-based security    Running
```

as well as:

```text
A hypervisor has been detected.
Features required for Hyper-V will not be displayed.
```

This established that **VBS was still causing Windows to operate with the Microsoft hypervisor active**.

Memory Integrity was disabled.

VBS was then explicitly disabled through:

```text
gpedit.msc

Computer Configuration
→ Administrative Templates
→ System
→ Device Guard
→ Turn On Virtualization Based Security
→ Disabled
```

After rebooting:

```text
Microsoft Hypervisor / VBS
        ↓
No longer active
```

VMware could then use the system's virtualization extensions in the configuration required for nested Proxmox virtualization.

---

# Final Configuration

The desired configuration for this lab is:

| Component | State |
|---|---|
| BIOS Intel VT-x / AMD-V | **ON** |
| BIOS VT-d / AMD IOMMU | **ON where available** |
| Hyper-V | **OFF** |
| Windows Hypervisor Platform | **OFF** |
| Virtual Machine Platform | **OFF** |
| Windows Sandbox | **OFF** |
| Memory Integrity / HVCI | **OFF** |
| VBS Group Policy | **Disabled** |
| `hypervisorlaunchtype` | **Off** |
| VMware nested virtualization | **ON** |
| Proxmox KVM | **Available** |

---

# Do These Settings Need to Be Reverted After Installing Proxmox?

**No.**

These changes are not only required for the Proxmox installer.

They are required because the desired environment is:

```text
VMware Workstation
        ↓
    Proxmox VE
        ↓
      KVM VMs
```

Proxmox needs nested virtualization whenever it runs KVM virtual machines inside VMware.

Re-enabling VBS/Hyper-V may cause VMware to return to Windows Hypervisor Platform mode and can prevent the nested virtualization configuration from working.

Therefore, while this machine is being used as a VMware → Proxmox lab host, leave these settings configured as described above.

---

# Security Consideration

Memory Integrity and VBS are Windows security technologies.

Disabling them reduces some of the isolation protections Windows normally provides.

Therefore, there is a tradeoff:

```text
Normal Windows Security Configuration

VBS / Memory Integrity
        ON
        ↓
Additional Windows isolation/security
```

versus:

```text
Nested Virtualization Lab

VBS / Microsoft Hypervisor
        OFF
        ↓
VMware direct virtualization
        ↓
Proxmox
        ↓
KVM VMs
```

For a machine dedicated primarily to virtualization/lab work, the latter configuration may be appropriate.

If the computer stops being used for VMware nested virtualization, the Windows security features can be restored.

---

# Quick Diagnostic Commands

### Check Windows boot configuration

```cmd
bcdedit /enum {current}
```

Look for:

```text
hypervisorlaunchtype    Off
```

### Disable Microsoft hypervisor at boot

```cmd
bcdedit /set hypervisorlaunchtype off
```

### Open System Information

```text
msinfo32
```

### Open Windows Features

```text
optionalfeatures
```

### Open Group Policy Editor

```text
gpedit.msc
```

---

# Key Lesson

Disabling the **Hyper-V Windows Feature does not necessarily disable the Microsoft hypervisor**.

Modern Windows security features such as:

- Virtualization-Based Security (VBS)
- Memory Integrity / HVCI
- Credential Guard
- Device Guard policies

can continue using Microsoft's hypervisor even when the normal Hyper-V role appears to be disabled.

For troubleshooting VMware nested virtualization, `msinfo32` is therefore an important verification tool.

The desired end state is:

```text
BIOS Virtualization:        ENABLED
Windows Hyper-V:            DISABLED
Windows VBS:                DISABLED
Microsoft Hypervisor:       NOT RUNNING
VMware VT-x/AMD-V Access:   AVAILABLE
VMware Nested Virt:         ENABLED
Proxmox KVM:                AVAILABLE
```
