# Compute Platform

## Overview

The Media Services Platform runs as a dedicated Debian 13 virtual machine on the Proxmox VE virtualization platform.

The workload was originally hosted directly on a Late 2014 Mac mini before being migrated to the homelab's virtualized compute environment.


## Compute Platform

| Component | Details |
|---|---|
| Virtualization Platform | Proxmox VE |
| Physical Host | `prox-lab-03` |
| Virtual Machine | `media-lab-vm` |
| Guest Operating System | Debian GNU/Linux 13 (Trixie) |
| Application Runtime | Docker Engine |
| Application | Jellyfin |
| Media Storage | Centralized NAS via read-only SMB mount |

## Virtual Machine Resources

| Resource | Allocation |
|---|---|
| vCPU | 2 vCPU |
| Memory | 4 GB |
| System Disk | 64 GB |
| Network | Virtual Ethernet |

> Virtual resources can be adjusted through Proxmox VE as workload requirements change.

## Storage

| Storage | Location | Purpose |
|---|---|---|
| VM System Disk | Proxmox-managed virtual disk | Operating system and Docker runtime |
| Jellyfin Configuration | `/opt/docker/jellyfin/config` | Persistent application configuration |
| Jellyfin Cache | `/opt/docker/jellyfin/cache` | Application cache |
| Media Library | `/mnt/media` | Read-only centralized media storage |

Primary media is not stored within the virtual machine and remains independent of the application workload.

## Platform Evolution

| | Original | Current |
|---|---|---|
| Compute | Late 2014 Mac Mini | Proxmox VE host |
| Deployment | Physical / standalone | Virtual machine |
| Operating System | Debian 13 | Debian 13 |
| Application | Native Jellyfin | Dockerized Jellyfin |
| Resources | Fixed physical hardware | Virtualized and adjustable |
| Media Storage | Centralized NAS | Centralized NAS |

## Validation

```bash
hostnamectl
lscpu
free -h
lsblk
```
