# Node Exporter

Reference guide for installing and managing Prometheus Node Exporter directly on a Debian-based Linux host.

Node Exporter exposes operating system and hardware metrics in Prometheus format. Typical metrics include CPU utilization, memory usage, filesystem capacity, disk activity, load, and network statistics.

## Overview

| Setting | Value |
|---|---|
| **Platform** | Debian-based Linux |
| **Deployment** | Native binary |
| **Service Manager** | systemd |
| **Default Port** | `9100/TCP` |
| **Service Account** | `node_exporter` |
| **Binary** | `/usr/local/bin/node_exporter` |
| **Service File** | `/etc/systemd/system/node-exporter.service` |
| **Prometheus Job** | `node-exporter` |

The naming convention intentionally preserves the upstream Node Exporter binary and service account naming while using hyphenated names for the systemd service and Prometheus job.

```text
Product          Node Exporter
Binary           node_exporter
Service Account  node_exporter
systemd Service  node-exporter.service
Prometheus Job   node-exporter
```

The basic metrics flow is:

```text
Linux Host
    │
    ▼
Node Exporter :9100
    │
    ▼
Prometheus
    │
    ▼
Grafana
```

## 1. Check System Architecture

Determine the host architecture before downloading Node Exporter:

```bash
uname -m
```

Typical output on an x86-64 system:

```text
x86_64
```

Use the corresponding `linux-amd64` Node Exporter release.

## 2. Create the Service Account

Create a dedicated system account for Node Exporter:

```bash
sudo useradd --system \
  --no-create-home \
  --shell /usr/sbin/nologin \
  node_exporter
```

Verify the account:

```bash
getent passwd node_exporter
```

Node Exporter does not require an interactive login account.

## 3. Download Node Exporter

Download the desired Node Exporter release from the official Prometheus repository.

Set the version being deployed:

```bash
VERSION="1.12.1"
```

Download the archive:

```bash
cd /tmp

wget "https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz"
```

Extract it:

```bash
tar -xzf "node_exporter-${VERSION}.linux-amd64.tar.gz"
```

Install the binary:

```bash
sudo cp \
  "node_exporter-${VERSION}.linux-amd64/node_exporter" \
  /usr/local/bin/node_exporter
```

Set ownership and permissions:

```bash
sudo chown root:root /usr/local/bin/node_exporter
sudo chmod 755 /usr/local/bin/node_exporter
```

Verify the installation:

```bash
/usr/local/bin/node_exporter --version
```

## 4. Create the systemd Service

Create the service file:

```bash
sudo vi /etc/systemd/system/node-exporter.service
```

Add:

```ini
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Enable Node Exporter at boot and start it immediately:

```bash
sudo systemctl enable --now node-exporter
```

## 5. Verify the Service

Check the service:

```bash
systemctl status node-exporter
```

Verify that Node Exporter is listening on TCP port `9100`:

```bash
ss -lntp | grep 9100
```

Test the metrics endpoint locally:

```bash
curl http://localhost:9100/metrics
```

A successful response returns Prometheus-formatted metrics such as:

```text
node_cpu_seconds_total
node_filesystem_size_bytes
node_memory_MemTotal_bytes
node_network_receive_bytes_total
```

The endpoint can also be tested from another authorized system:

```bash
curl http://<host-address>:9100/metrics
```

## 6. Configure Prometheus

Add the Node Exporter host to the Prometheus scrape configuration:

```yaml
scrape_configs:

  - job_name: "node-exporter"
    static_configs:
      - targets:
          - "<host-address>:9100"
```

Multiple Linux hosts can be included in the same job:

```yaml
scrape_configs:

  - job_name: "node-exporter"
    static_configs:
      - targets:
          - "<host-01>:9100"
          - "<host-02>:9100"
          - "<host-03>:9100"
```

Validate the Prometheus configuration before applying the change:

```bash
promtool check config /path/to/prometheus.yml
```

If Prometheus itself runs in Docker, validation can instead be performed inside the Prometheus container:

```bash
docker exec prometheus \
  promtool check config /etc/prometheus/prometheus.yml
```

Reload or restart Prometheus after updating the configuration.

## 7. Verify Prometheus Collection

Open the Prometheus targets page and confirm the Node Exporter target reports:

```text
UP
```

The target can also be verified with PromQL:

```promql
up{job="node-exporter"}
```

A value of:

```text
1
```

means Prometheus successfully scraped the target.

A value of:

```text
0
```

means Prometheus knows about the target but cannot successfully scrape it.

## Service Management

Start Node Exporter:

```bash
sudo systemctl start node-exporter
```

Stop Node Exporter:

```bash
sudo systemctl stop node-exporter
```

Restart Node Exporter:

```bash
sudo systemctl restart node-exporter
```

Check status:

```bash
systemctl status node-exporter
```

Enable at boot:

```bash
sudo systemctl enable node-exporter
```

Disable at boot:

```bash
sudo systemctl disable node-exporter
```

View recent logs:

```bash
journalctl -u node-exporter
```

Follow logs:

```bash
journalctl -u node-exporter -f
```

## Updating Node Exporter

Check the currently installed version:

```bash
node_exporter --version
```

Download and extract the desired newer release using the same installation process.

Stop the service:

```bash
sudo systemctl stop node-exporter
```

Replace the binary:

```bash
sudo cp node_exporter /usr/local/bin/node_exporter
sudo chown root:root /usr/local/bin/node_exporter
sudo chmod 755 /usr/local/bin/node_exporter
```

Start the service:

```bash
sudo systemctl start node-exporter
```

Verify:

```bash
node_exporter --version
systemctl status node-exporter
```

## Troubleshooting

### Service Does Not Start

Check systemd status:

```bash
systemctl status node-exporter
```

Review logs:

```bash
journalctl -u node-exporter --no-pager -n 100
```

Confirm the binary exists:

```bash
ls -l /usr/local/bin/node_exporter
```

Confirm the service account exists:

```bash
getent passwd node_exporter
```

### Port 9100 Is Not Listening

Check:

```bash
ss -lntp | grep 9100
```

Then verify the service:

```bash
systemctl status node-exporter
```

### Metrics Work Locally but Not Remotely

Test locally first:

```bash
curl http://localhost:9100/metrics
```

Then test from the Prometheus host:

```bash
curl http://<host-address>:9100/metrics
```

If local access works but remote access fails, investigate:

- host firewall rules
- network ACLs
- routing
- VLAN/firewall boundaries
- TCP port `9100` reachability

### Prometheus Target Shows DOWN

Confirm Node Exporter is running:

```bash
systemctl status node-exporter
```

Confirm the endpoint responds:

```bash
curl http://<host-address>:9100/metrics
```

Verify the configured target and port in Prometheus.

After correcting the configuration, confirm:

```promql
up{job="node-exporter"}
```

returns:

```text
1
```

## Security

Node Exporter exposes detailed information about the host and should be treated as an internal monitoring service.

Recommended practices:

- Restrict `9100/TCP` to trusted monitoring networks.
- Do not expose Node Exporter directly to the public Internet.
- Limit access to the Prometheus server and authorized administrative systems.
- Run Node Exporter using the dedicated `node_exporter` service account.
- Keep the Node Exporter binary updated.
- Use sanitized hostnames and addresses in public documentation.

Node Exporter's metrics endpoint does not require authentication by default. Network-level access controls should therefore be used to restrict access.

## Native vs Container Deployment

Node Exporter can also run in Docker, but container deployments require additional host access to expose accurate host-level metrics.

Typical container deployments may expose host resources such as:

```text
/proc
/sys
/
```

and may use host namespaces or additional Node Exporter path configuration.

Native deployment avoids this additional container configuration and is particularly useful on Linux infrastructure hosts where installing a container runtime solely for Node Exporter would add unnecessary complexity.

Where Docker is already part of the host's role, either deployment model can be used depending on operational requirements.

## Removal

Stop and disable the service:

```bash
sudo systemctl disable --now node-exporter
```

Remove the service definition:

```bash
sudo rm /etc/systemd/system/node-exporter.service
```

Reload systemd:

```bash
sudo systemctl daemon-reload
```

Remove the binary:

```bash
sudo rm /usr/local/bin/node_exporter
```

Remove the service account if it is no longer required:

```bash
sudo userdel node_exporter
```
