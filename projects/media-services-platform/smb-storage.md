# SMB Storage Configuration

This document outlines the configuration used to integrate network-based media storage into the Media Services Platform.

## Overview

Media content is stored centrally on a NAS platform and mounted to the Debian host using the SMB/CIFS protocol.

The mount is configured as read-only to protect source media files from accidental modification or deletion while still allowing Jellyfin to access the content.

---

## Storage Architecture

```text
nas-lab
    ↓
SMB Share
    ↓
Read-Only Mount
    ↓
/mnt/media
    ↓
Jellyfin
```

---

## Create Mount Point

Create the local mount point that will be used to access the media share.

```bash
sudo mkdir -p /mnt/media
```

---

## Create SMB Credentials File

Store SMB credentials in a dedicated file rather than directly within the mount configuration.

Create the credentials file:

```bash
sudo vim /root/.smbcredentials-jellyfin
```

Contents:

```text
username=service-account-jellyfin
password=YOUR_PASSWORD
```

---

## Service Account Configuration

A dedicated service account was created on the NAS specifically for Jellyfin access.

The account was granted only the minimum permissions required to perform its function.

| Setting | Configuration |
|----------|----------|
| Account Name | service-account-jellyfin |
| Access Type | Service Account |
| Share Access | Read-Only |
| Scope | Media Share Only |

### Security Rationale

Using a dedicated service account provides several benefits:

- Limits access to only the media required by Jellyfin
- Prevents accidental modification or deletion of media files
- Separates application access from administrative accounts
- Supports the principle of least privilege
- Simplifies auditing and future permission management

The credentials stored in the SMB credentials file belong to this dedicated service account rather than a personal or administrative NAS account.

---

## Secure Credentials

Restrict access to the credentials file.

```bash
sudo chmod 600 /root/.smbcredentials-jellyfin
```

Verify permissions:

```bash
ls -l /root/.smbcredentials-jellyfin
```

---

## Backup Existing fstab Configuration

Create a backup before modifying the filesystem mount configuration.

```bash
sudo cp /etc/fstab /etc/fstab.bak
```

---

## Configure Persistent Mount

Add the following entry to `/etc/fstab`:

```fstab
//nas-lab.local/media /mnt/media cifs credentials=/root/.smbcredentials-jellyfin,vers=3.0,ro,nofail,x-systemd.automount,_netdev 0 0
```

### Configuration Notes

| Option | Purpose |
|----------|----------|
| credentials | Uses a separate credentials file |
| vers=3.0 | Uses SMB version 3 |
| ro | Mounts the share as read-only |
| nofail | Allows the system to boot if the share is unavailable |
| x-systemd.automount | Mounts the share on first access |
| _netdev | Delays mount processing until networking is available |

---

## Reload System Configuration

Reload systemd configuration after updating fstab.

```bash
sudo systemctl daemon-reload
```

---

## Test the Mount

Apply the new mount configuration.

```bash
sudo mount -a
```

Verify media content is accessible.

```bash
ls /mnt/media
```

---

## Verify Mount Status

Confirm that the mount is active and using the expected configuration.

```bash
findmnt /mnt/media
```

Example output:

```text
TARGET      SOURCE                 FSTYPE OPTIONS
/mnt/media  //nas-lab.local/media  cifs   ro,...
```

---

## Security Considerations

The SMB share is mounted as read-only.

Benefits include:

- Protection against accidental file deletion
- Reduced risk of application misconfiguration
- Preservation of source media files
- Separation of storage and application responsibilities

Administrative changes to media content are performed directly on the NAS rather than through the media server.

The use of a dedicated read-only service account further limits access and aligns with the principle of least privilege.

---

## Validation

The following checks were performed:

- Mount successfully established
- Media content accessible through `/mnt/media`
- Share automatically available after reboot
- Jellyfin successfully detected media files
- Read-only permissions functioning as expected

---

## Related Documentation

- [Architecture](./architecture.md)
- [Base System Configuration](./base-system-configuration.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)
- [Troubleshooting](./troubleshooting.md)

---

## Outcome

The Media Services Platform successfully integrates centralized NAS storage through a secure read-only SMB mount, providing reliable access to media content while protecting source files from unintended modification.
