# Mac Mini Auto Power-On Under Linux

Reference for making an Intel Mac mini running Linux power on by itself when power returns after an outage. Needed for any Mac mini on the UPS, such as `monitor-lab-02`, so it comes back after the UPS power-cycles its outlets.

## Overview

| Setting | Value |
|---|---|
| **Hardware** | Mac mini (Late 2014), Intel 8 Series chipset |
| **OS** | Debian 13 |
| **Device** | `00:1f.0` (ISA bridge / LPC controller) |
| **Register** | `0xa4`, bit 0 |
| **Bit 0 = 0** | Power on after power loss |
| **Bit 0 = 1** | Stay off after power loss |

On macOS, the "Start up automatically after a power failure" setting writes this register at every boot. Once macOS is replaced by Linux, nothing writes it any more, and on many Mac minis the firmware resets it so the machine stays off after a power loss. The service below sets it at every boot.

## 1. Confirm the Chipset

```bash
lspci -s 00:1f.0
```

Expected:

```text
00:1f.0 ISA bridge: Intel Corporation 8 Series LPC Controller (rev 04)
```

The register address applies to this kind of Intel chipset only. Don't apply it to other hardware.

## 2. Read the Current Value

```bash
sudo setpci -s 0:1f.0 0xa4.b
```

| Last hex digit | Bit 0 | Behavior |
|---|---|---|
| Even (`0 2 4 6 8 A C E`), e.g. `08` | 0 | Powers on after power loss |
| Odd (`1 3 5 7 9 B D F`), e.g. `09` | 1 | Stays off after power loss |

## 3. Set It at Every Boot

The value:mask form `=0:1` clears only bit 0 and leaves the rest of the register unchanged. It's safe to run repeatedly.

```bash
sudo tee /etc/systemd/system/mac-autopower.service >/dev/null <<'UNIT'
[Unit]
Description=Mac mini: power on after AC power loss
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/setpci -s 0:1f.0 0xa4.b=0:1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now mac-autopower.service
systemctl is-active mac-autopower.service     # active
sudo setpci -s 0:1f.0 0xa4.b                  # even, e.g. 08
```

## 4. Test

1. Shut down: `sudo shutdown -h now`, and wait until the machine is fully off.
2. Unplug the power cord, wait 10 seconds, and plug it back in.
3. The Mac mini should power on by itself within a few seconds.

A test under macOS doesn't prove the behavior under Linux. Test again after installing Linux.

## Notes

- To make the Mac mini stay off after power loss again, disable the service first (`sudo systemctl disable mac-autopower.service`); otherwise it re-enables auto power-on at every boot.
- Re-check the register after any firmware update.
- On `monitor-lab-02` the register already read `08` after the Linux install, and the unplug test passed. The service is kept as a safeguard in case the value is ever reset.
