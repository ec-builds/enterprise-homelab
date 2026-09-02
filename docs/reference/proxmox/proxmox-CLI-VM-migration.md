# Proxmox VM Migration via CLI

## Purpose

Migrate a virtual machine between Proxmox cluster nodes when the source and destination use different node-local storage.

This is useful when the Proxmox GUI cannot automatically map local storage during migration.

## Verify VM Configuration

Review the VM configuration from the source node.

```bash
qm config 120
```

Confirm the VM disks and identify their current storage.

Example:

```text
efidisk0: nvme-lab-01:vm-120-disk-0,...
scsi0: nvme-lab-01:vm-120-disk-1,...
```

## Offline Migration

Shut down the VM before performing an offline migration.

```bash
qm migrate <VM_ID> <TARGET_NODE> --targetstorage <TARGET_STORAGE>
```

Example:

```bash
qm migrate 120 prox-lab-02 --targetstorage nvme-lab-02
```

The `--targetstorage` option places local VM disks on the specified storage available to the destination node.

In this example:

```text
prox-lab-01                         prox-lab-02
nvme-lab-01                        nvme-lab-02
    │                                  ▲
    └── VM 120 ───── migration ────────┘
```

## Validation

After migration, verify the VM configuration on the destination node.

```bash
qm config 120
```

Confirm that the disks reference the destination storage.

Example:

```text
efidisk0: nvme-lab-02:vm-120-disk-0,...
scsi0: nvme-lab-02:vm-120-disk-1,...
```

Start the VM and confirm normal operation.

## Notes

- Run the migration command from the source Proxmox node.
- The source and destination nodes must belong to the same Proxmox cluster.
- The destination storage must be configured, enabled, and available to the target node.
- The VM should be powered off for an offline migration.
- Network bridges referenced by the VM must exist on the destination node.
- Migration time depends on VM disk size and network performance.
