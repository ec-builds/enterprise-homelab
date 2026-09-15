# Proxmox PCI Device Passthrough

## Overview

This document provides a reference for passing a physical PCI device from a Proxmox VE host directly to a virtual machine using VFIO and IOMMU.

The example uses an Intel HD Graphics 530 integrated GPU, but the same underlying concepts apply to other PCI devices such as:

- Dedicated GPUs
- Network interface cards
- Storage controllers and HBAs
- USB controllers
- Other supported PCIe devices

Most of the VM-side PCI passthrough configuration can also be performed through the Proxmox web interface. The CLI was intentionally used during this deployment to better understand and validate the underlying PCI, IOMMU, driver, and VFIO processes rather than relying entirely on the GUI.

A primary goal was to keep changes to the Proxmox host as minimal as possible.

Blacklisting the host's `i915` graphics driver was considered as a fallback if the integrated GPU could not be reliably released for passthrough. Testing showed that this was unnecessary. When the VM was started, the GPU was successfully assigned through VFIO and became available to the guest.

Because passthrough worked without globally blacklisting `i915`, no driver blacklist was added to the Proxmox host. This kept the host closer to its original configuration and avoided making an unnecessary system-wide change.


## Passthrough Architecture

```text
Physical PCI Device
        |
        v
Proxmox Host
        |
        | IOMMU / VFIO
        v
Virtual Machine
        |
        v
Guest Driver
        |
        v
Guest Application
```

For the Intel GPU used during testing:

```text
Intel HD Graphics 530
        |
        v
Proxmox
        |
        | vfio-pci
        v
PCI Passthrough
        |
        v
Debian VM
        |
        | i915
        v
Guest Applications
```


## Example Environment

### Proxmox Host

```text
CPU: Intel Core i7-6700T
GPU: Intel HD Graphics 530
GPU PCI Address: 00:02.0
GPU PCI ID: 8086:1912
```

### Virtual Machine

```text
VM ID: <VMID>
OS: Debian
Machine: q35
BIOS: OVMF
CPU Type: host
```

> [!Important]
> PCI addresses, device IDs, IOMMU groups, VM IDs, and driver requirements vary between systems.
>
> Always discover and verify the values on the current host rather than copying the example values from this document.


## 1. Identify the PCI Device

List graphics devices:

```bash
lspci | grep -Ei 'vga|display'
```

For other PCI devices:

```bash
lspci
```

Example GPU:

```text
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530
```

Display detailed information:

```bash
lspci -nnk -s 00:02.0
```

Example before passthrough:

```text
00:02.0 VGA compatible controller [0300]: Intel Corporation HD Graphics 530 [8086:1912]
    Subsystem: <SYSTEM-VENDOR> Device
    Kernel driver in use: i915
    Kernel modules: i915
```

This identifies:

```text
PCI Address: 00:02.0
PCI ID: 8086:1912
Current Driver: i915
```

At this point, the Proxmox host owns the device.


## 2. Verify IOMMU

PCI passthrough requires IOMMU support.

For an Intel system:

```bash
sudo dmesg | grep -e DMAR -e IOMMU
```

Example:

```text
DMAR: Intel(R) Virtualization Technology for Directed I/O
```

The tested system also reported:

```text
[drm] VT-d active for gfx access
```

This confirmed that Intel VT-d was active for the integrated graphics device.


## 3. Verify IOMMU Groups

List IOMMU groups:

```bash
find /sys/kernel/iommu_groups/ -type l | sort
```

Locate a specific PCI device:

```bash
find /sys/kernel/iommu_groups/ -type l | grep '0000:00:02.0'
```

Example:

```text
/sys/kernel/iommu_groups/<GROUP>/devices/0000:00:02.0
```

Review all devices belonging to the same group.

The Intel GPU used during testing was isolated in its own IOMMU group, allowing it to be passed through without assigning unrelated PCI devices to the VM.

Devices sharing an IOMMU group should be evaluated together before passthrough.


## 4. Review the Kernel Command Line

Check the active kernel command line:

```bash
cat /proc/cmdline
```

Some passthrough guides immediately recommend adding parameters such as:

```text
intel_iommu=on
```

Do not add kernel parameters simply because they appear in a generic passthrough guide.

First determine whether IOMMU is already active.

During this deployment:

```text
IOMMU groups: Present
DMAR: Active
VT-d: Active
PCI passthrough: Functional
```

No additional IOMMU kernel parameter was required.

This avoided making an unnecessary boot configuration change to the Proxmox host.


## 5. Load VFIO Modules

VFIO provides the framework used to assign physical PCI devices to virtual machines.

Create:

```bash
sudo nano /etc/modules-load.d/vfio.conf
```

Add:

```text
vfio
vfio_iommu_type1
vfio_pci
```

Load the modules:

```bash
sudo modprobe vfio
sudo modprobe vfio_iommu_type1
sudo modprobe vfio_pci
```

Verify:

```bash
lsmod | grep vfio
```

Expected modules include:

```text
vfio
vfio_pci
vfio_iommu_type1
```


## 6. Review the Target VM

Shut down the VM before adding the physical device:

```bash
sudo qm shutdown <VMID>
```

Verify:

```bash
sudo qm status <VMID>
```

Expected:

```text
status: stopped
```

Review its configuration:

```bash
sudo qm config <VMID>
```

The tested VM uses:

```text
bios: ovmf
cpu: host
machine: q35
ostype: l26
```

Q35 provides a modern PCIe-oriented virtual chipset and OVMF provides UEFI firmware for the VM.


## 7. Add the PCI Device

Add the physical device to the VM:

```bash
sudo qm set <VMID> -hostpci0 00:02.0,pcie=1
```

Verify:

```bash
sudo qm config <VMID>
```

Expected:

```text
hostpci0: 0000:00:02.0,pcie=1
```

The same device assignment can also be configured through the Proxmox web interface.

Using the CLI makes the resulting VM configuration and PCI mapping explicit.


## 8. Verify VFIO Ownership

Check the physical device:

```bash
lspci -nnk -s 00:02.0
```

For the tested GPU, successful VFIO ownership appeared as:

```text
00:02.0 VGA compatible controller [0300]: Intel Corporation HD Graphics 530 [8086:1912]
    Subsystem: <SYSTEM-VENDOR> Device
    Kernel driver in use: vfio-pci
    Kernel modules: i915
```

The important line is:

```text
Kernel driver in use: vfio-pci
```

The following line has a different meaning:

```text
Kernel modules: i915
```

It identifies a kernel module capable of supporting the hardware. It does not mean that `i915` currently owns the device.


## 9. Test Passthrough Before Blacklisting Drivers

Before making additional changes to the Proxmox host, test whether the existing configuration can successfully pass the device to the VM.

The approach used during this deployment was:

```text
Verify IOMMU
      |
      v
Verify IOMMU Group
      |
      v
Load VFIO
      |
      v
Assign PCI Device
      |
      v
Start VM
      |
      v
Validate Passthrough
```

The host graphics driver was intentionally **not blacklisted first**.

Blacklisting `i915` was reserved as a fallback if the host refused to release the integrated GPU or passthrough proved unreliable.

This follows a simple principle:

> Make only the host changes that are actually required.


## 10. Start the VM

Start the VM:

```bash
sudo qm start <VMID>
```

Intel integrated graphics passthrough may produce an informational message similar to:

```text
kvm: -device vfio-pci,...: info: OpRegion detected on Intel display 1912.
```

This message alone does not indicate a failure.

Verify the VM started:

```bash
sudo qm status <VMID>
```

Expected:

```text
status: running
```


## 11. Validate Passthrough

Verify the device on the Proxmox host:

```bash
lspci -nnk -s 00:02.0
```

The tested deployment showed:

```text
Kernel driver in use: vfio-pci
```

Then verify the physical device from inside the guest.

For a Linux guest:

```bash
lspci -nnk
```

The Intel GPU used during testing appeared inside the Debian VM and was claimed by the guest's `i915` driver.

This demonstrated the intended ownership path:

```text
Physical GPU
      |
      v
Proxmox
  vfio-pci
      |
      v
PCI Passthrough
      |
      v
Guest VM
  i915
```

VFIO does not provide graphics acceleration itself. Its role is to securely expose the physical PCI device to the VM.

The guest operating system then loads the appropriate native driver.


## Why the Host Driver Was Not Blacklisted

Blacklisting the host driver is commonly recommended in PCI/GPU passthrough guides because it prevents the host from claiming a device during boot.

It was intentionally treated as a fallback rather than a prerequisite during this deployment.

Testing showed that:

```text
[x] IOMMU was active
[x] GPU was isolated
[x] VFIO could claim the GPU
[x] VM started successfully
[x] GPU appeared inside the guest
[x] Guest driver successfully initialized the GPU
```

There was therefore no reason to globally blacklist `i915`.

Avoiding the blacklist kept the Proxmox host closer to its default configuration and reduced the number of host-level modifications required for the project.

> [!Note]
> Other hardware may behave differently. If a device cannot be reliably released by the host, persistent VFIO binding, driver blacklisting, kernel parameters, or other device-specific configuration may be required.


## Driver Ownership

Understanding driver ownership is useful when troubleshooting PCI passthrough.

### Before Passthrough

```text
Physical GPU
     |
     v
Proxmox
     |
    i915
```

### Prepared for Passthrough

```text
Physical GPU
     |
     v
Proxmox
     |
  vfio-pci
```

### Passed Through to Guest

```text
Physical GPU
     |
     v
Proxmox / VFIO
     |
     v
Virtual Machine
     |
     v
Guest Driver
```

The physical device has not been duplicated. Ownership has moved from the host's normal device driver to VFIO so the VM can directly control the hardware.


## Validation Checklist

```text
[ ] Hardware virtualization support enabled
[ ] IOMMU active
[ ] IOMMU groups present
[ ] PCI address identified
[ ] PCI device ID identified
[ ] IOMMU group reviewed
[ ] VFIO modules loaded
[ ] Target VM stopped
[ ] VM configuration reviewed
[ ] PCI device added to VM
[ ] Device available through vfio-pci
[ ] VM starts successfully
[ ] Physical device detected inside guest
[ ] Guest driver initializes device
```


## Troubleshooting

### Device Remains Owned by Host Driver

Check:

```bash
lspci -nnk -s <PCI-ADDRESS>
```

If the host driver remains active when the device needs to be available for passthrough, investigate VFIO binding first.

If the device cannot be reliably released, persistent VFIO binding or blacklisting the host driver may be required.


### IOMMU Groups Are Missing

Check:

```bash
sudo dmesg | grep -e DMAR -e IOMMU
cat /proc/cmdline
```

Verify that hardware virtualization and IOMMU support are enabled in system firmware.

Only modify kernel parameters if the required functionality is not already active.


### VM Does Not Start

Verify:

```bash
lspci -nnk -s <PCI-ADDRESS>
sudo qm config <VMID>
```

Check that:

- The PCI address is correct.
- The device is not assigned to another VM.
- The IOMMU group is appropriate.
- The VM configuration supports the intended device.
- VFIO is available.


### Device Missing Inside Guest

Confirm the VM is running:

```bash
sudo qm status <VMID>
```

Verify the Proxmox configuration:

```bash
sudo qm config <VMID>
```

Confirm:

```text
hostpci0: <PCI-ADDRESS>,pcie=1
```

Then inspect PCI devices from inside the guest.

For Linux:

```bash
lspci -nnk
```

If the physical device appears but is not functioning, troubleshooting should continue at the guest operating system and driver layer rather than the Proxmox passthrough layer.


## Related Documentation

- Jellyfin Hardware Acceleration and GPU Passthrough
- Debian GPU Hardware Acceleration
- Proxmox Virtual Machine Configuration
- Proxmox Networking
