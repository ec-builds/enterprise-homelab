# Pre-Deployment Proxmox Test Environment

## Overview

Before deploying **Proxmox VE to dedicated bare-metal hardware**, I created a temporary virtualized environment using VMware Workstation on Windows.

The purpose of this environment was to become familiar with the Proxmox installation process, management interface, networking, storage, and administrative workflow before modifying the physical lab infrastructure.

This environment is strictly for **testing and familiarization** and does not represent the final virtualization architecture.

## Test Architecture

![Proxmox Dashboard Test Environment](./diagrams/proxmox-dashboard-test.png)
_Proxmox VE 9.2.2 running in the temporary VMware Workstation test environment._

```text
Physical Hardware
└── Windows Host
    └── VMware Workstation
        └── Proxmox VE
```

The final lab architecture removes the Windows and VMware layers:

```text
Physical Server
└── Proxmox VE
    ├── Infrastructure VMs
    ├── Linux VMs
    └── Lab Workloads
```


## VMware Configuration

| Component | Configuration |
|---|---|
| Hypervisor | VMware Workstation |
| Guest OS | Linux / Debian 64-bit |
| Firmware | UEFI |
| CPU | 1 virtual socket / 4 cores |
| Memory | 8 GB |
| Virtual Disk | 100 GB, single virtual disk file |
| Networking | VMware virtual network |
| Nested virtualization | Tested, later disabled due to instability |
| Installation method | Proxmox VE graphical installer |

The virtual disk was stored as a **single file** because the environment was intended to remain on the local system rather than being frequently moved between hosts.

## Proxmox Installation

Proxmox VE was installed using the graphical installer.

The installation process included:

- Selecting the virtual disk as the installation target.
- Configuring locale, time zone, and keyboard settings.
- Creating the initial `root` administrator password.
- Configuring the management network.
- Assigning an FQDN to the Proxmox host.
- Completing installation and accessing the web management interface.

Proxmox creates the initial administrative account automatically:

```text
Username: root
Realm:    Linux PAM standard authentication
```

The management interface is accessed using:

```text
https://<proxmox-ip>:8006
```

## Hostname and DNS Naming

Proxmox expects a fully qualified domain name (FQDN) during installation.

For private home infrastructure, the reserved `home.arpa` namespace can be used without registering a public domain.

Example:

```text
pve-test.home.arpa
```

A more structured internal namespace could also be used:

```text
pve01.lab.home.arpa
dc01.lab.home.arpa
docker01.lab.home.arpa
```

The final hostname and DNS structure will be established as part of the bare-metal network and infrastructure design.

## VMware Networking

Both VMware NAT and bridged networking were considered during testing.

### NAT

```text
Physical LAN
    │
Windows Host
    │
VMware NAT
    │
Proxmox
```

With NAT, Proxmox receives an IP address from VMware's private virtual network.

This provides outbound connectivity while keeping the test environment separated from the physical LAN.

### Bridged

```text
Physical LAN
├── Windows Host
├── Other Devices
└── Proxmox VM
```

With bridged networking, the Proxmox VM behaves more like an independent device on the physical network and receives an address on the same LAN as other systems.

Bridged networking more closely represents the final bare-metal deployment, while NAT provides a simple isolated environment for initial testing.

## Nested Virtualization Testing

To test KVM virtual machines inside the virtualized Proxmox host, VMware nested virtualization was initially enabled:

```text
VM Settings
→ Processors
→ Virtualize Intel VT-x/EPT or AMD-V/RVI
```

The intended nested architecture was:

```text
Physical CPU
└── VMware Workstation
    └── Proxmox VE
        └── KVM VM
```

This requires VMware to expose the physical CPU's hardware virtualization extensions to the Proxmox guest.

## Windows Hypervisor Conflict

VMware initially reported that nested virtualization was unavailable because **Hyper-V or Device/Credential Guard** was active.

Hyper-V was disabled through Windows Features, but the issue remained.

The Windows hypervisor was also disabled at boot:

```cmd
bcdedit /set hypervisorlaunchtype off
```

After rebooting, `msinfo32` still reported:

```text
Virtualization-based security    Running
```

and indicated that a hypervisor was detected.

This revealed that **Virtualization-Based Security (VBS)** remained active even though the Hyper-V Windows Feature had been disabled.

VBS was disabled through:

```text
Computer Configuration
└── Administrative Templates
    └── System
        └── Device Guard
            └── Turn On Virtualization Based Security
                └── Disabled
```

Memory Integrity and unnecessary Windows virtualization components were also disabled for the test environment.

After rebooting, Windows no longer reported the Microsoft hypervisor as active and VMware was able to expose nested virtualization.

Detailed Windows-specific configuration is documented separately in the Windows virtualization reference documentation.

## Nested KVM Stability Testing

Although VMware successfully exposed VT-x/EPT to Proxmox, enabling nested KVM resulted in repeated CPU watchdog errors:

```text
watchdog: BUG: soft lockup - CPU#2 stuck for 22s! [CPU 0/KVM]
```

The lockups occurred during normal Proxmox activity, including operations such as:

```bash
apt update
```

and eventually caused the Proxmox VM to become unstable and reboot.

To isolate the problem, VMware nested virtualization was disabled:

```text
Virtualize Intel VT-x/EPT or AMD-V/RVI
```

After disabling this option, Proxmox remained stable.

This isolated the problem to the nested:

```text
VMware
    ↓
Proxmox
    ↓
KVM
```

virtualization path rather than the base Proxmox installation.

## Testing Decision

Nested KVM testing was discontinued in this temporary environment.

The stable test architecture therefore became:

```text
Windows
└── VMware Workstation
    └── Proxmox VE
        ├── Web Management
        ├── Networking Configuration
        ├── Storage Configuration
        └── Administrative Testing
```

This remains sufficient for becoming familiar with:

- Proxmox installation and initial configuration.
- Datacenter and node management.
- Web interface navigation.
- Storage configuration.
- Linux bridge networking.
- Repository and update management.
- Users, authentication, and permissions.
- VM and CT configuration concepts.

Full KVM workload testing will be performed after Proxmox is deployed directly to physical hardware.

## Bare-Metal Transition

The final environment will eliminate the nested virtualization layers:

```text
Physical Hardware
        ↓
    Proxmox VE
        ↓
      KVM/QEMU
        ↓
        VMs
```

Hardware virtualization will remain enabled in BIOS/UEFI so Proxmox can directly use Intel VT-x/EPT or AMD-V/RVI.

The nested VMware instability does not demonstrate a problem with hardware virtualization itself; it was observed specifically when virtualization extensions were passed through VMware to a second hypervisor.

## Outcome

The pre-deployment environment successfully provided hands-on experience with Proxmox before committing physical hardware to the platform.

Testing also provided practical experience troubleshooting multiple virtualization layers:

```text
Hardware Virtualization
        ↓
Windows Hypervisor / VBS
        ↓
VMware Workstation
        ↓
Proxmox VE
        ↓
KVM
```

The test identified two important considerations before bare-metal deployment:

1. Windows Hyper-V/VBS can interfere with VMware nested virtualization even when the Hyper-V Windows Feature itself is disabled.
2. Nested VT-x/EPT may introduce stability problems that are specific to the multi-hypervisor test environment.

The temporary environment will therefore be used for **Proxmox platform familiarization**, while VM lifecycle, performance, networking, backup/recovery, and other production-like testing will be validated on the final bare-metal Proxmox host.
