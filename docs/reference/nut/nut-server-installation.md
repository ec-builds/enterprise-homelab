# NUT Server Installation

Reference guide for connecting a USB UPS to a Debian host and sharing its status on the network with Network UPS Tools (NUT).

The NUT server reads the UPS over USB and publishes its status, load and runtime on port `3493/TCP`. Other machines run NUT clients that watch that status and shut themselves down during an outage. This guide covers the server. Shutdown timers and clients are covered in the [UPS Power Protection Plan](../../../projects/backup-disaster-recovery/TODO-ups-power-protection-plan.md).

## Overview

| Setting | Value |
|---|---|
| **Platform** | Debian 13 (trixie) |
| **Host** | `monitor-lab-02` |
| **UPS** | CyberPower CP1500PFCLCD, USB |
| **Driver** | `usbhid-ups` |
| **UPS name** | `ups` |
| **Mode** | `netserver` |
| **Port** | `3493/TCP` |
| **Packages** | `nut` (installs `nut-server` and `nut-client`) |
| **Config folder** | `/etc/nut/` |

```text
CyberPower UPS
      │ USB
      ▼
usbhid-ups driver ──► upsd (3493/TCP) ──► NUT clients on the network
                          │
                          ▼
                    upsmon (local)
```

| Component | systemd unit | Purpose |
|---|---|---|
| Driver | `nut-driver@ups.service` | Talks to the UPS over USB |
| Server | `nut-server.service` (`upsd`) | Publishes UPS data on the network |
| Monitor | `nut-monitor.service` (`upsmon`) | Watches the UPS and shuts the host down |

## 1. Confirm the UPS Is Detected

Connect the UPS USB cable, then check that the host sees it.

```bash
lsusb
```

Expected:

```text
Bus 001 Device 007: ID 0764:0601 Cyber Power System, Inc. PR1500LCDRT2U UPS
```

`0764` is CyberPower's USB vendor ID. `lsusb` labels `0764:0601` with the name from its ID database, which CyberPower shares across several models, so the model name shown may not match the UPS. The kernel log reports the name the UPS itself sends:

```bash
sudo journalctl -k | grep -i -E "usb|hid|cyber"
```

Expected:

```text
usb 1-1: New USB device found, idVendor=0764, idProduct=0601, bcdDevice= 2.00
usb 1-1: Product: CP1500PFCLCDa
usb 1-1: Manufacturer: CPS
hid-generic 0003:0764:0601.0004: hiddev1,hidraw1: USB HID v1.10 Device [CPS CP1500PFCLCDa] on usb-0000:00:14.0-1/input0
```

If `lsusb` is missing, install it with `sudo apt install usbutils`. To watch detection live, run `sudo dmesg -w` and replug the cable.

A UPS can be connected to only one host. Remove any USB passthrough or vendor software on the previous host before moving the cable.

## 2. Install NUT

```bash
sudo apt install nut
```

## 3. Scan for the UPS

```bash
sudo nut-scanner -U
```

Expected (serial removed):

```text
[nutdev1]
	driver = "usbhid-ups"
	port = "auto"
	vendorid = "0764"
	productid = "0601"
	product = "CP1500PFCLCDa"
	serial = "<serial>"
	vendor = "CPS"
	bus = "001"
	device = "007"
	busport = "001"
```

Warnings about SNMP, XML, Avahi or IPMI libraries can be ignored. Those scan types aren't needed for a USB UPS.

## 4. Configure NUT

### Mode

`/etc/nut/nut.conf`:

```ini
MODE=netserver
```

The package installs with `MODE=none`. Until it's changed, `nut-server` and `nut-monitor` start and exit straight away, logging `upsd disabled, please adjust the configuration to your needs`.

### UPS Definition

Add to the end of `/etc/nut/ups.conf`:

```ini
[ups]
    driver = usbhid-ups
    port = auto
    vendorid = 0764
    productid = 0601
    desc = "CyberPower CP1500PFCLCD"
    pollinterval = 15
```

- The UPS is named `ups` because Synology's NUT client only connects to a UPS with that name.
- `bus` and `device` from the scan are left out. They can change after a reboot or replug; the vendor and product IDs don't.

### Network Listener

`/etc/nut/upsd.conf`:

```ini
LISTEN 127.0.0.1 3493
LISTEN 0.0.0.0 3493
```

Limit port `3493/TCP` to the NUT clients with a firewall rule (see [Restrict Network Access](#7-restrict-network-access)).

### Users

`/etc/nut/upsd.users`:

```ini
[upsmon_local]
    password = <long-random-password>
    upsmon primary

[upsmon_remote]
    password = <long-random-password>
    upsmon secondary

[monuser]
    password = <synology-fixed-password>
    upsmon secondary
```

| User | Used by |
|---|---|
| `upsmon_local` | `upsmon` on the server itself |
| `upsmon_remote` | Linux clients, such as Proxmox nodes |
| `monuser` | Synology DSM, which uses a fixed username and password that can't be changed |

Generate passwords with:

```bash
openssl rand -base64 24
```

Passwords are stored outside the repository.

### Local Monitoring

Add to `/etc/nut/upsmon.conf`:

```ini
MONITOR ups@localhost 1 upsmon_local <upsmon_local-password> primary
```

Debian's default `upsmon.conf` already contains `SHUTDOWNCMD "/sbin/shutdown -h +0"` and has no active `MONITOR` line, so only the `MONITOR` line is needed. Check that there's exactly one of each:

```bash
grep -nE '^(MONITOR|SHUTDOWNCMD)' /etc/nut/upsmon.conf
```

With the remaining defaults, the host shuts down only when the UPS reports low battery. Staggered shutdown timers and UPS outlet power-cycling are added separately, after testing.

### File Permissions

```bash
sudo chown root:nut /etc/nut/upsd.users /etc/nut/upsmon.conf
sudo chmod 640 /etc/nut/upsd.users /etc/nut/upsmon.conf
```

## 5. Start the Services

```bash
sudo systemctl restart nut-driver-enumerator.service
sudo systemctl restart nut-server.service nut-monitor.service
```

`nut-driver-enumerator` reads `ups.conf` and creates the `nut-driver@ups` unit for each UPS defined there.

If the UPS was plugged in before NUT was installed, the driver can't open the USB device yet (see [Troubleshooting](#troubleshooting)). Re-apply the USB rules first:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=usb --action=add
ls -l /dev/bus/usb/<bus>/<device>     # group should be nut
sudo systemctl restart nut-driver@ups
```

Use the bus and device numbers from `lsusb`. The package's udev rule covers this UPS (`0764:0601`) from then on, including after reboots.

## 6. Verify

```bash
upsc ups@localhost
```

Example output on the lab UPS (excerpt, serial removed):

```text
battery.charge: 100
battery.runtime: 3200
battery.runtime.low: 300
device.model: CP1500PFCLCDa
driver.name: usbhid-ups
ups.delay.shutdown: 20
ups.delay.start: 30
ups.load: 15
ups.realpower.nominal: 1000
ups.status: OL
```

`Init SSL without certificate database` at the top of the output is normal when NUT runs without SSL.

Key values:

| Value | Meaning |
|---|---|
| `ups.status` | `OL` on line, `OB` on battery, `LB` low battery |
| `ups.load` | Current load, in percent |
| `battery.charge` | Battery charge, in percent |
| `battery.runtime` | Estimated runtime at the current load, in seconds |

Single value:

```bash
upsc ups@localhost battery.runtime
```

From another host on the network:

```bash
upsc ups@<nut-server-ip>
```

`battery.runtime` and `ups.load` under the real load are the basis for shutdown timer values.

## 7. Restrict Network Access

Allow `3493/TCP` only from the NUT clients. The host also runs Docker, which manages its own firewall rules, so the stock `nftables` service isn't used: its default config starts with `flush ruleset`, which would remove Docker's rules too. Instead, one small table filters only port `3493` and leaves all other traffic alone.

`/etc/nut/nut-firewall.nft`:

```text
table inet nut_filter {
  chain input {
    type filter hook input priority 0; policy accept;
    tcp dport 3493 iif "lo" accept
    tcp dport 3493 ip saddr { <prox-lab-01-ip>, <prox-lab-02-ip>, <prox-lab-03-ip>, <nas-ip> } accept
    tcp dport 3493 drop
  }
}
```

`/etc/systemd/system/nut-firewall.service`:

```ini
[Unit]
Description=Restrict NUT port 3493 to lab clients
Before=nut-server.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/nft -f /etc/nut/nut-firewall.nft
ExecStop=/usr/sbin/nft delete table inet nut_filter
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable and check:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nut-firewall.service
sudo nft list table inet nut_filter
upsc ups@localhost ups.status     # still OL
```

To add a client later, add its address to the set and run `sudo systemctl restart nut-firewall.service`.

## 8. Discord Alerts

`upsmon` runs a command for each power event it's told to report. A small script posts the event to a Discord channel through a webhook.

Store the webhook URL without putting it in shell history:

```bash
read -rsp "Webhook URL: " WEBHOOK; echo
printf '%s\n' "$WEBHOOK" | sudo tee /etc/nut/discord-webhook >/dev/null
sudo chown root:nut /etc/nut/discord-webhook
sudo chmod 640 /etc/nut/discord-webhook
unset WEBHOOK
```

`/etc/nut/notify.sh` (owner `root:nut`, mode `750`):

```sh
#!/bin/sh
# Called by upsmon (NOTIFYCMD). $1 = message, NOTIFYTYPE = event type.
WEBHOOK=$(cat /etc/nut/discord-webhook)
MSG="[$(hostname)] ${NOTIFYTYPE:-EVENT}: $1"
curl -fsS -m 10 -H "Content-Type: application/json" \
  -d "{\"content\": \"$MSG\"}" "$WEBHOOK" >/dev/null \
  || logger -t nut-notify "Discord notification failed: $MSG"
```

Add to `/etc/nut/upsmon.conf`, then restart `nut-monitor`:

```ini
NOTIFYCMD /etc/nut/notify.sh
NOTIFYFLAG ONBATT   SYSLOG+WALL+EXEC
NOTIFYFLAG ONLINE   SYSLOG+WALL+EXEC
NOTIFYFLAG LOWBATT  SYSLOG+WALL+EXEC
NOTIFYFLAG FSD      SYSLOG+WALL+EXEC
NOTIFYFLAG SHUTDOWN SYSLOG+WALL+EXEC
NOTIFYFLAG COMMBAD  SYSLOG+WALL+EXEC
NOTIFYFLAG COMMOK   SYSLOG+WALL+EXEC
NOTIFYFLAG NOCOMM   SYSLOG+WALL+EXEC
NOTIFYFLAG REPLBATT SYSLOG+WALL+EXEC
```

Test as the `nut` user, the same way `upsmon` runs it:

```bash
sudo -u nut env NOTIFYTYPE=TEST /etc/nut/notify.sh "Test from NUT"
```

Then unplug the UPS from the wall for about a minute. An `ONBATT` alert should arrive within seconds, and an `ONLINE` alert when it's plugged back in. If nothing arrives, check `journalctl -t nut-notify`.

## NUT Users

| User | Role | Used by | Notes |
|---|---|---|---|
| `upsmon_local` | `primary` | `upsmon` on the server | Only used on the server itself |
| `upsmon_remote` | `secondary` | Linux clients such as the Proxmox nodes | Stored in a password manager and later Ansible Vault |
| `monuser` | `secondary` | Synology DSM | Fixed username and password set by DSM |
| `upsadmin` | `instcmds` only | Admin, for battery tests | Limited to `test.battery.start.quick` and `test.battery.stop` |

List them on the server:

```bash
sudo grep -E '^\[|password|upsmon|instcmds' /etc/nut/upsd.users
```

Passwords and the webhook URL are kept in a password manager, so a rebuilt server can reuse them without reconfiguring clients.

## Useful Commands

### Status

```bash
upsc ups@localhost                          # everything the UPS reports
upsc ups@localhost ups.status               # OL, OB, LB, OL CHRG ...
upsc ups@localhost | grep -E 'ups.status|ups.load|battery.charge|battery.runtime'
```

### Live Monitor

Prints the time, runtime estimate and charge every minute. Useful during a runtime check on battery; stop it with Ctrl+C.

```bash
while true; do
  echo "$(date +%T) $(upsc ups@localhost battery.runtime 2>/dev/null) s, charge $(upsc ups@localhost battery.charge 2>/dev/null)%"
  sleep 60
done
```

During a runtime check, `battery.runtime` should drop by about 60 seconds per minute. On this UPS the runtime estimate is the full-charge runtime multiplied by `battery.charge`, and the charge is worked out from battery voltage, so it drops quickly in the first minutes on battery and partly recovers when charging starts.

### Battery Test

```bash
upscmd -l ups                                                  # commands the UPS supports
upscmd -u upsadmin -p '<upsadmin-password>' ups test.battery.start.quick
sleep 30; upsc ups@localhost ups.test.result
```

Run it near full charge. A healthy battery reports a passed result.

### Services and Logs

```bash
systemctl status nut-driver@ups nut-server nut-monitor nut-firewall
sudo systemctl restart nut-driver@ups
sudo journalctl -u nut-driver@ups -u nut-server -u nut-monitor -n 50
sudo journalctl -u nut-monitor -f                              # follow power events live
journalctl -t nut-notify                                       # failed Discord sends
```

## Troubleshooting

| Symptom | Check |
|---|---|
| `nut-scanner: command not found` | NUT isn't installed: `sudo apt install nut` |
| Services exit with `upsd disabled` / `upsmon disabled` | `MODE` in `nut.conf` is still `none` |
| `upsc` returns `Driver not connected`, driver stuck in `activating` | Driver is failing and retrying: `journalctl -u nut-driver@ups -n 30` |
| Driver logs `insufficient permissions on everything` / `No matching HID UPS found` | The USB device isn't in the `nut` group yet. Re-apply the udev rules (step 5) or replug the cable, then restart the driver |
| Driver can't find the UPS | Compare `vendorid` and `productid` in `ups.conf` with `lsusb` |
| `upsc` works locally but not from another host | `LISTEN` in `upsd.conf`, the host firewall, and that `nut-server` was restarted |
| Client login fails | Username, password and `primary`/`secondary` role in `upsd.users` |

## Security

- Allow `3493/TCP` only from the hosts that run NUT clients (see [Restrict Network Access](#7-restrict-network-access)).
- Keep `upsd.users` and `upsmon.conf` readable only by `root` and the `nut` group, because they contain passwords.
- Synology's fixed login is a known value, so restricting access to port `3493` is the main control for that account.
- Keep the Discord webhook URL in `/etc/nut/discord-webhook` (`root:nut`, `640`), never in scripts or the repo.
- Don't publish UPS serial numbers, NUT passwords or client addresses.
