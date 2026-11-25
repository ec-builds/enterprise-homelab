# Point-in-Time Restore Runbook

**Status: ⚪ Planned**  
**Targets:** see [DR Overview](../dr-overview.md#recovery-targets)

## Scenario

A system is running but its data is wrong: a bad change, an update that broke a service, corruption, or ransomware. The fix is to restore to a point before the problem started.

## First Steps

1. Work out when the problem started from logs, monitoring and change history.
2. For suspected ransomware, isolate affected systems from the network first, and don't restore onto them until the cause is understood.
3. Choose a backup or snapshot from before that time.

## Restore Options

| What | From | How |
|---|---|---|
| Whole VM | PBS | Restore the chosen backup, to a new VM ID first if possible, then swap |
| Files inside a VM | PBS | File restore from the chosen backup |
| NAS data | Backup server ZFS snapshots | Roll back or copy out the `nas` dataset from a snapshot |
| Docker service config | Git | Check out the last known good commit and redeploy |

Restoring to a new VM ID keeps the broken VM available for comparison until the restore is confirmed.

## Validation

- [ ] Restored system works and the original problem is gone
- [ ] Data changed since the restore point identified and recreated where needed
- [ ] Broken copy removed only after the restore is confirmed
- [ ] Time to recover recorded in the [DR Test Log](../dr-test-log.md)
