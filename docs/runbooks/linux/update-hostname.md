# Update Debian Hostname

## Overview

This runbook outlines the process for changing a hostname on a Debian system and updating local hostname resolution.

Use this procedure when renaming a server to align with the Naming Conventions standard or when correcting an existing hostname.

---

## Prerequisites

- Administrative access (`sudo`)
- Existing SSH or console access to the system

> [!NOTE]
> This runbook assumes `sudo` is already installed and configured.
>
> If `sudo` is not available, complete the
> [Configure sudo Access](./configure-sudo.md)
> runbook before proceeding.

---

## Verify Current Hostname

Display the current hostname.

```bash
hostname
```

Display detailed hostname information.

```bash
hostnamectl
```

Example output:

```text
Static hostname: old-hostname
```

---

## Update the Hostname

Set the new hostname.

```bash
sudo hostnamectl set-hostname <new-hostname>
```

Example:

```bash
sudo hostnamectl set-hostname media-server
```

Verify the change.

```bash
hostnamectl
```

Expected output:

```text
Static hostname: media-server
```

---

## Update Local Host Resolution

Edit the hosts file.

```bash
sudo vim /etc/hosts
```

Locate the existing hostname entry.

Example:

```text
127.0.1.1    old-hostname
```

Replace it with the new hostname.

```text
127.0.1.1    media-server
```

A typical hosts file should contain:

```text
127.0.0.1    localhost
127.0.1.1    media-server

::1          localhost ip6-localhost ip6-loopback
```

Save and exit Vim:

```vim
:wq
```

---

## Verify Hostname Resolution

Verify the current hostname.

```bash
hostname
```

Verify hostname resolution.

```bash
getent hosts $(hostname)
```

Expected output:

```text
127.0.1.1    media-server
```

---

## Verify sudo Functionality

Test administrative access.

```bash
sudo whoami
```

Expected output:

```text
root
```

If the following error appears:

```text
sudo: unable to resolve host <hostname>
```

Verify that the hostname and `/etc/hosts` entry match exactly.

---

## Apply Changes

Most hostname changes take effect immediately.

If any services continue displaying the previous hostname, reconnect your session or reboot the system.

Reconnect:

```bash
exit
```

or reboot:

```bash
sudo reboot
```

---

## Validation

Verify the following:

- Hostname updated successfully
- `/etc/hosts` reflects the new hostname
- Hostname resolution functions correctly
- `sudo` executes without hostname resolution errors
- New SSH sessions display the updated hostname

Successful validation confirms that the hostname update is complete.

>[!NOTE]
>You can quickly validate all sections requiring a hostname update with:
>
>```bash
>hostnamectl
>cat /etc/hostname
>cat /etc/hosts
>hostname
>```


---

## Related Documentation

- [Naming Conventions](../standards/naming-conventions.md)
- [Debian Installation](../standards/debian-install.md)
- [Configure sudo Access](./configure-sudo.md)
