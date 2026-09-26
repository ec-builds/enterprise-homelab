# Alloy Notes

Quick reference for the Grafana Alloy deployment in the Enterprise Homelab.

## Deployment

| Item | Value |
|------|-------|
| Image | `grafana/alloy:v1.19.2` |
| Deployment | Docker Compose |
| HTTP / UI Port | `12345/TCP` |
| Configuration | `config.alloy` |
| State Storage | Bind mount |
| Docker Network | `monitoring` |
| Current Role | rsyslog file collection and Loki forwarding |

Alloy currently provides the collection layer between persisted rsyslog logs and Loki.

## Current Pipeline

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

The current Alloy deployment is intentionally limited to rsyslog file collection. Additional sources such as Docker logs can be added separately after the base logging pipeline is validated.

## Bind Mounts

The container uses the following mounts:

```yaml
volumes:
  - ./config.alloy:/etc/alloy/config.alloy:ro
  - ./data:/var/lib/alloy/data
  - /opt/docker/rsyslog/logs:/var/log/rsyslog:ro
```

Purpose:

| Container Path | Access | Purpose |
|----------------|--------|---------|
| `/etc/alloy/config.alloy` | Read-only | Alloy configuration |
| `/var/lib/alloy/data` | Read/write | Persistent Alloy state |
| `/var/log/rsyslog` | Read-only | Centralized rsyslog files |

rsyslog logs are mounted read-only so Alloy can collect them without modifying the original files.

## Configuration

The current pipeline discovers rsyslog log files, tails them, and forwards entries to Loki.

```alloy
logging {
  level  = "info"
  format = "logfmt"
}

local.file_match "rsyslog" {
  path_targets = [
    {
      "__path__" = "/var/log/rsyslog/*.log",
      "job"      = "rsyslog",
    },
  ]
}

loki.source.file "rsyslog" {
  targets    = local.file_match.rsyslog.targets
  forward_to = [loki.write.local.receiver]
}

loki.write "local" {
  endpoint {
    url = "http://loki:3100/loki/api/v1/push"
  }
}
```

Because Alloy and Loki share the external `monitoring` Docker network, Alloy reaches Loki using the container name `loki` rather than the Docker host address.

## Alloy Configuration Syntax

Alloy configuration files use `//` for comments:

```alloy
// Valid Alloy comment
```

Do not use shell/YAML-style `#` comments:

```text
# Invalid Alloy comment
```

Using `#` causes validation errors such as:

```text
illegal character U+0023 '#'
expected identifier, got ILLEGAL
```

## Configuration Validation

Validate `config.alloy` before deploying or restarting Alloy:

```bash
docker run --rm \
  -v "$(pwd)/config.alloy:/etc/alloy/config.alloy:ro" \
  grafana/alloy:v1.19.2 \
  validate /etc/alloy/config.alloy
```

A successful validation exits without configuration errors.

Also validate Docker Compose:

```bash
docker compose config
```

## Deployment Validation

Check the container:

```bash
docker ps --filter name=alloy
```

Check Alloy logs:

```bash
docker logs --tail 100 alloy
```

Successful startup should include:

```text
Alloy is running
```

The logs should also show the configured files being tailed:

```text
start tailing file
```

## HTTP / UI Validation

Check the Alloy HTTP endpoint:

```bash
curl -I http://localhost:12345/
```

Expected:

```text
HTTP/1.1 200 OK
```

The Alloy UI can also be used to inspect configured components and their current status.

## Verify rsyslog Access

Confirm Alloy can see the read-only rsyslog mount:

```bash
docker exec alloy ls -lah /var/log/rsyslog
```

The configured `*.log` files should be visible.

Alloy startup logs should show a tailer being created for each discovered file.

## Loki Validation

The current configuration assigns:

```text
job="rsyslog"
```

to collected logs.

Query Loki directly to verify end-to-end ingestion:

```bash
curl -sG 'http://localhost:3100/loki/api/v1/query_range' \
  --data-urlencode 'query={job="rsyslog"}' \
  --data-urlencode 'limit=10'
```

A successful response should contain:

```json
"status": "success"
```

and a non-empty result containing actual rsyslog entries.

If `jq` is installed, the response can be formatted with:

```bash
curl -sG 'http://localhost:3100/loki/api/v1/query_range' \
  --data-urlencode 'query={job="rsyslog"}' \
  --data-urlencode 'limit=10' | jq
```

## Current Labels

The initial pipeline exposes labels including:

```text
job="rsyslog"
filename="/var/log/rsyslog/<source>.log"
```

Additional source-specific labels can be introduced later if they provide operational value.

Avoid creating high-cardinality labels from values such as IP addresses, message contents, ports, request IDs, or other frequently changing fields.

## Persistent State

Alloy state is persisted under:

```text
/var/lib/alloy/data
```

through the host bind mount:

```text
./data
```

Persistent state allows file collection components to maintain their progress across container recreation and service restarts.

Do not delete the Alloy data directory as part of routine container recreation.

## Log Rotation

rsyslog log files are rotated independently by the Docker host.

Alloy reads the persisted rsyslog files rather than receiving syslog directly. File collection behavior should be revalidated whenever the rsyslog rotation strategy is changed.

## Useful Commands

```bash
# Validate Alloy configuration
docker run --rm \
  -v "$(pwd)/config.alloy:/etc/alloy/config.alloy:ro" \
  grafana/alloy:v1.19.2 \
  validate /etc/alloy/config.alloy

# Validate Compose
docker compose config

# Start
docker compose up -d

# Stop
docker compose down

# Restart
docker compose restart

# Follow Alloy logs
docker logs -f alloy

# Check HTTP endpoint
curl -I http://localhost:12345/

# Verify rsyslog files are visible
docker exec alloy ls -lah /var/log/rsyslog

# Query ingested logs from Loki
curl -sG 'http://localhost:3100/loki/api/v1/query_range' \
  --data-urlencode 'query={job="rsyslog"}' \
  --data-urlencode 'limit=10'
```

## Troubleshooting

Verify the pipeline in order:

```text
Source
  │
  ▼
rsyslog
  │
  ▼
Host log file
  │
  ▼
Alloy read-only mount
  │
  ▼
local.file_match
  │
  ▼
loki.source.file
  │
  ▼
loki.write
  │
  ▼
Loki
```

If logs are not reaching Loki:

1. Confirm rsyslog is writing to the source log file.
2. Confirm the file is visible inside the Alloy container.
3. Check Alloy logs for `start tailing file`.
4. Check the Alloy UI for component errors.
5. Confirm Loki is reachable from the `monitoring` Docker network.
6. Query Loki directly using `{job="rsyslog"}`.

## Future Expansion

Potential future Alloy sources include:

- Docker container logs
- Linux system logs / journal
- Application logs
- Additional telemetry sources where Alloy is appropriate

Docker log collection is not currently configured. Avoid mounting the Docker socket until Docker discovery is intentionally implemented and its access implications are considered.

## Sources

- https://grafana.com/docs/alloy/latest/set-up/install/docker/
- https://grafana.com/docs/alloy/latest/reference/components/local/local.file_match/
- https://grafana.com/docs/alloy/latest/reference/components/loki/loki.source.file/
- https://grafana.com/docs/alloy/latest/reference/components/loki/loki.write/
