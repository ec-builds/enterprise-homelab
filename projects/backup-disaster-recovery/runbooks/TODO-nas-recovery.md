# NAS Recovery Runbook

**Status: ⚪ Planned**  
**Targets:** see [DR Overview](../dr-overview.md#recovery-targets)

## Scenario

`nas-lab` holds the media library, shared data and the weekly VM backups. Two cases: a drive fails with the NAS still running, or the NAS or its data is lost.

## Drive Failure

1. Confirm the failed drive in DSM Storage Manager. The storage pool should show degraded, with data still available.
2. Check that the most recent backup to the backup server succeeded before touching anything.
3. Replace the drive and let DSM repair the pool. Avoid heavy load during the rebuild.
4. Confirm the pool returns to healthy.

## NAS or Data Lost

1. Recover or replace the NAS hardware and set up DSM.
2. Restore data from the backup server's `nas` dataset with Hyper Backup, newest version first.
3. If the backup server copy is also lost or untrustworthy, restore from the offsite copy (see [Full Rebuild](./TODO-full-rebuild.md)).
4. If ransomware or deletion is suspected, restore from a ZFS snapshot taken before the problem started (see [Point-in-Time Restore](./TODO-point-in-time-restore.md)).
5. Recreate shares and permissions, then reconnect the Proxmox NAS storage and VM mounts.
6. Restore lower-priority data such as media last, or rebuild it.

## Validation

- [ ] Shares mount on the Proxmox nodes and VMs
- [ ] Spot-check restored files against the source
- [ ] Next NAS backup job runs successfully
- [ ] Time to recover recorded in the [DR Test Log](../dr-test-log.md)
