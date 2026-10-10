# Proxmox Node Upgrades & Maintenance

This document records the testing performed while upgrading Proxmox nodes in the homelab cluster.

## Objective

The goal was to upgrade nodes without unnecessarily disrupting workloads while validating VM migration, backup, recovery, and post-upgrade stability.

Nodes were upgraded individually rather than simultaneously so that other cluster nodes remained available for workloads and recovery.

## Upgrade Process

The general process used for each node was:

1. Verify the node and hosted VMs were operating normally.
2. Create known-good backups of important VMs.
3. Migrate workloads to another Proxmox node.
4. Perform firmware and Proxmox updates requiring downtime or reboot.
5. Verify the upgraded node and cluster connectivity.
6. Migrate workloads back to their original host.
7. Test VMs and application services.
8. Monitor the upgraded node before upgrading another node.

For VMs being shut down before migration, the workflow was:

    VM shutdown
        ↓
    Full Proxmox VM backup
        ↓
    Migrate VM
        ↓
    Upgrade node
        ↓
    Validate node
        ↓
    Migrate VM back
        ↓
    Validate VM and services

The offline backup created immediately before migration provided a known-good recovery point independent of the migrated VM.

## Migration Testing

Both offline and live VM migration were tested.

### Offline Migration

VMs where downtime was acceptable were shut down before migration. A full backup was created while the VM was offline before moving it to another node.

This provided both a clean migration state and a known-good backup immediately before maintenance.

### Live Migration

Live migration was tested successfully and worked well for evacuating running workloads while minimizing downtime.

During testing, Proxmox reported:

    conntrack state migration not supported or disabled,
    active connections might get dropped

The VM remained running during migration, but existing network sessions could potentially be interrupted because connection-tracking state was not migrated.

This behavior was acceptable for the workloads tested in the lab.

## Post-Upgrade Validation

After each node upgrade and reboot, the node was validated before workloads were returned.

Proxmox, kernel, cluster, and storage status were checked with:

    pveversion -v
    uname -r
    pvecm status
    pvesm status

Additional testing verified:

- Cluster connectivity
- Network connectivity
- Local and shared storage
- Proxmox web interface
- VM migration capability
- Hardware passthrough where applicable

VMs were then migrated back to the upgraded node.

After migration, VM boot, networking, QEMU Guest Agent communication, application services, storage, and hardware passthrough where applicable were tested.

If problems appeared, workloads could be migrated to another known-good node again while troubleshooting was performed. The pre-upgrade offline backups also remained available as a recovery option.

## Staged Rollout

Nodes are intentionally upgraded one at a time.

The process follows:

    Upgrade one node
        ↓
    Validate node
        ↓
    Return workloads
        ↓
    Test normal operation
        ↓
    Monitor for approximately one week
        ↓
    Upgrade next node

The observation period is intentional.

A successful reboot does not necessarily prove that every workload, driver, storage configuration, migration path, or passthrough device will remain stable during normal operation.

Waiting approximately one week between node upgrades allows the upgraded node to run normal workloads before the same changes are introduced across additional cluster nodes.

## Results

| Test | Result |
|---|---|
| Offline VM migration | Successful |
| Live VM migration | Successful |
| Known-good offline VM backups | Successful |
| Node upgrade and reboot | Successful |
| Cluster and storage connectivity | Successful |
| Migration back to upgraded node | Successful |
| VM networking and guest services | Successful |
| Application services | Successful |
| Hardware passthrough testing | Successful where applicable |

No significant VM issues were observed following the completed upgrades.

