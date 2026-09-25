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

The pipeline is designed so syslog collection and local storage operate before Alloy and Loki are deployed.

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
| Layout | One directory per source host |
| Rotation | TBD |
| Retention | TBD — see retention policy |

Logs share a disk with Prometheus and other monitoring services. Rotation and retention should be defined early so syslog volume cannot fill the monitoring host.

## Data Sources

| Infrastructure | Collection Path | Status |
|----------------|-----------------|:------:|
| NAS / Storage | Syslog → rsyslog | 🟢 |
| Proxmox Hosts | Syslog → rsyslog | ⚪ |
| Cisco Network Devices | Syslog → rsyslog | ⚪ |
| Firewalls | Syslog → rsyslog | ⚪ |

## Ports & Protocols

| Source | Destination | Port / Protocol | Purpose | Status |
|--------|-------------|-----------------|---------|:------:|
| Infrastructure hosts / devices | rsyslog | 514/TCP | Syslog forwarding (preferred) | 🟢 |
| Infrastructure hosts / devices | rsyslog | 514/UDP | Syslog forwarding where TCP is unsupported | 🟢 |
| rsyslog | Alloy | TBD | Handoff to logging pipeline | ⚪ |
| Alloy | Loki | 3100/TCP | Log push | ⚪ |

The current TCP/UDP 514 syslog transport is unauthenticated and unencrypted. Port 514 should be restricted to known source addresses. TLS syslog (6514/TCP) is a possible future improvement.

## Alloy Handoff (Planned)

The rsyslog → Alloy method will be selected when Alloy is deployed. Two options are under consideration:

| Option | How It Works | Trade-off |
|--------|--------------|-----------|
| **Forward** | rsyslog forwards messages over TCP to an Alloy syslog listener | Near real-time; rsyslog can convert messages to RFC 5424, which Alloy's listener expects |
| **File tail** | Alloy reads the log files rsyslog writes to disk | Simple; Alloy catches up from files after an outage |

This section will be updated with the chosen method, port, and configuration once implemented.

## Proxmox Forwarding (Planned)

Each Proxmox node forwards system events to the central collector using its local rsyslog service as the forwarding client. A separate rsyslog container is not required on each node.

```text
systemd-journald ──> local rsyslog ──TCP/514──> Central rsyslog
```

Proxmox VE relies heavily on systemd-journald, and rsyslog may not be installed by default. Confirm it is present before configuring forwarding:

```bash
dpkg -l rsyslog || apt install rsyslog
```

Forwarding configuration is placed under `/etc/rsyslog.d/`. A disk-assisted queue buffers events locally if the collector is unreachable, so they are delivered when the connection returns rather than lost:

```text
# /etc/rsyslog.d/90-forward.conf
*.* action(type="omfwd" target="<collector-ip>" port="514" protocol="tcp"
           queue.type="LinkedList" queue.filename="fwd_queue"
           queue.saveOnShutdown="on" action.resumeRetryCount="-1")
```

Validate on one node end-to-end before deploying to the remaining cluster nodes.

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

**3. Test TCP reachability from the source:**

```bash
nc -vz <collector-ip> 514
```

**4. Send a test message directly to the collector:**

```bash
logger -n <collector-ip> -P 514 -T "SYSLOG TEST from $(hostname)"
```

Omitting `-n` tests the full path through the source's local rsyslog forwarder instead.

**5. Confirm arrival at the collector:**

```bash
tail -f /opt/docker/rsyslog/logs/<source-host>/*.log
```

## Troubleshooting

Verify the path in order:

```text
Source logging ──> Local forwarder ──> Network ──> Docker host :514 ──> rsyslog container ──> /opt/docker/rsyslog/logs
```

Packet capture confirms whether events reach the monitoring host:

```bash
sudo tcpdump -ni any port 514        # arrival
sudo tcpdump -ni any port 514 -A     # message contents
```

**Source identity:** The network source address and the hostname contained within a syslog message are separate values and may differ. If sources are misidentified, verify the container networking configuration and whether logs are organized by sender address or message hostname.

**Timestamps:** Correlating events across systems requires all sources to be time-synchronized with NTP.

## Failure Behavior

| Failure | Impact |
|---------|--------|
| Source rsyslog service down | Events from that source are not forwarded |
| Network path unavailable | Events queue on sources with disk-assisted queues; otherwise lost |
| rsyslog container down | Central ingestion stops; queued sources resend on recovery |
| Docker Monitoring Host down | Central ingestion stops |
| Alloy down *(planned)* | Collection continues; forwarding gaps depend on the handoff method |
| Loki down *(planned)* | Collection and local storage continue; logs unavailable in Grafana |

## Design Principles

- Use rsyslog as the central collector for infrastructure that supports standard syslog.
- Prefer TCP; use UDP only where required.
- Persist logs outside the container and define retention early.
- Buffer on the source so collector outages do not lose events.
- Restrict syslog ports to known sources.
- Keep collection independent of storage and visualization.
- Preserve source identity and synchronized time for correlation.
- Validate one source end-to-end before expanding.

## Next Steps

**Completed**

- 🟢 Deploy centralized rsyslog collector
- 🟢 Validate NAS syslog forwarding

**Remaining**

- ⚪ Define log rotation and retention
- ⚪ Restrict port 514 to known sources
- ⚪ Configure Proxmox syslog forwarding
- ⚪ Configure Cisco syslog forwarding
- ⚪ Configure firewall syslog forwarding
- ⚪ Select and implement the Alloy handoff method
- ⚪ Validate log queries in Grafana after Loki deployment
