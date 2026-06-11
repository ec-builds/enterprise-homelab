# 💾 Backup & Disaster Recovery

**Status: 📋 Planned**

Designing, implementing, and **testing** data protection for the entire lab — *a backup that hasn't been restored is not a backup*.

## Objectives

- Implement the **3-2-1 rule** (3 copies, 2 media types, 1 offsite)
- Protect all critical workloads: Proxmox VMs, container volumes, configs, personal data
- Define and measure RPO and RTO per workload tier
- Perform and document regular restore tests
- Write a disaster recovery runbook anyone could follow

## Technologies

- Proxmox Backup Server (VM-level backups with deduplication)
- restic or BorgBackup (file-level and container volumes)
- Offsite target (Backblaze B2 or S3-compatible storage, encrypted)
- Network device config backups

## Key Tasks

- [ ] Inventory and classify workloads by criticality
- [ ] Define backup schedules and retention per tier
- [ ] Deploy Proxmox Backup Server; schedule VM backups with verification
- [ ] Back up Docker volumes and service configs
- [ ] Configure encrypted offsite replication
- [ ] **Perform a full restore test of a critical VM; document timing and results**
- [ ] Restore a single file from offsite backup as a drill
- [ ] Write the DR runbook (step-by-step recovery from total loss)
- [ ] Alert on backup job failures via [infrastructure-monitoring](../infrastructure-monitoring/)

## Folder Structure

```
backup-disaster-recovery/
├── docs/            # Backup policy, restore test results, DR runbook
├── configs/         # Sanitized job configurations
├── scripts/         # Backup automation scripts
└── screenshots/     # Visual documentation
```
