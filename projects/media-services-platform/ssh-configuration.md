# 🔐 SSH Configuration

This document outlines the SSH configuration used to administer the Media Services Platform.

## Overview

SSH (Secure Shell) provides secure remote access to the Debian host and serves as the primary method of system administration.

The initial deployment utilizes standard password-based SSH authentication. Future enhancements will include SSH key-based authentication and additional hardening measures.

---

## Purpose

SSH is used for:

- Remote administration
- System maintenance
- Package management
- Configuration changes
- Service management
- Troubleshooting and diagnostics

The platform is managed primarily through SSH rather than direct console access.

---

## Installation

SSH was installed during the Debian installation process.

The following package was included:

```text
OpenSSH Server
```

Verify installation:

```bash
systemctl status ssh
```

Expected output:

```text
active (running)
```

---

## Service Management

Check service status:

```bash
sudo systemctl status ssh
```

Verify automatic startup:

```bash
sudo systemctl is-enabled ssh
```

Expected output:

```text
enabled
```

Restart the service:

```bash
sudo systemctl restart ssh
```

---

## Network Access

The server is accessible from devices on the local network.

Example:

```bash
ssh username@media-server-lab.local
```

Alternatively:

```bash
ssh username@SERVER_IP
```

The Avahi daemon allows the host to be accessed using its local hostname without requiring manual DNS configuration.

---

## Validation

The following tests were performed:

- SSH service confirmed running
- Automatic service startup verified
- Successful connection from the primary workstation
- Remote command execution verified
- Multiple administrative sessions tested

SSH access functioned reliably throughout deployment and configuration activities.

---

## Current Security Configuration

The current implementation uses:

- Standard SSH configuration
- Password-based authentication
- Local network access only
- Default SSH port (22)

This configuration is sufficient for the initial deployment phase while additional hardening measures are planned.

---

## Planned Improvements

Future enhancements include:

### SSH Key-Based Authentication

Generate a public/private key pair:

```bash
ssh-keygen -t ed25519
```

Copy the public key to the server:

```bash
ssh-copy-id username@media-server-lab.local
```

Benefits include:

- Stronger authentication
- Reduced risk of password attacks
- Improved administrative convenience

### Additional Hardening

Potential future improvements:

- Disable password authentication
- Disable root SSH login
- Restrict allowed users
- Configure idle session timeouts
- Review SSH logging and auditing

These changes will be evaluated as the platform evolves.

---

## Related Documentation

- [Base System Configuration](./base-system-configuration.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)
- [Architecture](./architecture.md)

---

## Outcome

SSH provides reliable remote administration of the Media Services Platform and serves as the primary management interface for ongoing operations.

The current implementation uses standard password authentication, with SSH key-based authentication and additional hardening planned for future iterations.
