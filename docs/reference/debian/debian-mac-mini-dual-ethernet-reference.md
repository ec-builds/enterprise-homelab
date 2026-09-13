# Debian - Mac Mini Dual Ethernet / Thunderbolt Ethernet

## Overview

This document provides a deployment guide and technical reference for configuring and validating dual Ethernet connectivity on a Linux-based Mac mini using the built-in Ethernet interface and an Apple Thunderbolt to Gigabit Ethernet Adapter.

The configuration provides two independent physical network interfaces suitable for:

- Firewall and router deployments
- WAN/LAN separation
- Network security labs
- Traffic monitoring
- Network segmentation
- General dual-NIC testing

The example system runs Debian Linux.

The deployment workflow is designed to be reproducible after a fresh operating system installation. Interface names, Thunderbolt device paths, UUIDs, and PCI addresses should always be discovered on the current system rather than copied from a previous installation.

> [!Important]
> Do not reassign, remove, or reconfigure the interface currently providing SSH connectivity until alternate management access is available. Network role assignment is intentionally outside the scope of this document.

## Tools and Components

### Linux Tools

The following command-line tools are used to inspect network interfaces, identify hardware, validate Ethernet links, manage Thunderbolt devices, and troubleshoot the system.

| Tool | Purpose | Example |
|---|---|---|
| `ip` | Displays and manages network interfaces, IP addresses, routes, and interface states. | `ip -br link` |
| `lspci` | Lists PCI/PCIe devices and identifies physical Ethernet and Thunderbolt controllers. | `lspci \| grep -i ethernet` |
| `ethtool` | Displays Ethernet link information, including negotiated speed, duplex, auto-negotiation, and carrier status. | `sudo ethtool <INTERFACE>` |
| `lshw` | Displays detailed hardware information such as NIC model, driver, MAC address, link speed, and interface name. | `sudo lshw -class network` |
| `boltctl` | Manages Thunderbolt devices, including discovery, authorization, enrollment, and authorization policy. | `boltctl` |
| `dmesg` | Displays kernel messages for troubleshooting hardware detection, PCIe enumeration, driver initialization, and link events. | `sudo dmesg \| grep -i thunderbolt` |
| `systemctl` | Displays and controls systemd services and daemons. | `systemctl status polkit` |
| `apt` | Installs, removes, and updates software packages on Debian-based systems. | `sudo apt install ethtool lshw bolt polkitd` |

### Supporting Packages and Services

Some of the tools require additional packages or background services.

| Package | Provides | Role |
|---|---|---|
| `ethtool` | `ethtool` | Provides Ethernet interface and physical link diagnostics. |
| `lshw` | `lshw` | Provides detailed hardware inventory and device information. |
| `bolt` | `boltctl`, `boltd` | Provides the Thunderbolt management CLI and background daemon used for device authorization and enrollment. |
| `polkitd` | PolicyKit service | Provides the authorization framework used by services such as `boltd` when privileged actions require approval. |

Tools such as `ip`, `lspci`, `dmesg`, and `systemctl` are generally provided by standard Debian system packages and are normally already available.

## Architecture

A typical firewall deployment can use the two interfaces as follows:

```text
                    Mac mini
              ┌──────────────────┐
              │                  │
Internet ────►│ Thunderbolt NIC  │
              │      WAN         │
              │                  │
              │  Built-in NIC    │
              │      LAN         │
              └────────┬─────────┘
                       │
                       ▼
                    Switch
                       │
                  Internal LAN
```

The WAN and LAN assignments can be reversed if required.

This reference establishes and validates both physical interfaces. IP addressing, routing, firewall rules, and final WAN/LAN role assignment should be performed separately as part of the firewall deployment.

## Hardware

| Component | Purpose |
|---|---|
| Built-in Gigabit Ethernet | Primary physical NIC |
| Apple Thunderbolt to Gigabit Ethernet Adapter | Secondary physical NIC |
| Thunderbolt controller | Provides PCIe connectivity to the external NIC |
| Ethernet switch | Network connectivity and physical link validation |

The Apple Thunderbolt to Gigabit Ethernet Adapter is not a conventional USB Ethernet adapter.

Thunderbolt exposes the Ethernet controller through PCIe, allowing Linux to enumerate the controller similarly to an internally installed PCIe NIC.

# Fresh Installation Workflow

Use the following sequence after a fresh Debian installation to restore and validate dual-Ethernet functionality.

## 1. Update the System and Install Packages

Update the operating system:

```bash
sudo apt update
sudo apt upgrade
```

Install the additional packages required by this configuration:

```bash
sudo apt install ethtool lshw bolt polkitd
```

## 2. Identify the Built-in Ethernet Interface

Display available network interfaces:

```bash
ip -br link
```

Identify physical Ethernet controllers:

```bash
lspci | grep -i ethernet
```

Display detailed network hardware:

```bash
sudo lshw -class network
```

Record the interface name assigned to the built-in Ethernet controller.

Do not assume that an interface name from a previous installation will remain identical.

## 3. Verify Thunderbolt Detection

Connect the Apple Thunderbolt to Gigabit Ethernet Adapter.

Check Thunderbolt devices:

```bash
boltctl
```

Check kernel detection:

```bash
sudo dmesg | grep -i thunderbolt
```

The adapter may appear as:

```text
Apple, Inc. Thunderbolt to Gigabit Ethernet Adapter
```

At this stage, Thunderbolt may detect the adapter even though Linux has not yet created an Ethernet interface for it.

## 4. Check Thunderbolt Security and Authorization

Check the Thunderbolt security policy:

```bash
cat /sys/bus/thunderbolt/devices/domain0/security
```

A system requiring user authorization may report:

```text
user
```

Locate Thunderbolt devices:

```bash
ls /sys/bus/thunderbolt/devices/
```

Identify the adapter's device path.

Example:

```text
0-3
```

Check its authorization state:

```bash
cat /sys/bus/thunderbolt/devices/<DEVICE>/authorized
```

Replace `<DEVICE>` with the device identifier discovered on the current system.

A result of:

```text
0
```

indicates that the Thunderbolt device is detected but not authorized.

A result of:

```text
1
```

indicates that the device is authorized.

## 5. Temporarily Authorize the Adapter

If the adapter is detected but not authorized, authorize it for initial testing:

```bash
echo 1 | sudo tee /sys/bus/thunderbolt/devices/<DEVICE>/authorized
```

Example syntax:

```bash
echo 1 | sudo tee /sys/bus/thunderbolt/devices/0-3/authorized
```

The expected result is:

```text
1
```

This authorizes the Thunderbolt device for the current session and allows the Ethernet controller behind the adapter to enumerate.

## 6. Verify PCIe and Ethernet Enumeration

Check the physical Ethernet controllers again:

```bash
lspci | grep -i ethernet
```

Then check Linux network interfaces:

```bash
ip -br link
```

Two physical Ethernet controllers should now be visible.

A typical configuration may resemble:

```text
Built-in Ethernet
└── Gigabit Ethernet Controller
    └── <BUILT-IN-INTERFACE>

Thunderbolt Ethernet
└── Gigabit Ethernet Controller
    └── <THUNDERBOLT-INTERFACE>
```

Record the interface name assigned to the Thunderbolt Ethernet adapter.

For additional hardware details:

```bash
sudo lshw -class network
```

## 7. Enroll the Thunderbolt Adapter

Manual authorization is useful for testing but should not be required after every reboot.

Obtain the adapter UUID:

```bash
boltctl
```

Enroll the adapter:

```bash
sudo boltctl enroll <THUNDERBOLT-DEVICE-UUID>
```

Use the UUID reported by the current system. Do not copy a UUID from another installation or device.

### PolicyKit Enrollment Error

On a minimal Debian installation, enrollment may fail if PolicyKit is unavailable.

An error may resemble:

```text
GDBus.Error:
org.freedesktop.DBus.Error.ServiceUnknown:
The name org.freedesktop.PolicyKit1 was not provided
```

Verify that PolicyKit is installed:

```bash
sudo apt install polkitd
```

Start the service if necessary:

```bash
sudo systemctl start polkit
```

Check its status:

```bash
systemctl status polkit
```

A static systemd unit is not inherently a problem and does not necessarily need to be manually enabled.

Retry enrollment:

```bash
sudo boltctl enroll <THUNDERBOLT-DEVICE-UUID>
```

## 8. Verify Persistent Authorization

Check the enrolled Thunderbolt device:

```bash
boltctl
```

A successfully enrolled adapter should report information similar to:

```text
status: authorized
policy: auto
```

The adapter should also be stored by `boltd`.

Automatic authorization allows the known Thunderbolt device to be authorized during future boots without manually modifying the sysfs authorization value.

## 9. Reboot and Validate Persistence

Reboot the system:

```bash
sudo reboot
```

After reconnecting, check Thunderbolt authorization:

```bash
boltctl
```

Check network interfaces:

```bash
ip -br link
```

Check Ethernet controllers:

```bash
lspci | grep -i ethernet
```

The Thunderbolt adapter should automatically be authorized and the second Ethernet controller should appear without manually writing to the `authorized` sysfs entry.

An authorization state may include:

```text
status: authorized
authflags: boot
policy: auto
```

## 10. Bring Up the Thunderbolt Ethernet Interface

A successfully detected interface may initially appear as:

```text
<THUNDERBOLT-INTERFACE>    DOWN
```

This does not necessarily indicate a hardware problem.

Bring the interface administratively up:

```bash
sudo ip link set <THUNDERBOLT-INTERFACE> up
```

Check the interface:

```bash
ip -br link
```

With an active physical Ethernet connection, the interface should include:

```text
UP,LOWER_UP
```

## 11. Validate the Physical Ethernet Link

With an Ethernet cable connected to an active switch port:

```bash
sudo ethtool <THUNDERBOLT-INTERFACE> | grep -E 'Speed|Duplex|Link detected'
```

A successful Gigabit Ethernet connection should report:

```text
Speed: 1000Mb/s
Duplex: Full
Link detected: yes
```

This confirms the complete path:

```text
Mac mini
   │
Thunderbolt
   │
Thunderbolt Ethernet Adapter
   │
PCIe Ethernet Controller
   │
Linux Network Interface
   │
1 Gb/s Full Duplex
   │
Switch
```

At this point, dual physical Ethernet functionality has been restored and validated.

Do not assign WAN/LAN addresses until the firewall network configuration is ready.

# Reference and Troubleshooting

## Interface States

### `UP` and `LOWER_UP`

Example:

```text
<BROADCAST,MULTICAST,UP,LOWER_UP>
```

`UP` indicates that the interface is administratively enabled.

`LOWER_UP` indicates that the physical layer reports an active carrier.

Together, these normally indicate an enabled interface with an active physical Ethernet connection.

### `NO-CARRIER`

Example:

```text
<NO-CARRIER,BROADCAST,MULTICAST,UP>
```

The interface is administratively enabled but does not currently detect a physical Ethernet carrier.

Possible causes include:

- Ethernet cable disconnected
- Switch port disabled
- Adapter disconnected
- Link negotiation in progress
- Physical cabling problem

### `DOWN`

An interface can exist normally while remaining administratively down.

Bring it up with:

```bash
sudo ip link set <INTERFACE> up
```

## IP Address Considerations

Bringing an interface up does **not** automatically assign an IPv4 address.

Check addresses with:

```bash
ip -br addr
```

An interface can have:

```text
Link: UP
Speed: 1000 Mb/s
IP: none
```

and still be functioning correctly at Layer 1 and Layer 2.

For a firewall deployment, avoid unintentionally assigning addresses from the same LAN subnet to both independent physical interfaces.

For example:

```text
NIC 1 ── 10.0.0.x/24
NIC 2 ── 10.0.0.y/24
```

This can introduce unintended routing and neighbor-resolution behavior unless the configuration is deliberate.

Instead, assign explicit network roles as part of the firewall deployment:

```text
NIC 1 → WAN
NIC 2 → LAN
```

## PCI Address and Interface Naming

Thunderbolt devices are dynamically enumerated through PCIe.

As a result, a Thunderbolt Ethernet controller's PCI bus address may change between boots.

For example:

```text
XX:00.0
```

may become:

```text
YY:00.0
```

after a reboot or hardware re-enumeration.

This does not necessarily indicate a problem.

Do not use the Thunderbolt PCI bus address as the primary persistent identifier for network configuration.

Linux interface names may also differ after a fresh operating system installation. Always discover the current interface names before applying configuration.

## Virtual Interface Note

Docker and other virtualization technologies may create additional Linux network interfaces.

Common Docker interfaces include:

```text
docker0
br-xxxxxxxxxxxx
vethxxxxxxxx
```

These are virtual interfaces and should not be confused with physical Ethernet adapters.

A `docker0` interface showing:

```text
DOWN
NO-CARRIER
```

does not necessarily indicate that Docker itself is down.

For example, containers attached to a custom Docker bridge may leave the default `docker0` bridge unused.

Check Docker independently with:

```bash
sudo systemctl status docker
```

List running containers:

```bash
docker ps
```

## Quick Troubleshooting Commands

### Network Interfaces

```bash
ip -br link
```

### IP Addresses

```bash
ip -br addr
```

### Ethernet Controllers

```bash
lspci | grep -i ethernet
```

### Ethernet and Thunderbolt PCI Devices

```bash
lspci -nn | grep -iE 'ethernet|thunderbolt'
```

### Detailed Network Hardware

```bash
sudo lshw -class network
```

### Ethernet Link Status

```bash
sudo ethtool <INTERFACE>
```

### Thunderbolt Devices and Authorization

```bash
boltctl
```

### Thunderbolt Kernel Messages

```bash
sudo dmesg | grep -i thunderbolt
```

### Ethernet and Thunderbolt Kernel Messages

```bash
sudo dmesg | grep -iE 'thunderbolt|ethernet|tg3'
```

### Recent Kernel Events

```bash
sudo dmesg | tail -100
```

### PolicyKit Status

```bash
systemctl status polkit
```

## Troubleshooting Sequence

If the Thunderbolt Ethernet interface does not appear, check the system in this order:

```text
1. Is the Thunderbolt adapter physically detected?
              │
              ▼
           boltctl
              │
              ▼
2. Does the kernel detect Thunderbolt?
              │
              ▼
   dmesg | grep -i thunderbolt
              │
              ▼
3. Is the Thunderbolt device authorized?
              │
              ▼
      authorized = 1
              │
              ▼
4. Did the Ethernet controller enumerate?
              │
              ▼
   lspci | grep -i ethernet
              │
              ▼
5. Did Linux create the interface?
              │
              ▼
         ip -br link
              │
              ▼
6. Is the interface administratively up?
              │
              ▼
       ip link set ... up
              │
              ▼
7. Is physical carrier detected?
              │
              ▼
           ethtool
```

This separates Thunderbolt authorization problems from PCIe enumeration, Linux interface, and physical Ethernet problems.

# Validation Checklist

Before considering the dual-Ethernet configuration complete, verify:

- [ ] Built-in Ethernet controller is detected
- [ ] Built-in Ethernet interface is identified
- [ ] Thunderbolt adapter is detected by `boltctl`
- [ ] Thunderbolt security state is identified
- [ ] Thunderbolt adapter can be authorized
- [ ] Second Ethernet controller appears in `lspci`
- [ ] Second Linux Ethernet interface appears
- [ ] Thunderbolt adapter is enrolled with `boltd`
- [ ] Authorization policy is `auto`
- [ ] Adapter remains authorized after reboot
- [ ] Second Ethernet controller automatically enumerates after reboot
- [ ] Thunderbolt Ethernet interface can be brought administratively up
- [ ] Physical Ethernet carrier is detected
- [ ] Link negotiates at 1 Gb/s
- [ ] Link negotiates at full duplex

Once these checks pass, the Mac mini has two independently usable physical Gigabit Ethernet interfaces and is ready for WAN/LAN assignment as part of a separate firewall or network-security deployment.
