## 2026-08-15 — Nested KVM Caused CPU Soft Lockups in VMware

**Context**

After successfully installing Proxmox VE inside VMware Workstation, I enabled VMware's **Virtualize Intel VT-x/EPT or AMD-V/RVI** option so Proxmox could use KVM hardware acceleration and run nested virtual machines.

With nested virtualization enabled, Proxmox began reporting repeated watchdog errors:

```text
watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [CPU 0/KVM]
```

The lockups occurred even during normal host activity such as running `apt update` and eventually caused the Proxmox VM to become unstable and reboot.

**Lesson**

Nested virtualization introduces an additional virtualization layer that can create compatibility or CPU scheduling issues that do not exist in a bare-metal Proxmox deployment. Successfully exposing VT-x/AMD-V to a nested hypervisor does not necessarily mean the resulting KVM environment will be stable.

Disabling VMware's nested virtualization option immediately stabilized the Proxmox VM, isolating the issue to the **VMware → Proxmox → KVM** virtualization path rather than the Proxmox installation itself.

**Result**

- Confirmed Proxmox VE itself was stable when VMware nested virtualization was disabled.
- Isolated repeated `watchdog: BUG: soft lockup` errors to VMware's nested VT-x/AMD-V exposure.
- Verified stability by disabling **Virtualize Intel VT-x/EPT or AMD-V/RVI** and repeating normal Proxmox operations.
- Avoided unnecessary Proxmox reinstallation after identifying the virtualization layer as the source of instability.
- Continued using the nested Proxmox instance for management, networking, storage, and interface familiarization without nested KVM acceleration.
- Reinforced the value of changing one infrastructure variable at a time to isolate faults.
- Recognized that this limitation applies to the temporary VMware test environment and will not represent the final bare-metal Proxmox architecture.


## 2026-08-15 — Windows Hyper-V and VBS Can Prevent Nested Virtualization

**Context**

Before deploying Proxmox VE to dedicated bare-metal hardware, I wanted to test Proxmox inside VMware Workstation on Windows. VMware reported that Hyper-V or Device/Credential Guard was active and that it would use the Windows Hypervisor Platform, which prevented nested virtualization from being available.

Disabling the Hyper-V Windows Feature and setting `hypervisorlaunchtype` to `off` did not initially resolve the issue. Checking `msinfo32` showed that Virtualization-Based Security (VBS) was still running and that Windows continued to detect an active hypervisor.

**Lesson**

Disabling the Hyper-V Windows Feature does not necessarily stop the underlying Microsoft hypervisor. Windows security technologies such as VBS and Memory Integrity/HVCI can continue using the virtualization stack even when Hyper-V itself is disabled.

Nested virtualization requires VMware to expose the host's Intel VT-x/AMD-V virtualization extensions to the Proxmox guest. On this system, VBS had to be disabled through the Device Guard Group Policy before VMware could provide nested virtualization to Proxmox.

**Result**

- Disabled Hyper-V and other unnecessary Windows virtualization components for the VMware test environment.
- Disabled Memory Integrity and configured `hypervisorlaunchtype` as `off`.
- Used `msinfo32` to identify that VBS and the Microsoft hypervisor were still active after the initial changes.
- Disabled **Turn On Virtualization Based Security** under the Device Guard Group Policy and confirmed the hypervisor was no longer active after reboot.
- Enabled VMware's **Virtualize Intel VT-x/EPT or AMD-V/RVI** option for the Proxmox VM.
- Learned that hardware virtualization should remain enabled in BIOS/UEFI even when the Windows hypervisor must be disabled.
- Established a temporary VMware → Proxmox nested environment for testing before the final bare-metal Proxmox deployment.
