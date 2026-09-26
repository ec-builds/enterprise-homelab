# Grafana Notes

Quick reference for the Grafana deployment in the Enterprise Homelab.

## Deployment

| Item | Value |
|------|-------|
| Image | `grafana/grafana:13.2.1` |
| Deployment | Docker Compose |
| Web Port | `3000/TCP` |
| Data Storage | Bind mount |
| Docker Network | `monitoring` |
| Current Role | Visualization and log exploration |

Grafana provides the visualization and investigation layer for the monitoring stack.

## Current Logging Pipeline

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

Grafana queries Loki rather than receiving logs directly.

## Persistent Storage

Grafana data is persisted using a bind mount:

```yaml
volumes:
  - ./data:/var/lib/grafana
```

The data directory contains Grafana's database, plugins, configuration state, dashboards, and other persistent application data.

Do not delete the data directory as part of routine container recreation.

The data directory should be excluded from Git.

## Bind Mount Permissions

Grafana runs as a non-root user inside the container.

If the host bind mount is not writable, startup may fail with errors similar to:

```text
GF_PATHS_DATA='/var/lib/grafana' is not writable.
mkdir: can't create directory '/var/lib/grafana/plugins': Permission denied
```

Determine the container UID before changing ownership:

```bash
docker image inspect grafana/grafana:13.2.1 \
  --format '{{.Config.User}}'
```

Then assign the Grafana data directory to the UID returned by the image.

Avoid using `chmod 777` or running Grafana as root to resolve bind-mount permissions.

## Loki Data Source

Grafana and Loki share the external Docker network:

```text
monitoring
```

Configure Loki under:

```text
Connections → Data sources → Add data source → Loki
```

Use the internal Docker URL:

```text
http://loki:3100
```

Do not use:

```text
http://localhost:3100
```

Inside the Grafana container, `localhost` refers to Grafana itself. Docker DNS resolves `loki` to the Loki container on the shared network.

No authentication or TLS is currently required for the internal Grafana-to-Loki connection.

## Validate Loki in Grafana

Open:

```text
Explore
```

Select the Loki data source and run:

```logql
{job="rsyslog"}
```

This should return logs collected through the centralized logging pipeline.

## Query a Specific Source File

Alloy currently attaches the source filename as a label.

Example:

```logql
{job="rsyslog", filename="/var/log/rsyslog/<source>.log"}
```

This limits the query to a specific rsyslog source file.

Source-specific labels may be introduced later so queries do not depend on filesystem paths.

## Useful LogQL Queries

All centralized rsyslog logs:

```logql
{job="rsyslog"}
```

Specific source:

```logql
{job="rsyslog", filename="/var/log/rsyslog/<source>.log"}
```

Search returned logs for text:

```logql
{job="rsyslog"} |= "error"
```

Exclude matching text:

```logql
{job="rsyslog"} != "debug"
```

LogQL queries should use labels for stable, low-cardinality metadata and filters for values contained within log messages.

## Deployment Validation

Check the container:

```bash
docker ps --filter name=grafana
```

Check startup logs:

```bash
docker logs --tail 100 grafana
```

A healthy startup should complete without persistent errors and report that Grafana modules are healthy.

## HTTP Validation

Check the local HTTP service:

```bash
curl -I http://localhost:3000/
```

A successful response confirms that the Grafana web service is reachable.

## Docker Network Validation

Confirm Grafana is attached to the expected network:

```bash
docker inspect grafana \
  --format '{{json .NetworkSettings.Networks}}'
```

Grafana and Loki must share a Docker network for the internal `http://loki:3100` endpoint to work.

## Useful Commands

```bash
# Validate Compose
docker compose config

# Start Grafana
docker compose up -d

# Stop Grafana
docker compose down

# Restart Grafana
docker compose restart

# Check container
docker ps --filter name=grafana

# Follow logs
docker logs -f grafana

# Check HTTP service
curl -I http://localhost:3000/

# Inspect persistent data
ls -lah ./data
```

## Troubleshooting

For Grafana-to-Loki issues, validate the path in order:

```text
Grafana
   │
   ▼
Docker Network
   │
   ▼
Loki
   │
   ▼
Log Streams
```

If Loki queries fail:

1. Confirm the Loki container is running.
2. Confirm Grafana and Loki share the `monitoring` Docker network.
3. Verify the Loki data source URL is `http://loki:3100`.
4. Use **Save & test** in the Grafana Loki data source configuration.
5. Confirm Loki contains data using a direct Loki query.
6. Run `{job="rsyslog"}` from Grafana Explore.
7. Check Grafana logs for data-source or connectivity errors.

## Current Status

The initial logging visualization path has been validated as:

```text
Infrastructure
      │
      ▼
   rsyslog
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

Additional Grafana data sources and dashboards can be added as the monitoring stack expands.

## Future Expansion

Potential additions include:

- Prometheus data source
- Infrastructure dashboards
- Network monitoring dashboards
- Log dashboards
- Alert visualization
- Dashboard provisioning from files
- Data source provisioning from files
- Correlation between metrics and logs

Provisioning configuration should be introduced when repeatable Grafana deployment becomes more valuable than manual configuration.

## Security Notes

- Do not commit Grafana credentials or secrets.
- Do not commit the persistent `data` directory.
- Do not publish raw infrastructure logs.
- Raw logs may contain internal addresses, external addresses, hostnames, MAC addresses, ports, authentication events, and other infrastructure details.
- Keep internal data-source communication on the Docker monitoring network where practical.

## Sources

- https://hub.docker.com/r/grafana/grafana
- https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/
- https://grafana.com/docs/grafana/latest/datasources/loki/
- https://grafana.com/docs/loki/latest/query/
