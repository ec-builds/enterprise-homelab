# Proxmox VE Live Migration

Quick reference for live-migrating a running VM between Proxmox VE cluster nodes, including **local storage → local storage** migrations.

## Requirements

Before migrating, verify:

| Requirement | Check |
|---|---|
| Cluster | Both nodes are members of the same Proxmox cluster |
| Resources | Target has sufficient CPU and RAM |
| Storage | Target has enough free storage |
| Networking | Required bridges and VLANs exist on target |
| CPU | VM CPU model is compatible with target host |
| Hardware | VM does not depend on unavailable PCI/USB passthrough devices |

> **Note:** Shared storage is not required. Proxmox can transfer VM disks between the local storage of each node.

## GUI Migration

For a running VM:

1. Select the **VM**.
2. Click **Migrate**.
3. Select the **Target Node**.
4. Select **Online** migration.
5. Choose the appropriate **Target Storage**.
6. Click **Migrate**.

For local storage, Proxmox transfers both the VM's disks and running state:

```text
Source Node                         Target Node
┌─────────────────┐               ┌─────────────────┐
│ Running VM      │ ────────────► │ Running VM      │
│ Local VM Disk   │ ────────────► │ Local VM Disk   │
└─────────────────┘               └─────────────────┘
```

The VM remains running during most of the process, with a brief switchover near completion.

## CLI Migration

Basic online migration:

```bash
qm migrate <VMID> <TARGET-NODE> --online
```

For local disks:

```bash
qm migrate <VMID> <TARGET-NODE> \
  --online \
  --with-local-disks \
  --targetstorage <TARGET-STORAGE>
```

Example:

```bash
qm migrate 100 pve-node02 \
  --online \
  --with-local-disks \
  --targetstorage local-lvm
```

## Important Considerations

### CPU Compatibility

Using:

```text
CPU Type: host
```

can make live migration between different CPU generations more difficult because host-specific CPU features are exposed to the VM.

Use a CPU model compatible with all intended cluster nodes when frequent live migration is required.

### Network Configuration

If the VM uses:

```text
vmbr0
```

the target node should have the corresponding bridge and VLAN configuration.

### Hardware Passthrough

Check for:

- GPU passthrough
- PCI passthrough
- USB passthrough
- Physical disks
- Other host-specific devices

These can prevent or complicate live migration.

## Quick Checks

```bash
# Cluster status
pvecm status

# Available storage
pvesm status

# List VMs
qm list

# VM configuration
qm config <VMID>
```

## Key Takeaway

```text
Shared Storage
VM state ─────────────► Target
Disk remains shared

Local Storage
VM state ─────────────► Target
VM disks ─────────────► Target local storage
```

**Local-to-local live migration works without shared storage**, but it takes longer because the VM's disks must also be transferred across the network.
