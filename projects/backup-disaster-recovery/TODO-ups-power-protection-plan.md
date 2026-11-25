# UPS Power Protection Plan

**Status: 🟡 In Progress**  
**Type:** Implementation plan  
**Lab:** Backup & Disaster Recovery

## Overview

The lab runs on one CyberPower CP1500PFCLCD UPS, which can signal only one machine over USB. This plan moves that USB connection to `monitor-lab-02` and runs Network UPS Tools (NUT) there, so every protected system shuts down cleanly and in order during an outage, then comes back on its own when power returns.

## Planned Work

1. Remove the UPS USB passthrough from `win11-lab-01` on `prox-lab-01`, move the cable to `monitor-lab-02`, and install the NUT server.
2. Measure the real load and battery runtime, then set the shutdown timers from those numbers.
3. Install NUT clients on the three Proxmox nodes and configure the Synology as a NUT client.
4. Set guest shutdown behavior and start order on the Proxmox nodes.
5. Enable automatic power-on after power loss on every machine.
6. Configure UPS outlet power-cycling and Wake-on-LAN for recovery.
7. Send power events to Discord.
8. Test a real outage, including power returning partway through the shutdown.

## Progress

| Step | State |
|---|---|
| NUT server on `monitor-lab-02` | 🟢 Running. The driver reads the UPS, and `upsc` reports status, load and runtime |
| Measured load and runtime | About 15% load (about 150 W of 1,000 W) with about 53 minutes of runtime at full charge (Nov 2026) |
| Shutdown behavior | Default only: `monitor-lab-02` shuts down when the UPS reports low battery (about 5 minutes left) |
| Firewall | 🟢 Port `3493/TCP` limited to the Proxmox nodes and the NAS |
| Discord alerts | 🟢 Tested: unplugging the UPS sent `ONBATT` within seconds, and plugging it back in sent `ONLINE` |
| Battery | Charge reading dropped to about 76% during the alert test, which is steep for a two-month-old battery. The reading is voltage-based, so a timed runtime check and the UPS quick test are planned at full charge |
| Clients, timers, outlet power-cycle | ⚪ Not started |

Setup steps: [NUT Server Installation](../../docs/reference/nut/nut-server-installation.md).

### Resume Here

- [ ] Step 3 on `monitor-lab-02`: commit timer (`upssched`, 5 min), forced shutdown, UPS outlet delays (240/300), check `nutshutdown` hook
- [ ] Step 4: NUT clients on `prox-lab-01`–`03` and the Synology
- [ ] Test 2: cancel test (unplug about 3 min, nothing shuts down)
- [ ] Test 3: full sequence with a 2-minute timer, all systems down, outlets cycle, all systems back
- [ ] Battery check at full charge: timed runtime check and quick battery test
- [ ] Write `nut-shutdown-and-testing.md` and `nut-client-setup.md` from the results

## Target Configuration

```text
                CyberPower CP1500PFCLCD
                          │ USB
                          ▼
              monitor-lab-02 (NUT server)
                          │ network
      ┌───────────────────┼───────────────────┐
      │                   │                   │
 prox-lab-01..03       nas-lab          Other clients
 (NUT client;          (DSM NUT         (any physical
  VMs shut down         client)          machine added
  with their host)                       later)
```

| Component | Role |
|---|---|
| `monitor-lab-02` | NUT server: USB connection, shutdown timing, UPS power-cycle, alerts |
| `prox-lab-01`, `prox-lab-02`, `prox-lab-03` | NUT clients. Shutting down the host shuts down its VMs, so VMs need no client |
| `nas-lab` | NUT client through DSM's built-in UPS settings |
| Cisco switch, ASUS router | Not NUT-aware. Stay powered until the UPS cuts its outlets |

### Shutdown Sequence

Timers are starting points. Final values are set after measuring runtime under the real load.

| Step | Trigger | What happens |
|---|---|---|
| 1 | Power lost | `monitor-lab-02` sends a Discord alert and starts timers |
| 2 | ~3–5 min on battery | All three Proxmox nodes shut down together, their VMs first |
| 3 | Proxmox nodes down, or low battery | NAS shuts down |
| 4 | Last | `monitor-lab-02` tells the UPS to turn its outlets off after a delay, then shuts itself down |
| 5 | Power returns | UPS turns its outlets back on, and every machine powers on |

The Proxmox nodes shut down as a group. Shutting them down one at a time leaves the last node without quorum, so it can't start or change VMs, and the VMs also depend on NAS storage.

### Recovery

- **Outage outlasts the sequence.** The UPS power-cycles its outlets, so every machine boots when power returns, even if power came back after a machine shut down but before the battery ran out.
- **Power returns mid-sequence.** `monitor-lab-02` cancels the remaining timers and sends Wake-on-LAN to any node that already shut down. Once the final step has started, the sequence finishes and the outlet power-cycle brings everything back.
- **Start order.** Proxmox start-at-boot order brings the domain controllers up first, then the Docker host, monitoring and media VMs.

## Dependencies / Decisions

- **Battery outlets.** Every protected machine, the switch and the router must be on the UPS's battery-backed outlets, not the surge-only ones.
- **Power-on after AC loss.** Enable it in the BIOS of each Proxmox node, enable "restart automatically when power supply issue is fixed" in DSM, and set the equivalent on the Mac mini.
- **Clean guest shutdown.** VMs need ACPI or the QEMU guest agent, and a guest shutdown timeout long enough for the domain controllers to stop cleanly.
- **Synology client login.** DSM uses a fixed NUT username and password, so the NUT server must accept it. Access is limited to the lab's own hosts.
- **Credentials.** NUT passwords, the Discord webhook and MAC addresses for Wake-on-LAN are stored outside the repository.
- **Backup server.** The planned Proxmox Backup Server becomes a NUT client once it's deployed.

## Validation / Completion Criteria

- [ ] `upsc` on `monitor-lab-02` shows UPS status, load and runtime
- [ ] Every client sees the UPS and reports the correct status
- [ ] Discord alerts arrive for power lost, power restored and shutdown started
- [ ] Full test: wall power unplugged, systems shut down in order, outlets power-cycle, everything boots and services recover
- [ ] Partial test: power restored mid-sequence, timers cancel, shut-down nodes wake
- [ ] Domain controllers and other VMs shut down cleanly, with no unclean shutdown events afterwards
- [ ] Results and final timer values recorded

## Rollback / Recovery

Stopping the NUT services leaves every machine running as before. The UPS still provides battery power without NUT, but nothing shuts down automatically. If outlet power-cycling misbehaves, disable it and rely on timed shutdowns plus manual power-on until it's fixed.

## Implementation Notes

- The `usbhid-ups` driver supports this UPS. Its outlet off/on delays need a real test before the sequence is trusted.
- `upssched` handles the timers on the server and clients.
- NUT event notifications go to Discord through the secondary monitoring webhook on `monitor-lab-02`.
