# 🎬 Media Libraries

This document outlines the media library structure used by the Media Services Platform.

The objective of the library design is to provide a simple, scalable, and organized structure that can be easily consumed by Jellyfin while remaining manageable on the NAS platform.

---

## Overview

Media content is stored on the NAS and presented to Jellyfin through a read-only SMB mount.

Jellyfin scans the mounted directories and automatically organizes content into libraries for browsing and playback.

```text
nas-lab
    ↓
Media Share
    ↓
/mnt/media
    ↓
Jellyfin Libraries
```

---

## Library Structure

The current deployment utilizes a dedicated Movies library.

```text
/mnt/media
└── movies
```

This structure provides a simple foundation for media organization while allowing future expansion as additional content types are added.

---

## Movies Library

### Path

```text
/mnt/media/movies
```

### Purpose

Stores feature films and movie collections.

### Jellyfin Library Type

```text
Movies
```

### Benefits

- Automatic metadata retrieval
- Poster and artwork downloads
- Cast and crew information
- Collection support
- Improved browsing experience

---

## Read-Only Access Model

Media libraries are mounted as read-only.

Benefits include:

- Protection against accidental file deletion
- Preservation of source media files
- Separation of storage and application responsibilities
- Reduced risk of application-related modifications

All media management activities are performed directly on the NAS rather than through the media server.

---

## Metadata Management

Jellyfin automatically retrieves metadata from configured providers.

Examples include:

- Movie descriptions
- Cover artwork
- Cast information
- Collection information
- Release dates
- Ratings and reviews

This allows the media libraries to remain organized while minimizing manual administration.

---

## Future Expansion

Additional libraries may be added as the platform evolves.

Potential additions include:

```text
/mnt/media
├── movies
├── television
├── home-videos
├── audiobooks
└── documentaries
```

Future library additions can be integrated without modifying the underlying storage architecture.

---

## Related Documentation

- [Architecture](./architecture.md)
- [SMB Storage Configuration](./smb-storage.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)
- [Client Testing](./client-testing.md)

---

## Outcome

The media library structure provides a simple and scalable foundation for content organization while supporting automated metadata management and future platform growth.
