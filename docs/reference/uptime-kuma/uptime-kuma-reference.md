# Uptime Kuma Reference

Reference guide for configuring and managing Uptime Kuma monitors in a homelab environment.

## Quick Start

Recommended baseline settings for most homelab services:

| Setting | Recommended Value |
|----------|-------------------|
| Monitor Type | Depends on service |
| Heartbeat Interval | 60 seconds |
| Retries | 2 |
| Request Timeout | 10 seconds |
| HTTP Method | GET |
| Accepted Status Codes | 200-299 |
| Max Redirects | 10 |
| IP Family | Auto Select |

### Monitor Selection Guide

Choose the monitor based on **what needs to be validated**, not simply the type of device.

| Target | Recommended Monitor | What It Validates |
|----------|---------------------|-------------------|
| Web Application | HTTP(s) | Application is responding |
| Web Management Interface | HTTP(s) | Management service is responding |
| Linux / Windows Server | Ping | Host is reachable |
| Hypervisor | Ping | Host is reachable |
| Network Device | Ping | Device is reachable |
| Specific Service | TCP Port | Service is listening |
| DNS Server | DNS | DNS queries are working |
| Internet Connectivity | Ping | External network connectivity |
| API Endpoint | HTTP(s) | API endpoint is responding |
| Database Service | TCP Port | Database port is listening |

Examples:

| Service | Monitor |
|----------|---------|
| Grafana | HTTP(s) |
| Prometheus | HTTP(s) |
| Homepage | HTTP(s) |
| Uptime Kuma | HTTP(s) |
| Proxmox Host | Ping |
| Docker Host | Ping |
| Router / Firewall | Ping + HTTP(s) |
| Managed Switch | Ping |
| NAS | Ping + HTTP(s) |
| SSH | TCP Port 22 |
| RDP | TCP Port 3389 |
| SMB | TCP Port 445 |
| DNS | DNS |

> [!Tip]
> For important systems, monitor both the **host** and the **application or service**.
>
> Example:
>
> ```text
> Docker Host (Ping)       → Is the server reachable?
> Uptime Kuma (HTTP)       → Is the application responding?
> ```
>
> If Ping is UP but HTTP is DOWN, the host is reachable but the application or its Docker container may have a problem.


## Initial Deployment

### Database Type

During the initial Uptime Kuma setup, select the database used to store monitors, configuration, notifications, and historical monitoring data.

| Database | How It Works | Advantages | Best Use Case |
|----------|--------------|------------|---------------|
| **SQLite** | Stores the database in a local file within the Uptime Kuma data directory | Simple, lightweight, no separate database server, easy to back up and migrate | **Single-instance homelab deployments** |
| **MariaDB** | Uses a separate MariaDB database server or container | Centralized database, mature MySQL-compatible platform, database can be managed independently of Uptime Kuma | Larger deployments or environments already using MariaDB |
| **MySQL** | Uses a separate MySQL database server or container | Centralized database, widely supported, independent database management and backup | Environments already running MySQL |

### Recommended Homelab Configuration

For a single Uptime Kuma instance, use:

```text
Database Type: SQLite
```

SQLite does not require another container or database server and keeps the deployment simple.

With the Docker bind mount:

```yaml
volumes:
  - ./data:/app/data
```

persistent Uptime Kuma data is stored under:

```text
/opt/docker/uptime-kuma/data/
```

This keeps the application configuration and database together with the Docker project, making the deployment easier to back up and migrate between Docker hosts.

> [!Tip]
> SQLite is generally the best choice when Uptime Kuma is the only application that needs the database. MariaDB or MySQL becomes more useful when there is already centralized database infrastructure or a specific requirement to manage the database independently.

> [!Important]
> The live SQLite database should remain on local storage. Backing up the data directory to a NAS is appropriate, but the active database should not be placed directly on an SMB or NFS network share.



## Monitor Types

### HTTP(s)

Use HTTP(s) when the objective is to verify that a web application or management interface is responding.

Examples:

```text
Grafana
Prometheus
Homepage
Uptime Kuma
Portainer
NAS Management
Router / Firewall Management
```

HTTP monitoring provides more useful application-level validation than Ping alone.

### Ping

Use Ping to determine whether a host or network device is reachable.

Examples:

```text
Proxmox Hosts
Docker Hosts
Linux Servers
Switches
Access Points
Router / Firewall
NAS
```

Ping confirms network reachability but does **not** confirm that an application running on the host is healthy.

### TCP Port

Use TCP monitoring when the objective is to verify that a specific service is listening.

Examples:

```text
SSH        22
DNS        53
SMB        445
RDP        3389
PostgreSQL 5432
```

A successful TCP connection confirms that the port is accepting connections but does not necessarily validate the complete application workflow.

### DNS

Use DNS monitoring when the objective is to verify that a DNS server can successfully resolve queries.

This provides better DNS validation than simply monitoring TCP/UDP port 53 because it tests the actual DNS service.

Examples:

```text
Internal DNS Server
1.1.1.1
8.8.8.8
```

## General Settings

### Friendly Name

Use a name that identifies both the system and, when necessary, what is being monitored.

Examples:

```text
prox-lab-01 - Ping
docker-lab-01 - Ping
Grafana - HTTP
DNS01 - DNS
NAS - DSM
```

This becomes particularly useful when the same device has multiple monitors.

### Target / URL

Use the address appropriate for the monitor.

Examples:

```text
10.0.0.10
https://10.0.0.1
https://10.0.0.10:5001
http://10.0.0.70:3001
```

Internal DNS names can also be used when DNS itself is not the dependency being tested.

> [!Note]
> When troubleshooting infrastructure, using an IP address can help separate application availability from DNS availability. Using a hostname tests the service together with its DNS dependency.

### Heartbeat Interval

Controls how frequently Uptime Kuma performs the check.

| Value | Frequency |
|----------|----------|
| 60 | Every minute |
| 300 | Every 5 minutes |
| 900 | Every 15 minutes |

Recommended baseline:

```text
60 seconds
```

A one-minute interval provides timely detection while generating very little load in a typical homelab.

### Retries

Retries prevent a single temporary failure from immediately generating a DOWN event.

Recommended:

```text
2
```

Conceptually:

```text
Check → Fail
Retry → Fail
Retry → Fail
Status → DOWN
```

This helps reduce alerts caused by brief network interruptions or application delays.

### Request Timeout

Maximum amount of time Uptime Kuma waits for the target to respond.

Recommended baseline:

```text
10 seconds
```

For LAN services, consistently reaching the timeout may itself indicate a performance or connectivity problem.

## HTTP Options

### Method

Recommended for normal web monitoring:

```text
GET
```

Other methods such as `POST` or `HEAD` should only be used when required by the endpoint being monitored.

### Body

Leave empty for normal web monitoring.

Configure a request body only when testing an endpoint that specifically requires one.

### Headers

Leave empty unless the endpoint requires custom headers.

Example:

```json
{
  "Authorization": "Bearer <token>"
}
```

> [!Important]
> Do not place credentials, API keys, or tokens in public documentation or screenshots.

### Authentication

Configure authentication only when the monitored endpoint requires it.

The exact authentication method depends on the application.

## TLS and Certificate Monitoring

### Certificate Expiry Notification

Enable for HTTPS services where certificate expiration needs to be tracked.

Particularly useful for:

```text
Public websites
Reverse-proxied services
Public APIs
```

### Domain Name Expiry Notification

Enable for registered public domains when domain expiration monitoring is useful.

Not applicable to IP-only monitors or internal-only DNS names.

### Ignore TLS/SSL Errors

Leave disabled whenever possible.

It may be required for internal services using self-signed or otherwise untrusted certificates.

Examples:

```text
Router / Firewall
NAS
Lab management interfaces
```

> [!Note]
> Ignoring TLS errors allows availability monitoring to continue, but it also means the monitor is no longer validating certificate trust.

## Advanced HTTP Settings

### Add Cachebuster Parameter

Recommended:

```text
Disabled
```

Enable only when caching interferes with the monitor.

### Upside Down Mode

Recommended:

```text
Disabled
```

This reverses the normal monitor logic and is intended for specialized use cases.

### Max Redirects

Recommended:

```text
10
```

The default is normally sufficient.

### Save HTTP Error Response

Recommended:

```text
Enabled
```

The response can provide useful troubleshooting information when a monitor fails.

### Save HTTP Success Response

Recommended:

```text
Disabled
```

Usually unnecessary unless response content is specifically needed.

### Response Max Length

Recommended:

```text
1024 bytes
```

The default is sufficient for normal monitoring.

### Accepted Status Codes

Recommended:

```text
200-299
```

Change this only when an application intentionally returns another status code that should be considered healthy.

### IP Family

Recommended:

```text
Auto Select
```

Force IPv4 or IPv6 only when intentionally testing a specific protocol.

## Notifications

Uptime Kuma supports multiple notification providers, including:

- Email
- Discord
- Slack
- Telegram
- ntfy
- Webhooks

Configure monitors and confirm that they behave correctly before enabling production notifications.

This prevents configuration mistakes from generating unnecessary alerts.

## Recommended Homelab Monitoring Pattern

As the environment grows, separate **infrastructure availability** from **application availability**.

Example:

```text
Internet
└── External Ping

Network
├── Router / Firewall - Ping
├── Switch - Ping
└── Access Point - Ping

Proxmox
├── prox-lab-01 - Ping
├── prox-lab-02 - Ping
└── prox-lab-03 - Ping

Docker
├── docker-lab-01 - Ping
│   ├── Homepage - HTTP
│   ├── Portainer - HTTP
│   └── Reverse Proxy - HTTP
│
├── monitor-lab-01 - Ping
│   ├── Prometheus - HTTP
│   ├── Grafana - HTTP
│   └── Uptime Kuma - HTTP
│
└── media-lab-vm - Ping
    └── Jellyfin - HTTP
```

This makes failures easier to interpret.

For example:

```text
Host DOWN + Applications DOWN
→ Likely host, VM, network, or power problem

Host UP + One Application DOWN
→ Likely container or application problem

Multiple Hosts DOWN
→ Investigate shared network, hypervisor, or power dependency
```

## Recommended Starter Monitors

> [!Note]
> IP addresses below use sanitized documentation addressing. Substitute addresses appropriate for the environment.

### Router / Firewall

```text
Ping
10.0.0.1
```

Optionally add a separate HTTP(s) monitor for the management interface.

### Proxmox Hosts

```text
Ping
10.0.0.x
```

Create one monitor for each cluster node.

### Docker Hosts

```text
Ping
10.0.0.x
```

Monitor important applications separately using HTTP(s).

### NAS

Use both:

```text
Ping
10.0.0.10
```

and:

```text
HTTP(s)
https://10.0.0.10:5001
```

This distinguishes NAS availability from management-service availability.

### DNS

Use a DNS monitor against the internal DNS server and configure a known internal or external hostname as the query target.

This validates actual DNS resolution rather than simply checking whether the server responds to Ping.

### Uptime Kuma

An HTTP monitor can be created for Uptime Kuma itself:

```text
http://10.0.0.70:3001
```

> [!Note]
> Self-monitoring can detect some application-level problems and provides useful uptime history, but it cannot alert when the entire Uptime Kuma host or notification path is unavailable. External monitoring is required to detect a complete failure of the monitoring system itself.

## Monitoring Strategy

Think of each monitor as answering a specific question:

```text
Ping
→ Is the host reachable?

TCP
→ Is the service accepting connections?

DNS
→ Can the DNS server resolve a query?

HTTP(s)
→ Is the application responding?
```

Uptime Kuma should complement, rather than replace, infrastructure telemetry.

In this environment:

```text
Uptime Kuma
→ Availability and alerting

Prometheus
→ Metrics collection

Grafana
→ Visualization

Loki
→ Log aggregation

Alertmanager
→ Metrics-based alert routing
```

Together, these provide both **availability monitoring** and deeper **performance and infrastructure telemetry**.

## Best Practices

1. Monitor the dependency that actually matters rather than creating monitors simply because a device exists.
2. Use Ping for host availability and HTTP(s) for application availability.
3. Use DNS monitors to validate DNS resolution rather than relying only on Ping.
4. Use meaningful names when multiple monitors target the same system.
5. Use retries to reduce alerts from brief interruptions.
6. Start with a 60-second heartbeat interval and adjust only when necessary.
7. Validate monitors before enabling notifications.
8. Monitor important hosts and their applications separately.
9. Avoid ignoring TLS errors unless required.
10. Never expose credentials, API tokens, internal addresses, or private hostnames in public documentation.
11. Group related monitors as the environment grows.
12. Use Uptime Kuma for availability while Prometheus, Grafana, and Loki provide deeper observability.
