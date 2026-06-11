# Hardware

## Overview

This document provides hardware specifications and platform information for the Media Services Platform.

The platform is currently deployed on a repurposed **Late 2014 Mac Mini**, demonstrating that enterprise concepts and self-hosted services can be implemented using affordable, second-hand hardware.

---

<p align="left">
  <img src="../../diagrams/mac-mini-2014.jpeg" alt="Late 2014 Mac Mini" width="300">
  <br>
  <em>Late 2014 Mac Mini (Macmini7,1)</em>
</p>

---

## Hardware Specifications

| Component | Details |
|------------|------------|
| Platform | Apple Mac Mini (Late 2014) |
| Model Identifier | Macmini7,1 |
| CPU | Intel Core i5-4260U @ 1.40 GHz |
| Memory | 4 GB DDR3 1600 MHz (2 × 2 GB) |
| Storage | 256 GB SSD |
| Network | Gigabit Ethernet |
| Operating System | Debian GNU/Linux 13 (Trixie) |
| Hostname (Documentation) | media-server-lab |
| Project Role | Media Services Platform |

---

## Storage Layout

| Partition | Size | Purpose |
|------------|------------|------------|
| EFI System Partition | 976 MB | Boot files and EFI configuration |
| Root Filesystem | 251.3 GB | Debian operating system and application data |
| Swap | 3.9 GB | Virtual memory |

---

## Platform Considerations

### Advantages

- Low power consumption
- Quiet operation
- Small physical footprint
- Reliable Intel-based platform
- Suitable for Linux server workloads

### Limitations

- Limited memory capacity (4 GB)
- Older mobile-class processor
- Limited internal storage expansion
- No dedicated hardware transcoding currently configured

---

## Future Plans

The current hardware serves as a foundation for learning Linux administration, storage integration, and self-hosted services.

Potential future enhancements include:

- Migration to a virtualized environment
- Hardware upgrades where supported
- Expanded monitoring and observability
- Backup and disaster recovery integration

---

## Validation

System information was collected using:

```bash
hostnamectl
lscpu
free -h
lsblk
```

---

## Outcome

The Late 2014 Mac Mini provides a stable and cost-effective platform for hosting the Media Services Platform while supporting hands-on learning in Linux administration and self-hosted infrastructure.
