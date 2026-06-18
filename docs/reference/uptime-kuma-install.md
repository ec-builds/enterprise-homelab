# Uptime Kuma Installation Guide

Reference guide for deploying Uptime Kuma using Docker Compose.

## Purpose

This document provides a repeatable procedure for deploying Uptime Kuma within the homelab environment using Docker Compose.

Uptime Kuma is a self-hosted monitoring platform used to monitor the availability and health of websites, servers, network devices, APIs, and other services. ([GitHub](https://github.com/louislam/uptime-kuma?utm_source=chatgpt.com))

> [!NOTE]
> This guide was created by following and validating procedures documented in the official Uptime Kuma project:
>
> [Uptime Kuma GitHub Repository](https://github.com/louislam/uptime-kuma?utm_source=chatgpt.com)
>
> The Uptime Kuma project documentation is the authoritative source and should be consulted for the latest installation procedures, supported features, and upgrade guidance.

---

## Prerequisites

Verify Docker is installed:

```bash
docker --version
```

Verify Docker Compose is available:

```bash
docker compose version
```

Verify Docker is running:

```bash
docker ps
```

---

## Create Project Directory

Create the application directory:

```bash
sudo mkdir -p /opt/docker/uptime-kuma
sudo chown -R $USER:$USER /opt/docker/uptime-kuma
```

Move into the project directory:

```bash
cd /opt/docker/uptime-kuma
```

---

## Create Docker Compose File

Create the Compose file:

```bash
vi docker-compose.yml
```

Configure the following:

```yaml
services:
  uptime-kuma:
    image: louislam/uptime-kuma:2
    container_name: uptime-kuma
    restart: unless-stopped

    ports:
      - "3001:3001"

    volumes:
      - uptime-kuma:/app/data

volumes:
  uptime-kuma:
```

The official project recommends the `:2` image tag for Uptime Kuma v2 deployments. ([Docker Hub](https://hub.docker.com/r/louislam/uptime-kuma?utm_source=chatgpt.com))

---

## Validate Configuration

Verify the Compose file:

```bash
docker compose config
```

Expected result:

```text
Configuration validated successfully
```

---

## Deploy Uptime Kuma

Start the container:

```bash
docker compose up -d
```

Docker Compose will:

1. Download the image if required.
2. Create the Docker network.
3. Create the Docker volume.
4. Create and start the container. ([GitHub](https://github.com/louislam/uptime-kuma/blob/master/compose.yaml?utm_source=chatgpt.com))

---

## Verify Deployment

Check container status:

```bash
docker ps
```

Expected result:

```text
uptime-kuma    Up
```

Verify Compose status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Follow logs:

```bash
docker compose logs -f
```

---

## Access Uptime Kuma

Open a web browser:

```text
http://<server-ip>:3001
```

Example:

```text
http://10.10.10.70:3001
```

Uptime Kuma should display the first-time setup wizard. ([GitHub](https://github.com/louislam/uptime-kuma?utm_source=chatgpt.com))

---

## Initial Configuration

Complete the setup wizard:

1. Create an administrator account.
2. Configure the desired username and password.
3. Log in to the dashboard.
4. Create the first monitor.

Recommended first monitors:

| Monitor | Type |
|----------|----------|
| Router | HTTP(s) |
| Synology DSM | HTTP(s) |
| Debian Host | Ping |
| Uptime Kuma | HTTP(s) |

---

## Verify Persistent Storage

List Docker volumes:

```bash
docker volume ls
```

Inspect the Uptime Kuma volume:

```bash
docker volume inspect uptime-kuma
```

Expected result:

```text
Mountpoint:
...
```

> [!IMPORTANT]
> Uptime Kuma stores configuration, monitor definitions, notifications, and historical data within `/app/data`. This data is persisted through the Docker volume and survives container recreation. ([GitHub](https://github.com/louislam/uptime-kuma?utm_source=chatgpt.com))

---

## Update Procedure

Move into the project directory:

```bash
cd /opt/docker/uptime-kuma
```

Pull the latest image:

```bash
docker compose pull
```

Recreate the container:

```bash
docker compose up -d
```

Verify status:

```bash
docker compose ps
```

The existing volume is automatically reattached and configuration data remains intact. ([GitHub](https://github.com/louislam/uptime-kuma/wiki/%F0%9F%86%99-How-to-Update?utm_source=chatgpt.com))

---

## Removal Procedure

Stop the container:

```bash
docker compose down
```

Remove the project directory:

```bash
rm -rf /opt/docker/uptime-kuma
```

Remove the image if desired:

```bash
docker image rm louislam/uptime-kuma:2
```

Remove the volume only if data should be permanently deleted:

```bash
docker volume rm uptime-kuma
```

> [!WARNING]
> Removing the Docker volume permanently deletes all Uptime Kuma configuration, monitor definitions, and historical monitoring data.

---

## Lessons Learned

### Container Recreation Does Not Remove Data

During deployment, the container naming convention was changed from the Docker Compose generated name to a custom container name.

The container was removed and recreated, but all monitor configuration remained intact.

Reason:

```text
Image
    ↓
Container
    ↓
Volume (Persistent Data)
```

The Docker volume continued to exist and was automatically reattached to the new container.

This demonstrated the importance of storing application data in persistent Docker volumes rather than within containers.

---

## Installation Checklist

| Task | Status |
|----------|----------|
| Docker installed | ☐ |
| Docker Compose available | ☐ |
| Project directory created | ☐ |
| Compose file created | ☐ |
| Configuration validated | ☐ |
| Container deployed | ☐ |
| Web interface accessible | ☐ |
| Administrator account created | ☐ |
| First monitor configured | ☐ |
| Volume persistence verified | ☐ |

---

## Related Documentation

| Document | Purpose |
|----------|----------|
| [docker-installation.md](docker-installation.md) | Docker installation procedures |
| [docker-concepts.md](docker-concepts.md) | Docker architecture and terminology |
| [docker-command-reference.md](docker-command-reference.md) | Common Docker administration commands |
| [docker-container-deployment.md](docker-container-deployment.md) | Standard Docker Compose deployment workflow |
| [uptime-kuma-reference.md](uptime-kuma-reference.md) | Monitor configuration and operational guidance |
