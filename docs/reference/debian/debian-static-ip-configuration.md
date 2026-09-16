# Debian Static IP Configuration

## Overview

This document provides a general reference for configuring a static IPv4 address on Debian Linux.

Debian systems may use different networking frameworks depending on the installation method, system role, and installed packages. Before changing network configuration, identify which networking framework currently manages the interface.

Common implementations include:

- `ifupdown`
- `systemd-networkd`
- NetworkManager

> [!Important]
> Do not modify the interface currently providing remote SSH connectivity unless console or alternate management access is available. An incorrect network configuration can immediately disconnect the system.



## Example Network Configuration

The examples in this document use placeholder addressing:

| Setting | Example |
|---|---|
| Interface | `ens18` |
| IPv4 Address | `10.0.0.50` |
| Prefix | `/24` |
| Default Gateway | `10.0.0.1` |
| Primary DNS | `10.0.0.10` |
| Secondary DNS | `10.0.0.11` |
| DNS Domain | `lab.example.com` |

Replace these values with those appropriate for the deployed environment.



## Identify the Network Interface

Display available interfaces and current addresses:

```bash
ip -br addr
```

Example:

```text
lo       UNKNOWN        127.0.0.1/8
ens18    UP             10.0.0.150/24
```

Display routing information:

```bash
ip route
```

The interface associated with the default route is typically the primary network interface.



## Identify the Networking Framework

### Check NetworkManager

```bash
systemctl is-active NetworkManager
```

### Check systemd-networkd

```bash
systemctl is-active systemd-networkd
```

### Check ifupdown

Inspect:

```bash
cat /etc/network/interfaces
```

and:

```bash
ls -la /etc/network/interfaces.d/
```

A configuration such as:

```text
allow-hotplug ens18
iface ens18 inet dhcp
```

indicates that the interface is configured through traditional Debian `ifupdown`.

Use the configuration method corresponding to the framework managing the interface.



# ifupdown

## Current DHCP Configuration

A DHCP-configured interface may appear in `/etc/network/interfaces` as:

```text
allow-hotplug ens18
iface ens18 inet dhcp
```

Back up the existing configuration before making changes:

```bash
sudo cp /etc/network/interfaces /etc/network/interfaces.backup
```

Edit the configuration:

```bash
sudo vi /etc/network/interfaces
```

Change the interface from DHCP to static addressing:

```text
allow-hotplug ens18
iface ens18 inet static
    address 10.0.0.50/24
    gateway 10.0.0.1
    dns-nameservers 10.0.0.10 10.0.0.11
    dns-search lab.example.com
```

Apply the configuration:

```bash
sudo ifdown ens18
sudo ifup ens18
```

> [!Warning]
> Running `ifdown` on an interface being used for SSH will interrupt the connection. Use local or hypervisor console access when possible.

> [!Note]
> When changing an active interface from DHCP to static, the old DHCP address or routes may remain temporarily. Verify with `ip -br addr` and `ip route`. If they remain, a planned reboot provides a clean network restart.

A reboot may also be used during a planned maintenance window:

```bash
sudo reboot
```



# systemd-networkd

Create or edit the appropriate `.network` file:

```bash
sudo vi /etc/systemd/network/20-wired.network
```

Example:

```ini
[Match]
Name=ens18

[Network]
Address=10.0.0.50/24
Gateway=10.0.0.1
DNS=10.0.0.10
DNS=10.0.0.11
Domains=lab.example.com
```

Restart the networking service:

```bash
sudo systemctl restart systemd-networkd
```



# NetworkManager

List connections:

```bash
nmcli connection show
```

Identify the connection associated with the target interface.

Configure static IPv4 addressing:

```bash
sudo nmcli connection modify "Wired connection 1" \
    ipv4.method manual \
    ipv4.addresses 10.0.0.50/24 \
    ipv4.gateway 10.0.0.1 \
    ipv4.dns "10.0.0.10 10.0.0.11" \
    ipv4.dns-search "lab.example.com"
```

Apply the configuration:

```bash
sudo nmcli connection up "Wired connection 1"
```



# Validation

## Verify Address

```bash
ip -br addr
```

Confirm the expected static IPv4 address is assigned.

## Verify Default Route

```bash
ip route
```

Expected structure:

```text
default via 10.0.0.1 dev ens18
10.0.0.0/24 dev ens18 proto kernel scope link
```

## Verify Gateway Connectivity

```bash
ping -c 4 10.0.0.1
```

## Verify DNS Configuration

Depending on the resolver configuration:

```bash
cat /etc/resolv.conf
```

or:

```bash
resolvectl status
```

## Verify DNS Resolution

```bash
getent hosts example.com
```

If internal DNS is deployed, also test an appropriate internal hostname:

```bash
getent hosts server01.lab.example.com
```

## Verify Internet Connectivity

Test connectivity without relying on DNS:

```bash
ping -c 4 1.1.1.1
```

Then test DNS-dependent connectivity:

```bash
ping -c 4 example.com
```



# Operational Considerations

Static addresses should generally be assigned to infrastructure that must remain reachable independently of DHCP, such as:

- Hypervisors
- DNS and directory servers
- Network infrastructure
- Storage systems
- Management systems
- Selected infrastructure services

Client endpoints are generally better suited to DHCP.

Static addresses should be selected from address space intentionally reserved for static infrastructure and should not overlap with active DHCP allocation ranges.

Maintain the assignment in network documentation or an IP address management system to prevent duplicate addresses.



## Recovery

If a static configuration prevents network connectivity, access the system through its local or hypervisor console.

For `ifupdown`, restore the previous configuration:

```bash
sudo cp /etc/network/interfaces.backup /etc/network/interfaces
```

Then reboot or restart the affected networking configuration.



## Security and Documentation

Public documentation should not expose production or private-environment addressing plans, hostnames, DNS domains, interface identifiers unique to a system, credentials, or other environment-specific identifiers.

Use generalized examples such as:

```text
10.0.0.0/24
lab.example.com
server01
```

and maintain actual deployment values in private infrastructure documentation.
