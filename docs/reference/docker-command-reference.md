# 🐳 Docker Command Reference

Quick reference for common Docker and Docker Compose commands used throughout the homelab.

## Quick Summary

| Task | Command |
|----------|----------|
| Verify Docker installation | `docker --version` |
| View running containers | `docker ps` |
| View all containers | `docker ps -a` |
| View images | `docker images` |
| Start Docker Compose stack | `docker compose up -d` |
| Stop Docker Compose stack | `docker compose down` |
| Restart container | `docker restart <container>` |
| View container logs | `docker logs <container>` |
| Follow logs live | `docker logs -f <container>` |
| Open shell in container | `docker exec -it <container> bash` |
| View volumes | `docker volume ls` |
| View networks | `docker network ls` |
| View resource usage | `docker stats` |
| View Docker disk usage | `docker system df` |
| Remove unused resources | `docker system prune` |

---

## Table of Contents

1. [Verify Installation](#verify-installation)
2. [Images](#images)
3. [Containers](#containers)
4. [Docker Compose](#docker-compose)
5. [Volumes](#volumes)
6. [Networks](#networks)
7. [Resource Usage](#resource-usage)
8. [Troubleshooting](#troubleshooting)
9. [Common Uptime Kuma Commands](#common-uptime-kuma-commands)
10. [Useful Concepts](#useful-concepts)
11. [Naming Conventions](#naming-conventions)

---

## Verify Installation

Check Docker version:

```bash
docker --version
```

Check Docker Compose version:

```bash
docker compose version
```

Verify Docker service status:

```bash
systemctl status docker
```

---

## Images

List images:

```bash
docker images
```

Pull an image:

```bash
docker pull louislam/uptime-kuma:2
```

Remove an image:

```bash
docker image rm <image>
```

Remove unused images:

```bash
docker image prune
```

Remove all unused Docker resources:

```bash
docker system prune
```

---

## Containers

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Start a container:

```bash
docker start <container>
```

Stop a container:

```bash
docker stop <container>
```

Restart a container:

```bash
docker restart <container>
```

Remove a container:

```bash
docker rm <container>
```

Force remove a container:

```bash
docker rm -f <container>
```

View container logs:

```bash
docker logs <container>
```

Follow container logs:

```bash
docker logs -f <container>
```

View container details:

```bash
docker inspect <container>
```

Open a shell inside a container:

```bash
docker exec -it <container> bash
```

---

## Docker Compose

Deploy a stack:

```bash
docker compose up -d
```

Stop a stack:

```bash
docker compose down
```

Restart a stack:

```bash
docker compose restart
```

View running services:

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

Pull updated images:

```bash
docker compose pull
```

Update containers:

```bash
docker compose pull
docker compose up -d
```

Validate compose file:

```bash
docker compose config
```

---

## Volumes

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect <volume>
```

Remove a volume:

```bash
docker volume rm <volume>
```

Remove unused volumes:

```bash
docker volume prune
```

---

## Networks

List networks:

```bash
docker network ls
```

Inspect a network:

```bash
docker network inspect <network>
```

Remove a network:

```bash
docker network rm <network>
```

---

## Resource Usage

View container resource usage:

```bash
docker stats
```

View disk usage:

```bash
docker system df
```

---

## Troubleshooting

View Docker service logs:

```bash
journalctl -u docker
```

View recent Docker service logs:

```bash
journalctl -u docker -n 50
```

Check container health:

```bash
docker inspect <container> | grep -A10 Health
```

Check container status:

```bash
docker ps
```

---

## Common Uptime Kuma Commands

Start stack:

```bash
cd /opt/docker/uptime-kuma
docker compose up -d
```

Stop stack:

```bash
cd /opt/docker/uptime-kuma
docker compose down
```

View logs:

```bash
docker logs uptime-kuma
```

Restart container:

```bash
docker restart uptime-kuma
```

Check status:

```bash
docker ps
```

Open web interface:

```text
http://<server-ip>:3001
```

---

## Useful Concepts

| Object | Purpose |
|----------|----------|
| Image | Template used to create containers |
| Container | Running instance of an image |
| Volume | Persistent data storage |
| Network | Communication between containers |
| Docker Compose | Multi-container management |
| Docker Daemon | Background service that runs containers |

---

## Naming Conventions

| Object | Convention |
|----------|----------|
| Compose Projects | Lowercase with hyphens |
| Containers | Short descriptive names |
| Networks | Project-specific |
| Volumes | Application-specific |

Examples:

```text
uptime-kuma
prometheus
grafana
homepage
```
