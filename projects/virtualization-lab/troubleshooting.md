# Troubleshooting

## VMware Nested Virtualization Unavailable

**Symptom:** VMware reported that nested virtualization was unavailable because Hyper-V or Device/Credential Guard was active.

**Cause:** Windows Virtualization-Based Security remained active after Hyper-V was disabled.

**Resolution:** Disabled VBS and verified the Microsoft hypervisor was no longer active using `msinfo32`.

**Reference:** See the detailed Windows VMware/Proxmox nested virtualization guide.

---

## Proxmox CPU Soft Lockups Under Nested KVM

**Symptom:**

`watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [CPU 0/KVM]`

**Cause:** Instability occurred when VMware exposed nested VT-x/EPT to the Proxmox VM.

**Resolution:** Disabled VMware nested virtualization and confirmed Proxmox remained stable.

**Impact:** Nested KVM testing was deferred to the final bare-metal deployment.
