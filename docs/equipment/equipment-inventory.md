# 🖥️ Equipment Inventory

This document serves as the centralized inventory for hardware and infrastructure assets used throughout the Enterprise Homelab.

As the homelab evolves, this document will be updated to reflect new equipment, replacements, upgrades, and decommissioned assets.

<p align="left">
  <img src="../../diagrams/optiplex-fleet-02.jpeg"
       alt="Optiplex Fleet"
       width="500">
</p>

---

## Inventory Summary

| Asset | Type | CPU | RAM | Storage | Role |
|---|---|---|---:|---|---|
| ASUS RT-AX5400 | Router | 1.5 GHz tri-core | 512 MB | N/A | Primary Home Router |
| Cisco WS-C3560CG-8PC-S | Network Switch | PowerPC-class | 128 MB | N/A | Networking & VLAN Lab |
| Synology DS718+ | Storage | Celeron J3455 | 2 GB | 2 × 8 TB HDD | NAS |
| OptiPlex 3070 | Virtualization Server | Core i5-9500T (6C/6T) | 32 GB | 1 TB SATA + 1 TB NVMe | Proxmox Cluster Node |
| OptiPlex 7040-01 | Virtualization Server | Core i7-6700T (4C/8T) | 16 GB | 1 TB SATA + 1 TB NVMe | Proxmox Cluster Node |
| OptiPlex 7040-02 | Virtualization Server | Core i7-6700T (4C/8T) | 8 GB | 500 GB HDD + 500 GB NVMe | Proxmox Cluster Node |
| Mac Mini (Late 2014) | Server | Core i5-4260U | 4 GB | 256 GB SSD | Media Services |
| Latitude 7420 | Laptop | Core i7-1185G7 | 32 GB | 256 GB NVMe | Administration & Testing |
| Desktop-01 | Workstation | Ryzen 7 5700X (8C/16T) | 64 GB | 2 × 1 TB NVMe | Pending Assignment |
| Desktop-02 | Workstation | Pending | Pending | Pending | Pending Assignment |



## Asset Categories

### Servers

Systems used for infrastructure services, virtualization, application hosting, and enterprise lab workloads.

### Storage

Devices used for centralized storage, backup, and data protection.

### Networking

Switches, routers, firewalls, and other network infrastructure devices used for connectivity, segmentation, and security.

### Endpoints

Workstations and laptops used for administration, testing, development, and day-to-day management.



## Lifecycle Management

Future updates to this inventory may include:

- Asset acquisition dates
- Hardware upgrades
- Warranty information
- Power consumption metrics
- Asset tagging
- Decommissioning records
- Asset replacement history



## Related Projects

- [Media Services Platform](../projects/media-services-platform/)
- [Virtualization Lab](../projects/virtualization-lab/)
- [Network Infrastructure](../projects/network-infrastructure/)
- [Infrastructure Monitoring](../projects/infrastructure-monitoring/)
- [Backup & Disaster Recovery](../projects/backup-disaster-recovery/)
