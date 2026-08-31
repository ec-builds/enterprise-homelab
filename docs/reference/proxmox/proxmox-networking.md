# 🌐 Proxmox Networking Reference

Quick reference for configuring and troubleshooting Proxmox VE management and cluster networking.

> Examples use a fictional 10.0.0.0/24 lab network, generic hostnames, and placeholder interface information. Values do not represent the production or internal addressing of the documented environment.

## Standard Proxmox Bridge

Proxmox typically places the management IP on a Linux bridge such as `vmbr0`, rather than directly on the physical NIC.

```text
Physical NIC (eth0)
        │
        ▼
Linux Bridge (vmbr0)
        │
        ├── Proxmox management
        ├── VM network interfaces
        └── Cluster communication
```

The physical interface normally has no IP configuration:

```text
iface eth0 inet manual
```

The management IP belongs to `vmbr0`.

## Standard Static Configuration

For persistent infrastructure, particularly clustered nodes, configure the management address statically on the host.

```text
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

This produces the following relationship:

```text
eth0
 │
 │ manual / no host IP
 ▼
vmbr0
 │
 ├── 10.0.0.10/24
 ├── Default gateway
 ├── Proxmox management
 └── VM networking
```

## Check Current Network Configuration

### Interface Configuration

```bash
cat /etc/network/interfaces
```

### Current Addresses

```bash
ip addr show vmbr0
```

A statically configured address should appear similar to:

```text
inet 10.0.0.10/24 scope global vmbr0
    valid_lft forever preferred_lft forever
```

A DHCP-managed address typically includes `dynamic` and lease timers:

```text
inet 10.0.0.10/24 scope global dynamic vmbr0
    valid_lft 86000sec preferred_lft 86000sec
```

### Routing Table

```bash
ip route
```

Expected default route:

```text
default via 10.0.0.1 dev vmbr0
```

## Static IP vs DHCP

### Static Addressing

Recommended for persistent Proxmox infrastructure:

```text
iface vmbr0 inet static
        address 10.0.0.10/24
        gateway 10.0.0.1
```

Static host-level addressing is especially useful for:

- Proxmox cluster nodes
- Corosync communication
- Predictable hostname resolution
- Infrastructure monitoring
- Administrative access

### DHCP

A standalone Proxmox host can obtain its management address through DHCP:

```text
iface vmbr0 inet dhcp
```

Example:

```text
auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0
```

A DHCP reservation can make the assigned address predictable, but the host still considers the address dynamically assigned.

```text
DHCP Reservation
       │
       ▼
DHCP Server
       │
       ▼
vmbr0 → dynamic address
```

This differs from configuring the address directly on the host:

```text
/etc/network/interfaces
       │
       ▼
vmbr0 → static address
```

For clustered Proxmox nodes, prefer host-level static addressing.

## Hostname Resolution

The Proxmox hostname should resolve consistently to the node's management address.

Check:

```bash
hostname
hostname -I
getent hosts $(hostname)
```

Example:

```text
$ hostname
pve01

$ hostname -I
10.0.0.10

$ getent hosts pve01
10.0.0.10    pve01.example.test pve01
```

The management address and resolved hostname should agree.

Local hostname mappings can be inspected in:

```bash
cat /etc/hosts
```

Example:

```text
10.0.0.10 pve01.example.test pve01
```

## Cluster Networking

Proxmox clustering uses Corosync for node-to-node cluster communication.

A basic deployment can use the existing management network:

```text
                    LAN
                     │
          ┌──────────┴──────────┐
          │                     │
        vmbr0                 vmbr0
          │                     │
       pve01                  pve02
     10.0.0.10              10.0.0.11
          │                     │
          └──── Corosync ───────┘
                  Link 0
```

For a small lab, using the management network for **Corosync Link 0** is sufficient.

Larger or production-oriented environments may use additional physical interfaces or dedicated networks for cluster traffic and redundancy.

Multiple Corosync links should represent genuinely independent network paths when redundancy is required.

## Issue 1 — Proxmox Has Two IPv4 Addresses

### Symptom

```bash
ip addr show vmbr0
```

shows something similar to:

```text
inet 10.0.0.20/24 scope global vmbr0
    valid_lft forever

inet 10.0.0.10/24 scope global secondary dynamic vmbr0
    valid_lft 86000sec
```

### Meaning

The interface has both:

```text
10.0.0.20 → static address
10.0.0.10 → DHCP address
```

Useful indicators:

| Output | Meaning |
|---|---|
| `valid_lft forever` | Typically statically configured |
| `dynamic` | Dynamically assigned |
| `secondary` | Additional address on the interface |

### Cause

An installation-time static address may still be configured while a DHCP client has also obtained an address.

Check:

```bash
cat /etc/network/interfaces
```

If DHCP should control the management IP, change:

```text
iface vmbr0 inet static
        address 10.0.0.20/24
        gateway 10.0.0.1
```

to:

```text
iface vmbr0 inet dhcp
```

If the host will become a cluster node, prefer resolving the conflict in the opposite direction: remove DHCP and retain a single static management address.

After networking is reapplied or the host is rebooted, verify:

```bash
ip addr show vmbr0
```

Only the intended management IPv4 address should remain.

## Issue 2 — Boot Screen Shows the Old Management IP

### Symptom

The network interface is correctly using the new address:

```text
10.0.0.10
```

but the Proxmox console still displays an old address:

```text
https://10.0.0.20:8006/
```

### Cause

The old installation-time address may still be associated with the Proxmox hostname in:

```text
/etc/hosts
```

Check:

```bash
cat /etc/hosts
```

Example old entry:

```text
10.0.0.20 pve01.example.test pve01
```

Update it to the current management address:

```text
10.0.0.10 pve01.example.test pve01
```

After rebooting, the console should advertise the correct management URL:

```text
https://10.0.0.10:8006/
```

## Issue 3 — No Address Available for Corosync Link 0

### Symptom

When creating a Proxmox cluster, the **Link 0** address selection does not contain the expected management address.

### Check Address Assignment

```bash
ip addr show vmbr0
```

If the address appears as dynamically assigned:

```text
inet 10.0.0.10/24 scope global dynamic vmbr0
```

review the management configuration:

```bash
cat /etc/network/interfaces
```

For a cluster node, configure a stable host-level address:

```text
auto vmbr0
iface vmbr0 inet static
        address 10.0.0.10/24
        gateway 10.0.0.1
        bridge-ports eth0
        bridge-stp off
        bridge-fd 0
```

### Check Hostname Resolution

Verify that the node hostname resolves to the same management address:

```bash
hostname -I
getent hosts $(hostname)
```

Expected:

```text
10.0.0.10
10.0.0.10    pve01.example.test pve01
```

If the hostname resolves to an obsolete address, inspect:

```bash
cat /etc/hosts
```

and correct the mapping before creating the cluster.

### Validation

After correcting the network configuration:

```bash
ip addr show vmbr0
hostname -I
getent hosts $(hostname)
ip route
```

Confirm that:

- `vmbr0` has one intended management IPv4 address.
- The address is statically configured.
- The hostname resolves to that address.
- The default gateway uses `vmbr0`.
- The expected management address is available for Corosync Link 0.

## Verify Final Configuration

### Bridge

```bash
ip addr show vmbr0
```

### Routing

```bash
ip route
```

### Hostname Resolution

```bash
getent hosts $(hostname)
```

### Persistent Configuration

```bash
cat /etc/network/interfaces
cat /etc/hosts
```

Expected management path:

```text
Client
  │
  ▼
LAN
  │
  ▼
eth0
  │
  ▼
vmbr0 (Static Management IP)
  │
  ├── Proxmox Web UI :8006
  ├── VM networking
  └── Corosync Link 0
```

## Quick Validation Commands

```bash
# Interface configuration
cat /etc/network/interfaces

# Active bridge address
ip addr show vmbr0

# Routing
ip route

# Hostname
hostname

# Management addresses
hostname -I

# Hostname resolution
getent hosts $(hostname)

# Local hostname mappings
cat /etc/hosts
```

## Key Takeaways

| Item | Purpose |
|---|---|
| Physical NIC | Connects the host to the physical network |
| `vmbr0` | Linux bridge carrying management and VM traffic |
| Static management IP | Provides a stable endpoint for infrastructure and clustering |
| `/etc/network/interfaces` | Defines persistent interface and IP configuration |
| `/etc/hosts` | Provides local hostname-to-address mapping |
| `ip addr` | Shows currently active addresses |
| `ip route` | Shows routing and the default gateway |
| `getent hosts` | Validates hostname resolution |
| DHCP reservation | Makes a DHCP assignment predictable but does not make it host-static |
| Corosync Link 0 | Primary cluster communication path |
| Port `8006` | Default Proxmox VE web interface |

> **Caution:** Changing the management IP remotely can disconnect the current SSH or web session. Prefer local console access or a planned maintenance window when making significant management-network changes.
