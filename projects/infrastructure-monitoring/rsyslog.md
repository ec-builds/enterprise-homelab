# rsyslog

Centralized syslog collector deployed as part of the Docker Lab.

**Status: 🟢 Operational**

rsyslog provides a common logging endpoint for infrastructure systems and network devices that support standard syslog forwarding. The container receives syslog events, writes them to persistent source-specific log files, and provides those files to Grafana Alloy for downstream processing.

Detailed logging architecture, source integrations, severity processing, Loki ingestion, and Grafana visualization are documented in the `infrastructure-monitoring` lab.

## Deployment

rsyslog runs as a Docker container on the Docker Monitoring Host.

| Item | Value |
|---|---|
| Deployment | Docker Compose |
| Service directory | `/opt/docker/rsyslog` |
| Persistent logs | `/opt/docker/rsyslog/logs` |
| TCP listener | `514/TCP` |
| UDP listener | `514/UDP` |
| Docker network | `monitoring` |
| Restart policy | `unless-stopped` |

The service follows the standard Docker Lab directory structure:

```text
/opt/docker/rsyslog/
├── docker-compose.yml
├── config/
│   └── rsyslog.conf
└── logs/
    └── *.log
```

> [!note]
> For the example Docker Compose configuration and deployment notes, see `/configs/rsyslog`.
>
> For reference notes on rsyslog and logrotate, see `docs/reference/logs`.

## Configuration

The rsyslog configuration is maintained under:

```text
/opt/docker/rsyslog/config/
```

The configuration handles:

- TCP and UDP syslog reception
- source identification
- source-specific log routing
- severity and facility preservation
- persistent file output

Received events are normalized using a format similar to:

```text
<timestamp> <source> severity=<severity> facility=<facility> <application>: <message>
```

A representative output template is:

```conf
template(name="RemoteFormat" type="string"
         string="%timegenerated% %fromhost-ip% severity=%syslogseverity-text% facility=%syslogfacility-text% %syslogtag%%msg%\n")
```

Source addresses and environment-specific routing rules are intentionally omitted from public documentation.

## Persistent Storage

Received logs are persisted on the Docker host under:

```text
/opt/docker/rsyslog/logs/
```

Each configured source writes to a separate active log file.

Example:

```text
logs/
├── firewall.log
├── hypervisor01.log
├── hypervisor02.log
├── network-switch.log
├── storage.log
└── ...
```

Because the files are stored outside the container, they persist across container restarts, recreation, and image updates.

Log rotation is handled by the Docker host using `logrotate`.

| Setting | Value |
|---|---|
| Rotation | Daily |
| Retention | 90 rotated logs |
| Compression | Enabled |
| Method | `copytruncate` |

See `docs/reference/logs/` for the log rotation configuration and operational reference.

## Monitoring Integration

The rsyslog container is responsible for receiving and persisting traditional syslog events.

Grafana Alloy consumes the active log files for downstream processing.

```text
Syslog Sources
      │
      ▼
   rsyslog
      │
      ▼
Persistent *.log Files
      │
      ▼
 Grafana Alloy
```

The complete pipeline is documented in the Infrastructure Monitoring Lab:

```text
rsyslog → Alloy → Loki → Grafana
```

This Docker Lab document intentionally does not duplicate the logging architecture, Loki configuration, LogQL queries, or Grafana dashboard implementation.

## Security

TCP and UDP syslog on port 514 are unencrypted and unauthenticated.

The listeners should therefore:

- remain internal
- be restricted to trusted sources
- not be exposed directly to the public Internet

Persisted logs may contain operational or security-relevant information and should be protected accordingly.

Credentials, private infrastructure addresses, and other sensitive configuration are not stored in the public repository.

## References

For detailed logging implementation and operations, see:

- `infrastructure-monitoring/logs-monitoring.md` — centralized logging architecture, processing, Loki, and Grafana
- `docs/reference/logs/` — log rotation and retention
- source-specific infrastructure documentation — syslog forwarding configuration

This document is intentionally limited to the **rsyslog Docker container and its deployment**.
