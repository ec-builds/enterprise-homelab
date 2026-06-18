# Docker Concepts Reference

Reference guide for fundamental Docker concepts used throughout the homelab.

## Core Components

Docker applications are built from several related components:

```text
Image
   ↓
Container
   ↓
Volume
```

Understanding the relationship between these components is essential for deploying, troubleshooting, and maintaining containerized applications.

---

## Image

An image is a read-only template used to create containers.

Examples:

```text
louislam/uptime-kuma:2
grafana/grafana
prom/prometheus
```

Common commands:

```bash
docker images
docker pull <image>
docker image rm <image>
```

### Key Characteristics

- Templates used to create containers
- Can be reused multiple times
- Do not store application data
- Downloaded from container registries

### Analogy

An image is similar to installation media or an ISO file.

---

## Container

A container is a running instance of an image.

Examples:

```text
uptime-kuma
grafana
prometheus
```

Common commands:

```bash
docker ps
docker start <container>
docker stop <container>
docker restart <container>
```

### Key Characteristics

- Created from an image
- Executes application processes
- Can be started, stopped, recreated, and removed
- Uses mounted storage for persistent data

### Analogy

A container is similar to an installed and running computer.

---

## Volume

A volume provides persistent storage for containers.

Example:

```yaml
volumes:
  - uptime-kuma:/app/data
```

Common commands:

```bash
docker volume ls
docker volume inspect <volume>
```

### Key Characteristics

- Stores persistent application data
- Survives container deletion
- Can be mounted into new containers
- Managed independently from containers

### Analogy

A volume is similar to a hard drive.

---

## How They Work Together

Example workflow:

```text
Image
  louislam/uptime-kuma:2
          ↓
Container
  uptime-kuma
          ↓
Volume
  uptime-kuma-data
```

The image provides the application.

The container runs the application.

The volume stores the application's data.

---

## Container Recreation Example

> [!IMPORTANT]
> Containers are designed to be disposable. Persistent application data should be stored in Docker volumes, allowing containers to be recreated without data loss.

Scenario:

1. Container is deleted.
2. Image remains available.
3. Volume remains available.
4. Docker Compose recreates the container.

Result:

```text
Application returns with all data intact.
```

Reason:

The persistent data is stored in the volume rather than inside the container.

> [!NOTE]
> During the initial Uptime Kuma deployment, the container naming convention was changed from the Docker Compose generated name (`uptime-kuma-uptime-kuma-1`) to a custom name (`uptime-kuma`) using the `container_name` directive. During this process, existing containers were removed and recreated. Despite the container recreation, all Uptime Kuma configuration and monitoring data remained intact. This demonstrated that application data was stored in a persistent Docker volume rather than inside the container itself. When Docker Compose recreated the container, the existing volume was automatically reattached, allowing the application to resume operation without requiring reconfiguration.

---

## Common Misconceptions

| Misconception | Reality |
|----------|----------|
| Deleting a container deletes application data | Data stored in volumes remains |
| Images contain application data | Images only contain application code and dependencies |
| Containers are permanent | Containers are designed to be replaceable |
| Docker Compose stores data | Volumes store data |

---

## Quick Reference

| Component | Purpose | Analogy |
|----------|----------|----------|
| Image | Template | Installation media / ISO |
| Container | Running application | Computer |
| Volume | Persistent storage | Hard drive |
| Network | Container communication | Network switch |
| Docker Compose | Service orchestration | Deployment blueprint |
| Docker Daemon | Container runtime | Hypervisor / service manager |
