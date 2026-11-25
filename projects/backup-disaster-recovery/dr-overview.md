# Disaster Recovery Overview

**Status: ⚪ Planned**

How the lab recovers from failures: recovery targets, the order systems come back in, how to get in when the usual path is down, and how each scenario is tested. Step-by-step procedures are in the [runbooks](#runbooks).

## Recovery Targets

Targets are set before testing and compared with the results in the [DR Test Log](./dr-test-log.md).

| System | RTO (back within) | RPO (data loss at most) |
|---|---|---|
| Domain controllers (`dc-lab-01`, `dc-lab-02`) | 1 hour | 24 hours |
| NAS shares (`nas-lab`) | 4 hours | 24 hours |
| Docker host (`docker-lab-01`) | 4 hours | 24 hours |
| Monitoring (`monitor-lab-01`) | 4 hours | 24 hours |
| Media (`media-lab-01`) | 24 hours | Best effort (rebuildable) |
| Full rebuild from offsite | 3 days | 7 days |

RPO follows the backup schedule: nightly PBS backups for VMs, weekly vzdump to the NAS, and an offsite copy of critical VMs only.

## Recovery Order

Systems come back in dependency order. Each step is checked before starting the next.

| Order | System | Depends on |
|---|---|---|
| 1 | ASUS router, Cisco switch | Power |
| 2 | `nas-lab` | Network |
| 3 | `prox-lab-01`, `prox-lab-02`, `prox-lab-03` | Network, NAS storage |
| 4 | `dc-lab-01`, `dc-lab-02` | Proxmox |
| 5 | `docker-lab-01`, `monitor-lab-01` | DNS and DHCP from the DCs, NAS |
| 6 | `media-lab-01` and remaining VMs | NAS media share |

Proxmox start-at-boot order is set to follow steps 4 to 6, so a full power-on recovers without manual steps.

## Access During an Outage

| Path | Use |
|---|---|
| ASUS WireGuard | Primary remote access |
| `monitor-lab-02` WireGuard | Interim second path, outside the Proxmox cluster |
| Proxmox web UI or node console | VM restores and node recovery |
| Physical console | When the network itself is down |

Credentials and recovery keys are stored outside the repository and must be reachable without the lab running.

Real values for the placeholders in these runbooks are kept in a private values sheet stored outside the lab.

## Runbooks

| Runbook | Scenario | Status |
|---|---|---|
| [Power Outage](./runbooks/TODO-power-outage.md) | Utility power lost | ⚪ |
| [Proxmox Node Failure](./runbooks/TODO-node-failure.md) | One node down for good | ⚪ |
| [Domain Controller Recovery](./runbooks/TODO-domain-controller-recovery.md) | One or both DCs lost | ⚪ |
| [NAS Recovery](./runbooks/TODO-nas-recovery.md) | Drive failure or NAS loss | ⚪ |
| [Point-in-Time Restore](./runbooks/TODO-point-in-time-restore.md) | Bad change, corruption or ransomware | ⚪ |
| [Full Rebuild](./runbooks/TODO-full-rebuild.md) | Site loss, rebuild from offsite | ⚪ |

## Testing

- A runbook stays ⚪ until it has been run end to end at least once.
- Each test is logged with its date, time to recover and what went wrong, and the runbook is updated from the results.
- Restore tests use isolated copies where possible, so production systems aren't overwritten.
