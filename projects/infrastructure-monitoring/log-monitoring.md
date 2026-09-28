# Log Monitoring

This document describes the centralized log monitoring architecture used in the homelab, including how logs are collected, normalized, forwarded, stored, queried, and visualized.

The logging stack is designed around four primary components:

| Component | Role |
|---|---|
| rsyslog | Receives and normalizes traditional syslog messages |
| Grafana Alloy | Collects log files, adds metadata, and forwards logs |
| Loki | Stores and queries centralized logs |
| Grafana | Provides dashboards, filtering, and log investigation |

Together, these components provide a centralized view of infrastructure events without requiring administrators to inspect individual systems manually.

## Architecture Overview

```text
Infrastructure Devices
│
├── Hypervisors
├── Network Devices
├── Storage Systems
├── Firewalls / Routers
└── Other Syslog-Capable Devices
        │
        │ Syslog
        ▼
     rsyslog
        │
        │ Persistent Log Files
        ▼
  Grafana Alloy
        │
        │ Structured Log Streams
        ▼
       Loki
        │
        ▼
     Grafana
        │
        ▼
 Dashboards / Investigation
```

The architecture separates log collection from log storage and visualization. Each component has a specific responsibility and can be maintained independently.

## Log Processing Flow

### 1. Log Generation

Infrastructure systems generate events locally.

Examples include:

- Authentication activity
- Service starts and stops
- Configuration changes
- Scheduled jobs
- Firewall events
- System warnings and errors
- Network device events

Systems capable of standard syslog forwarding send these events to the centralized rsyslog collector.

### 2. Central Syslog Collection

rsyslog acts as the centralized receiver for traditional syslog sources.

The collector accepts syslog messages from approved infrastructure devices and writes messages to separate files based on their source.

Persistent rsyslog files are stored on the Docker host under:

```text
/opt/docker/rsyslog/logs/
```

Example:

```text
/opt/docker/rsyslog/logs/
├── firewall.log
├── hypervisor01.log
├── hypervisor02.log
├── network-switch.log
└── storage.log
```

Source-specific files make it easier to identify where an event originated and allow downstream processing to assign consistent source metadata.

The exact source names used in production are environment-specific.

Log rotation and retention are handled separately from the collection pipeline. For additional information about log rotation, retention, and operational management, see:

```text
docs/reference/logs/
```

For the rsyslog container deployment and implementation details, see the Docker lab documentation.

## Severity Preservation

The rsyslog collector preserves the native syslog severity and facility when writing events.

A normalized entry follows this general structure:

```text
<timestamp> <source> severity=<severity> facility=<facility> <application>: <message>
```

Example:

```text
Sep 28 14:30:00 192.0.2.10 severity=warning facility=daemon service: Example warning event
```

The standard syslog severity levels are:

| Level | Severity | General Meaning |
|---:|---|---|
| 0 | `emerg` | System unusable |
| 1 | `alert` | Immediate action required |
| 2 | `crit` | Critical condition |
| 3 | `err` | Error condition |
| 4 | `warning` | Warning condition |
| 5 | `notice` | Normal but significant condition |
| 6 | `info` | Informational event |
| 7 | `debug` | Debugging information |

Preserving severity at collection time prevents downstream systems from having to infer severity based on keywords such as `error`, `failed`, or `warning`.

## Grafana Alloy

Grafana Alloy monitors the centralized rsyslog files and forwards new entries to Loki.

The processing pipeline is conceptually:

```text
Log Files
    │
    ▼
File Discovery
    │
    ▼
File Tail
    │
    ▼
Source Labeling
    │
    ▼
Severity Parsing
    │
    ▼
Loki
```

### Source Identification

Alloy derives the source from the log filename.

For example:

```text
/var/log/rsyslog/hypervisor01.log
```

can produce:

```text
source="hypervisor01"
```

The `/var/log/rsyslog/` path represents the log directory as mounted inside the Alloy container. The persistent host-side files are maintained under:

```text
/opt/docker/rsyslog/logs/
```

This allows administrators to filter logs by originating system without embedding infrastructure addresses into queries.

### Severity Parsing

Alloy extracts the severity and facility fields preserved by rsyslog.

Conceptually:

```text
severity=warning
facility=daemon
```

becomes structured metadata available during processing.

Severity is promoted to a Loki stream label:

```text
severity="warning"
```

Facility may be extracted for processing while remaining outside the indexed label set unless operational requirements justify indexing it.

This keeps the label model intentionally small.

## Loki

Loki provides centralized storage and querying for the collected log streams.

The primary label model is:

```text
job="rsyslog"
source="<source>"
severity="<severity>"
```

For example:

```text
job="rsyslog"
source="hypervisor01"
severity="warning"
```

These labels are deliberately low-cardinality.

Values such as the following should generally not become Loki labels:

- IP addresses
- Usernames
- Process IDs
- MAC addresses
- Source ports
- Destination ports
- Complete log messages
- Session identifiers

These values can remain within the log body and be searched when needed.

Keeping labels low-cardinality improves Loki scalability and prevents unnecessary stream proliferation.

## Log Queries

Logs can be queried using LogQL.

### All Centralized Logs

```logql
{job="rsyslog"}
```

### Logs From a Specific Source

```logql
{job="rsyslog", source="hypervisor01"}
```

### Warning Events

```logql
{job="rsyslog", severity="warning"}
```

### Errors and More Severe Events

```logql
{job="rsyslog", severity=~"emerg|alert|crit|err"}
```

### Warnings and Errors

```logql
{job="rsyslog", severity=~"emerg|alert|crit|err|warning"}
```

Informational and notice events remain available for investigation even though they are not normally treated as problem indicators.

## Grafana

Grafana provides the primary interface for reviewing and investigating centralized logs.

The general log dashboard is designed to answer several questions:

1. How much logging activity is occurring?
2. Are systems generating warnings or errors?
3. Which systems are producing the most events?
4. Has log volume changed unexpectedly?
5. What events occurred around a specific incident?

A typical dashboard layout is:

```text
┌────────────────┬────────────────┬────────────────┐
│ Log Events     │ Errors         │ Warnings       │
│ Last 5m        │ Last 5m        │ Last 5m        │
└────────────────┴────────────────┴────────────────┘

┌──────────────────────────────────────────────────┐
│              Log Volume Over Time                │
└──────────────────────────────────────────────────┘

┌───────────────────────┬──────────────────────────┐
│ Events by Source      │ Recent Errors / Warnings │
└───────────────────────┴──────────────────────────┘

┌──────────────────────────────────────────────────┐
│                Live / Recent Logs                │
└──────────────────────────────────────────────────┘
```

## Dashboard Queries

### Log Events — Last 5 Minutes

```logql
sum(
  count_over_time(
    {job="rsyslog", source=~"$source"}[5m]
  )
)
```

### Errors — Last 5 Minutes

Errors include error-level events and all more severe syslog classifications.

```logql
sum(
  count_over_time(
    {job="rsyslog", source=~"$source", severity=~"emerg|alert|crit|err"}[5m]
  )
)
```

### Warnings — Last 5 Minutes

```logql
sum(
  count_over_time(
    {job="rsyslog", source=~"$source", severity="warning"}[5m]
  )
)
```

### Log Volume Over Time

```logql
sum by (source) (
  count_over_time(
    {job="rsyslog", source=~"$source"}[$__auto]
  )
)
```

### Events by Source

```logql
sum by (source) (
  count_over_time(
    {job="rsyslog", source=~"$source"}[$__range]
  )
)
```

### Recent Errors / Warnings

```logql
{job="rsyslog", source=~"$source", severity=~"emerg|alert|crit|err|warning"}
```

### Live / Recent Logs

```logql
{job="rsyslog", source=~"$source"}
```

## Source Filtering

The Grafana dashboard uses a source variable to allow administrators to view the entire environment or isolate individual systems.

Conceptually:

```text
Source
├── All
├── firewall
├── hypervisor01
├── hypervisor02
├── network-switch
└── storage
```

The variable is populated dynamically from Loki rather than maintaining a static device list.

This allows newly integrated sources to become available to the dashboard without redesigning individual panels.

## Severity Strategy

Severity is treated according to the classification provided by the originating system and parsed by the syslog pipeline.

The dashboard groups severity into three operational categories:

| Category | Included Severities |
|---|---|
| Errors | `emerg`, `alert`, `crit`, `err` |
| Warnings | `warning` |
| Normal / Context | `notice`, `info`, `debug` |

Informational events are retained because they provide important context during troubleshooting.

For example, an error may become significantly easier to understand when correlated with preceding authentication activity, configuration changes, service restarts, or scheduled operations.

However, informational events are not treated as headline problem indicators simply because of their volume.

## Why Structured Severity Matters

Searching for keywords can produce misleading results.

For example:

```logql
{job="rsyslog"} |~ "(?i)error|failed|failure"
```

may match a normal informational message simply because the word `error` appears in its text.

Structured severity instead allows:

```logql
{job="rsyslog", severity="err"}
```

This uses the severity assigned by the originating syslog system rather than attempting to infer severity from the message.

Structured severity therefore provides more reliable dashboard statistics and a better foundation for future alerting.

## Device-Specific Monitoring

The general Logs Overview dashboard should remain source-neutral.

Device-specific events such as:

- Firewall drops
- Authentication failures
- Interface state changes
- VPN events
- Storage failures
- Hypervisor-specific events

may be useful operationally but should generally be placed in dedicated dashboards rather than promoted to global headline statistics.

For example:

```text
Logs Overview
├── Overall log health
├── Errors
├── Warnings
├── Volume
└── Source activity

Network / Firewall Logs
├── Drops
├── Denies
├── Interface events
└── Network security events

Authentication / Security Logs
├── Failed authentication
├── Administrative access
└── Authentication trends
```

This prevents a device-specific metric from appearing to represent the entire environment.

## Validation

The logging pipeline can be tested by generating controlled syslog events from a Linux system.

Example:

```bash
logger -p local0.warning "TEST WARNING - monitoring validation"
logger -p local0.err "TEST ERROR - monitoring validation"
logger -p local0.crit "TEST CRITICAL - monitoring validation"
```

Expected normalized severity values are:

```text
warning
err
crit
```

Validation should confirm the event at each stage:

```text
Source
  │
  ▼
rsyslog file
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

A successful test verifies both transport and processing rather than only confirming that the source generated an event.

## Historical Logs

Changes to parsing or labeling apply only to newly ingested logs.

Existing Loki entries are not retroactively rewritten when:

- rsyslog templates change
- Alloy parsing rules change
- New Loki labels are introduced

Older events may therefore lack newer labels or appear with an unknown severity in visualization tools.

This is expected and does not indicate a problem with newly ingested data.

## Log Rotation and Retention

The active rsyslog files are maintained under:

```text
/opt/docker/rsyslog/logs/
```

Active files are rotated independently of the rsyslog-to-Alloy-to-Loki ingestion pipeline.

The directory may therefore contain both active and rotated files:

```text
/opt/docker/rsyslog/logs/
├── firewall.log
├── firewall.log-YYYY-MM-DD
├── firewall.log-YYYY-MM-DD.gz
├── hypervisor01.log
├── hypervisor01.log-YYYY-MM-DD
└── hypervisor01.log-YYYY-MM-DD.gz
```

Alloy monitors the active `*.log` files. Rotated files are retained according to the host's log rotation policy and are not treated as new active log sources.

For detailed log rotation configuration, retention behavior, and operational procedures, see:

```text
docs/reference/logs/
```

For the rsyslog container deployment, volume mappings, and collector configuration, see the Docker lab rsyslog documentation.

## Design Principles

The logging architecture follows several principles:

- Centralize infrastructure logs.
- Preserve source-generated severity.
- Normalize metadata before storage.
- Maintain persistent rsyslog logs in a standardized Docker service location.
- Separate active log ingestion from log rotation and retention.
- Use low-cardinality Loki labels.
- Avoid deriving severity from message keywords when structured data is available.
- Keep collection, processing, storage, and visualization responsibilities separate.
- Retain informational events for troubleshooting context.
- Keep general dashboards source-neutral.
- Use device-specific dashboards for specialized operational views.
- Validate the complete logging path with controlled test events.

## Component Responsibilities

```text
rsyslog
├── Receive syslog
├── Identify configured sources
├── Preserve severity and facility
├── Write persistent log files
└── Maintain logs under /opt/docker/rsyslog/logs/

Grafana Alloy
├── Discover active log files
├── Tail new events
├── Assign source metadata
├── Parse severity/facility
└── Forward structured streams

Loki
├── Store centralized logs
├── Index selected labels
└── Provide LogQL querying

Grafana
├── Visualize log activity
├── Filter by source/severity
├── Surface warnings/errors
└── Support incident investigation
```

This separation keeps the logging stack modular while providing a single operational view of events across the environment.

Detailed component deployment and configuration remain documented with the individual services, while log rotation and retention procedures are maintained under `docs/reference/logs/`.
