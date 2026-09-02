# 🔧 Troubleshooting


## Node-Local NVMe Storage Unavailable After Joining Proxmox Cluster

**Symptom:** After joining the second Proxmox host to the cluster, its secondary NVMe storage remained present at the Linux and LVM layers but did not initially appear as usable storage in the Proxmox resource tree.

**Cause:** Proxmox storage definitions are managed through the cluster configuration, while the underlying LVM physical volumes, volume groups, and thin pools remain local to each node. Joining the cluster did not remove the underlying storage, but the existing local storage configuration required reconciliation with the cluster-wide Proxmox storage configuration.

**Troubleshooting:** Verified that the underlying storage remained intact:

```bash
pvesm status
pvs
vgs
lvs
```

The NVMe device, LVM physical volume, volume group, and thin pool were still present, confirming that the issue was with the Proxmox storage definition rather than the underlying disk or LVM configuration.

**Resolution:** Reconfigured the NVMe storage in Proxmox and standardized node-specific storage IDs:

```text
prox-lab-01 → nvme-01-lvm
prox-lab-02 → nvme-02-lvm
prox-lab-03 → nvme-03-lvm (planned)
```

**Impact:** Each node's local NVMe LVM-thin storage is clearly identified within the cluster while remaining associated with its respective host.

**Lesson Learned:** Proxmox storage configuration and the underlying Linux storage stack are separate layers. Before recreating, formatting, or modifying storage that disappears from the Proxmox interface, verify the physical disk and LVM configuration from the host first.



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



## VMware Nested Virtualization Unavailable

**Symptom:** VMware reported that nested virtualization was unavailable because Hyper-V or Device/Credential Guard was active.

**Cause:** Windows Virtualization-Based Security remained active after Hyper-V was disabled.

**Resolution:** Disabled VBS and verified the Microsoft hypervisor was no longer active using `msinfo32`.

**Reference:** See the detailed Windows VMware/Proxmox nested virtualization guide.



## Proxmox CPU Soft Lockups Under Nested KVM

**Symptom:**

`watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [CPU 0/KVM]`

**Cause:** Instability occurred when VMware exposed nested VT-x/EPT to the Proxmox VM.

**Resolution:** Disabled VMware nested virtualization and confirmed Proxmox remained stable.

**Impact:** Nested KVM testing was deferred to the final bare-metal deployment.
