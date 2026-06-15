# 🖥️ Equipment Inventory

This document serves as the centralized inventory for hardware and infrastructure assets used throughout the Enterprise Homelab.

The purpose of this inventory is to document system specifications, intended use cases, lifecycle considerations, and infrastructure dependencies. As the homelab evolves, this document will be updated to reflect new equipment, replacements, upgrades, and decommissioned assets.

---

## Inventory Summary

| Asset | Type | CPU | RAM | Storage | Role | Status |
|---------|---------|---------|---------|---------|---------|---------|
| [ASUS RT-AX5400](./asus-rt-ax5400.md) | Router | 1.5 GHz tri-core processor | 512 MB | NA | Primary Home Network Router | Active |
| [Cisco WS-C3560CG-8PC-S](./cisco-switch-3560cg.md) | Network Switch | Embedded PowerPC-class CPU | 128 MB | NA | Networking & VLAN Lab | Available |
| [Desktop-01](./desktop-01.md) | Workstation | AMD Ryzen 7 5700X 8-Core Processor | 64 GB | 2x (1TB) NVMe Drives | Pending Assignment | Available |
| [Desktop-02](./desktop-02.md) | Workstation | Pending | Pending | Pending | Pending Assignment | Available |
| [Latitude 7420](./latitude-7420.md) | Laptop | Pending | 32 GB | Pending | Administration & Testing | Active |
| [Mac Mini (Late 2014)](./mac-mini-2014.md) | Server | Intel(R) Core(TM) i5-4260U CPU @ 1.40GHz | 4 GB | Pending | Media Services Platform | Active |
| [OptiPlex 3070](./optiplex-3070.md) | Server / Workstation | Pending | Pending | 2× NVMe Drives | Future Infrastructure Projects | Available |
| [OptiPlex 7040-01](./optiplex-7040-01.md) | Server / Workstation | Pending | Pending | 2× NVMe Drives | Future Infrastructure Projects | Available |
| [OptiPlex 7040-02](./optiplex-7040-02.md) | Server / Workstation | Pending | Pending | 2× NVMe Drives | Future Infrastructure Projects | Available |
| [Synology DS718+](./synology-ds718.md) | Storage | Intel Celeron J3455 | 2 GB | 2x (8TB) HDD | Network Attached Storage (NAS) | Active |

---

## Asset Categories

### Servers

Systems used for infrastructure services, virtualization, application hosting, and enterprise lab workloads.

### Storage

Devices used for centralized storage, backup, and data protection.

### Networking

Switches, routers, firewalls, and other network infrastructure devices used for connectivity, segmentation, and security.

### Endpoints

Workstations and laptops used for administration, testing, development, and day-to-day management.

---

## Lifecycle Management

Future updates to this inventory may include:

- Asset acquisition dates
- Hardware upgrades
- Warranty information
- Power consumption metrics
- Asset tagging
- Decommissioning records
- Asset replacement history

---

## Related Projects

- [Media Services Platform](../projects/media-services-platform/)
- [Virtualization Lab](../projects/virtualization-lab/)
- [Network Infrastructure](../projects/network-infrastructure/)
- [Infrastructure Monitoring](../projects/infrastructure-monitoring/)
- [Backup & Disaster Recovery](../projects/backup-disaster-recovery/)
