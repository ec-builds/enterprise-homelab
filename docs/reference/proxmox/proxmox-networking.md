# 🌐 Proxmox Networking Reference

Quick reference for configuring and troubleshooting Proxmox VE management networking.

> Examples use the `10.0.0.0/24` lab network and generic host/interface information.

## Standard Proxmox Bridge

Proxmox typically places the management IP on a Linux bridge such as `vmbr0`, rather than directly on the physical NIC.

```text id="8vrp9v"
Physical NIC (eth0)
        │
        ▼
Linux Bridge (vmbr0)
        │
        ├── Proxmox management interface
        └── VM network interfaces
```

The physical interface normally has no IP configuration:

```text id="p2b0v2"
iface eth0 inet manual
```

The management IP belongs to `vmbr0`.

## Check Current Network Configuration

### Interface Configuration

```bash id="sp1v9b"
cat /etc/network/interfaces
```

Example static configuration:

```text id="yzdhpl"
auto lo
iface lo inet loopback

iface eth0 inet manual

auto vmbr0
iface vmbr0 inet static
        address 10.0.0.10/24
        gateway 10.0.0.1
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0

source /etc/network/interfaces.d/*
```

### Current Addresses

```bash id="jvqugy"
ip addr show vmbr0
```

### Routing Table

```bash id="n19xtm"
ip route
```

## Static IP vs DHCP

### Static

Proxmox installations commonly configure a static management address:

```text id="v5yy9p"
iface vmbr0 inet static
        address 10.0.0.10/24
        gateway 10.0.0.1
```

### DHCP

To have a DHCP server assign the management address:

```text id="dlp4ar"
iface vmbr0 inet dhcp
```

Example:

```text id="yp51ly"
auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0
```

For a server, a **DHCP reservation** can be used so the management address remains predictable.

## Issue 1 — Proxmox Has Two IPv4 Addresses

### Symptom

```bash id="4nhf02"
ip addr show vmbr0
```

shows something similar to:

```text id="pmg95d"
inet 10.0.0.20/24 scope global vmbr0
    valid_lft forever

inet 10.0.0.10/24 scope global secondary dynamic vmbr0
    valid_lft 86000sec
```

### Meaning

The interface has both:

```text id="8ivx7r"
10.0.0.20 → static address
10.0.0.10 → DHCP address
```

Useful indicators:

| Output | Meaning |
|---|---|
| `valid_lft forever` | Usually static |
| `dynamic` | Dynamically assigned |
| `secondary` | Additional address on the interface |

### Cause

An installation-time static address is still configured while a DHCP client has also obtained an address.

Check:

```bash id="3c5tjc"
cat /etc/network/interfaces
```

If DHCP should control the management IP, change:

```text id="n6llup"
iface vmbr0 inet static
        address 10.0.0.20/24
        gateway 10.0.0.1
```

to:

```text id="cmkz3b"
iface vmbr0 inet dhcp
```

Then verify:

```bash id="1c2gt5"
ip addr show vmbr0
```

Only the intended management IPv4 address should remain after networking is reapplied or the host is rebooted.

## Issue 2 — Boot Screen Shows the Old Management IP

### Symptom

The network interface is correctly using the new address:

```text id="vz43rp"
10.0.0.10
```

but the Proxmox console still displays an old address:

```text id="3kjn1x"
https://10.0.0.20:8006/
```

### Cause

The old installation-time address may still be associated with the Proxmox hostname in:

```text id="4qrlas"
/etc/hosts
```

Check:

```bash id="n0f1qu"
cat /etc/hosts
```

Example old entry:

```text id="rmfyx5"
10.0.0.20 pve01.example.test pve01
```

Update it to the current management address:

```text id="rzfggo"
10.0.0.10 pve01.example.test pve01
```

Edit with:

```bash id="z0fh43"
vi /etc/hosts
```

After rebooting, the console should advertise the correct management URL:

```text id="uwjrgv"
https://10.0.0.10:8006/
```

## Verify the Final Configuration

Check the bridge:

```bash id="dzyr3r"
ip addr show vmbr0
```

Check routing:

```bash id="e67g07"
ip route
```

Check hostname resolution:

```bash id="njkr21"
getent hosts $(hostname)
```

Review the configuration:

```bash id="7v0ntg"
cat /etc/network/interfaces
cat /etc/hosts
```

Expected management path:

```text id="81f33q"
Client
  │
  ▼
LAN
  │
  ▼
eth0
  │
  ▼
vmbr0 (Management IP)
  │
  ├── Proxmox Web UI :8006
  └── VM networking
```

## Key Takeaways

| Item | Purpose |
|---|---|
| Physical NIC | Connects the host to the physical network |
| `vmbr0` | Linux bridge carrying management and VM traffic |
| `/etc/network/interfaces` | Defines interface and IP configuration |
| `/etc/hosts` | Maps the Proxmox hostname to an IP address |
| `ip addr` | Shows currently active addresses |
| `ip route` | Shows routing and the default gateway |
| DHCP reservation | Keeps a DHCP-managed host on a predictable address |
| Port `8006` | Default Proxmox VE web interface |

> **Caution:** Changing the management IP remotely can disconnect the current SSH or web session. Prefer the local console when making significant management-network changes.
