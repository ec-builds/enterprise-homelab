# Uptime Kuma Reference

Reference guide for configuring and managing monitors in Uptime Kuma.

## Quick Start

Recommended settings for most homelab services:

| Setting | Recommended Value |
|----------|----------|
| Monitor Type | Depends on Service Type |
| Heartbeat Interval | 60 seconds |
| Retries | 2 |
| Request Timeout | 10 seconds |
| Method | GET |
| Accepted Status Codes | 200-299 |
| Max Redirects | 10 |
| IP Family | Auto Select |

### Uptime Kuma Monitor Selection Guide

| Service Type | Recommended Monitor | Example |
|----------|----------|----------|
| Web Application | HTTP(s) | Grafana, Uptime Kuma, Homepage |
| Device with Web Management Interface | HTTP(s) | ASUS Router, Synology DSM, iDRAC, iLO |
| Server Without Web Interface | Ping | Linux Server, Hypervisor Host |
| Specific Service Port | TCP Port | SSH (22), RDP (3389), SMB (445), Database Ports |
| DNS Server | DNS | Internal DNS, Public DNS Servers |
| Network Device | Ping | Switches, Access Points, Firewalls |
| Internet Connectivity | Ping | 1.1.1.1, 8.8.8.8 |
| API Endpoint | HTTP(s) | REST APIs, Webhooks |
| Database Service | TCP Port | SQL Server, MySQL, PostgreSQL |

---

> [!TIP]
> For critical systems, monitor both the host and the application. This helps distinguish between a device outage and an application outage.
>
> Example:
>
> - `Debian VM (Ping)` → Confirms the server is reachable.
> - `Uptime Kuma (HTTP)` → Confirms the application is functioning.
>
> If Ping is UP but HTTP is DOWN, the server is healthy but the application likely has an issue.

## Monitor Types

| Type | Purpose | Example |
|----------|----------|----------|
| HTTP(s) | Monitor web applications and management interfaces | Router, Synology, Grafana |
| Ping | Monitor host availability | Servers, routers, switches |
| TCP Port | Verify a service is listening on a port | SSH, RDP, databases |
| DNS | Monitor DNS functionality | Public or internal DNS servers |

### Recommendation

Use:

- HTTP(s) for applications with a web interface
- Ping for basic device availability
- TCP Port for infrastructure services

---

## General Settings

### Friendly Name

Display name shown in the dashboard.

Examples:

```text
ASUS Router
Synology NAS
Debian VM
Grafana
Prometheus
```

---

### URL

Target address monitored by Uptime Kuma.

Examples:

```text
https://<router-ip>
https://<nas-ip>:5001
http://<server-ip>:3001
```

---

### Heartbeat Interval

How often the monitor performs a check.

| Value | Frequency |
|----------|----------|
| 60 | Every minute |
| 300 | Every 5 minutes |
| 900 | Every 15 minutes |

### Recommendation

```text
60 seconds
```

Provides timely alerts while maintaining low resource usage.

---

### Retries

Number of failed checks before the monitor is marked down.

Example:

```text
Retries = 2

Check 1 → Fail
Check 2 → Fail
Check 3 → Fail

Status = DOWN
```

### Recommendation

```text
2
```

Helps prevent false positives caused by temporary network issues.

---

### Request Timeout

Maximum time Uptime Kuma waits for a response.

### Recommendation

```text
10 seconds
```

Suitable for most LAN and internet services.

---

## HTTP Options

### Method

HTTP method used for the check.

Common values:

```text
GET
POST
HEAD
```

### Recommendation

```text
GET
```

Suitable for most monitors.

---

### Body Encoding

Used when sending request bodies.

Common values:

```text
JSON
Form Data
```

### Recommendation

Leave default unless monitoring an API that requires a request body.

---

### Body

Optional request payload.

### Recommendation

Not required for standard web monitoring.

---

### Headers

Custom HTTP headers.

Example:

```json
{
  "Authorization": "Bearer TOKEN"
}
```

### Recommendation

Leave blank unless required.

---

### Authentication

Used when monitoring protected services.

Common methods:

- None
- Basic Authentication
- Token Authentication

### Recommendation

Use only when the endpoint requires authentication.

---

## Notifications

Notification providers can be configured for alerts.

Examples:

- Email
- Discord
- Slack
- Telegram
- ntfy
- Webhooks

### Recommendation

Configure notifications after monitor validation.

---

## Advanced Settings

### Certificate Expiry Notification

Alerts when an SSL certificate approaches expiration.

### Recommendation

Enable for public-facing services.

---

### Domain Name Expiry Notification

Alerts when a domain approaches expiration.

Examples:

```text
emmanuelcasillas.com
xeregen.com
nuvelink.com
```

### Recommendation

Enable for public domains.

Not useful for IP-based monitors.

---

### Ignore TLS/SSL Errors

Ignores certificate validation failures.

### Common Use Case

Internal devices using self-signed certificates:

```text
Router
NAS
Lab services
```

### Recommendation

Enable only when necessary.

---

### Add Cachebuster Parameter

Adds a random parameter to bypass caching.

### Recommendation

Leave disabled unless cache-related issues are suspected.

---

### Upside Down Mode

Marks the service as down when it is reachable.

### Recommendation

Leave disabled.

Used only for specialized monitoring scenarios.

---

### Max Redirects

Maximum redirects to follow.

### Recommendation

```text
10
```

Default is sufficient.

---

### Save HTTP Error Response

Stores failed responses for use in notifications.

### Recommendation

Enable.

Useful for troubleshooting.

---

### Save HTTP Success Response

Stores successful responses.

### Recommendation

Disable unless specifically required.

---

### Response Max Length

Maximum amount of response data to store.

### Recommendation

```text
1024 bytes
```

Default is sufficient.

---

### Accepted Status Codes

HTTP status codes considered successful.

Default:

```text
200-299
```

### Recommendation

Keep default.

---

### IP Family

Network protocol preference.

Options:

```text
Auto Select
IPv4
IPv6
```

### Recommendation

```text
Auto Select
```

---

## Recommended Starter Monitors

### ASUS Router

| Setting | Value |
|----------|----------|
| Type | HTTP(s) |
| URL | https://10.10.10.1 |
| Interval | 60 seconds |
| Retries | 2 |
| Timeout | 10 seconds |

---

### ASUS Router (Availability)

| Setting | Value |
|----------|----------|
| Type | Ping |
| Target | 10.10.10.1 |

---

### Debian VM

| Setting | Value |
|----------|----------|
| Type | Ping |
| Target | 10.10.10.70 |

---

### Synology NAS

| Setting | Value |
|----------|----------|
| Type | HTTP(s) |
| URL | https://10.10.10.10:5001 |

---

### Uptime Kuma Self-Monitor

| Setting | Value |
|----------|----------|
| Type | HTTP(s) |
| URL | http://10.10.10.70:3001 |

---

## Monitoring Strategy

### Ping Monitors

Answer:

```text
Is the device reachable?
```

Examples:

- Router
- Servers
- Switches

---

### HTTP(s) Monitors

Answer:

```text
Is the application working?
```

Examples:

- Router management page
- Synology DSM
- Grafana
- Uptime Kuma

---

## Best Practices

1. Start with a small number of monitors.
2. Use meaningful monitor names.
3. Enable retries to reduce false positives.
4. Use HTTPS whenever available.
5. Enable TLS error ignoring only when necessary.
6. Configure notifications after monitor validation.
7. Use both Ping and HTTP(s) monitors for critical infrastructure.
8. Group related monitors as the environment grows.
