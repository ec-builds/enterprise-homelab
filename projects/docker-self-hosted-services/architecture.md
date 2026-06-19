# Docker & Self-Hosted Services Architecture

Architecture overview for the Docker & Self-Hosted Services project.

## Purpose

This document describes the current and planned architecture for containerized self-hosted services running on the Debian Docker host.

The architecture is designed to support:

- Self-hosted application deployment
- Service availability monitoring
- Future observability tooling
- Persistent application data
- Repeatable Docker Compose deployments
- Operational documentation and troubleshooting

---

## Current Architecture

```text
Internet
    │
    ▼
ASUS RT-AX5400 Router
    │
    ▼
Home Network
    │
    ├── Synology NAS
    │
    │     └── Media Storage
    │
    │
    └── Docker Host: home-server-01
          │
          ├── Jellyfin
          ├── Uptime Kuma
          └── Future Docker Services
```

---

## Core Components

| Component | Role | Status |
|----------|------|--------|
| ASUS RT-AX5400 | Primary router and network gateway | Active |
| Synology NAS | Shared storage and media source | Active |
| Docker Host | Debian host running Docker services | Active |
| Jellyfin | Media streaming application | Active |
| Uptime Kuma | Service and host availability monitoring | Deployed |
| Prometheus | Metrics collection | Planned |
| Grafana | Metrics visualization | Planned |
| Loki | Log aggregation | Planned |
| Homepage | Service dashboard | Planned |

---

## Docker Host

The Docker host is a Debian-based system used to run self-hosted services through Docker Compose.

Current role:

```text
Docker Host
├── Application containers
├── Persistent service data
├── Monitoring tools
└── Future observability stack
```

Docker Compose application directories are standardized under:

```text
/opt/docker
```

Example:

```text
/opt/docker/
├── uptime-kuma/
├── grafana/
├── prometheus/
├── loki/
└── homepage/
```

---

## Service Deployment Model

Services are deployed using Docker Compose.

Each service should have:

- Dedicated project directory
- Compose file
- Persistent storage configuration
- Port assignment
- Documentation
- Backup consideration

Example deployment pattern:

```text
/opt/docker/<service-name>/
├── docker-compose.yml
└── data/
```

---

## Current Service Layout

```text
/opt/docker/
└── uptime-kuma/
    ├── docker-compose.yml
    └── data/
```

Uptime Kuma uses a bind mount:

```text
/opt/docker/uptime-kuma/data
    ↓
/app/data
```

This stores Uptime Kuma configuration, monitor definitions, notification settings, and historical monitoring data.

---

## Network Flow

### Internal User Access

```text
Client Device
    │
    ▼
Home Network
    │
    ▼
Docker Host
    │
    ▼
Container Port Mapping
    │
    ▼
Application Container
```

Example:

```text
Browser
    │
    ▼
http://<docker-host>:3001
    │
    ▼
Docker Host Port 3001
    │
    ▼
Uptime Kuma Container Port 3001
```

---

## Port Mapping

| Service | Host Port | Container Port | Protocol | Status |
|----------|----------|----------|----------|----------|
| Uptime Kuma | 3001 | 3001 | TCP | Active |
| Jellyfin | 8096 | 8096 | TCP | Active |
| Grafana | 3000 | 3000 | TCP | Planned |
| Prometheus | 9090 | 9090 | TCP | Planned |
| Homepage | TBD | TBD | TCP | Planned |

---

## Monitoring Architecture

Uptime Kuma currently provides availability monitoring.

Current monitoring approach:

```text
Uptime Kuma
    │
    ├── Router Ping
    ├── Router HTTPS
    ├── Docker Host Ping
    ├── Jellyfin HTTP
    ├── Uptime Kuma HTTP
    └── Internet Connectivity Checks
```

Monitoring goals:

- Confirm infrastructure availability
- Confirm service availability
- Identify host vs application failures
- Provide status page visibility

---

## Storage Architecture

### Application Data

Application configuration and runtime data are stored under each service directory or Docker-managed storage, depending on the deployment pattern.

For Uptime Kuma:

```text
/opt/docker/uptime-kuma/data
```

is mounted into the container at:

```text
/app/data
```

---

## Planned Observability Architecture

Future monitoring stack:

```text
Prometheus
    │
    ├── Node Exporter
    ├── cAdvisor
    ├── SNMP Exporter
    └── Application Exporters

Grafana
    │
    └── Dashboards

Loki
    │
    └── Logs
```

Purpose:

| Tool | Purpose |
|------|---------|
| Uptime Kuma | Availability monitoring |
| Prometheus | Metrics collection |
| Grafana | Metrics visualization |
| Loki | Log aggregation |

Uptime Kuma answers:

```text
Is it up?
```

Prometheus and Grafana answer:

```text
How healthy is it?
```

---

## Status Page

Uptime Kuma provides a status page for high-level visibility.

Current status page groups:

- Applications
- Infrastructure
- Internet

Purpose:

- Provide quick operational status
- Summarize service availability
- Separate infrastructure, application, and connectivity checks

---

## Security Considerations

- Secrets are not committed to source control.
- `.env` files should be excluded through `.gitignore`.
- Administrative access is restricted to authorized users.
- Services should expose only required ports.
- Reverse proxy and TLS strategy are planned.
- Docker administrators are treated as privileged users.
- Persistent data should be backed up before destructive changes.

---

## Current Limitations

| Limitation | Impact | Planned Improvement |
|----------|--------|---------------------|
| No reverse proxy | Services accessed by IP and port | Evaluate reverse proxy |
| No centralized metrics | Limited performance visibility | Deploy Prometheus and Grafana |
| No centralized logs | Logs reviewed per service | Deploy Loki |
| NAS dependency not automated | Jellyfin may start before storage | Add mount dependency or restart procedure |
| No UPS | Sudden outage risk | Evaluate UPS |

---

## Related Documentation

| Document | Purpose |
|----------|----------|
| [lessons-learned.md](lessons-learned.md) | Project lessons and operational findings |
| [docker-installation.md](../../docs/reference/docker-installation.md) | Docker installation procedure |
| [docker-container-deployment.md](../../docs/reference/docker-container-deployment.md) | Docker Compose deployment procedure |
| [docker-concepts.md](../../docs/reference/docker-concepts.md) | Docker concepts and terminology |
| [docker-command-reference.md](../../docs/reference/docker-command-reference.md) | Docker command reference |
| [uptime-kuma-reference.md](../../docs/reference/uptime-kuma-reference.md) | Uptime Kuma monitor configuration reference |
