# 🌐 Proxmox Network Configuration

Network configuration for the Proxmox virtualization lab.

## Overview

The Proxmox host uses a Linux bridge to connect the management interface and virtual workloads to the physical network.

```text
Physical Network
       │
       ▼
     nic0
       │
       ▼
     vmbr0
       │
       ├── Proxmox Management
       ├── Virtual Machines
       └── LXC Containers
```

The physical NIC operates as a bridge port. The management IP is assigned to `vmbr0` rather than directly to `nic0`.

## Configuration

The host currently obtains its management address through DHCP.

```text
iface nic0 inet manual

auto vmbr0
iface vmbr0 inet dhcp
        bridge-ports nic0
        bridge-stp off
        bridge-fd 0
```

A DHCP reservation is used to provide predictable management addressing without configuring a static address directly on the host.

## Issue Encountered

The initial Proxmox installation configured a static management IP.

After switching the bridge to DHCP, `vmbr0` temporarily had two IPv4 addresses:

```text
vmbr0
├── 10.0.0.20/24     static
└── 10.0.0.10/24     DHCP
```

The persistent configuration in `/etc/network/interfaces` was changed from:

```text
iface vmbr0 inet static
```

to:

```text
iface vmbr0 inet dhcp
```

This removed the installation-time static configuration and left DHCP responsible for management addressing.

## Console Address Issue

After the network configuration was corrected, the Proxmox boot console continued displaying the original management address.

The old address remained associated with the Proxmox hostname in:

```text
/etc/hosts
```

Updating the hostname entry to the current management address corrected the URL displayed at boot.

## Validation

The final configuration was verified with:

```bash
ip -br addr
ip route
cat /etc/network/interfaces
cat /etc/hosts
```

Expected state:

```text
nic0
  │
  ▼
vmbr0
  │
  ├── DHCP management address
  └── Default gateway
```

## Current State

| Component | Configuration |
|---|---|
| Physical interface | `nic0` |
| Linux bridge | `vmbr0` |
| Management addressing | DHCP |
| Address consistency | DHCP reservation |
| STP | Disabled |
| Forward delay | 0 |
| Web management | HTTPS / TCP 8006 |

The host now has a single predictable management address and is ready to provide bridged networking to virtual machines and containers.

For configuration examples, commands, and troubleshooting procedures, see:

```text
Proxmox Networking Reference
```
