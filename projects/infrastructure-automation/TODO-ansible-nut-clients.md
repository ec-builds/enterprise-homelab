# Ansible NUT Client Deployment

**Status: ⚪ Planned**  
**Type:** Implementation plan  
**Lab:** Infrastructure Automation

## Overview

The first real Ansible project in the lab: install and configure the Network UPS Tools (NUT) client on the three Proxmox nodes, so they shut down cleanly during a power outage. It's a small, repeatable task on identical hosts, and it puts the [UPS Power Protection Plan](../backup-disaster-recovery/TODO-ups-power-protection-plan.md) into practice.

## Planned Work

1. Set up Ansible on the admin workstation with an inventory for `prox-lab-01`, `prox-lab-02` and `prox-lab-03`.
2. Store the NUT client password in Ansible Vault.
3. Write a `nut_client` role: install `nut-client`, template the NUT config files, set the shutdown timer and enable the service.
4. Run it in check mode first, then on one node, then on all three.
5. Confirm a second run reports no changes.
6. Test the shutdown timer with a simulated on-battery event.

## Target Configuration

```text
Admin workstation (Ansible)
        │ SSH
        ├──► prox-lab-01 ─┐
        ├──► prox-lab-02 ─┼── nut-client ──► NUT server on monitor-lab-02
        └──► prox-lab-03 ─┘
```

| Setting | Value |
|---|---|
| Hosts | `prox-lab-01`, `prox-lab-02`, `prox-lab-03` (inventory group `proxmox`) |
| NUT server | `monitor-lab-02`, UPS name `ups` |
| NUT user | `upsmon_remote`, role `secondary` |
| Shutdown | After a set time on battery, all three nodes together |
| Secrets | Ansible Vault |

Steps and examples: [Ansible NUT Client Deployment reference](../../docs/reference/ansible/ansible-nut-client-deployment.md).

## Dependencies / Decisions

- The NUT server on `monitor-lab-02` is running and reachable on `3493/TCP` from the nodes.
- Ansible connects with the admin account and its SSH key, using `become` for root tasks.
- The shutdown delay is set from measured UPS runtime. The starting value is a placeholder.
- The backup server joins the same role as a new inventory host once it's deployed.

## Validation / Completion Criteria

- [ ] Check mode shows the expected changes and nothing else
- [ ] `upsc ups@monitor-lab-02` works from all three nodes
- [ ] `nut-monitor` is active and enabled on all three nodes
- [ ] A second run reports `changed=0`
- [ ] Simulated on-battery event shuts the nodes down after the delay, and cancelling it works
- [ ] Vault file is encrypted in the repo

## Rollback / Recovery

Stop and disable `nut-monitor` on the nodes, or remove `nut-client`. The nodes keep running; they just won't shut down automatically.
