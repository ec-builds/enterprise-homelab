# Power Outage Runbook

**Status: ⚪ Planned**  
**Targets:** see [DR Overview](../dr-overview.md#recovery-targets)

## Scenario

Utility power is lost. The UPS carries the lab while NUT on `monitor-lab-02` shuts systems down in order, then power-cycles the UPS outlets so everything restarts when power returns. Design: [UPS Power Protection Plan](../TODO-ups-power-protection-plan.md).

## Detection

- Discord alert from `monitor-lab-02`: on battery
- `upsc ups@<nut-server-ip> ups.status` shows `OB` (on battery) or `LB` (low battery)

## During the Outage

No action is needed if the automatic sequence runs. Watch the alerts:

1. On battery: the 5-minute commit timer starts.
2. At 5 minutes: the forced-shutdown alert. Proxmox nodes (VMs first) and the NAS shut down together.
3. `monitor-lab-02` shuts down last and sets the UPS outlet power-cycle.

If the alerts stop before step 3, assume the network or `monitor-lab-02` lost power early, and check every system after recovery.

## After Power Returns

Systems should power on by themselves. Check in [recovery order](../dr-overview.md#recovery-order):

1. Router and switch up; remote access works.
2. NAS up; shares available.
3. All three Proxmox nodes up; cluster quorate (`pvecm status`).
4. DCs up; DNS resolves and DHCP hands out leases.
5. Docker and monitoring hosts up; Uptime Kuma shows all monitors green.
6. Remaining VMs up.
7. Next backup job runs successfully.

If a system stays off, power it on manually, then check its power-on-after-AC-loss setting.

## Power Returns Mid-Sequence

- Within the first 5 minutes: the commit timer is cancelled and nothing shuts down. Confirm the `ONLINE` alert arrived.
- After the forced shutdown started: the sequence finishes and the outlet power-cycle restarts everything. Follow "After Power Returns".

## Validation

- [ ] Systems shut down in the planned order
- [ ] No unclean shutdown events on the DCs or other VMs
- [ ] Every system came back without manual steps
- [ ] Time from power return to all services green recorded in the [DR Test Log](../dr-test-log.md)
