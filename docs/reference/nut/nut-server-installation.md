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

Limit port `3493/TCP` to the lab's own hosts with a host firewall rule (see [Security](#security)).

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

Add or edit in `/etc/nut/upsmon.conf`:

```ini
MONITOR ups@localhost 1 upsmon_local <upsmon_local-password> primary
SHUTDOWNCMD "/sbin/shutdown -h +0"
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

## 6. Verify

```bash
upsc ups@localhost
```

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

## Service Management

```bash
systemctl status nut-driver@ups nut-server nut-monitor
sudo systemctl restart nut-driver@ups
sudo journalctl -u nut-driver@ups -u nut-server -u nut-monitor -n 50
```

## Troubleshooting

| Symptom | Check |
|---|---|
| `nut-scanner: command not found` | NUT isn't installed: `sudo apt install nut` |
| `upsc` returns `Driver not connected` | Driver isn't running: `systemctl status nut-driver@ups` and its journal |
| Driver reports a USB permission error | Replug the UPS cable so the package's udev rules apply, then restart the driver |
| Driver can't find the UPS | Compare `vendorid` and `productid` in `ups.conf` with `lsusb` |
| `upsc` works locally but not from another host | `LISTEN` in `upsd.conf`, the host firewall, and that `nut-server` was restarted |
| Client login fails | Username, password and `primary`/`secondary` role in `upsd.users` |

## Security

- Allow `3493/TCP` only from the hosts that run NUT clients.
- Keep `upsd.users` and `upsmon.conf` readable only by `root` and the `nut` group, because they contain passwords.
- Synology's fixed login is a known value, so restricting access to port `3493` is the main control for that account.
- Don't publish UPS serial numbers, NUT passwords or client addresses.
