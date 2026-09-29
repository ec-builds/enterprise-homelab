# SNMP Exporter

Prometheus SNMP Exporter provides SNMP-based metrics collection for network devices and appliances that do not run native Prometheus exporters.

In this lab, a single SNMP Exporter instance provides the translation layer between Prometheus and SNMP-enabled infrastructure.

## Deployment Overview

| Component | Configuration |
|-----------|---------------|
| Application | Prometheus SNMP Exporter |
| Deployment | Docker Compose |
| Container | `snmp-exporter` |
| Image | `prom/snmp-exporter:v0.30.1` |
| Exporter Port | `9116/TCP` |
| SNMP Transport | `161/UDP` |
| Docker Network | `monitoring` |
| Restart Policy | `unless-stopped` |
| Authentication | SNMPv3 |
| Security Level | `authPriv` |
| Status | 🟢 Operational |

## Purpose

SNMP Exporter converts SNMP data into metrics that Prometheus can scrape and store.

The exporter acts as an intermediary rather than continuously collecting metrics itself.

```text
Prometheus
    │
    │ HTTP /snmp
    ▼
SNMP Exporter
    │
    │ SNMP
    ▼
Infrastructure Devices
```

Prometheus requests metrics from SNMP Exporter and specifies the target device, SNMP module, and authentication profile. SNMP Exporter then queries the target device and returns the results in Prometheus format.

## Monitored Devices

SNMP Exporter is intended to provide metrics collection for infrastructure devices including:

| Device Type | Purpose |
|-------------|---------|
| Synology NAS | Storage, disk, hardware, and system telemetry |
| Cisco Switch | Interface, traffic, error, and network telemetry |

Additional SNMP-capable infrastructure can be added without deploying a separate SNMP Exporter instance for each device.

Device-specific modules and authentication profiles allow the same exporter to query different platforms.

## Architecture

```text
                         ┌──► Synology NAS
                         │      SNMPv3 / UDP 161
                         │
Prometheus ──► SNMP Exporter
                         │
                         └──► Cisco Switch
                                SNMPv3 / UDP 161
```

Prometheus communicates with SNMP Exporter over the internal Docker monitoring network.

SNMP Exporter then communicates directly with each monitored device using SNMP.


## Configuration

SNMP Exporter configuration examples are maintained in:

```text
/configs/docker/snmp-exporter/
```

The deployment uses the following files:

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines the SNMP Exporter container, network, configuration mounts, and environment variables. |
| `snmp-auth.yaml` | Defines SNMPv3 authentication profiles used for monitored devices. |
| `.env.example` | Documents the environment variables required for SNMP credentials without containing real secrets. |

The stock `snmp.yml` provided by the SNMP Exporter container defines the available SNMP modules and metrics. A custom copy is not maintained unless device-specific modules are required.

Actual credentials are stored in a local `.env` file, which is excluded from Git and restricted to the file owner:

```bash
chmod 600 .env
```

See `/configs/docker/snmp-exporter/` for sanitized deployment examples.


## Prometheus Integration

Prometheus scrapes SNMP devices indirectly through SNMP Exporter.

A typical scrape follows this path:

```text
Prometheus
    │
    │ target + module + auth profile
    ▼
SNMP Exporter :9116
    │
    │ SNMPv3
    ▼
Target Device :161/UDP
    │
    ▼
SNMP Response
    │
    ▼
SNMP Exporter
    │
    ▼
Prometheus TSDB
```

Different Prometheus jobs may use different modules and authentication profiles while sharing the same SNMP Exporter instance.

This allows platform-specific monitoring without requiring a dedicated exporter container for every device.

## Validation

Verify the container is running:

```bash
docker ps --filter name=snmp-exporter
```

Check the exporter logs:

```bash
docker logs snmp-exporter --tail 50
```

Verify the exporter HTTP endpoint:

```bash
curl http://localhost:9116/metrics
```

The `/metrics` endpoint exposes metrics about SNMP Exporter itself. It does not verify communication with an SNMP target.

An end-to-end SNMP query can be tested through the `/snmp` endpoint:

```bash
curl -G 'http://localhost:9116/snmp' \
  --data-urlencode 'target=<device-host-or-ip>' \
  --data-urlencode 'module=<snmp-module>' \
  --data-urlencode 'auth=<snmp-auth-profile>'
```

A successful response confirms that SNMP Exporter can communicate with the target and translate the returned SNMP data into Prometheus metrics.

After adding the target to Prometheus, verify collection with:

```promql
up{job="<snmp-job>"}
```

A value of `1` confirms that Prometheus is successfully scraping the device through SNMP Exporter.

## Security

SNMPv3 is used where supported to provide authenticated and encrypted SNMP communication.

SNMP access should remain restricted to trusted internal monitoring systems.

The exporter HTTP endpoint should not be exposed directly to the public Internet.

Sensitive information must not be committed to the repository, including:

- SNMP usernames
- Authentication passwords
- Privacy passwords
- Community strings
- Private infrastructure addresses

Environment files containing credentials should remain local and be excluded from Git.

## Related Documentation

For example deployment and configuration files:

```text
/configs
```

For monitoring architecture, implementation, and operational reference:

```text
/docs/monitoring
```
