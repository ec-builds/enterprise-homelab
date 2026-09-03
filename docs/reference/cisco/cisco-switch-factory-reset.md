# Cisco Switch Factory Reset

## Overview

This document outlines the process for restoring a Cisco Catalyst switch to a clean factory configuration using the Cisco IOS CLI.

The procedure was validated on:

- **Model:** Cisco Catalyst WS-C3560CG-8PC-S
- **IOS:** Cisco IOS 15.2(2)E
- **Access Method:** Serial console

> [!WARNING]
> A factory reset permanently removes the saved switch configuration. Do not perform this procedure on a production switch unless the existing configuration is no longer required or has been backed up.


## Prerequisites

Before beginning:

- Connect to the switch through the serial console.
- Confirm that console access is working.
- Verify that the existing configuration can be safely removed.

For console connection instructions, see:

[cisco-switch-console-connection.md](./cisco-switch-console-connection.md)


## Enter Privileged EXEC Mode

A console session normally begins in User EXEC mode:

```text
Switch>
```

Enter Privileged EXEC mode:

```text
enable
```

The prompt changes to:

```text
Switch#
```


## Inspect the Existing Configuration

Before erasing the switch, review the existing configuration.

Check the startup configuration:

```text
show startup-config
```

A switch without a saved configuration may report:

```text
startup-config is not present
```

Check the current VLAN database:

```text
show vlan brief
```

A default Catalyst configuration normally places the physical switch ports in VLAN 1.

Example:

```text
VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Gi0/1, Gi0/2, Gi0/3, Gi0/4
                                                Gi0/5, Gi0/6, Gi0/7, Gi0/8
                                                Gi0/9, Gi0/10
1002 fddi-default                     act/unsup
1003 token-ring-default               act/unsup
1004 fddinet-default                  act/unsup
1005 trnet-default                    act/unsup
```

VLANs 1002–1005 are legacy Cisco default VLANs and do not indicate that custom VLAN segmentation has been configured.


## Erase the Startup Configuration

Erase the configuration stored in NVRAM:

```text
write erase
```

IOS prompts for confirmation:

```text
Erasing the nvram filesystem will remove all configuration files! Continue? [confirm]
```

Press `Enter`.

A successful erase should report:

```text
[OK]
Erase of nvram: complete
```

> [!NOTE]
> `write erase` removes the startup configuration but may not remove VLAN information stored separately on older Catalyst platforms.


## Check the VLAN Database

Some Cisco Catalyst switches store VLAN information separately in:

```text
flash:vlan.dat
```

Check the contents of flash:

```text
dir flash:
```

Look for:

```text
vlan.dat
```

If `vlan.dat` is not present, no additional VLAN database cleanup is required.


## Delete vlan.dat

If `vlan.dat` exists and a complete factory reset is required, delete it:

```text
delete flash:vlan.dat
```

Confirm the deletion when prompted.

Verify that the file has been removed:

```text
dir flash:
```

> [!CAUTION]
> Only delete `vlan.dat` when performing a complete reset. Do not delete the IOS image or other unknown files from flash. Removing the IOS image can prevent the switch from booting normally and require bootloader recovery.


## Reload the Switch

Reload IOS:

```text
reload
```

If IOS asks whether the current configuration should be saved, answer:

```text
no
```

When prompted:

```text
Proceed with reload? [confirm]
```

Press `Enter`.

The switch will restart and perform its normal POST and IOS boot sequence.


## Console Baud Rate After Reset

An inherited configuration may contain a non-default console baud rate.

Erasing the configuration can restore the console to the Cisco default of:

```text
9600 8N1
```

If console output becomes unreadable after the switch reloads, disconnect the existing serial session and reconnect at 9600 baud.

For example on macOS:

```bash
screen /dev/cu.usbserial-XXXXXXXX 9600
```

Garbled characters during boot commonly indicate that the terminal and switch are using different baud rates.


## Initial Configuration Dialog

After booting without a startup configuration, IOS may display:

```text
--- System Configuration Dialog ---

Would you like to enter the initial configuration dialog? [yes/no]:
```

This is Cisco's interactive first-time configuration wizard.

For manual CLI configuration, enter:

```text
no
```

The switch will eventually present:

```text
Switch>
```

The switch is now ready for manual configuration.


## Verify the Reset

Enter Privileged EXEC mode:

```text
enable
```

Verify that no startup configuration exists:

```text
show startup-config
```

Expected output:

```text
startup-config is not present
```

Verify the VLAN configuration:

```text
show vlan brief
```

The physical interfaces should be assigned to the default VLAN:

```text
VLAN 1
```

Check flash:

```text
dir flash:
```

Confirm that no custom `vlan.dat` remains if the VLAN database was intentionally removed.


## Default Switching Behavior

After a factory reset, the physical interfaces are placed in VLAN 1 by default.

For example:

```text
Gi0/1  ─┐
Gi0/2   │
Gi0/3   │
Gi0/4   │
Gi0/5   ├── VLAN 1
Gi0/6   │
Gi0/7   │
Gi0/8   │
Gi0/9   │
Gi0/10 ─┘
```

This allows the switch to provide basic Layer 2 connectivity without additional VLAN configuration.

A simple flat network can therefore operate as:

```text
Internet
    │
    ▼
Router / Firewall
    │
    ▼
Cisco Catalyst Switch
    │
    ├── Server
    ├── Hypervisor
    ├── NAS
    ├── Workstation
    └── Other LAN Devices
```

The upstream router or firewall continues to provide services such as:

- DHCP
- Default gateway
- DNS
- NAT
- Internet routing

The Catalyst switch provides Layer 2 Ethernet connectivity between devices.


## Common Issue: Mistyped Commands Trigger DNS Lookup

IOS may interpret an unrecognized command as a hostname.

For example, entering:

```text
Switch#relaod
```

instead of:

```text
Switch#reload
```

may produce:

```text
Translating "relaod"...domain server (255.255.255.255)
```

This does not indicate a problem with the switch. IOS is attempting to resolve the unknown command through DNS.

DNS lookup can later be disabled in global configuration mode:

```text
no ip domain-lookup
```

This prevents unnecessary DNS lookup delays when commands are mistyped.


## Factory Reset Workflow

```text
Connect to Console
        │
        ▼
Enter Privileged EXEC Mode
        │
        ▼
Inspect Existing Configuration
        │
        ├── show startup-config
        └── show vlan brief
        │
        ▼
     write erase
        │
        ▼
     dir flash:
        │
        ▼
Is vlan.dat Present?
     │         │
    Yes        No
     │         │
     ▼         │
Delete         │
vlan.dat       │
     │         │
     └────┬────┘
          ▼
        reload
          │
          ▼
Reconnect at 9600 if Required
          │
          ▼
Decline Initial Configuration Dialog
          │
          ▼
Verify Startup Config and VLANs
          │
          ▼
Begin Manual Configuration
```


## Quick Reference

Enter Privileged EXEC mode:

```text
enable
```

Erase the startup configuration:

```text
write erase
```

Check flash:

```text
dir flash:
```

Delete the VLAN database if present:

```text
delete flash:vlan.dat
```

Reload:

```text
reload
```

Decline the setup wizard:

```text
no
```

Verify the reset:

```text
show startup-config
show vlan brief
dir flash:
```


## Key Takeaways

- `write erase` removes the saved startup configuration from NVRAM.
- Older Catalyst switches may store VLAN information separately in `vlan.dat`.
- Check for `vlan.dat` rather than assuming it exists.
- Do not delete IOS image files while cleaning flash.
- A reset may restore a previously modified console speed to the default **9600 8N1**.
- The initial configuration dialog is optional and can be skipped for manual CLI configuration.
- VLANs 1002–1005 are normal legacy Cisco default VLANs.
- After a factory reset, physical switch ports are placed in VLAN 1 and can provide basic Layer 2 connectivity without additional configuration.
