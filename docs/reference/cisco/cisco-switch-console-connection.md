# Cisco Switch Console Connection

## Overview

This document outlines the process for connecting to a Cisco Catalyst switch through the serial console using macOS.

Console access provides out-of-band management and does not depend on the switch having a working network configuration.

The procedure was validated on:

- **Model:** Cisco Catalyst WS-C3560CG-8PC-S
- **IOS:** Cisco IOS 15.2(2)E
- **Console:** RJ45 serial console
- **Adapter:** FTDI USB-C to RJ45 console cable
- **Client:** macOS


## When to Use Console Access

The serial console can be used without:

- An IP address
- DHCP
- Ethernet connectivity
- SSH
- Existing network configuration

This makes console access useful for:

- Initial switch configuration
- Network troubleshooting
- Recovering management access
- Password recovery
- Factory resets
- Configuration errors that prevent network access


## Connect the Console Cable

Connect the RJ45 end of the console cable to the switch's **Console** port.

Connect the USB end to the management computer.

For an FTDI-based adapter, modern macOS systems may recognize the adapter without requiring an additional driver.


## Identify the Serial Device

Open Terminal and list available serial devices:

```bash
ls /dev/cu.*
```

An FTDI USB serial adapter typically appears similar to:

```text
/dev/cu.usbserial-XXXXXXXX
```

Other devices may also be listed:

```text
/dev/cu.Bluetooth-Incoming-Port
/dev/cu.debug-console
/dev/cu.usbserial-XXXXXXXX
```

The `/dev/cu.usbserial-*` device is the USB-to-serial console adapter.


## Default Cisco Console Settings

Cisco Catalyst switches traditionally use the following serial console settings:

| Setting | Value |
|---|---|
| Baud rate | 9600 |
| Data bits | 8 |
| Parity | None |
| Stop bits | 1 |
| Flow control | None |

These settings are commonly abbreviated as:

```text
9600 8N1
```


## Connect Using screen

macOS includes the `screen` utility, which can be used as a serial terminal.

Connect using:

```bash
screen /dev/cu.usbserial-XXXXXXXX 9600
```

Replace the serial device name with the device detected on the local system.

Press `Enter` after connecting.

A functioning connection should eventually display a Cisco CLI prompt such as:

```text
Switch>
```

or:

```text
Switch#
```


## Specify the Baud Rate Explicitly

When connecting to network equipment, explicitly specify the expected baud rate:

```bash
screen /dev/cu.usbserial-XXXXXXXX 9600
```

Rather than:

```bash
screen /dev/cu.usbserial-XXXXXXXX
```

Explicitly defining the baud rate ensures the computer and switch are communicating at the same serial speed and makes the connection procedure reproducible.


## Garbled Console Output

Unreadable characters usually indicate that the computer and switch are using different baud rates.

Example:

```text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

If the default 9600 baud does not produce readable output, the console speed may have been changed by a previous administrator.

A common alternative is:

```bash
screen /dev/cu.usbserial-XXXXXXXX 115200
```

Other baud rates may also be possible depending on the switch configuration.

Once the correct baud rate is selected, normal IOS output should become readable.


## Baud Rate After a Factory Reset

A switch with an inherited configuration may have a non-default console speed.

For example:

```text
Existing configuration
        │
        └── Console configured for 115200 baud
                    │
                    ▼
             Factory Reset
                    │
                    ▼
          Configuration Removed
                    │
                    ▼
          Default 9600 Baud
```

If console output becomes unreadable immediately after resetting and rebooting a switch, reconnect using the default:

```bash
screen /dev/cu.usbserial-XXXXXXXX 9600
```


## Exit the Console Session

To terminate a `screen` session:

1. Press `Ctrl+A`
2. Press `K`
3. Press `Y` to confirm

The terminal returns to the normal shell prompt.


## Cisco CLI Prompts

After connecting, IOS commonly presents:

```text
Switch>
```

This indicates **User EXEC mode**.

Enter privileged EXEC mode with:

```text
enable
```

The prompt changes to:

```text
Switch#
```

The `#` indicates **Privileged EXEC mode**, which provides access to administrative and diagnostic commands.


## Troubleshooting

### Serial Device Does Not Appear

Run:

```bash
ls /dev/cu.*
```

Disconnect the USB console adapter, run the command again, reconnect the adapter, and compare the results.

For an FTDI adapter, look for:

```text
/dev/cu.usbserial-XXXXXXXX
```


### Console Is Blank

Press `Enter` once or twice.

If the terminal remains blank:

- Verify the correct serial device was selected.
- Verify the cable is connected to the switch's console port.
- Verify the switch is powered on.
- Verify the baud rate.


### Console Displays Garbage Characters

Disconnect from the current `screen` session and reconnect using the expected baud rate.

Start with:

```bash
screen /dev/cu.usbserial-XXXXXXXX 9600
```

If the switch has an inherited configuration with a modified console speed, test a known alternative such as:

```bash
screen /dev/cu.usbserial-XXXXXXXX 115200
```


### USB Serial Adapter Is Not Detected

If `/dev/cu.usbserial-*` does not appear:

- Disconnect and reconnect the adapter.
- Try another USB port.
- Verify the USB-to-console cable chipset.
- Check whether the chipset requires a macOS driver.

FTDI-based adapters are commonly recognized by modern macOS versions without an additional driver.


## Connection Workflow

```text
Cisco Console Port
        │
        ▼
USB-to-Serial Adapter
        │
        ▼
      macOS
        │
        ▼
ls /dev/cu.*
        │
        ▼
Identify usbserial Device
        │
        ▼
screen <device> 9600
        │
        ▼
     Cisco CLI
```


## Quick Reference

Identify the adapter:

```bash
ls /dev/cu.*
```

Connect:

```bash
screen /dev/cu.usbserial-XXXXXXXX 9600
```

Enter privileged EXEC mode:

```text
enable
```

Exit `screen`:

```text
Ctrl+A
K
Y
```


## Key Takeaways

- Serial console access works independently of the switch's network configuration.
- Cisco Catalyst switches traditionally use **9600 8N1** for console access.
- FTDI USB-to-serial adapters are commonly exposed as `/dev/cu.usbserial-*` on macOS.
- Garbled output commonly indicates a baud-rate mismatch.
- An inherited switch configuration may use a non-default console speed.
- A factory reset can restore the console to its default baud rate.
- Explicitly specifying the baud rate makes console access predictable and reproducible.
