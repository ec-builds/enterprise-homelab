# UPS Power Protection Plan

**Status: 🟡 In Progress**  
**Type:** Implementation plan  
**Lab:** Backup & Disaster Recovery

## Overview

The lab runs on one CyberPower CP1500PFCLCD UPS, which can signal only one machine over USB. This plan moves that USB connection to `monitor-lab-02` and runs Network UPS Tools (NUT) there, so every protected system shuts down cleanly and in order during an outage, then comes back on its own when power returns.

## Planned Work

1. Remove the UPS USB passthrough from `win11-lab-01` on `prox-lab-01`, move the cable to `monitor-lab-02`, and install the NUT server.
2. Measure the real load and battery runtime, then set the commit timer from those numbers.
3. Install NUT clients on the three Proxmox nodes and configure the Synology as a NUT client.
4. Set guest shutdown behavior and start order on the Proxmox nodes.
5. Enable automatic power-on after power loss on every machine.
6. Configure the commit timer, forced shutdown and UPS outlet power-cycling for recovery.
7. Send power events to Discord.
8. Test a real outage, including power returning partway through the shutdown.

## Progress

| Step | State |
|---|---|
| NUT server on `monitor-lab-02` | 🟢 Running. The driver reads the UPS, and `upsc` reports status, load and runtime |
| Measured load and runtime | About 15% load (about 150 W of 1,000 W) with about 53 minutes of runtime at full charge (Nov 2026) |
| Shutdown behavior | Live, not yet tested: after 5 minutes on battery, every system shuts down and the UPS power-cycles its outlets |
| Firewall | 🟢 Port `3493/TCP` limited to the Proxmox nodes and the NAS |
| Discord alerts | 🟢 Tested: unplugging the UPS sent `ONBATT` within seconds, and plugging it back in sent `ONLINE` |
| Battery | Charge reading dropped to about 76% during the alert test, which is steep for a two-month-old battery. The reading is voltage-based, so a timed runtime check and the UPS quick test are planned at full charge |
| Clients | 🟢 `prox-lab-01`, `prox-lab-02`, `prox-lab-03` and the Synology connected to the NUT server and reading the UPS |
| Commit timer, forced shutdown, outlet power-cycle | 🟡 Configured, not yet tested: 5-minute timer on `monitor-lab-02`, and the UPS accepted the outlet delays (off 240 s after the command, back on 300 s after power returns) |
| Power-on after an outage | 🟢 VMs set to start at boot, Proxmox BIOS restore-on-AC-power-loss set, DSM auto restart on, and `monitor-lab-02` auto power-on set and tested (see [Mac Mini Auto Power-On Under Linux](../../docs/reference/mac/mac-linux-auto-power-on.md)) |

Setup steps: [NUT Server Installation](../../docs/reference/nut/nut-server-installation.md).

### Resume Here

- [x] Step 3 on `monitor-lab-02`: commit timer (`upssched`, 5 min), forced shutdown, UPS outlet delays (240/300), check `nutshutdown` hook
- [x] Power-on after an outage: VMs `onboot`, Proxmox BIOS, DSM, `monitor-lab-02` auto power-on
- [x] Step 4: NUT clients on `prox-lab-01`–`03` and the Synology
- [ ] Test 2: cancel test (unplug about 3 min, nothing shuts down)
- [ ] Test 3: full sequence with a 2-minute timer, all systems down, outlets cycle, all systems back
- [ ] Battery check at full charge: timed runtime check and quick battery test
- [x] Write `nut-shutdown-and-testing.md` and `nut-client-setup.md` (test results added as tests are run)

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

The NUT server makes every decision; clients run no timers of their own.

| Step | Trigger | What happens |
|---|---|---|
| 1 | Power lost | `monitor-lab-02` sends a Discord alert and starts a 5-minute commit timer |
| 2 | Power back within 5 minutes | Timer cancelled, Discord alert, nothing shuts down |
| 3 | Still on battery at 5 minutes | `monitor-lab-02` forces a shutdown: the Proxmox nodes (their VMs first) and the NAS shut down together |
| 4 | Last | `monitor-lab-02` shuts down and tells the UPS to cut its outlets 240 seconds later |
| 5 | Power returns | After 300 seconds the UPS restores its outlets, and every machine powers on |

The Proxmox nodes shut down as a group. Shutting them down one at a time leaves the last node without quorum, so it can't start or change VMs, and the VMs also depend on NAS storage.

Details and commands: [NUT Shutdown Sequence and Testing](../../docs/reference/nut/nut-shutdown-and-testing.md).

### Recovery

- **Outage outlasts the sequence.** The UPS power-cycles its outlets, so every machine boots when power returns.
- **Power returns mid-sequence.** Once the forced shutdown has started, it finishes, and the outlet power-cycle still restarts everything. No machine is left off, so Wake-on-LAN isn't needed.
- **Start order.** Proxmox start-at-boot order brings the domain controllers up first, then the Docker host, monitoring and media VMs.

## Dependencies / Decisions

- **Battery outlets.** Every protected machine, the switch and the router must be on the UPS's battery-backed outlets, not the surge-only ones.
- **Power-on after AC loss.** Enable it in the BIOS of each Proxmox node, enable "restart automatically when power supply issue is fixed" in DSM, and set the equivalent on the Mac mini.
- **Clean guest shutdown.** VMs need ACPI or the QEMU guest agent, and a guest shutdown timeout long enough for the domain controllers to stop cleanly.
- **Synology client login.** DSM uses a fixed NUT username and password, so the NUT server must accept it. Access is limited to the lab's own hosts.
- **Credentials.** NUT passwords and the Discord webhook are stored outside the repository.
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
- `upssched` on the NUT server handles the commit timer. Clients only react to the server's forced shutdown or to low battery.
- NUT event notifications go to Discord through the secondary monitoring webhook on `monitor-lab-02`.
