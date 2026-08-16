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
