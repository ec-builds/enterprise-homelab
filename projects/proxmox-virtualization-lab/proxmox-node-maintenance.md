# 🔧 Proxmox Node Maintenance

## Purpose

Provide a repeatable procedure for applying routine updates and performing planned maintenance on Proxmox VE cluster nodes.

Nodes are maintained individually to preserve availability of services distributed across the cluster.

## Maintenance Schedule

Routine Proxmox and Debian updates are reviewed and applied during a planned monthly maintenance window.

Critical security updates may be applied outside the normal maintenance schedule when required.

Major Proxmox version upgrades are handled separately as planned infrastructure changes.

## Pre-Maintenance

Before updating a node:

- [ ] Review available package updates
- [ ] Review relevant release notes or known issues
- [ ] Verify cluster and quorum health
- [ ] Verify other cluster nodes are operational
- [ ] Verify recent backups
- [ ] Identify workloads running on the target node
- [ ] Confirm critical services remain available from another node where applicable

Check cluster status:

```bash
pvecm status
```

Review available updates:

```bash
apt update
apt list --upgradable
```

## Workload Preparation

Gracefully shut down or migrate workloads as appropriate before rebooting the node.

For planned maintenance, workloads may be shut down through:

**Node → Bulk Actions → Bulk Shutdown**

Verify workloads have stopped before continuing.

> [!NOTE]
> Maintain one Proxmox node at a time. Complete validation of the updated node before beginning maintenance on another cluster node.

## Apply Updates

Update installed packages:

```bash
apt update
apt full-upgrade
```

Review the package changes before confirming the upgrade.

Reboot the node when required:

```bash
reboot
```

## Post-Maintenance Validation

After the node returns, verify:

- [ ] Proxmox management interface is reachable
- [ ] Node has rejoined the cluster
- [ ] Cluster quorum is healthy
- [ ] Storage is available
- [ ] Network bridges are operational
- [ ] Expected VMs can start successfully
- [ ] Guest networking is functional
- [ ] Critical services are reachable
- [ ] Monitoring reports the node and workloads as healthy

Verify cluster status:

```bash
pvecm status
```

Verify storage:

```bash
pvesm status
```

Verify running VMs:

```bash
qm list
```

## Complete Maintenance

After validation:

- [ ] Restore workloads that were stopped or migrated
- [ ] Confirm critical services are operational
- [ ] Record any issues encountered
- [ ] Document significant configuration changes
- [ ] Proceed to the next node only after the current node is healthy

## Related Documentation

- [Proxmox Virtualization Lab](../../projects/virtualization-lab/)
- [Proxmox Networking Reference](../reference/proxmox/proxmox-networking.md)
- [Virtual Machine Deployment Standard](../standards/vm-deployment-standard.md)
