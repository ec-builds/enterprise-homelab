# Proxmox Node Failure Runbook

**Status: ⚪ Planned**  
**Targets:** see [DR Overview](../dr-overview.md#recovery-targets)

## Scenario

One Proxmox node fails and won't come back soon (hardware failure, dead boot drive). The cluster keeps quorum with two of three nodes. HA is disabled and VMs use local storage on each node, so the failed node's VMs don't move by themselves; they're restored from backup onto the surviving nodes.

## Detection

- Uptime Kuma: node and its VMs down
- Proxmox web UI: node shown offline
- `pvecm status` on a surviving node: two of three votes

## Recovery

1. Confirm the node is really down and not just unreachable (console, power, network link).
2. List the VMs that were on it and restore them in [recovery order](../dr-overview.md#recovery-order).
3. Check capacity on the surviving nodes before restoring. Lower-priority VMs can wait.
4. For each VM: restore the latest PBS backup to a surviving node and its local storage, then start it.
   - If PBS is unavailable, restore from the weekly NAS backup instead (older RPO).
   - A domain controller is handled by the [Domain Controller Recovery](./TODO-domain-controller-recovery.md) runbook, not restored here.
5. Update monitoring and any references to the VM's old host.

## Repairing or Replacing the Node

1. Repair the hardware, or reinstall Proxmox from the baseline build.
2. If the node is replaced, remove the old node from the cluster first (`pvecm delnode <node>`) and join the new one.
3. Move VMs back with migration once the node is healthy.

## Validation

- [ ] Restored VMs boot and their services work
- [ ] Cluster quorate with all nodes after repair
- [ ] Time to restore each VM recorded in the [DR Test Log](../dr-test-log.md)
