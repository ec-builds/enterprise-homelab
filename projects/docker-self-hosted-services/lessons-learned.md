# 📚 Docker Lab Lessons Learned

A running log of lessons, decisions, and best practices discovered while building and operating the Docker & Self-Hosted Services project.

---

## Lesson 001 - Choosing a Docker Project Directory

### Question

Where should Docker Compose projects be stored on a Linux server?

### Findings

Docker Compose projects can technically be stored anywhere on the filesystem. Common locations include:

```text
/home/<user>/docker
/opt/docker
/srv/docker
```

> [!NOTE]
> Initial Docker and Uptime Kuma testing was performed from `/home/[username]` during the learning and validation phase for simplicity. After successful testing, the project standard was updated to use `/opt/docker` as the dedicated location for Docker Compose deployments.
Each location has a slightly different purpose:

| Directory | Purpose |
|------------|------------|
| `/home` | User-owned files and personal projects |
| `/opt` | Optional and third-party applications |
| `/srv` | Data and services provided by the server |

### Decision

Use:

```text
/opt/docker
```

as the standard location for Docker Compose projects.

Example:

```text
/opt/docker
├── uptime-kuma
├── prometheus
├── grafana
├── loki
└── homepage
```

### Rationale

- Keeps self-hosted services separated from personal user files.
- Common convention used throughout homelab and self-hosting communities.
- Easy to document and reproduce across servers.
- Provides a consistent location for Docker Compose stacks.
- Aligns with the Linux convention of storing optional or third-party software in `/opt`.

### Notes

- Docker itself stores container data under `/var/lib/docker`.
- The location of the Compose project directory does not affect container functionality.
- Consistency is more important than the specific directory chosen.
- Avoid mixing multiple project locations without a documented reason.

---

## Lesson 002 - Database Selection

### Question

Which database option should be selected during the initial Uptime Kuma deployment?

### Findings

Uptime Kuma offers multiple database options:

- Embedded MariaDB
- External MariaDB/MySQL
- SQLite

Embedded MariaDB provides a managed database experience without requiring a separate database server or container. SQLite offers the simplest deployment but is generally better suited for smaller installations. An external MariaDB/MySQL database provides maximum flexibility but introduces additional administrative overhead.

### Decision

Use **Embedded MariaDB** for the initial Uptime Kuma deployment.

### Rationale

Embedded MariaDB provides a production-grade database solution while maintaining deployment simplicity. It eliminates the need to manage a separate database service and offers greater scalability than SQLite, making it a suitable choice for a homelab monitoring environment.

### Notes

- No additional database container is required.
- Database management is handled by Uptime Kuma.
- Appropriate for small to medium homelab deployments.
- Reevaluate database architecture if monitoring requirements significantly increase in the future.

---

## Lesson 003 - Container Naming

### Question

Should Docker Compose containers use automatically generated names or explicit container names?

### Findings

By default, Docker Compose generates container names using the format:

`<project>-<service>-<instance>`

Example:

`uptime-kuma-uptime-kuma-1`

While functional, generated names can become lengthy and less convenient when viewing logs, restarting containers, or troubleshooting.

### Decision

Use the `container_name` directive to assign a concise and descriptive container name.

Example:

`uptime-kuma`

### Rationale

Explicit container names improve readability and simplify administration by reducing command length and making container identification easier.

### Notes

- Container names must be unique on the Docker host.
- Existing containers with the same name must be removed before a new container can be created.
- This approach is suitable for small homelab environments where naming conflicts are unlikely.

---

## Future Lessons

Examples of future entries:

- Docker volumes vs bind mounts
- Container naming conventions
- Docker networks
- Port mapping strategy
- Reverse proxy architecture
- Backup and restore procedures
- Image update process
- Logging and monitoring
- Security hardening
- Resource limits and health checks
