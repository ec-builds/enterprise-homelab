# Configure sudo Access

## Overview

This runbook outlines the process for installing `sudo`, granting administrative privileges to a user account, and validating sudo access on Debian-based systems.

Use this procedure after a fresh Debian installation when administrative access must be delegated to a non-root user account.

---

## Prerequisites

- Root access to the system
- Local console access or SSH access as root
- Debian system with package repositories configured

---

## Verify Current User

Determine the currently logged-in user.

```bash
whoami
```

Example output:

```text
root
```

or

```text
username
```

---

## Become Root

If not already operating as root, switch to a root shell.

```bash
su -
```

Verify:

```bash
whoami
```

Expected output:

```text
root
```

---

## Install sudo

Update package repositories.

```bash
apt update
```

Install sudo.

```bash
apt install sudo
```

Verify installation.

```bash
sudo -V
```

Successful execution confirms that sudo is installed.

---

## Add User to the sudo Group

Add the target user to the Debian sudo group.

```bash
usermod -aG sudo <username>
```

Example:

```bash
usermod -aG sudo adminuser
```

---

## Verify Group Membership

Verify that the user has been added to the sudo group.

```bash
groups <username>
```

Expected output includes:

```text
sudo
```

Alternatively:

```bash
id <username>
```

Expected output includes:

```text
groups=...,27(sudo)
```

---

## Apply Group Membership Changes

Group membership changes require a new login session.

Exit the current session.

```bash
exit
```

Reconnect using the target user account.

```bash
ssh <username>@<server>
```

Alternatively:

```bash
su - <username>
```

---

## Verify sudo Access

Test administrative access.

```bash
sudo whoami
```

Expected output:

```text
root
```

Successful execution confirms that the user has sudo privileges.

---

## Verify sudo Group Members

Display current members of the sudo group.

```bash
getent group sudo
```

Example output:

```text
sudo:x:27:adminuser
```

---

## Troubleshooting

### Verify sudo Installation

```bash
which sudo
```

---

### Verify Current Group Membership

```bash
groups
```

---

### Verify User Identity Information

```bash
id
```

---

### Group Membership Changes Not Applied

If sudo access is not available after adding the user to the sudo group:

1. Log out of the current session.
2. Log back in.
3. Repeat the validation steps.

---

## Validation

Verify the following:

- `sudo` is installed
- Target user is a member of the `sudo` group
- User can successfully execute:

```bash
sudo whoami
```

Expected output:

```text
root
```

Successful validation confirms that delegated administrative access is configured correctly.

---

## Related Documentation

- [Debian Installation](../standards/debian-install.md)
- [Debian Baseline](../standards/debian-baseline.md)
- [SSH Hardening](../standards/ssh-hardening.md)
