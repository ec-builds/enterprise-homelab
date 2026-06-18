# Docker Deployment Guide

Step-by-step guide for deploying Docker Compose applications in the homelab environment.

## Purpose

This document provides a repeatable process for deploying containerized applications using Docker Compose.

It is intended to document the standard workflow used for services such as:

- Uptime Kuma
- Grafana
- Prometheus
- Loki
- Homepage
- Other self-hosted services

---

## Deployment Standard

Docker Compose project directories should be stored under:

```text
/opt/docker
```

Example structure:

```text
/opt/docker/
├── uptime-kuma/
├── grafana/
├── prometheus/
├── loki/
└── homepage/
```

Each application should have its own project directory containing its Compose file and any related configuration files.

---

## Prerequisites

Before deploying a Docker Compose application, verify:

| Requirement | Command |
|----------|----------|
| Docker installed | `docker --version` |
| Docker Compose available | `docker compose version` |
| Docker service running | `systemctl status docker` |
| User has Docker access | `docker ps` |

---

## Create Project Directory

Create a directory for the application:

```bash
sudo mkdir -p /opt/docker/<application-name>
```

Change ownership to the administrative user:

```bash
sudo chown -R $USER:$USER /opt/docker/<application-name>
```

Move into the project directory:

```bash
cd /opt/docker/<application-name>
```

Example:

```bash
sudo mkdir -p /opt/docker/uptime-kuma
sudo chown -R $USER:$USER /opt/docker/uptime-kuma
cd /opt/docker/uptime-kuma
```

---

## Create Docker Compose File

Create the Compose file:

```bash
vi docker-compose.yml
```

Example template:

```yaml
services:
  application-name:
    image: image/name:tag
    container_name: application-name
    restart: unless-stopped
    ports:
      - "host-port:container-port"
    volumes:
      - application-data:/path/inside/container

volumes:
  application-data:
```

---

## Example: Uptime Kuma

Example Uptime Kuma Compose file:

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

---

## Validate Compose File

Before deploying, validate the Compose configuration:

```bash
docker compose config
```

This checks the Compose file for syntax errors and displays the final interpreted configuration.

---

## Deploy Application

Start the application in detached mode:

```bash
docker compose up -d
```

Docker Compose will:

1. Pull the required image if it is not already present.
2. Create required networks.
3. Create required volumes.
4. Create and start the container.

---

## Verify Deployment

Check running containers:

```bash
docker ps
```

Check all containers:

```bash
docker ps -a
```

Check Compose services:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Follow logs live:

```bash
docker compose logs -f
```

---

## Access the Application

Open the service in a browser using the host IP address and exposed port.

Example:

```text
http://<server-ip>:3001
```

For Uptime Kuma:

```text
http://<server-ip>:3001
```

---

## Common Post-Deployment Tasks

After confirming the container is running:

1. Complete the application's initial setup wizard.
2. Create an admin account if required.
3. Configure application-specific settings.
4. Add monitoring or integrations.
5. Document exposed ports and service purpose.
6. Add the service to inventory documentation.

---

## Updating a Docker Compose Application

Move into the project directory:

```bash
cd /opt/docker/<application-name>
```

Pull the latest image:

```bash
docker compose pull
```

Recreate the container using the updated image:

```bash
docker compose up -d
```

Verify status:

```bash
docker compose ps
```

Check logs:

```bash
docker compose logs
```

---

## Stopping an Application

Stop and remove the Compose-managed container and network:

```bash
docker compose down
```

> [!IMPORTANT]
> `docker compose down` removes the container and project network, but it does not remove named volumes by default. Persistent application data remains intact.

---

## Removing an Application

Stop the application:

```bash
docker compose down
```

Remove the project directory:

```bash
rm -rf /opt/docker/<application-name>
```

Remove the image if no longer needed:

```bash
docker image rm <image>
```

Remove the named volume only if application data should be deleted:

```bash
docker volume rm <volume-name>
```

> [!WARNING]
> Removing a Docker volume deletes persistent application data. Only remove volumes after confirming backups are available or the data is no longer needed.

---

## Backup Considerations

For most Docker Compose applications, back up:

| Item | Reason |
|----------|----------|
| `docker-compose.yml` | Defines how the application is deployed |
| `.env` files | Stores environment-specific variables |
| Bind mount directories | Stores application configuration or data |
| Named volumes | Stores persistent application data |

Do not rely on containers themselves as backups. Containers should be considered disposable.

---

## Troubleshooting

### Container Does Not Start

Check logs:

```bash
docker compose logs
```

Check configuration:

```bash
docker compose config
```

Check container status:

```bash
docker ps -a
```

---

### Port Already in Use

Check what is using the port:

```bash
sudo ss -tulpn | grep <port>
```

Example:

```bash
sudo ss -tulpn | grep 3001
```

Resolve by either:

- Changing the host port in `docker-compose.yml`
- Stopping the conflicting service

---

### Container Name Conflict

Error example:

```text
Conflict. The container name "/application-name" is already in use.
```

Find the existing container:

```bash
docker ps -a
```

Remove the old container if appropriate:

```bash
docker rm -f <container-name>
```

Recreate the Compose stack:

```bash
docker compose up -d
```

---

### Application Is Running but Not Accessible

Check container status:

```bash
docker ps
```

Check port mapping:

```bash
docker compose ps
```

Check firewall rules if applicable:

```bash
sudo ufw status
```

Check logs:

```bash
docker compose logs
```

---

## Deployment Checklist

| Task | Status |
|----------|----------|
| Project directory created under `/opt/docker` | ☐ |
| Ownership assigned to administrative user | ☐ |
| `docker-compose.yml` created | ☐ |
| Compose file validated | ☐ |
| Application deployed with `docker compose up -d` | ☐ |
| Container status verified | ☐ |
| Logs reviewed | ☐ |
| Web interface or service endpoint tested | ☐ |
| Persistent storage confirmed | ☐ |
| Service documented in inventory | ☐ |
| Backup requirements identified | ☐ |

---

## Related Documentation

| Document | Purpose |
|----------|----------|
| `docker-commands.md` | Docker command reference |
| `docker-concepts.md` | Docker concepts and terminology |
| `uptime-kuma-reference.md` | Uptime Kuma monitor reference |
| `lessons-learned.md` | Project lessons and decisions |
| `troubleshooting.md` | Known issues and resolutions |
