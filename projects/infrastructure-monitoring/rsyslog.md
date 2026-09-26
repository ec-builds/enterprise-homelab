# rsyslog

Centralized syslog collection for infrastructure systems and network devices in the Enterprise Homelab.

**Status: 🟢 Operational**

rsyslog provides a common logging endpoint for systems that support standard syslog forwarding. It receives infrastructure and device events independently of the planned Loki backend and serves as the syslog ingestion layer for the centralized logging architecture.

Until Loki is deployed, rsyslog is also the **only central store** for infrastructure logs.

## Purpose

rsyslog is used to:

- Provide a central syslog destination for infrastructure devices
- Receive system and infrastructure events over standard syslog
- Consolidate and retain logs from multiple systems in one location
- Preserve infrastructure logs independently of individual source systems
- Provide the ingestion point for the planned Alloy and Loki pipeline

rsyslog handles syslog-capable infrastructure only. Agent-based sources (Linux, Docker, applications) will use Grafana Alloy directly; see the architecture document.

## Architecture

```text
Proxmox Hosts ────────┐
Cisco Devices ────────┤
Firewalls ────────────┼──> rsyslog ──> Alloy ──> Loki ──> Grafana
NAS / Storage ────────┘       🟢          ⚪        ⚪        🟢
```

The pipeline is designed so syslog collection and local storage operate independently of Alloy and Loki.

## Deployment

rsyslog runs as a Docker container on the Docker Monitoring Host, following the lab's Docker container standard.

| Item | Value |
|------|-------|
| Host | Docker Monitoring Host |
| Location | `/opt/docker/rsyslog` |
| Deployment | Docker Compose |
| Listening ports | 514/TCP, 514/UDP |

```text
/opt/docker/rsyslog/
├── docker-compose.yml
├── config/        # rsyslog configuration
└── logs/          # persisted remote logs (mounted volume)
```

For the container standard, directory conventions, and compose details, see `docs/reference`.

## Log Storage

Received logs are written to a mounted volume so they persist across container rebuilds.

| Item | Value |
|------|-------|
| Storage path | `/opt/docker/rsyslog/logs` |
| Layout | Separate log file per configured source/device |
| Rotation | Daily |
| Retention | 90 rotated logs |
| Compression | Enabled |

Log rotation is managed by the Docker host using `logrotate`. Logs rotate daily, retain up to 90 rotated files, and are compressed. `copytruncate` is used so the rsyslog container can continue writing to the active log files without requiring a container restart or reload.
See [`docs/reference/logs`](../../docs/reference/logs/) for the log rotation configuration and operational reference.

Example layout:

```text
logs/
├── cisco.log
├── nas.log
├── prox01.log
├── prox02.log
├── prox03.log
└── ...
```

Logs share a disk with Prometheus and other monitoring services. Daily rotation and retention limits prevent unbounded growth of the centralized syslog files.

## Data Sources

| Infrastructure | Collection Path | Status |
|----------------|-----------------|:------:|
| NAS / Storage | Syslog → rsyslog | 🟢 |
| Proxmox Hosts | Syslog → rsyslog | 🟢 |
| Cisco Network Devices | Syslog → rsyslog | 🟢 |
| Firewalls | Syslog → rsyslog | ⚪ |

## Ports & Protocols

| Source | Destination | Port / Protocol | Purpose | Status |
|--------|-------------|-----------------|---------|:------:|
| Infrastructure hosts / devices | rsyslog | 514/TCP | Syslog forwarding (preferred) | 🟢 |
| Infrastructure hosts / devices | rsyslog | 514/UDP | Syslog forwarding where TCP is unsupported | 🟢 |
| rsyslog files | Alloy | Local file access | Log collection | ⚪ |
| Alloy | Loki | 3100/TCP | Log push | ⚪ |

The current TCP/UDP 514 syslog transport is unauthenticated and unencrypted. Port 514 should be restricted to known source addresses. TLS syslog (6514/TCP) is a possible future improvement.

## Alloy Handoff (Planned)

Alloy will collect the persisted log files written by rsyslog and forward them to Loki.

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
```

File-based collection keeps syslog reception independent of the downstream logging pipeline. rsyslog can continue receiving and persisting events if Alloy or Loki is unavailable, and Alloy can resume reading persisted logs when service is restored.

The Alloy configuration and source labels will be documented when the integration is deployed.

## Proxmox Forwarding

Each Proxmox node forwards system events to the central collector using its local rsyslog service as the forwarding client. A separate rsyslog container is not required on each node.

```text
systemd-journald ──> local rsyslog ──TCP/514──> Central rsyslog
```

Proxmox VE relies heavily on systemd-journald, and rsyslog may not be installed by default. Confirm it is present before configuring forwarding:

```bash
dpkg -l rsyslog || apt install rsyslog
```

Forwarding configuration is placed under `/etc/rsyslog.d/`.

Example:

```text
# /etc/rsyslog.d/90-forward.conf
*.* action(type="omfwd" target="<collector-ip>" port="514" protocol="tcp"
           queue.type="LinkedList" queue.filename="fwd_queue"
           queue.saveOnShutdown="on" action.resumeRetryCount="-1")
```

The forwarding action uses a queue and automatic retry behavior so temporary collector interruptions do not immediately interrupt local logging.

All Proxmox nodes have been validated end-to-end against the central collector.

## Cisco Forwarding

Cisco IOS devices use native remote syslog functionality and do not require an additional logging agent.

```text
Cisco IOS ──UDP/514──> Central rsyslog
```

The switch forwards informational and higher-severity events to the collector.

Example:

```text
logging host <collector-ip>
logging trap informational
logging on
```

Local timestamps are configured so Cisco-generated event timestamps use the switch's configured local timezone:

```text
service timestamps debug datetime msec localtime
service timestamps log datetime msec localtime
```

See the Cisco remote syslog forwarding reference for configuration and validation procedures.

## Validation

**1. Check configuration before restarting (source systems):**

```bash
rsyslogd -N1
```

**2. Confirm the collector is listening (Docker Monitoring Host):**

```bash
ss -lntp | grep ':514'     # TCP
ss -lnup | grep ':514'     # UDP
docker port rsyslog
```

**3. Test TCP reachability from applicable sources:**

```bash
nc -vz <collector-ip> 514
```

**4. Send a test message directly to the collector from a Linux source:**

```bash
logger -n <collector-ip> -P 514 -T "SYSLOG TEST from $(hostname)"
```

Omitting `-n` tests the full path through the source's local rsyslog forwarder instead.

**5. Confirm arrival at the collector:**

```bash
tail -f /opt/docker/rsyslog/logs/<source>.log
```

**6. Confirm network delivery when troubleshooting:**

```bash
sudo tcpdump -ni any port 514
```

When Docker networking is involved, `-i any` may display the same packet at multiple stages as it traverses the host, Docker bridge, and container interface.

For source-specific validation, filter by the physical interface and source address where appropriate.

## Troubleshooting

Verify the path in order:

```text
Source logging ──> Local forwarder / native syslog ──> Network ──> Docker host :514 ──> rsyslog container ──> persisted log file
```

Packet capture confirms whether events reach the monitoring host:

```bash
sudo tcpdump -ni any port 514        # arrival
sudo tcpdump -ni any port 514 -A     # message contents
```

**Source identity:** The network source address and the hostname contained within a syslog message are separate values and may differ. If sources are misidentified, verify the container networking configuration and whether logs are organized by sender address or message hostname.

**Timestamps:** Correlating events across systems requires all sources to be time-synchronized with NTP. Some devices may require separate configuration to render syslog timestamps using the configured local timezone.

## Failure Behavior

| Failure | Impact |
|---------|--------|
| Source rsyslog service down | Events from that source are not forwarded |
| Network path unavailable | Delivery depends on source forwarding and queue behavior |
| rsyslog container down | Central ingestion stops; queued sources may resend on recovery |
| Docker Monitoring Host down | Central ingestion and local log storage stop |
| Alloy down *(planned)* | rsyslog continues collecting and persisting infrastructure logs |
| Loki down *(planned)* | rsyslog continues collecting; centralized queries remain unavailable until Loki recovers |

## Design Principles

- Use rsyslog as the central collector for infrastructure that supports standard syslog.
- Prefer TCP; use UDP where required or appropriate for the source platform.
- Persist logs outside the container and define retention early.
- Buffer on supported sources to improve resilience during collector outages.
- Restrict syslog ports to known sources.
- Keep collection independent of storage and visualization.
- Preserve source identity and synchronized time for correlation.
- Validate one source end-to-end before expanding.

## Next Steps

**Completed**

- 🟢 Deploy centralized rsyslog collector
- 🟢 Validate NAS syslog forwarding
- 🟢 Configure and validate Proxmox syslog forwarding
- 🟢 Configure and validate Cisco syslog forwarding

**Remaining**

- 🟢 Configure log rotation and retention
- ⚪ Restrict port 514 to known sources
- ⚪ Configure firewall syslog forwarding
- ⚪ Deploy Loki
- ⚪ Deploy Alloy
- ⚪ Configure Alloy file collection for rsyslog logs
- ⚪ Validate log ingestion and queries in Grafana
