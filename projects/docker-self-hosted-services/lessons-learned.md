# Docker Lab — Lessons Learned

A running log of decisions and best practices from building the Docker & Self-Hosted Services project.

| # | Topic | Decision | Why |
|---|-------|----------|-----|
| 001 | Docker project directory | Store Compose stacks in `/opt/docker`, one directory per stack | `/opt` is the Linux convention for optional/third-party software — keeps self-hosted services separate from personal files (`/home`) and is easy to reproduce across servers. Compose location doesn't affect containers (data lives in `/var/lib/docker`); consistency matters more than the path. |
| 002 | Uptime Kuma database | Embedded MariaDB | Production-grade without running a separate DB service, and more scalable than SQLite — a good fit for small-to-medium homelab monitoring. Revisit if monitoring needs grow. |
| 003 | Container naming | Set `container_name` explicitly (e.g. `uptime-kuma`) | Shorter, readable names simplify logs, restarts, and troubleshooting vs. auto-generated names like `uptime-kuma-uptime-kuma-1`. Names must be unique per host, so remove an existing container before recreating it. |
| 004 | Docker host | Run all containers on a dedicated Debian Docker VM | Consolidating containers on one VM simplifies backups, recovery, and management — the whole Docker environment can be snapshotted, backed up, and restored as a single unit, rather than scattered across hosts. |
| 005 | Container management | Use Portainer for container administration | Provides a web UI for managing containers, images, volumes, networks, and Compose stacks — faster visibility and control than CLI-only for day-to-day operations, without replacing Compose for deployment. |

## Future Lessons

Volumes vs. bind mounts · Docker networks · Port mapping · Reverse proxy · TLS certificates · Secrets handling · Backup/restore · Image updates · Logging & monitoring · Security hardening · Resource limits & health checks
