# Backup Strategy

This document outlines the current backup approach for the Media Services Platform.

## Overview

The Media Services Platform stores application data locally while media content resides on a centralized NAS platform.

Because media files remain on the NAS and are mounted as a read-only share, backup efforts are primarily focused on preserving system configuration and Jellyfin metadata.

---

## Backup Scope

### Included

- Jellyfin configuration
- Jellyfin metadata and database
- Debian configuration files
- System documentation
- SMB mount configuration
- Service configuration files

### Excluded

- Media files (movies, music, television content)

Media files are stored and protected separately on the NAS platform.

---

## Backup Architecture

```text
media-server-lab
    ↓
Configuration Files
    ↓
Jellyfin Data
    ↓
Backup Archive
    ↓
nas-lab
```

---

## Current Backup Method

The current strategy uses periodic file-based backups copied to the NAS.

Important directories include:

```text
/etc
/var/lib/jellyfin
/var/cache/jellyfin
```

Example backup command:

```bash
sudo rsync -av \
/etc \
/var/lib/jellyfin \
/var/cache/jellyfin \
/backup-destination/
```

---

## Recovery Objectives

| Objective | Target |
|------------|------------|
| Operating System Recovery | Reinstall Debian |
| Jellyfin Recovery | Restore configuration and metadata |
| Media Recovery | Not required (stored on NAS) |
| Documentation Recovery | Available in GitHub repository |

---

## Future Enhancements

Planned improvements include:

- Scheduled automated backups
- Backup verification procedures
- Integration with NAS snapshot capabilities
- Migration to a virtualized environment
- Disaster recovery testing

---

## Related Documentation

- [Architecture](./architecture.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)
- [SMB Storage Configuration](./smb-storage.md)

---

## Outcome

The current backup strategy prioritizes protection of system configuration and application data while leveraging centralized NAS storage for media content. This approach provides a simple recovery path while maintaining operational simplicity.
