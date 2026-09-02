## 2026-09-01 — Node-Local Storage Required CLI-Based VM Migration

**Context**

A VM needed to be migrated between Proxmox cluster nodes using separate node-local NVMe storage. The GUI migration failed because the source storage was not available on the destination node and could not be automatically mapped to the destination storage pool.

**Lesson**

Proxmox clustering does not make node-local storage shared between hosts. When the GUI cannot map local storage during migration, the CLI can explicitly specify the destination storage.

See the **Proxmox CLI VM Migration** reference documentation for the migration procedure.

**Result**

- Identified node-local storage as the cause of the GUI migration failure.
- Migrated the VM using the CLI with explicit destination-storage mapping.
- Verified the VM and its disks on the destination node.
- Established a repeatable procedure for migrations between node-local storage.



## 2026-08-31 — DHCP Addressing Prevented Proxmox Cluster Configuration

**Context**

The Proxmox management bridge (`vmbr0`) was initially configured using DHCP. Although the node consistently received the expected address through a DHCP reservation, Proxmox did not present the dynamically assigned address as an available Corosync cluster link during cluster creation.

```text
inet 10.x.x.x/24 scope global dynamic vmbr0
```

The management interface was changed from DHCP to a static address directly within the Proxmox network configuration.
Hostname resolution was also validated to ensure the node hostname resolved to the same static management address.

**Lesson**

A DHCP reservation provides predictable addressing from the DHCP server, but the host still considers the address dynamically assigned. Cluster infrastructure benefits from static host-level addressing to provide stable management and Corosync endpoints.

Network configuration and hostname resolution should therefore be validated before initializing a Proxmox cluster.

**Result**

- Converted `vmbr0` from DHCP to static addressing.
- Retained the existing management address to avoid unnecessary network changes.
- Verified the address was locally configured rather than dynamically leased.
- Corrected stale hostname resolution to match the static management address.
- Verified hostname and management-IP consistency with `hostname -I` and `getent hosts`.
- Successfully exposed the management address for Corosync Link 0 and proceeded with cluster creation.


## 2026-08-31 — Recreated LVM-Thin Storage for Standardized Cluster Naming

**Context**

After adding the second Proxmox node to the cluster, its secondary NVMe device was detected by Linux and remained configured as an LVM thin pool, but its storage entry did not appear alongside the node's other Proxmox storage.
Investigation showed that the underlying LVM storage and the Proxmox storage definition were separate configuration layers.

```text
Physical NVMe
    ↓
LVM Physical Volume (PV)
    ↓
Volume Group (VG)
    ↓
LVM Thin Pool
    ↓
Proxmox Storage Definition
```

Because the environment was still being built and the NVMe thin pools contained no VM data, the additional storage was removed and recreated using a consistent node-based naming convention.

**Lesson**

Removing a storage entry from **Datacenter → Storage** removes the Proxmox storage definition but does not remove the underlying LVM volume group, thin pool, or physical-volume metadata.

Tools such as `pvesm`, `pvs`, `vgs`, and `lvs` are useful for distinguishing between the Proxmox storage layer and the underlying Linux LVM configuration.

Storage naming should ideally be standardized before workloads are deployed, since changing storage identifiers becomes more complicated once VM or container disks reference them.

**Result**

- Confirmed the secondary NVMe and LVM structures remained intact.
- Verified the thin pool contained no VM data before making destructive changes.
- Removed the obsolete Proxmox storage definition.
- Removed and recreated the underlying LVM-thin configuration.
- Standardized node-local NVMe storage naming across the cluster.
- Preserved the default `pve` volume group and `local-lvm` system storage.



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
