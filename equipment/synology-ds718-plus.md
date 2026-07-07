# Synology DS718+

## Overview

The Synology DS718+ is the centralized storage platform for the homelab. It provides network-attached storage for media content, file shares, and future backup targets, and serves media libraries to the Media Services Platform over a read-only SMB/CIFS share.

| | |
|---|---|
| **Type** | Storage (NAS) |
| **Role** | Network Attached Storage |
| **Hostname (Documentation)** | nas-lab |
| **Status** | Active |

---

## Hardware Specifications

| Component | Details |
|------------|------------|
| Platform | Synology DiskStation DS718+ |
| CPU | Intel Celeron J3455 @ 1.5 GHz (quad-core, burst up to 2.3 GHz) |
| Memory | 2 GB DDR3L |
| Drive Bays | 2 (3.5"/2.5" SATA) |
| Installed Storage | 2 × 8 TB HDD |
| Network | 2 × Gigabit Ethernet |
| Operating System | Synology DSM |

---

## Current Role

- Central storage for media libraries consumed by the Media Services Platform
- SMB/CIFS file sharing with dedicated, least-privilege service accounts
- Read-only media share exported to media-server-lab

### Access Model

A dedicated service account is used for the Jellyfin SMB mount rather than a personal or administrative account, limiting exposure if credentials are compromised. Administrative changes to media content are performed directly on the NAS, not through client systems.

---

## Platform Considerations

### Advantages

- Purpose-built storage appliance with low administrative overhead
- DSM provides mature SMB, user, and permission management
- Expandable via Synology expansion unit if capacity requirements grow

### Limitations

- 2 GB memory limits containerized workloads on the NAS itself
- Two drive bays constrain redundancy and capacity options
- Aging platform; DSM support lifecycle should be monitored

---

## Future Plans

- Serve as backup target for the Backup & Disaster Recovery project
- Evaluate snapshot and replication features for data protection
- Document volume layout and redundancy configuration

---

## Related Documentation

- [Media Services Platform](../projects/media-services-platform/)
- [SMB Storage Integration](../projects/media-services-platform/smb-storage.md)
- [Backup & Disaster Recovery](../projects/backup-disaster-recovery/)
