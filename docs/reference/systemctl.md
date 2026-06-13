# systemctl Reference

## Overview

This document provides a quick-reference guide for common `systemctl` and `journalctl` commands used for Linux service administration and troubleshooting.

Use this reference when managing services, reviewing logs, troubleshooting startup issues, and performing system power operations.

---

## Common Commands Cheat Sheet

| Command | Purpose |
|----------|----------|
| `systemctl status ssh` | Check SSH service status |
| `systemctl status jellyfin` | Check Jellyfin service status |
| `systemctl status avahi-daemon` | Check Avahi service status |
| `systemctl is-active jellyfin` | Check if Jellyfin is running |
| `systemctl is-enabled jellyfin` | Check if Jellyfin starts at boot |
| `sudo systemctl restart jellyfin` | Restart Jellyfin |
| `sudo systemctl start jellyfin` | Start Jellyfin |
| `sudo systemctl stop jellyfin` | Stop Jellyfin |
| `sudo systemctl enable jellyfin` | Enable Jellyfin at boot |
| `sudo systemctl disable jellyfin` | Disable Jellyfin at boot |
| `journalctl -u jellyfin` | View Jellyfin logs |
| `journalctl -fu jellyfin` | Follow Jellyfin logs live |
| `systemctl --failed` | Show failed services |
| `systemctl list-units --type=service` | List running services |
| `systemctl list-unit-files --type=service` | List installed services |
| `systemctl list-unit-files --state=enabled` | List services enabled at boot |
| `sudo systemctl daemon-reload` | Reload systemd configuration |
| `systemctl cat jellyfin` | View service definition |
| `systemd-analyze` | Analyze boot time |
| `sudo systemctl reboot` | Reboot system |
| `sudo systemctl poweroff` | Shut down system |

---

## Check Service Status

Display detailed information about a service.

```bash
systemctl status <service>
```

Example:

```bash
systemctl status ssh
systemctl status avahi-daemon
systemctl status jellyfin
```

Displays:

- Current state
- Process ID (PID)
- Startup status
- Recent log entries

---

## Start a Service

Start a service immediately.

```bash
sudo systemctl start <service>
```

Example:

```bash
sudo systemctl start avahi-daemon
```

---

## Stop a Service

Stop a service immediately.

```bash
sudo systemctl stop <service>
```

Example:

```bash
sudo systemctl stop avahi-daemon
```

---

## Restart a Service

Restart a service.

```bash
sudo systemctl restart <service>
```

Example:

```bash
sudo systemctl restart ssh
```

Useful after configuration changes.

---

## Reload Configuration

Reload service configuration without performing a full restart.

```bash
sudo systemctl reload <service>
```

Example:

```bash
sudo systemctl reload nginx
```

---

## Enable Service at Boot

Configure a service to start automatically during system boot.

```bash
sudo systemctl enable <service>
```

Example:

```bash
sudo systemctl enable jellyfin
```

---

## Disable Service at Boot

Prevent a service from starting automatically at boot.

```bash
sudo systemctl disable <service>
```

Example:

```bash
sudo systemctl disable avahi-daemon
```

---

## Check if Service is Enabled

Display the startup state of a service.

```bash
systemctl is-enabled <service>
```

Example:

```bash
systemctl is-enabled avahi-daemon
```

Possible output:

```text
enabled
disabled
static
masked
```

---

## Check if Service is Running

Display the current runtime state of a service.

```bash
systemctl is-active <service>
```

Example:

```bash
systemctl is-active ssh
```

Possible output:

```text
active
inactive
failed
```

---

## View Recent Logs

Display historical logs for a service.

```bash
journalctl -u <service>
```

Example:

```bash
journalctl -u avahi-daemon
```

---

## Follow Logs Live

Follow service logs in real time.

```bash
journalctl -fu <service>
```

Example:

```bash
journalctl -fu jellyfin
```

Equivalent to:

```bash
tail -f
```

for a service log.

---

## List Failed Services

Display services currently in a failed state.

```bash
systemctl --failed
```

Useful for troubleshooting startup and dependency issues.

---

## List Running Services

Display loaded and active services.

```bash
systemctl list-units --type=service
```

---

## List Installed Service Files

Display all installed service definitions.

```bash
systemctl list-unit-files --type=service
```

Common states:

```text
enabled
disabled
static
masked
```

---

## Reload systemd

Reload systemd configuration after creating or modifying service files.

```bash
sudo systemctl daemon-reload
```

Common use cases:

- Creating a new service
- Modifying an existing service
- Editing files under:

```text
/etc/systemd/system/
```

---

## View Service Definition

Display the service definition and any active overrides.

```bash
systemctl cat <service>
```

Example:

```bash
systemctl cat jellyfin
```

Useful for troubleshooting and learning service configuration.

---

## Check Boot Time

Display boot performance information.

Quick summary:

```bash
systemd-analyze
```

Detailed breakdown:

```bash
systemd-analyze blame
```

Useful for identifying services that slow system startup.

---

## Power Operations

Shutdown:

```bash
sudo systemctl poweroff
```

Reboot:

```bash
sudo systemctl reboot
```

Suspend:

```bash
sudo systemctl suspend
```

Useful for servers, virtual machines, and remote administration.

---

## Related Documentation

- [Debian Baseline](../standards/debian-baseline.md)
- [SSH Hardening](../standards/ssh-hardening.md)
