# Troubleshooting

## Proxmox Management Address Persisted After Switching to DHCP

**Symptom:** After changing the Proxmox management bridge from static addressing to DHCP, `vmbr0` temporarily showed both the original static IP and a DHCP-assigned IP. The Proxmox boot console also continued displaying the old management address.

**Cause:** The installation-time static configuration remained associated with `vmbr0`, while the old address was also still mapped to the Proxmox hostname in `/etc/hosts`.

**Resolution:** Changed `vmbr0` from static addressing to DHCP in the Proxmox network configuration and updated `/etc/hosts` to reflect the current management address.

**Impact:** The host retained a single DHCP-assigned management address, with a DHCP reservation providing predictable addressing. The Proxmox console also displayed the correct management URL after reboot.

**Reference:** See the detailed Proxmox networking guide for bridge configuration and troubleshooting.


## Windows Boot Manager Prevented Proxmox Boot

**Symptom:** After the bare-metal Proxmox installation, the system did not automatically boot into Proxmox.

**Cause:** The Dell UEFI firmware retained an active Windows Boot Manager entry from the system's previous Windows installation and prioritized it during startup.

**Resolution:** Disabled Windows Boot Manager in the Dell BIOS/UEFI boot configuration while keeping UEFI boot mode enabled.

**Impact:** Proxmox booted normally without installation media attached. Confirmed the issue was caused by the firmware boot configuration rather than the Proxmox installation.

---

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
