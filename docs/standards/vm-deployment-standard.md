# 🖥️ Virtual Machine Deployment Standard

## Purpose

Establish a consistent baseline for virtual machines deployed within the homelab.

This standard defines the expected configuration and validation requirements for persistent VMs. Platform-specific procedures are maintained separately in the reference and project documentation.

## Standard

Virtual machines should:

- Follow established [naming conventions](./naming-conventions.md).
- Use resources appropriate for the workload rather than maximum available capacity.
- Use approved Proxmox storage and network bridges.
- Install and enable the QEMU Guest Agent when supported.
- Use paravirtualized devices such as VirtIO where supported.
- Use templates when a maintained template exists for the operating system.
- Receive a unique hostname and network identity after cloning.
- Be updated and configured with the appropriate operating system baseline before workload deployment.
- Be validated before being considered operational.
- Have significant configuration or deployment decisions documented.

## Resource Allocation

CPU, memory, and storage should be sized according to workload requirements while preserving capacity for other workloads and host operations.

For resource planning guidance, see:

- [Proxmox Resource Allocation](../reference/proxmox/proxmox-resource-allocation.md)

## Operating System Baselines

Operating system configuration should follow the applicable baseline and deployment references.

### Debian

- [Debian Installation](../reference/debian/debian-install.md)
- [Debian Base System Configuration](../reference/debian/debian-baseline.md)
- [Debian Post-Clone Configuration](../reference/debian/debian-post-clone-config.md)

### Windows

- [Windows 11 VM Template](../reference/proxmox/proxmox-win11-template.md)

## Validation

Before a VM is considered operational, verify:

- VM boots successfully
- Guest agent is functioning
- Network connectivity is available
- Hostname and network identity are unique
- Operating system updates and baseline configuration are complete
- Required services start successfully
- Workload-specific functionality has been tested

## Related Documentation

- [Proxmox Virtualization Lab](../../projects/virtualization-lab/)
- [Proxmox Resource Allocation](../reference/proxmox/proxmox-resource-allocation.md)
- [Naming Conventions](./naming-conventions.md)
