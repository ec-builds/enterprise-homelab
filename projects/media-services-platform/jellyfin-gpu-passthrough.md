# Jellyfin Hardware Acceleration and GPU Passthrough

## Overview

Configure Intel Quick Sync hardware acceleration for Jellyfin by passing the Intel integrated GPU from the Proxmox host to the Jellyfin media server virtual machine.

## Architecture

```text id="qnp0xz"
Intel Integrated GPU
        |
        v
prox-lab-03
        |
        | PCI Passthrough
        v
media-lab-vm
        |
        v
Docker
        |
        v
Jellyfin
        |
        v
Intel Quick Sync
```

## Environment

### Proxmox Host

```text id="jqldsh"
Hostname: prox-lab-03
CPU: Intel Core i7-6700T
GPU: Intel HD Graphics 530
GPU PCI Address: 00:02.0
GPU PCI ID: 8086:1912
```

### Jellyfin VM

```text id="j0u5um"
VM ID: <VMID>
Hostname: media-lab-vm
OS: Debian
vCPU: 2
RAM: 4 GB
Machine: q35
BIOS: OVMF
```

Jellyfin runs in Docker inside `media-lab-vm`.

---

# Validation Completed

## Verify Host CPU

```bash id="4ymh41"
lscpu
```

Confirmed:

```text id="pm0nyv"
Intel Core i7-6700T
```

## Identify Intel GPU

```bash id="nh7osz"
lspci | grep -Ei 'vga|display'
```

Result:

```text id="kmlz9i"
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530
```

## Verify DRM Devices

```bash id="k9zmkp"
ls -l /dev/dri
```

Confirmed:

```text id="g69a34"
/dev/dri/card0
/dev/dri/renderD128
```

The GPU is currently available to the Proxmox host.

## Identify Jellyfin VM

```bash id="dq52uh"
sudo qm list
```

Identify the VM ID associated with:

```text id="a29i80"
media-lab-vm
```

## Review VM Configuration

```bash id="uhfn3w"
sudo qm config <VMID>
```

Relevant configuration:

```text id="68q7e9"
bios: ovmf
cores: 2
machine: q35
memory: 4096
ostype: l26
```

## Verify IOMMU

```bash id="k9mhfz"
sudo dmesg | grep -e DMAR -e IOMMU
```

Confirmed Intel VT-d/IOMMU is active:

```text id="iwkbhj"
DMAR: Intel(R) Virtualization Technology for Directed I/O
```

## Verify IOMMU Group

```bash id="1b30sn"
find /sys/kernel/iommu_groups/ -type l | sort
```

The Intel integrated GPU was confirmed to be isolated in its own IOMMU group:

```text id="a6aex4"
/sys/kernel/iommu_groups/<GROUP>/devices/0000:00:02.0
```

## Verify Current GPU Driver

```bash id="kv71t6"
lspci -nnk -s 00:02.0
```

Result:

```text id="mm4yx9"
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530
    Kernel driver in use: i915
    Kernel modules: i915
```

The Proxmox host currently owns the GPU through the `i915` driver.

---

# Remaining Steps

## 1. Shut Down media-lab-vm

```bash id="0j77bx"
sudo qm shutdown <VMID>
sudo qm status <VMID>
```

Verify:

```text id="dy0lcf"
status: stopped
```

## 2. Add GPU to VM

```bash id="jwdmy4"
sudo qm set <VMID> -hostpci0 00:02.0,pcie=1
```

Verify:

```bash id="2tl0bx"
sudo qm config <VMID>
```

Expected:

```text id="ef6x7b"
hostpci0: 0000:00:02.0,pcie=1
```

## 3. Configure GPU Ownership

Configure `prox-lab-03` so the Intel integrated GPU can be assigned to `media-lab-vm` instead of being owned by the host `i915` driver.

Verify the GPU is available for passthrough before starting the VM.

## 4. Start media-lab-vm

```bash id="73p3ft"
sudo qm start <VMID>
```

## 5. Verify GPU Inside media-lab-vm

Connect to the media server:

```bash id="bajbr8"
ssh <admin-user>@media-lab-vm
```

Verify:

```bash id="i84kcx"
lspci | grep -Ei 'vga|display'
ls -l /dev/dri
```

Confirm the Intel GPU and render device are available.

## 6. Pass GPU to Jellyfin Docker Container

Expose the GPU device to the Jellyfin container:

```text id="g4qphb"
/dev/dri
```

Restart or redeploy the container.

## 7. Enable Jellyfin Hardware Acceleration

In Jellyfin:

```text id="mbs5dp"
Dashboard
→ Playback
→ Transcoding
→ Hardware acceleration
```

Configure Intel Quick Sync hardware acceleration.

## 8. Test Hardware Transcoding

Play media that requires transcoding.

Verify Jellyfin reports hardware-accelerated transcoding and confirm CPU utilization is significantly reduced.

---

# Current Status

```text id="3iyhl4"
[x] Intel integrated GPU detected
[x] /dev/dri/renderD128 available on prox-lab-03
[x] Intel VT-d/IOMMU enabled
[x] GPU isolated in its own IOMMU group
[x] media-lab-vm configuration verified
[x] Current i915 ownership identified

[ ] Shut down media-lab-vm
[ ] Add PCI passthrough
[ ] Configure GPU ownership
[ ] Verify GPU inside media-lab-vm
[ ] Pass /dev/dri to Docker
[ ] Enable Intel Quick Sync in Jellyfin
[ ] Test hardware transcoding
```
