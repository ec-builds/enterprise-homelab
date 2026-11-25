# Full Rebuild Runbook

**Status: ⚪ Planned**  
**Targets:** see [DR Overview](../dr-overview.md#recovery-targets)

## Scenario

The lab and its local backups are gone (fire, theft, flood). Recovery starts from the offsite copy on OneDrive and from configs in Git.

## What's Offsite

| Item | Source |
|---|---|
| Critical VMs: DCs, Docker host, monitoring host, AdGuard | Encrypted Hyper Backup on OneDrive |
| Service configs | GitHub (sanitized) |
| Network device configs | Exported configs |
| Media | Not offsite; rebuilt |

The Hyper Backup encryption key and account credentials are stored outside the lab, or the offsite copy can't be opened.

## Recovery

1. Get replacement hardware: network gear, at least one Proxmox host and storage.
2. Restore the network: router, switch and exported configs.
3. Install Proxmox from the baseline build.
4. Download the offsite backup and restore it with Hyper Backup or Hyper Backup Explorer.
5. Restore VMs in [recovery order](../dr-overview.md#recovery-order), starting with one DC.
6. Rebuild Docker services from Git.
7. Rebuild remaining systems and the backup chain, then take a fresh backup.

## Validation

- [ ] Offsite backup downloads and decrypts
- [ ] Restored DC and Docker services work
- [ ] New backups run on the rebuilt lab
- [ ] Time to recover recorded in the [DR Test Log](../dr-test-log.md)

A full test can use a single spare host: restore one critical VM from the offsite copy and confirm it boots.
