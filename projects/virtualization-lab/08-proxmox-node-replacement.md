# Proxmox Node Replacement

This document records the process used to replace an existing Proxmox node while retaining its hostname and position within the homelab cluster.

The goal is to evacuate workloads, cleanly remove the existing node, install the replacement using the same hostname, rejoin it to the cluster, and validate the node before returning workloads.

## Replacement Strategy

The general node replacement process is:

1. Create known-good backups of important VMs.
2. Migrate VMs and containers to other cluster nodes.
3. Save the existing node configuration for reference.
4. Shut down the old node.
5. Remove the old node from the cluster from another healthy node.
6. Install Proxmox on the replacement system.
7. Configure the replacement with the same hostname and management network settings.
8. Join the replacement node to the existing cluster.
9. Verify or recreate node-local storage and host-specific configuration.
10. Validate the replacement node.
11. Migrate workloads back and test services.

The old and replacement systems should never be online in the cluster simultaneously while using the same hostname or management address.

## Pre-Replacement Preparation

Before removing the existing node, workloads are evacuated to other cluster members.

Important VMs are backed up before migration to provide a known-good recovery point independent of the migration itself.

The existing host configuration is also recorded for reference.

Useful information includes:

    pveversion -v
    pvecm status
    pvesm status
    lsblk
    pvs
    vgs
    lvs
    ip addr
    ip route

Host-specific configuration should also be reviewed, including:

    /etc/network/interfaces

Additional settings such as IOMMU, VFIO, PCIe passthrough, storage controllers, or other hardware-specific configuration should be documented where applicable.

The saved configuration is used as a reference when rebuilding the replacement node rather than being restored wholesale.

## Workload Evacuation

VMs and containers are migrated to other available cluster nodes before the original node is removed.

Both live and offline migration have been successfully tested in the lab.

Where downtime is acceptable, the preferred workflow for important workloads is:

    Shutdown VM
        ↓
    Create known-good backup
        ↓
    Migrate VM
        ↓
    Verify VM on destination node

Live migration can be used when minimizing downtime is preferred.

## Remove the Existing Node

After workloads have been evacuated, the old node is shut down.

The old node must remain offline before its cluster identity, hostname, or management address is reused.

From another healthy cluster node, verify cluster status:

    pvecm status

The old node can then be removed:

    pvecm delnode <node-name>

Cluster status should be checked again to confirm that the removed node is no longer a cluster member.

The old installation should not be brought back onto the cluster network after the replacement begins using the same identity.

## Install the Replacement Node

Proxmox is installed normally on the replacement system.

The replacement is configured with the same intended node identity:

- Same Proxmox hostname
- Same management IP where applicable
- Correct gateway and DNS configuration
- Correct hostname resolution
- Required network bridges

Before joining the cluster, networking and hostname resolution should be verified.

The replacement node should represent a clean Proxmox installation rather than a restored copy of the previous node's cluster configuration.

## Rejoin the Cluster

After the replacement node is configured and network connectivity is confirmed, it is joined to the existing Proxmox cluster as a new member.

The reused hostname represents the node's role in the lab, but the replacement installation establishes a new cluster membership rather than attempting to restore the previous node's cluster state.

The old `/etc/pve` configuration should **not** be copied onto the replacement node.

Cluster configuration should instead be established normally when the replacement joins the existing cluster.

## Restore Node-Local Configuration

Cluster membership does not automatically recreate all host-specific configuration.

Node-local storage should be verified with:

    pvesm status
    lsblk
    pvs
    vgs
    lvs

This is particularly important in the lab because VM storage may reside on node-local NVMe LVM-thin pools.

If the underlying storage already exists, its Linux storage state should be verified before recreating, formatting, or modifying anything.

Other host-specific configuration should also be restored or recreated as needed, including:

- Network bridges
- Local storage definitions
- IOMMU configuration
- VFIO configuration
- PCIe or GPU passthrough
- Monitoring
- Hardware-specific settings

## Replacement Node Validation

Before returning workloads, the replacement node is validated.

Checks include:

    pveversion -v
    uname -r
    pvecm status
    pvesm status

Additional validation includes:

- Cluster membership
- Management network connectivity
- Proxmox web interface
- Local storage availability
- Network bridges
- VM migration capability
- Hardware passthrough where applicable

The replacement node should be confirmed healthy before normal workloads are returned.

## Return Workloads

After validation, VMs and containers can be migrated back to the replacement node.

Each returned workload is tested for:

- VM boot and guest operation
- Network connectivity
- QEMU Guest Agent communication
- Application and infrastructure services
- Storage access
- Hardware passthrough where applicable

If problems appear, workloads can be migrated back to another healthy cluster node while the replacement is investigated.

The known-good backups created before the replacement also remain available as an independent recovery option.

## Old Node Retention

The previous installation can be retained offline temporarily while the replacement node is tested.

This provides a reference for hardware or host-specific configuration if something was missed during documentation.

However, the old installation must not be booted onto the active cluster network while the replacement system is using the same hostname or management address.

Once the replacement has been validated and normal operation is confirmed, the old installation can be repurposed or removed.

