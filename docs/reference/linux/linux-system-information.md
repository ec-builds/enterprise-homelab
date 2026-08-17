# 🐧 Linux System Information

Quick reference for collecting system information from Linux and Proxmox hosts.

## Command Reference

| Information | Command | Purpose |
|---|---|---|
| Host / OS | `hostnamectl` | Hostname, OS, kernel, hardware model |
| Distribution | `cat /etc/os-release` | Linux distribution and version |
| Kernel | `uname -r` | Running kernel |
| Proxmox | `pveversion -v` | Proxmox and package versions |
| CPU | `lscpu` | CPU model, cores, threads, virtualization |
| Memory | `free -h` | RAM and swap usage |
| Memory modules | `dmidecode -t memory` | DIMM size, speed, type, slots |
| Disks | `lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL` | Disks, partitions, filesystems, models |
| Filesystems | `df -h` | Filesystem capacity and usage |
| Disk health | `smartctl -a /dev/sda` | SMART health information |
| PCI hardware | `lspci` | NICs, GPUs, controllers, other PCI devices |
| Network summary | `ip -br addr` | Interfaces, status, and addresses |
| Network details | `ip link` | Interface and link information |
| Routes | `ip route` | Routes and default gateway |
| NIC details | `ethtool <interface>` | Link speed, duplex, negotiation |
| Network config | `cat /etc/network/interfaces` | Debian/Proxmox network configuration |
| System hardware | `dmidecode -t system` | Manufacturer and hardware model |
| BIOS | `dmidecode -t bios` | BIOS version and release date |
| Failed services | `systemctl --failed` | Detect failed systemd services |
| Proxmox storage | `pvesm status` | Configured Proxmox storage |
| Virtual machines | `qm list` | Proxmox VM inventory |
| Containers | `pct list` | Proxmox LXC inventory |

## Quick Copy/Paste

Use this when collecting information from a Linux or Proxmox host:

```bash
# Hostname / OS
hostnamectl
cat /etc/os-release
uname -r

# Proxmox version
pveversion
pveversion -v

# CPU
lscpu

# Memory
free -h

# Disks / storage
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
df -h

# PCI hardware
lspci

# Network
ip -br addr
ip link
ip route

# Network configuration
cat /etc/network/interfaces

# NIC details / link speed
ethtool <interface>

# System hardware
dmidecode -t system

# BIOS / firmware
dmidecode -t bios

# Memory modules
dmidecode -t memory

# Disk health
smartctl -a /dev/sda
smartctl -a /dev/nvme0n1

# System health
systemctl --failed

# Proxmox
pvesm status
qm list
pct list
```

Replace `<interface>` with the actual physical interface name.

Example:

```bash
ethtool eth0
```

Use `lsblk` to determine the correct disk names before running `smartctl`.

## System Information Script

Save as:

```text
system-info.sh
```

Script:

```bash
#!/bin/bash

echo "===== HOST / OS ====="
hostnamectl
cat /etc/os-release
uname -r

echo
echo "===== PROXMOX ====="
if command -v pveversion >/dev/null 2>&1; then
    pveversion
    pveversion -v
fi

echo
echo "===== CPU ====="
lscpu

echo
echo "===== MEMORY ====="
free -h

echo
echo "===== STORAGE ====="
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,MODEL
df -h

echo
echo "===== PCI HARDWARE ====="
lspci

echo
echo "===== NETWORK ====="
ip -br addr
ip link
ip route

echo
echo "===== NETWORK CONFIGURATION ====="
if [ -f /etc/network/interfaces ]; then
    cat /etc/network/interfaces
fi

echo
echo "===== SYSTEM HARDWARE ====="
dmidecode -t system

echo
echo "===== BIOS ====="
dmidecode -t bios

echo
echo "===== MEMORY MODULES ====="
dmidecode -t memory

echo
echo "===== FAILED SERVICES ====="
systemctl --failed

if command -v pvesm >/dev/null 2>&1; then
    echo
    echo "===== PROXMOX STORAGE ====="
    pvesm status

    echo
    echo "===== VIRTUAL MACHINES ====="
    qm list

    echo
    echo "===== CONTAINERS ====="
    pct list
fi
```

Make it executable:

```bash
chmod +x system-info.sh
```

Run:

```bash
./system-info.sh
```

Or save the results:

```bash
./system-info.sh > system-info.txt
```

## Before Publishing

Raw system-information output should be reviewed and sanitized before posting publicly.

| Remove / Sanitize | Safe to Keep |
|---|---|
| MAC addresses | Hardware model |
| Machine / Boot IDs | CPU model |
| Product UUID | CPU cores / threads |
| Hardware serial / service tag | RAM capacity |
| Disk / memory serial numbers | Storage model / capacity |
| Public IP addresses | Linux / Proxmox version |
| Private IP addresses | NIC model / speed |
| Internal hostnames / domains | General network design |
| Credentials or tokens | Generic interface names |

> **Note:** Commands such as `hostnamectl`, `ip addr`, `ip link`, `dmidecode`, and `smartctl` may expose unique system identifiers. Always review command output before adding it to public documentation.
