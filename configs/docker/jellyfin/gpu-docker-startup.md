# Jellyfin GPU-Aware Docker Startup

## Overview

Jellyfin runs as a Docker container on `media-lab-vm` and uses an Intel GPU passed through from the Proxmox host for hardware-accelerated transcoding.

The Jellyfin container requires:

```text
/dev/dri/renderD128
```

During a `media-lab-vm` reboot, Docker can start before the Linux `i915` driver finishes initializing the passed-through Intel GPU. This creates a boot-time race condition where Docker attempts to start Jellyfin before `/dev/dri/renderD128` exists.

A systemd service was added to wait for the GPU render device before issuing `docker compose up -d`.

## Symptom

After rebooting `media-lab-vm`, other Docker containers started normally, but Jellyfin remained stopped.

Docker reported:

```text
failed to start container
error="error gathering device information while adding custom device
\"/dev/dri/renderD128\": no such file or directory"
```

The configured Docker restart policy was correct:

```text
RestartPolicy=unless-stopped
```

Jellyfin started normally when manually started after the GPU had initialized.

## Root Cause

The physical GPU remained assigned to `media-lab-vm`, but Debian must initialize the passed-through PCI device during every VM boot.

The approximate startup sequence was:

```text
media-lab-vm boots
    │
    ├── i915 begins initializing Intel GPU
    │
    ├── Docker starts
    │       │
    │       └── Attempts to restore Jellyfin
    │               │
    │               └── /dev/dri/renderD128 does not exist yet
    │                       └── Jellyfin startup fails
    │
    └── i915 initialization completes
            │
            └── /dev/dri/renderD128 becomes available
```

Observed timing:

```text
15:05:48  Docker attempts Jellyfin startup
15:05:48  /dev/dri/renderD128 does not exist
15:05:48  Jellyfin startup fails
15:05:50  GPU device is available and Jellyfin starts successfully
```

This was a guest OS device-initialization timing issue, not a failure of the physical GPU or Proxmox PCI passthrough.

## Jellyfin Docker Compose Configuration

Location:

```text
/opt/docker/jellyfin/docker-compose.yaml
```

Configuration:

```yaml
# source: https://jellyfin.org/docs/general/installation/container/

services:
  jellyfin:
    image: jellyfin/jellyfin:12.0
    container_name: jellyfin
    restart: unless-stopped

    networks:
      - media

    ports:
      - "8096:8096/tcp"
      - "7359:7359/udp"

    volumes:
      - ./config:/config
      - ./cache:/cache
      - /mnt/media:/media:ro

    devices:
      - /dev/dri/renderD128:/dev/dri/renderD128

    group_add:
      - "<RENDER_GROUP_GID>"

networks:
  media:
    external: true
```

> **Note:** Replace `<RENDER_GROUP_GID>` with the GID of the system's `render` group. This value varies between environments.

The GID can be identified with:

```bash
getent group render
```

The important hardware dependency is:

```yaml
devices:
  - /dev/dri/renderD128:/dev/dri/renderD128
```

Docker requires the host-side device to exist before it can create and start the container.

A delay inside the container would therefore not solve the problem because Docker fails before the Jellyfin process is launched.

## Systemd GPU Startup Service

### Service Location

```text
/etc/systemd/system/jellyfin-gpu-start.service
```

### Configuration

```ini
[Unit]
Description=Start Jellyfin after Intel GPU is available
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=/opt/docker/jellyfin
ExecStartPre=/bin/sh -c 'until [ -e /dev/dri/renderD128 ]; do sleep 1; done'
ExecStart=/usr/bin/docker compose up -d
TimeoutStartSec=60

[Install]
WantedBy=multi-user.target
```

## How the Service Works

The service starts after Docker:

```ini
Requires=docker.service
After=docker.service
```

Before attempting to start Jellyfin, it checks for the Intel render device:

```ini
ExecStartPre=/bin/sh -c 'until [ -e /dev/dri/renderD128 ]; do sleep 1; done'
```

The check repeats once per second until:

```text
/dev/dri/renderD128
```

exists.

Once the GPU is ready, systemd executes:

```bash
docker compose up -d
```

from:

```text
/opt/docker/jellyfin
```

The service has a 60-second startup timeout:

```ini
TimeoutStartSec=60
```

This prevents the startup job from waiting indefinitely if the GPU fails to initialize.

## Installation

Create the service:

```bash
sudo vi /etc/systemd/system/jellyfin-gpu-start.service
```

Add:

```ini
[Unit]
Description=Start Jellyfin after Intel GPU is available
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
WorkingDirectory=/opt/docker/jellyfin
ExecStartPre=/bin/sh -c 'until [ -e /dev/dri/renderD128 ]; do sleep 1; done'
ExecStart=/usr/bin/docker compose up -d
TimeoutStartSec=60

[Install]
WantedBy=multi-user.target
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable the service at boot:

```bash
sudo systemctl enable jellyfin-gpu-start.service
```

The resulting symlink should resemble:

```text
/etc/systemd/system/multi-user.target.wants/jellyfin-gpu-start.service
    → /etc/systemd/system/jellyfin-gpu-start.service
```

## Manual Testing

The service can be manually executed with:

```bash
sudo systemctl restart jellyfin-gpu-start.service
```

Check its status:

```bash
systemctl status jellyfin-gpu-start.service
```

Because the service uses:

```ini
Type=oneshot
```

it is normal for the service to show:

```text
Active: inactive (dead)
```

after successful execution.

A successful run should show:

```text
ExecStartPre=... status=0/SUCCESS
ExecStart=/usr/bin/docker compose up -d ... status=0/SUCCESS
```

Jellyfin itself continues running independently after the oneshot service exits.

Verify Jellyfin:

```bash
docker ps --filter name=jellyfin
```

Expected:

```text
STATUS
Up ... (healthy)
```

## Troubleshooting

### Check the GPU Device

```bash
ls -la /dev/dri
```

Expected devices include:

```text
card0
renderD128
```

Verify specifically:

```bash
ls -l /dev/dri/renderD128
```

### Check Intel GPU Initialization

```bash
sudo journalctl -b --no-pager | grep -iE 'i915|drm|renderD128'
```

Successful initialization should eventually include:

```text
Initialized i915
```

and `/dev/dri/renderD128` should appear.

### Check the Jellyfin Startup Service

```bash
sudo journalctl -b -u jellyfin-gpu-start.service --no-pager
```

Successful boot example:

```text
Starting jellyfin-gpu-start.service - Start Jellyfin after Intel GPU is available...
Container jellyfin Starting
Container jellyfin Started
jellyfin-gpu-start.service: Deactivated successfully.
Finished jellyfin-gpu-start.service - Start Jellyfin after Intel GPU is available.
```

### Check Docker's Initial Startup Attempt

```bash
sudo journalctl -b -u docker --no-pager | grep -iE 'jellyfin|renderD128'
```

Docker may still initially report:

```text
failed to start container
error="error gathering device information while adding custom device
\"/dev/dri/renderD128\": no such file or directory"
```

This is acceptable with the current configuration.

The systemd service acts as a boot-time recovery mechanism and starts Jellyfin once the GPU device becomes available.

## Validated Boot Test

A full reboot of `media-lab-vm` reproduced the original race condition.

Docker first attempted Jellyfin startup:

```text
15:05:48  failed to start container
           /dev/dri/renderD128: no such file or directory
```

The systemd service then waited for the GPU and successfully started Jellyfin:

```text
15:05:49  jellyfin-gpu-start.service started
15:05:50  Container jellyfin Starting
15:05:50  Container jellyfin Started
15:05:50  jellyfin-gpu-start.service completed successfully
```

Jellyfin subsequently reported:

```text
Up (healthy)
```

This validated the systemd workaround across a `media-lab-vm` reboot without requiring a Proxmox host reboot.

## Final Startup Flow

```text
media-lab-vm boots
      │
      ├── Docker starts
      │      │
      │      └── Docker may attempt Jellyfin
      │              │
      │              └── GPU not ready → startup fails
      │
      ├── i915 initializes passed-through Intel GPU
      │
      ├── /dev/dri/renderD128 appears
      │
      └── jellyfin-gpu-start.service
              │
              ├── Detects renderD128
              │
              └── docker compose up -d
                       │
                       └── Jellyfin starts successfully
```

## Notes

- Keep `restart: unless-stopped` in the Jellyfin Compose configuration.
- The systemd service supplements Docker's restart policy rather than replacing it.
- The entire Docker daemon does not need to be delayed because only Jellyfin depends on the GPU.
- A fixed `sleep` delay is unnecessary; the service waits for the actual device.
- `inactive (dead)` is normal after successful execution because the service is `Type=oneshot`.
- The physical GPU does not disappear when `media-lab-vm` reboots. Debian simply needs time to initialize the passed-through PCI device and create `/dev/dri/renderD128`.
- Docker Compose cannot solve this by sleeping inside the Jellyfin container because Docker validates the configured host device before launching the container process.
- The `render` group GID is environment-specific and should be verified rather than copied directly between systems.
