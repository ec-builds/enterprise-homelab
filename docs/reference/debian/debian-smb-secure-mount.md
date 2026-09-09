# Secure SMB Mount

This reference documents a reusable method for securely mounting an SMB/CIFS network share on a Debian-based Linux host.

The Jellyfin Media Services Platform is used as the example implementation. The same approach can be adapted for other applications that require authenticated access to network storage.

## Overview

The recommended design keeps SMB authentication at the operating-system layer rather than exposing network-storage credentials directly to an application or container.

In the Jellyfin example, media is stored on a NAS and accessed through a dedicated read-only service account.

```text
NAS Media Share
      │
      │ SMB/CIFS
      │ Dedicated service account
      ▼
Debian Host
      │
      │ /mnt/media
      ▼
Application / Container
```

The Debian host:

1. Stores the SMB credentials in a protected file.
2. Establishes the SMB mount through `/etc/fstab`.
3. Exposes the mounted filesystem to the application.

For containerized applications such as Jellyfin, the host-mounted directory can then be passed into the container without exposing the SMB credentials.

> [!NOTE]
> The application does not need to authenticate directly to the NAS. Authentication and network-storage connectivity are handled by the Linux host.



## Security Model

The example Jellyfin deployment uses multiple layers of access control:

```text
NAS Permissions
      │
      │ Dedicated read-only account
      ▼
SMB/CIFS Mount
      │
      │ Read-only
      ▼
Debian Filesystem
      │
      ▼
Docker Bind Mount
      │
      │ Read-only
      ▼
Jellyfin
```

This approach provides:

- Separation between application and storage credentials
- Least-privilege access to network storage
- Protection against accidental file modification or deletion
- Credentials stored outside application configuration
- Additional read-only enforcement at the host and container layers



## Prerequisites

The Linux host requires CIFS support to mount SMB shares.

On Debian:

```bash
sudo apt update
sudo apt install -y cifs-utils
```

The following information is also required:

- NAS hostname or IP address
- SMB share name
- Dedicated service account
- Service account password
- Local mount point



## Create a Dedicated Service Account

Create a dedicated account on the NAS for the application rather than using a personal or administrative account.

For the Jellyfin example:

```text
service-account-jellyfin
```

Configure the account with only the permissions required by the application.

| Setting | Jellyfin Example |
|----------|------------------|
| Account | `service-account-jellyfin` |
| Share | Media |
| Permission | Read-Only |
| Scope | Media Share Only |

Using a dedicated account separates application access from administrative access and makes permissions easier to audit or revoke.

> [!IMPORTANT]
> Permissions should be assigned according to the requirements of the application. Jellyfin requires only read access to the source media in this example, so write permissions are intentionally not granted.



## Create the Mount Point

Create the directory where the remote share will be mounted.

For Jellyfin:

```bash
sudo mkdir -p /mnt/media
```

The directory represents the SMB share within the local Linux filesystem.

```text
NAS media share
      │
      ▼
/mnt/media
```



## Create a Credentials File

Avoid placing SMB usernames and passwords directly in `/etc/fstab`.

Instead, create a dedicated credentials file.

For Jellyfin:

```bash
sudo vim /root/.smbcredentials-jellyfin
```

Add the SMB account credentials:

```text
username=service-account-jellyfin
password=YOUR_PASSWORD
```

> [!WARNING]
> Never commit populated SMB credentials files to source control.



## Secure the Credentials File

Restrict the credentials file so that only the root account can read or modify it.

```bash
sudo chmod 600 /root/.smbcredentials-jellyfin
```

Verify the permissions:

```bash
sudo ls -l /root/.smbcredentials-jellyfin
```

Expected permissions should resemble:

```text
-rw------- 1 root root ...
```

This prevents normal users from reading the stored NAS credentials.



## Backup fstab

Before modifying `/etc/fstab`, create a backup of the existing configuration.

```bash
sudo cp /etc/fstab /etc/fstab.bak
```

The backup can be restored if an invalid mount configuration is introduced.



## Configure the Persistent SMB Mount

Add the SMB share to `/etc/fstab`.

Example Jellyfin configuration:

```fstab
//nas-lab.local/media /mnt/media cifs credentials=/root/.smbcredentials-jellyfin,vers=3.0,ro,nofail,x-systemd.automount,_netdev 0 0
```

### Configuration Options

| Option | Purpose |
|----------|----------|
| `credentials=` | References the protected SMB credentials file |
| `vers=3.0` | Uses SMB version 3 |
| `ro` | Mounts the filesystem as read-only |
| `nofail` | Allows the host to boot if the NAS is unavailable |
| `x-systemd.automount` | Mounts the share when the path is accessed |
| `_netdev` | Identifies the filesystem as dependent on network connectivity |

### Why Use Automount

Network storage may not be available immediately during system startup.

Using:

```text
nofail,x-systemd.automount,_netdev
```

reduces dependency on the NAS during the Linux boot process and allows the share to be mounted when it is first accessed.



## Reload System Configuration

After modifying `/etc/fstab`, reload the systemd configuration.

```bash
sudo systemctl daemon-reload
```



## Test the Mount

Apply the configured filesystem mounts:

```bash
sudo mount -a
```

Access the mounted directory:

```bash
ls /mnt/media
```

With `x-systemd.automount` configured, accessing the directory can trigger the SMB mount.



## Verify the Mount

Use `findmnt` to confirm the active filesystem configuration:

```bash
findmnt /mnt/media
```

Example:

```text
TARGET      SOURCE                 FSTYPE OPTIONS
/mnt/media  //nas-lab.local/media  cifs   ro,...
```

The output should identify:

- The expected NAS share
- CIFS as the filesystem type
- The expected local mount point
- Read-only access when `ro` is configured



## Verify Read-Only Access

When the application requires only read access, verify that files cannot be created through the mount.

For example:

```bash
touch /mnt/media/write-test
```

The operation should fail on a correctly configured read-only mount.

> [!NOTE]
> A read-only NAS account provides an additional protection layer even if the client-side mount configuration is later changed accidentally.



## Container Integration

When the application runs in Docker, mount the SMB share on the Linux host rather than storing the SMB credentials inside the application container.

For Jellyfin, the Debian host provides:

```text
/mnt/media
```

The directory can then be passed to the container using a bind mount:

```yaml
volumes:
  - /mnt/media:/media:ro
```

The resulting path is:

```text
NAS
 │
 │ SMB/CIFS
 ▼
Debian Host
/mnt/media
 │
 │ Docker bind mount
 ▼
Jellyfin Container
/media
```

The `:ro` option adds another read-only boundary at the container layer.

Jellyfin can read and index the media library through `/media`, but the container does not receive the SMB username or password.



## Credential Separation

With this design, each component has a clearly defined responsibility:

| Layer | Responsibility |
|----------|----------|
| NAS | Stores data and enforces share permissions |
| Service Account | Provides limited authentication to the share |
| Debian Host | Stores credentials and establishes the SMB connection |
| Docker | Exposes the mounted filesystem to the container |
| Jellyfin | Reads media through the local container filesystem |

The application therefore does not need awareness of the underlying SMB authentication mechanism.



## Validation

After configuration, verify:

- `cifs-utils` is installed
- Dedicated service account is being used
- Service account has only the required share permissions
- Credentials are stored outside `/etc/fstab`
- Credentials file permissions are `600`
- SMB share mounts successfully
- Mount survives a host reboot
- NAS unavailability does not prevent normal host startup
- Expected files are accessible through the mount point
- Read-only access is enforced when required
- Containerized applications can access the bind-mounted directory
- SMB credentials are not exposed inside the application container



## Troubleshooting

### Mount Does Not Appear

Check the configured mount:

```bash
findmnt /mnt/media
```

Then review `/etc/fstab` for syntax errors.

Test the configuration:

```bash
sudo mount -a
```



### Authentication Fails

Verify:

- Username
- Password
- NAS share permissions
- Credentials file path
- Credentials file formatting

The credentials file should use:

```text
username=ACCOUNT_NAME
password=PASSWORD
```



### Share Is Unavailable After Boot

Verify that the mount includes:

```text
nofail,x-systemd.automount,_netdev
```

Access the mount point to trigger the automount:

```bash
ls /mnt/media
```

Then verify:

```bash
findmnt /mnt/media
```



### Application Cannot Access Files

First confirm that the files are accessible from the Linux host:

```bash
ls /mnt/media
```

If the host can access the files but a Docker container cannot, verify the container bind mount and filesystem permissions separately.



## Security Considerations

When using SMB storage for application workloads:

- Use dedicated service accounts rather than administrative accounts
- Grant access only to required shares
- Use read-only permissions when applications do not require writes
- Store credentials in protected files
- Restrict credential-file permissions
- Never place passwords directly in `/etc/fstab`
- Never commit populated credentials files to source control
- Keep network-storage authentication outside application containers when practical
- Apply additional read-only controls at the container layer when appropriate

For the Jellyfin implementation, these controls create three independent read-only boundaries:

```text
NAS Account Permissions
        │
        ▼
Read-Only SMB Mount
        │
        ▼
Read-Only Docker Bind Mount
        │
        ▼
Jellyfin
```

This defense-in-depth approach reduces the ability of an application error or container compromise to modify the source media library.



## Example: Jellyfin

The complete Jellyfin example can be summarized as:

```text
Service Account
service-account-jellyfin
        │
        ▼
NAS Share
//nas-lab.local/media
        │
        │ SMB 3.0
        ▼
Debian Host
/mnt/media
        │
        │ read-only bind mount
        ▼
Jellyfin Container
/media
```

Credentials:

```text
/root/.smbcredentials-jellyfin
```

Persistent host mount:

```fstab
//nas-lab.local/media /mnt/media cifs credentials=/root/.smbcredentials-jellyfin,vers=3.0,ro,nofail,x-systemd.automount,_netdev 0 0
```

Docker bind mount:

```yaml
volumes:
  - /mnt/media:/media:ro
```

The same pattern can be adapted for other applications by changing the service account, share, credentials file, mount point, and required permissions.
