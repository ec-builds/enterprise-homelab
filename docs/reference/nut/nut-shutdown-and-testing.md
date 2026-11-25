# NUT Shutdown Sequence and Testing

Reference for how the lab shuts down during a power outage and comes back afterwards, and how each part is tested. The NUT server makes every decision: after a set time on battery it forces all clients to shut down, shuts itself down, and has the UPS power-cycle its outlets so every machine restarts when power returns.

Server setup: [NUT Server Installation](./nut-server-installation.md). Clients: [NUT Client Setup](./nut-client-setup.md).

## Overview

| Setting | Value |
|---|---|
| **Decision point** | NUT server (`monitor-lab-02`) only; clients run no timers |
| **Commit timer** | 300 seconds on battery |
| **Shutdown trigger** | Forced shutdown (FSD) from the server, or low battery reported by the UPS |
| **UPS off delay** | 240 seconds after the server's final shutdown command |
| **UPS on delay** | 300 seconds after power returns |
| **Alerts** | Discord, from the server |

```text
Power lost
   │  ONBATT alert, commit timer starts (300 s)
   ▼
Power back before 300 s? ──yes──► timer cancelled, ONLINE alert, nothing shuts down
   │ no
   ▼
Forced shutdown (FSD)
   ├──► prox-lab-01..03 shut down (VMs stop with their host)
   ├──► NAS enters standby / shuts down
   └──► NUT server shuts down last
            │  final step: UPS told to cut outlets in 240 s
            ▼
       Outlets off ──► power returns ──► 300 s ──► outlets on ──► every machine boots
```

## How It Works

| Part | What it does |
|---|---|
| `upsmon` with `NOTIFYCMD` | Runs `notify.sh` for each power event |
| `notify.sh` | Posts the event to Discord, then hands it to `upssched` |
| `upssched` | Starts the commit timer on `ONBATT` and cancels it on `ONLINE` |
| `upssched-cmd` | When the timer ends, posts to Discord and runs `upsmon -c fsd` |
| Forced shutdown (FSD) | The server sets FSD on the UPS. Every client shuts down, then the server does |
| `POWERDOWNFLAG` | During the server's shutdown, `upsmon` creates `/etc/killpower` |
| `nutshutdown` hook | At the very end of shutdown, if `/etc/killpower` exists, it tells the UPS to power off its outlets after `offdelay` and back on after `ondelay` once power returns |

The outlet power-cycle is what makes recovery automatic. If power comes back while machines are shutting down, the UPS still cuts and restores its outlets, so every machine sees a power loss and boots instead of staying off.

## Configuration

Run on the NUT server, as root.

### Discord Sender and Event Handler

`discord.sh` posts one message. `notify.sh` is what `upsmon` runs for every event.

```bash
cat > /etc/nut/discord.sh <<'SCRIPT'
#!/bin/sh
WEBHOOK=$(cat /etc/nut/discord-webhook)
MSG="[$(hostname)] $1"
curl -fsS -m 10 -H "Content-Type: application/json" \
  -d "{\"content\": \"$MSG\"}" "$WEBHOOK" >/dev/null \
  || logger -t nut-notify "Discord notification failed: $MSG"
SCRIPT

cat > /etc/nut/notify.sh <<'SCRIPT'
#!/bin/sh
/etc/nut/discord.sh "${NOTIFYTYPE:-EVENT}: $1"
exec /sbin/upssched "$1"
SCRIPT
```

`notify.sh` calls `discord.sh` rather than posting itself, so `upssched-cmd` can post too without calling `upssched` in a loop.

### Commit Timer

```bash
cat > /etc/nut/upssched.conf <<'CONF'
CMDSCRIPT /etc/nut/upssched-cmd
PIPEFN /run/nut/upssched.pipe
LOCKFN /run/nut/upssched.lock

AT ONBATT * START-TIMER commit-shutdown 300
AT ONLINE * CANCEL-TIMER commit-shutdown
CONF

cat > /etc/nut/upssched-cmd <<'SCRIPT'
#!/bin/sh
case "$1" in
  commit-shutdown)
    logger -t upssched "On battery past the commit point: forced shutdown"
    /etc/nut/discord.sh "On battery past the commit point: starting forced shutdown of all systems"
    sudo /sbin/upsmon -c fsd
    ;;
  *)
    logger -t upssched "Unknown command: $1"
    ;;
esac
SCRIPT

chown root:nut /etc/nut/discord.sh /etc/nut/notify.sh /etc/nut/upssched-cmd /etc/nut/upssched.conf
chmod 750 /etc/nut/discord.sh /etc/nut/notify.sh /etc/nut/upssched-cmd
chmod 640 /etc/nut/upssched.conf
```

### Forced-Shutdown Permission

`upssched-cmd` runs as the `nut` user, and `upsmon -c fsd` needs root. A sudo rule allows exactly that command and nothing else:

```bash
echo 'nut ALL=(root) NOPASSWD: /sbin/upsmon -c fsd' > /etc/sudoers.d/nut-fsd
chmod 440 /etc/sudoers.d/nut-fsd
visudo -cf /etc/sudoers.d/nut-fsd        # parsed OK
```

### UPS Outlet Delays

Add under `[ups]` in `/etc/nut/ups.conf`. The off delay has to be longer than the time the Proxmox nodes need to shut down their VMs:

```bash
sed -i '/^\[ups\]/a\    offdelay = 240\n    ondelay = 300' /etc/nut/ups.conf
systemctl restart nut-driver@ups
sleep 10
systemctl restart nut-server nut-monitor
```

NUT watches `ups.conf` and may restart the driver itself as soon as the file changes, so `Job for nut-driver@ups.service canceled` after the restart is harmless.

### Check

```bash
upsc ups@localhost 2>/dev/null | grep -E 'ups.status|ups.delay'
# ups.delay.shutdown: 240
# ups.delay.start: 300
upsc -c ups@localhost 2>/dev/null                       # every client still connected
grep -n '^POWERDOWNFLAG' /etc/nut/upsmon.conf           # POWERDOWNFLAG "/etc/killpower"
ls /lib/systemd/system-shutdown/                        # nutshutdown
```

If the UPS shows different delay values than configured, it rounded or rejected them. Adjust `ups.conf` to values it accepts and check again.

## Power-On After an Outage

The outlet power-cycle only helps if every machine powers on by itself when power returns.

| System | Setting |
|---|---|
| Proxmox nodes | BIOS: restore on AC power loss |
| VMs | `onboot: 1` in each VM config: `grep -H onboot /etc/pve/qemu-server/*.conf` |
| Synology | Control Panel → Hardware & Power → General → restart automatically when power supply issue is fixed |
| Mac mini (`monitor-lab-02`) | Chipset register set at every boot: [Mac Mini Auto Power-On Under Linux](../mac/mac-linux-auto-power-on.md) |

## Changing or Pausing the Commit Timer

Change the commit time (in seconds) in `upssched.conf`, then restart `nut-monitor`:

```bash
sed -i 's/START-TIMER commit-shutdown [0-9]*/START-TIMER commit-shutdown 300/' /etc/nut/upssched.conf
grep commit-shutdown /etc/nut/upssched.conf
systemctl restart nut-monitor
```

To pause the automatic shutdown, so systems shut down only at low battery, comment out the `AT ONBATT` line and restart `nut-monitor`:

```bash
sed -i 's/^AT ONBATT/# AT ONBATT/' /etc/nut/upssched.conf
systemctl restart nut-monitor
```

## Tests

Run tests with the battery near full charge. Watch events live on the server during each test:

```bash
journalctl -f -t upssched -t nut-notify -u nut-monitor
```

### Test 1: Alerts

1. Unplug the UPS from the wall.
2. An `ONBATT` alert arrives on Discord within seconds.
3. Plug it back in after about a minute. An `ONLINE` alert arrives.

### Test 2: Cancel

1. Unplug the UPS and note the time.
2. `ONBATT` alert, and the log shows the `commit-shutdown` timer starting.
3. Plug it back in after about 3 minutes, before the 300-second commit point.
4. `ONLINE` alert, the log shows the timer cancelled, and nothing shuts down.

### Test 3: Full Sequence

A real shutdown of the whole lab. Pick a time when an outage of 15 to 20 minutes doesn't matter.

1. Shorten the commit timer to 120 seconds (see [Changing the Commit Timer](#changing-or-pausing-the-commit-timer)).
2. Unplug the UPS and note the time.
3. At about 2 minutes: the forced-shutdown message on Discord, and every client starts shutting down.
4. Time how long each Proxmox node takes to power off. All must be off before the UPS cuts its outlets, 240 seconds after the server's final step.
5. The server shuts down, then the UPS cuts its outlets.
6. Plug the UPS back in. After the on delay (300 seconds), the outlets come back on and every machine boots.
7. Check recovery: all five NUT clients connected (`upsc -c ups@localhost`), the Proxmox cluster quorate, VMs running, and the DCs with no unclean-shutdown events.
8. Set the commit timer back to 300 seconds.

### Test 4: Power Returns Mid-Sequence

Checks that machines don't stay off when power comes back during a shutdown. Run after test 3 passes.

1. Shorten the commit timer to 120 seconds.
2. Unplug the UPS. Wait for the forced-shutdown message.
3. Plug the UPS back in while the clients are still shutting down.
4. The UPS should still cut its outlets after the off delay and restore them after the on delay, and every machine should boot.
5. Set the commit timer back to 300 seconds.

### Runtime Check

At full charge, unplug the UPS for about 10 minutes with the [live monitor](./nut-server-installation.md#live-monitor) running. The runtime estimate should fall by about 60 seconds per minute, and the charge by about 1 to 1.5% per minute at this load. A much faster drop points to a weak battery.

### Battery Quick Test

```bash
upscmd -u upsadmin -p '<upsadmin-password>' ups test.battery.start.quick
sleep 30; upsc ups@localhost ups.test.result
```

Needs the `upsadmin` login (see [NUT Users](./nut-server-installation.md#nut-users)).

## Results

| Date | Test | Result | Notes |
|---|---|---|---|
| Nov 2026 | Test 1: Alerts | ✅ Passed | `ONBATT` within seconds, `ONLINE` on plug-in. Charge reading fell to about 76% during the test |
| | Test 2: Cancel | Pending | |
| | Test 3: Full sequence | Pending | Node shutdown times to be measured against the 240-second off delay |
| | Test 4: Power returns mid-sequence | Pending | |
| | Runtime check | Pending | |
| | Battery quick test | Pending | |

## Troubleshooting

| Symptom | Check |
|---|---|
| No timer starts on battery | `NOTIFYCMD /etc/nut/notify.sh` and `NOTIFYFLAG ONBATT ...EXEC` in `upsmon.conf`; `journalctl -t upssched` |
| Timer ends but nothing shuts down | `visudo -cf /etc/sudoers.d/nut-fsd`, and that `upssched-cmd` calls `sudo /sbin/upsmon -c fsd` |
| Clients don't shut down on FSD | Client connected (`upsc -c ups@localhost` on the server) and `nut-monitor` active on the client |
| Outlets never cut | `POWERDOWNFLAG` set in `upsmon.conf` and `nutshutdown` present in `/lib/systemd/system-shutdown/` |
| A machine stays off after power returns | Its power-on-after-AC-loss setting (see [Power-On After an Outage](#power-on-after-an-outage)) |
| Testing `notify.sh` by hand prints `UPSNAME and NOTIFYTYPE must be set` | Normal: `upssched` only accepts real events from `upsmon`. The Discord part runs first |

## Security

- The sudo rule allows the `nut` user one command only, `/sbin/upsmon -c fsd`.
- Scripts are `root:nut`, mode `750`, so the `nut` user can run them but not change them.
- The webhook URL stays in `/etc/nut/discord-webhook`, never in the scripts.
