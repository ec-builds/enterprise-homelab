# OPNsense - Mac Mini Firewall

## Overview

This document is a placeholder for the planned OPNsense deployment on a Mac mini using:

- Built-in Gigabit Ethernet
- Apple Thunderbolt to Gigabit Ethernet Adapter

The Mac mini is intended to serve as a dedicated firewall/router for the homelab.

Debian was previously used to validate that both physical Ethernet paths function correctly before replacing the operating system.

## Planned Architecture

```text
                    Mac mini
              ┌──────────────────┐
              │     OPNsense     │
              │                  │
Internet ────►│       WAN        │
              │                  │
              │       LAN        │
              └────────┬─────────┘
                       │
                     Switch
                       │
                  Internal LAN
```

Final WAN and LAN interface assignments will be determined during installation.

## Hardware

| Component | Role |
|---|---|
| Mac mini | Dedicated OPNsense firewall |
| Built-in Gigabit Ethernet | Physical network interface |
| Apple Thunderbolt to Gigabit Ethernet Adapter | Secondary physical network interface |
| Ethernet switch | Internal network connectivity |

## Compatibility

Pre-installation research indicates that the Apple Thunderbolt to Gigabit Ethernet Adapter should be supported by the FreeBSD networking stack used by OPNsense.

The Ethernet controller used by the adapter is supported by the FreeBSD `bge` driver.

Thunderbolt Ethernet behavior will be validated directly during the OPNsense installation before the configuration is considered complete.

> [!NOTE]
> Thunderbolt behavior under OPNsense may differ from Debian Linux. Linux-specific tools and configuration such as `boltctl`, `boltd`, PolicyKit, and Thunderbolt sysfs authorization do not apply to OPNsense.

## Planned Validation

During installation and testing, verify:

- [ ] OPNsense installs successfully on the Mac mini
- [ ] Built-in Ethernet interface is detected
- [ ] Thunderbolt Ethernet adapter is detected during boot
- [ ] Both physical interfaces are available for assignment
- [ ] WAN interface operates correctly
- [ ] LAN interface operates correctly
- [ ] Both Ethernet links negotiate at 1 Gb/s
- [ ] DHCP operates on the LAN
- [ ] Internet connectivity passes through the firewall
- [ ] Firewall rules function as expected
- [ ] OPNsense remains stable after reboot
- [ ] Thunderbolt Ethernet remains available after reboot

## Thunderbolt Considerations

Current research indicates that the Thunderbolt Ethernet adapter should be connected before the system boots.

The Thunderbolt adapter should be treated as permanently attached hardware during normal firewall operation.

Hot-plug and removal behavior will be tested cautiously and documented after deployment.

Disconnecting the Ethernet cable from the adapter is separate from disconnecting the Thunderbolt adapter itself.

## Planned Documentation

This document will be expanded after installation to include:

- Installation procedure
- Interface identification
- WAN/LAN assignment
- Initial LAN addressing
- Web interface access
- DHCP configuration
- DNS configuration
- Firewall rules
- VLAN configuration
- NAT
- VPN configuration
- IDS/IPS configuration
- Backup and restore
- Update procedure
- Troubleshooting
- Final validation

## Status

**Status:** Planned / Pending Installation

Hardware validation under Debian is complete.

OPNsense installation and direct FreeBSD/Thunderbolt testing are pending.
