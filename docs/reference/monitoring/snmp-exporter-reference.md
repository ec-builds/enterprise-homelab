# SNMP Exporter Reference

Reference guide for deploying, configuring, validating, and maintaining Prometheus SNMP Exporter in the homelab monitoring environment.

SNMP Exporter provides a bridge between SNMP-enabled infrastructure and Prometheus. It queries devices using SNMP and converts the responses into Prometheus-compatible metrics.

## Architecture

```text
Prometheus
    │
    │ HTTP /snmp
    ▼
SNMP Exporter :9116
    │
    ├── SNMPv3 / UDP 161 ──► Synology NAS
    │
    └── SNMPv3 / UDP 161 ──► Cisco Switch
```

A single SNMP Exporter instance can monitor multiple devices. Separate exporter containers are not required for each target.

Prometheus determines which device is queried by passing the target, module, and authentication profile to SNMP Exporter.

## Deployment

| Setting | Value |
|---------|-------|
| Deployment | Docker Compose |
| Container | `snmp-exporter` |
| Image | `prom/snmp-exporter:v0.30.1` |
| Exporter Port | `9116/TCP` |
| SNMP Port | `161/UDP` |
| Docker Network | `monitoring` |
| Restart Policy | `unless-stopped` |
| Authentication | SNMPv3 |
| Security Level | `authPriv` |

Example deployment files are maintained under:

```text
/configs/docker/snmp-exporter/
```

Typical directory structure:

```text
snmp-exporter/
├── docker-compose.yml
├── snmp-auth.yaml
├── .env
└── .env.example
```

The local `.env` contains actual credentials and must not be committed to Git.

## Configuration Files

### `docker-compose.yml`

Defines the SNMP Exporter container and loads both the stock module configuration and custom authentication configuration.

Example:

```yaml
services:
  snmp-exporter:
    container_name: snmp-exporter
    image: prom/snmp-exporter:v0.30.1
    restart: unless-stopped

    command:
      - "--config.file=/etc/snmp_exporter/snmp.yml"
      - "--config.file=/etc/snmp_exporter/snmp-auth.yaml"
      - "--config.expand-environment-variables"

    environment:
      SNMP_USERNAME: ${SNMP_USERNAME}
      SNMP_AUTH_PASSWORD: ${SNMP_AUTH_PASSWORD}
      SNMP_PRIV_PASSWORD: ${SNMP_PRIV_PASSWORD}

    volumes:
      - ./snmp-auth.yaml:/etc/snmp_exporter/snmp-auth.yaml:ro

    networks:
      - monitoring

    ports:
      - "9116:9116"

networks:
  monitoring:
    external: true
```

The `monitoring` network must already exist:

```bash
docker network ls
```

If required:

```bash
docker network create monitoring
```

### Stock `snmp.yml`

The official SNMP Exporter image contains:

```text
/etc/snmp_exporter/snmp.yml
```

This file defines the SNMP modules and object identifiers used to collect metrics.

The host does not need to contain its own `snmp.yml` when the stock configuration provides the required modules.

For example, the stock configuration can provide modules for platforms and standard MIBs such as:

```text
synology
if_mib
```

The configuration is loaded with:

```yaml
command:
  - "--config.file=/etc/snmp_exporter/snmp.yml"
```

Verify that the file exists inside the container:

```bash
docker exec snmp-exporter ls -lh /etc/snmp_exporter/snmp.yml
```

A custom generated `snmp.yml` is only required when the stock modules do not provide the required device telemetry.

### `snmp-auth.yaml`

Authentication profiles are maintained separately from the stock module configuration.

Example:

```yaml
auths:
  <snmp-auth-profile>:
    version: 3

    username: ${SNMP_USERNAME}

    security_level: authPriv

    password: ${SNMP_AUTH_PASSWORD}
    auth_protocol: SHA

    priv_protocol: AES
    priv_password: ${SNMP_PRIV_PASSWORD}
```

The authentication and privacy protocols must match those configured on the target device.

Multiple authentication profiles can be defined when different devices use different credentials.

For example:

```yaml
auths:
  <storage-auth-profile>:
    version: 3
    username: ${STORAGE_SNMP_USERNAME}
    security_level: authPriv
    password: ${STORAGE_SNMP_AUTH_PASSWORD}
    auth_protocol: SHA
    priv_protocol: AES
    priv_password: ${STORAGE_SNMP_PRIV_PASSWORD}

  <switch-auth-profile>:
    version: 3
    username: ${SWITCH_SNMP_USERNAME}
    security_level: authPriv
    password: ${SWITCH_SNMP_AUTH_PASSWORD}
    auth_protocol: SHA
    priv_protocol: AES
    priv_password: ${SWITCH_SNMP_PRIV_PASSWORD}
```

Using separate credentials for different device classes limits credential reuse and makes future credential rotation easier.

## Environment Variables

Actual credentials are stored locally in `.env`.

Example:

```dotenv
SNMP_USERNAME=<snmp-username>
SNMP_AUTH_PASSWORD=<snmp-auth-password>
SNMP_PRIV_PASSWORD=<snmp-privacy-password>
```

Restrict access to the file:

```bash
chmod 600 .env
```

Verify:

```bash
ls -l .env
```

Expected permissions:

```text
-rw-------
```

The file should also be excluded from Git:

```gitignore
.env
```

Only `.env.example` containing placeholders should be published.

## SNMPv3

SNMPv3 is preferred because it supports authentication and encrypted communication.

The deployment uses:

```text
Security Level: authPriv
Authentication: SHA
Privacy: AES
```

`authPriv` provides both:

- authentication of SNMP requests
- encryption of SNMP traffic

The configured algorithms must match the capabilities and configuration of the target device.

SNMPv3 credentials should not be placed directly in Prometheus configuration.

Prometheus references an authentication profile instead:

```text
auth=<snmp-auth-profile>
```

SNMP Exporter resolves that profile using `snmp-auth.yaml`.

## Starting SNMP Exporter

Validate the Compose configuration first:

```bash
docker compose config
```

Start the container:

```bash
docker compose up -d
```

Verify:

```bash
docker compose ps
```

Review startup logs:

```bash
docker logs snmp-exporter --tail 50
```

A successful startup should show that SNMP Exporter is listening on:

```text
:9116
```

## Exporter Self-Metrics

Test the SNMP Exporter HTTP endpoint:

```bash
curl http://localhost:9116/metrics
```

This endpoint reports metrics about SNMP Exporter itself.

It does **not** verify communication with an SNMP device.

The exporter may be healthy while an individual SNMP target remains unreachable or incorrectly configured.

## Testing an SNMP Target

Use the `/snmp` endpoint to perform an end-to-end query:

```bash
curl -G 'http://localhost:9116/snmp' \
  --data-urlencode 'target=<device-host-or-ip>' \
  --data-urlencode 'module=<snmp-module>' \
  --data-urlencode 'auth=<snmp-auth-profile>'
```

For a storage appliance using the stock Synology module, the request follows the pattern:

```bash
curl -G 'http://localhost:9116/snmp' \
  --data-urlencode 'target=<storage-host-or-ip>' \
  --data-urlencode 'module=synology' \
  --data-urlencode 'auth=<snmp-auth-profile>'
```

A successful request returns Prometheus-formatted metrics.

This validates:

```text
SNMP Exporter
      │
      │ SNMPv3
      ▼
Target Device
      │
      │ SNMP response
      ▼
SNMP Exporter
      │
      ▼
Prometheus-formatted metrics
```

Testing the exporter directly is useful before adding a device to Prometheus because it isolates SNMP connectivity and authentication from Prometheus configuration.

## Prometheus Integration

Prometheus uses the SNMP Exporter `/snmp` endpoint instead of scraping the device directly.

Example:

```yaml
- job_name: "snmp-storage"

  metrics_path: /snmp

  params:
    module: [synology]
    auth: [<snmp-auth-profile>]

  static_configs:
    - targets:
        - "<storage-host-or-ip>"

  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target

    - source_labels: [__param_target]
      target_label: instance

    - target_label: __address__
      replacement: snmp-exporter:9116
```

The relabeling performs three important operations.

First, the configured target becomes the `target` parameter sent to SNMP Exporter:

```text
__address__
      ↓
__param_target
```

Second, the original device address is preserved as the Prometheus `instance` label:

```text
__param_target
      ↓
instance
```

Finally, Prometheus redirects the actual HTTP scrape to SNMP Exporter:

```text
snmp-exporter:9116
```

The resulting request is conceptually equivalent to:

```text
http://snmp-exporter:9116/snmp
    ?target=<device>
    &module=<module>
    &auth=<profile>
```

SNMP Exporter then performs the SNMP query on behalf of Prometheus.

## Multiple Devices

One SNMP Exporter can service many Prometheus jobs.

For example:

```text
Prometheus
    │
    ├── snmp-storage
    │       │
    │       ▼
    │   SNMP Exporter ──► Storage Appliance
    │
    └── snmp-switch
            │
            ▼
        SNMP Exporter ──► Network Switch
```

Different device classes can use different:

- SNMP modules
- authentication profiles
- credentials
- Prometheus jobs

This keeps SNMP collection centralized while allowing device-specific monitoring.

## Validating Prometheus Collection

Before restarting Prometheus, validate its configuration:

```bash
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

After loading the configuration, query:

```promql
up{job="<snmp-job>"}
```

Expected result:

```text
1
```

A value of `1` confirms the complete collection path:

```text
Prometheus
    │
    ▼
SNMP Exporter
    │
    ▼
SNMP Device
    │
    ▼
SNMP Exporter
    │
    ▼
Prometheus
```

Device metrics can then be inspected with:

```promql
{job="<snmp-job>"}
```

## Troubleshooting

### Exporter Starts but Target Fails

Confirm the target is reachable from the Docker host:

```bash
ping <device-host-or-ip>
```

Then test the target directly through SNMP Exporter:

```bash
curl -G 'http://localhost:9116/snmp' \
  --data-urlencode 'target=<device-host-or-ip>' \
  --data-urlencode 'module=<snmp-module>' \
  --data-urlencode 'auth=<snmp-auth-profile>'
```

### Hostname Cannot Be Resolved

An error similar to:

```text
lookup <device-host>: no such host
```

indicates name resolution failed.

Test:

```bash
getent hosts <device-host>
```

When troubleshooting initially, using the target's internal IP can help distinguish DNS problems from SNMP problems.

### Authentication Failure

Verify that the following match the target device:

- SNMPv3 username
- security level
- authentication protocol
- authentication password
- privacy protocol
- privacy password

Also verify that Docker received the expected environment variables:

```bash
docker compose config
```

Avoid publishing command output containing resolved credential values.

### Configuration File Mounted as a Directory

If SNMP Exporter reports:

```text
snmp-auth.yaml: is a directory
```

check:

```bash
ls -ld snmp-auth.yaml
```

The configuration must be a regular file:

```text
-rw-------
```

not a directory:

```text
drwx------
```

This can occur when a bind-mounted host path does not exist before the container is created.

### Missing `snmp.yml`

The stock configuration exists inside the container rather than the host deployment directory.

Verify:

```bash
docker exec snmp-exporter ls -l /etc/snmp_exporter/snmp.yml
```

Do not create an empty host `snmp.yml` simply because one is not present beside the Compose file.

### Prometheus Reports `up = 0`

Check each layer independently:

```text
Prometheus
    │
    ├── Can it resolve snmp-exporter?
    │
    ├── Can it reach TCP 9116?
    │
    ▼
SNMP Exporter
    │
    ├── Is the module valid?
    ├── Is the auth profile valid?
    ├── Can it reach the target?
    └── Does SNMPv3 authentication succeed?
```

Testing `/snmp` directly is usually the fastest way to determine whether the failure is on the Prometheus side or the SNMP side.

## Security Considerations

Keep SNMP Exporter and SNMP traffic on trusted internal networks.

Recommended practices:

- Use SNMPv3 instead of SNMPv1 or SNMPv2c where supported.
- Use `authPriv` for authenticated and encrypted communication.
- Use unique credentials where practical.
- Keep credentials in environment files rather than repository configuration.
- Restrict `.env` permissions.
- Exclude credential files from Git.
- Do not expose port `9116` directly to the public Internet.
- Restrict UDP `161` access to authorized monitoring systems where device firewall controls permit it.
- Avoid publishing raw SNMP output containing infrastructure identifiers.

## Maintenance

When upgrading SNMP Exporter:

1. Review the target release.
2. Update the pinned image version.
3. Pull the new image.
4. Recreate the container.
5. Review startup logs.
6. Test exporter self-metrics.
7. Test at least one SNMP target directly.
8. Verify Prometheus targets remain `up`.

Example:

```bash
docker compose pull
docker compose up -d
docker logs snmp-exporter --tail 50
```

After configuration changes, validate both the exporter and the Prometheus scrape path rather than relying only on container status.

## Related Documentation

Example deployment configuration:

```text
/configs/docker/snmp-exporter/
```
