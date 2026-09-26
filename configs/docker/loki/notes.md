# Loki Notes

Quick reference for the Loki deployment in the Enterprise Homelab.

## Deployment

| Item | Value |
|------|-------|
| Image | `grafana/loki:3.7.0` |
| Deployment | Docker Compose |
| Port | `3100/TCP` |
| Storage | Local filesystem |
| Index | TSDB |
| Schema | v13 |
| Retention | 30 days |
| Analytics | Disabled |
| Authentication | Disabled |
| Docker Network | `monitoring` |

Loki is deployed as a single-node instance. Distributed Loki and external object storage are not required for the current environment.

## Storage

Persistent Loki data is bind-mounted:

```yaml
volumes:
  - ./loki-config.yaml:/mnt/config/loki-config.yaml:ro
  - ./data:/loki
```

Typical structure after initialization:

```text
data/
├── chunks/
├── compactor/
│   ├── deletion/
│   └── retention/
├── rules/
├── tsdb-shipper-active/
├── tsdb-shipper-cache/
└── wal/
```

## Bind Mount Permissions

The Loki 3.7.0 container runs as UID `10001`.

Check the image:

```bash
docker image inspect grafana/loki:3.7.0 \
  --format '{{.Config.User}}'
```

A host-created `data/` directory may initially be owned by the host user, causing:

```text
mkdir /loki/rules: permission denied
error initialising module: ruler-storage
```

Correct ownership:

```bash
sudo chown -R 10001:10001 /opt/docker/loki/data
```

Verify numerically:

```bash
ls -ldn /opt/docker/loki/data
```

Do not use `chmod 777` or run Loki as root to work around bind-mount permissions.

## Configuration

The deployment uses:

- TSDB storage
- Schema v13
- Filesystem object storage
- 24-hour index period
- Single-instance in-memory ring
- Replication factor 1
- 30-day retention using the Compactor

Retention configuration:

```yaml
limits_config:
  retention_period: 30d

compactor:
  working_directory: /loki/compactor
  retention_enabled: true
  delete_request_store: filesystem
```

Usage analytics are explicitly disabled:

```yaml
analytics:
  reporting_enabled: false
```

## Validation

Validate Docker Compose:

```bash
docker compose config
```

Check the container:

```bash
docker ps --filter name=loki
```

Check startup logs:

```bash
docker logs loki
```

Check readiness:

```bash
curl http://localhost:3100/ready
```

Expected:

```text
ready
```

Check the metrics endpoint:

```bash
curl -s http://localhost:3100/metrics | head
```

Check recent logs:

```bash
docker logs --since 1m loki
```

Check persistent storage:

```bash
sudo find /opt/docker/loki/data -maxdepth 2 -type d
```

## Startup Notes

Immediately after startup, `/ready` may temporarily return:

```text
Ingester not ready: waiting for 15s after being ready
```

This is expected during initialization. Retry after approximately 15–20 seconds.

An initial message such as:

```text
error getting ingester clients err="empty ring"
```

may also occur while the single Loki instance is initializing its ring. Confirm that subsequent logs show the components becoming active and:

```text
msg="Loki started"
```

Recurring errors after startup should be investigated.

## Logging Pipeline

Current target architecture:

```text
Infrastructure
      │
      ▼
   rsyslog
      │
      ▼
Persistent Log Files
      │
      ▼
     Alloy
      │
      ▼
      Loki
      │
      ▼
    Grafana
```

rsyslog remains responsible for receiving and retaining traditional infrastructure syslog. Alloy will collect the persisted rsyslog files and forward them to Loki.

## Useful Commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# Restart
docker compose restart

# Follow logs
docker logs -f loki

# Readiness
curl http://localhost:3100/ready

# Metrics
curl http://localhost:3100/metrics

# Storage usage
du -sh /opt/docker/loki/data

# Inspect persistent files
sudo find /opt/docker/loki/data -maxdepth 2 -type d
```

## Sources

- https://github.com/grafana/loki
- https://github.com/grafana/loki/blob/main/cmd/loki/loki-docker-config.yaml
- https://grafana.com/docs/loki/latest/configure/
- https://grafana.com/docs/loki/latest/configure/examples/configuration-examples/
- https://grafana.com/docs/loki/latest/operations/storage/retention/
- https://grafana.com/docs/loki/v3.7.x/setup/install/docker/
