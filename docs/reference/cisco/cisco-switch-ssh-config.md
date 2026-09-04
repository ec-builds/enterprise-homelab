# Cisco Switch SSH Configuration

## Overview

This document outlines the configuration of SSH management access on a Cisco Catalyst switch.

The procedure was validated on:

- **Platform:** Cisco Catalyst 3560-CG
- **IOS:** Cisco IOS 15.2(2)E
- **SSH:** Version 2
- **Client:** macOS OpenSSH

The configuration provides:

- A static management IP
- Local administrator authentication
- Privileged EXEC protection
- SSHv2 remote management
- RSA host keys
- SSH-only VTY access
- Compatibility guidance for modern OpenSSH clients

> [!NOTE]
> Cisco IOS 15.2 on this platform uses an older SSH implementation. Modern OpenSSH clients may require host-specific compatibility options to connect.


## Prerequisites

Before configuring SSH:

- Connect to the switch through the serial console.
- Enter Privileged EXEC mode.
- Confirm the switch is connected to the management network.
- Select an unused management IP address.
- Identify the subnet mask and default gateway.

Example addressing used throughout this document:

```text
Management IP:   10.0.0.2
Subnet Mask:     255.255.255.0
Default Gateway: 10.0.0.1
```

> [!NOTE]
> Replace example addressing, usernames, hostnames, and domains with values appropriate for the environment.


## Enter Global Configuration Mode

From Privileged EXEC mode:

```text
Switch#
```

Enter:

```text
configure terminal
```

The prompt changes to:

```text
Switch(config)#
```


## Configure the Hostname

Set a descriptive hostname:

```text
hostname switch-lab-01
```

The prompt changes to:

```text
switch-lab-01(config)#
```


## Disable DNS Lookup

By default, IOS may interpret an unrecognized command as a hostname and attempt DNS resolution.

For example, mistyping:

```text
relaod
```

may result in:

```text
Translating "relaod"...domain server
```

Disable this behavior:

```text
no ip domain-lookup
```


## Configure the Enable Secret

Configure a password for Privileged EXEC access:

```text
enable secret <ENABLE_SECRET>
```

Do not use an actual password in documentation or configuration examples.

> [!IMPORTANT]
> Use a strong, unique secret and store it securely.


## Create a Local Administrator

Create a local account with privilege level 15:

```text
username <ADMIN_USER> privilege 15 secret <ADMIN_PASSWORD>
```

Example:

```text
username admin privilege 15 secret <ADMIN_PASSWORD>
```

Privilege level 15 provides full administrative access to IOS.


## Configure the Management Interface

A Layer 2 switch is typically managed through a Switch Virtual Interface (SVI).

For a simple flat network using VLAN 1:

```text
interface vlan 1
```

Assign the management IP:

```text
ip address 10.0.0.2 255.255.255.0
```

Enable the SVI:

```text
no shutdown
```

Return to global configuration mode:

```text
exit
```

> [!NOTE]
> VLAN 1 is used here for a simple flat lab environment. In a segmented network, management access should typically be moved to a dedicated management VLAN.


## Configure the Default Gateway

Configure the upstream router or firewall as the switch's default gateway:

```text
ip default-gateway 10.0.0.1
```

This allows management traffic to reach networks outside the switch's local subnet.


## Verify the Management Interface

Return to Privileged EXEC mode:

```text
end
```

Verify interface status:

```text
show ip interface brief
```

Expected output once at least one physical port in the VLAN is active:

```text
Interface              IP-Address      OK? Method Status    Protocol
Vlan1                  10.0.0.2        YES manual up        up
```

The SVI may initially display:

```text
Vlan1                  10.0.0.2        YES manual up        down
```

This can occur when no physical interface assigned to that VLAN currently has an active link.

Once an associated physical interface becomes active, the SVI should transition to:

```text
up    up
```


## Configure the Domain Name

RSA key generation requires a hostname and domain name.

Return to global configuration mode:

```text
configure terminal
```

Configure the domain:

```text
ip domain-name lab.example.com
```

With:

```text
hostname switch-lab-01
```

IOS uses the resulting identity:

```text
switch-lab-01.lab.example.com
```


## Generate the RSA Host Key

Check the supported RSA modulus sizes:

```text
crypto key generate rsa modulus ?
```

On supported IOS versions, output may show a range such as:

```text
<360-4096>  size of the key modulus
```

Generate a 2048-bit RSA key:

```text
crypto key generate rsa modulus 2048
```

IOS should report:

```text
The name for the keys will be: switch-lab-01.lab.example.com

% The key modulus size is 2048 bits
% Generating 2048 bit RSA keys, keys will be non-exportable...
[OK]
```

> [!NOTE]
> RSA-2048 provides an appropriate balance for legacy Catalyst hardware. Larger keys may be supported but increase computational requirements without modernizing the switch's underlying SSH implementation.


## Require SSH Version 2

Key generation may initially cause IOS to report SSH version `1.99`, indicating compatibility with SSH versions 1 and 2.

Explicitly require SSHv2:

```text
ip ssh version 2
```

SSH version 1 should not be enabled.


## Configure VTY Authentication

Configure the virtual terminal lines used for remote management:

```text
line vty 0 15
```

Require authentication against the local user database:

```text
login local
```

Allow SSH and disable Telnet:

```text
transport input ssh
```

Exit VTY configuration:

```text
exit
```

The resulting configuration is:

```text
line vty 0 15
 login local
 transport input ssh
```


## Verify SSH Configuration

Return to Privileged EXEC mode:

```text
end
```

Verify SSH:

```text
show ip ssh
```

Expected output includes:

```text
SSH Enabled - version 2.0
```

Older IOS releases may also report supported authentication methods and Diffie-Hellman parameters.


## Running EXEC Commands from Configuration Mode

Commands such as:

```text
show ip ssh
```

are EXEC commands and normally cannot be executed directly from:

```text
switch-lab-01(config)#
```

Either return to Privileged EXEC mode:

```text
end
```

or prefix the command with `do`:

```text
do show ip ssh
```

This is useful when verifying configuration without leaving global configuration mode.


## Test Network Connectivity

From another system on the management network, verify that the switch responds:

```bash
ping 10.0.0.2
```

An initial ping may occasionally time out while ARP resolution and Layer 2 forwarding state are established.

Subsequent responses should confirm connectivity.


## Test SSH from a Modern Client

Attempt a normal SSH connection first:

```bash
ssh <ADMIN_USER>@10.0.0.2
```

On modern OpenSSH releases, an older Cisco IOS implementation may fail negotiation with an error similar to:

```text
Unable to negotiate with 10.0.0.2 port 22:
no matching key exchange method found.
```

The switch may offer legacy key-exchange algorithms such as:

```text
diffie-hellman-group-exchange-sha1
diffie-hellman-group14-sha1
diffie-hellman-group1-sha1
```


## Legacy Key Exchange Compatibility

For a legacy Catalyst switch, selectively permit:

```text
diffie-hellman-group14-sha1
```

for the individual connection:

```bash
ssh \
  -oKexAlgorithms=+diffie-hellman-group14-sha1 \
  <ADMIN_USER>@10.0.0.2
```

Of the legacy methods offered by this IOS release, `diffie-hellman-group14-sha1` is preferred over `diffie-hellman-group1-sha1`.

> [!CAUTION]
> Do not enable legacy SSH algorithms globally when only a specific legacy device requires them.

Avoid enabling `diffie-hellman-group1-sha1` when a stronger supported option is available.


## Legacy SSH-RSA Host Key Compatibility

After enabling the required key-exchange method, a modern OpenSSH client may report:

```text
Unable to negotiate with 10.0.0.2 port 22:
no matching host key type found.
Their offer: ssh-rsa
```

Allow the legacy SSH-RSA host-key algorithm for the individual connection:

```bash
ssh \
  -oKexAlgorithms=+diffie-hellman-group14-sha1 \
  -oHostKeyAlgorithms=+ssh-rsa \
  <ADMIN_USER>@10.0.0.2
```

This permits the required legacy algorithms only for that SSH invocation.


## Verify the Host Key

The first successful connection should display a host-key fingerprint:

```text
The authenticity of host '10.0.0.2' can't be established.
RSA key fingerprint is SHA256:<FINGERPRINT>
```

Verify the fingerprint when possible before accepting it.

After verification, accept the host key:

```text
yes
```

The client stores the host key in its `known_hosts` database.

The administrator password should then be requested:

```text
(<ADMIN_USER>@10.0.0.2) Password:
```

A successful privilege-15 login should present:

```text
switch-lab-01#
```


## Why Modern OpenSSH Requires Compatibility Options

The switch may support SSHv2 while still relying on algorithms that modern OpenSSH versions disable by default.

For example:

```text
Legacy Cisco IOS                   Modern OpenSSH
────────────────                   ──────────────
SSHv2                    ←────→    SSHv2
RSA 2048 host key        ←────→    Supported key size

group14-sha1 KEX         ←─ X ─→   Disabled by default
ssh-rsa signatures       ←─ X ─→   Disabled by default
```

The **2048-bit RSA key size itself is not the primary compatibility problem**.

The issue is the older algorithms and SHA-1-based signatures used by the legacy IOS SSH implementation.


## Save the Configuration

Once remote management has been successfully tested, save the running configuration:

```text
write memory
```

Expected output:

```text
Building configuration...
[OK]
```

Alternatively:

```text
copy running-config startup-config
```

Verify that a startup configuration now exists:

```text
show startup-config
```


## Verify the Saved Configuration

Useful verification commands include:

```text
show ip interface brief
show ip ssh
show running-config
show startup-config
```

Long output may be paginated with:

```text
--More--
```

Controls include:

- `Space` — next page
- `Enter` — next line
- `Q` — quit

Pagination can temporarily be disabled for the current terminal session:

```text
terminal length 0
```


## Configuration Workflow

```text
Serial Console Access
        │
        ▼
Configure Hostname
        │
        ▼
Disable DNS Lookup
        │
        ▼
Configure Enable Secret
        │
        ▼
Create Local Administrator
        │
        ▼
Configure Management SVI
        │
        ▼
Configure Default Gateway
        │
        ▼
Configure Domain Name
        │
        ▼
Generate RSA-2048 Host Key
        │
        ▼
Require SSH Version 2
        │
        ▼
Configure VTY Lines
        │
        ├── login local
        └── transport input ssh
        │
        ▼
Verify Management Connectivity
        │
        ▼
Test SSH
        │
        ▼
Apply Per-Host Legacy Compatibility
if Required by Modern OpenSSH
        │
        ▼
Verify Remote Login
        │
        ▼
Save Configuration
```


## Quick Reference

### Cisco Configuration

```text
configure terminal

hostname switch-lab-01
no ip domain-lookup

enable secret <ENABLE_SECRET>
username <ADMIN_USER> privilege 15 secret <ADMIN_PASSWORD>

interface vlan 1
 ip address 10.0.0.2 255.255.255.0
 no shutdown
exit

ip default-gateway 10.0.0.1

ip domain-name lab.example.com

crypto key generate rsa modulus 2048
ip ssh version 2

line vty 0 15
 login local
 transport input ssh
exit

end
write memory
```


### Verification

```text
show ip interface brief
show ip ssh
show startup-config
```


### Modern OpenSSH Connection

Try the standard connection first:

```bash
ssh <ADMIN_USER>@10.0.0.2
```

If required by the legacy IOS SSH implementation:

```bash
ssh \
  -oKexAlgorithms=+diffie-hellman-group14-sha1 \
  -oHostKeyAlgorithms=+ssh-rsa \
  <ADMIN_USER>@10.0.0.2
```


## Key Takeaways

- SSH management requires IP connectivity to a switch management interface.
- A Layer 2 Catalyst switch can use an SVI as its management interface.
- VLAN 1 is acceptable for a simple flat lab, but a dedicated management VLAN is preferable in a segmented environment.
- Configure a local administrator and use `login local` for VTY authentication.
- `transport input ssh` prevents Telnet access through the VTY lines.
- SSH version 2 should be explicitly configured.
- RSA-2048 is appropriate for this legacy Catalyst platform.
- Older IOS SSH implementations may require compatibility exceptions on modern OpenSSH clients.
- `diffie-hellman-group14-sha1` is preferable to the weaker `diffie-hellman-group1-sha1` when legacy compatibility is required.
- Apply legacy SSH exceptions only to the affected device rather than weakening the client's global SSH configuration.
- Verify remote access before saving the configuration.
- Save the running configuration to NVRAM so it survives a reboot.
