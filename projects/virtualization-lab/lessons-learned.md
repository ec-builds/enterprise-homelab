## 2026-08-15 — Nested KVM Caused CPU Soft Lockups in VMware

**Context**

While testing Proxmox VE inside VMware Workstation, I enabled nested VT-x/EPT so Proxmox could run KVM virtual machines. This caused repeated CPU soft lockups and eventually made the Proxmox VM unstable.

```text
watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [CPU 0/KVM]
```

**Lesson**

Nested virtualization adds another hypervisor layer and can introduce stability issues not present with bare-metal virtualization. Disabling nested VT-x/EPT immediately stabilized Proxmox, isolating the issue to the **VMware → Proxmox → KVM** path rather than Proxmox itself.

**Result**

- Isolated the soft lockups to VMware nested virtualization.
- Confirmed Proxmox remained stable with nested VT-x/EPT disabled.
- Continued using the VM to test Proxmox management, networking, and storage.
- Confirmed the issue is specific to the temporary nested environment, not the planned bare-metal architecture.


## 2026-08-15 — Hyper-V and VBS Can Prevent VMware Nested Virtualization

**Context**

VMware initially reported that Hyper-V or Device/Credential Guard was active and that nested virtualization was unavailable. Disabling Hyper-V alone did not resolve the issue because Windows VBS remained active.

**Lesson**

Disabling the Hyper-V Windows Feature does not necessarily stop the Microsoft hypervisor. VBS and Memory Integrity/HVCI can continue using it. `msinfo32` confirmed VBS was still running, and disabling VBS through Device Guard Group Policy resolved the conflict.

**Result**

- Disabled Hyper-V, Memory Integrity, and unnecessary Windows virtualization components.
- Set `hypervisorlaunchtype` to `off`.
- Used `msinfo32` to confirm VBS was still keeping the Microsoft hypervisor active.
- Disabled **Turn On Virtualization Based Security** through Group Policy.
- Restored VMware's ability to expose nested VT-x/EPT to the Proxmox VM.
- Learned to distinguish **hardware virtualization (VT-x/EPT)** from the **Windows hypervisor/VBS layer**.
