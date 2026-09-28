# Alerting

**Status:** 🟡 In Progress

Alerting provides notification of infrastructure and service conditions that require investigation or intervention.

The alerting strategy is designed to complement the monitoring capabilities of the Enterprise Homelab:

> **Availability** detects service outages.  
> **Metrics** detect infrastructure health and performance conditions.  
> **Logs** provide event context for investigation.  
> **Alerting** determines which conditions require attention and delivers notifications.

The current operational alerting path uses Uptime Kuma with Discord notifications. Prometheus and Alertmanager provide the foundation for metrics-based alerting and are being expanded as monitoring baselines and alert rules are developed.

## Objectives

- Detect actionable infrastructure and service conditions
- Notify administrators when critical services become unavailable
- Provide recovery notifications when services return to normal
- Develop metrics-based alerts using observed infrastructure baselines
- Route and group alerts to reduce unnecessary notification noise
- Avoid duplicate alerts for the same underlying infrastructure failure
- Validate alert delivery from detection through notification

## Alerting Architecture

Alerting operates across the monitoring capabilities rather than functioning as a separate telemetry layer.

```text
Availability
     │
     ▼
 Uptime Kuma
     │
     ▼
Discord Webhook
     │
     ▼
Remote Notification
     🟢


Metrics
     │
     ▼
 Prometheus
  Alert Rules
     │
     ▼
 Alertmanager
     │
     ▼
Notification Routing
     🟡


Logs
     │
     ▼
    Loki
     │
     ▼
Log-Based Alerting
     ⚪
```

Availability alerting is currently operational. Metrics-based alerting is being developed through Prometheus and Alertmanager. Log-based alerting may be introduced later for specific actionable conditions.

## Current Alerting Components

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned

| Component | Purpose | Status |
|---|---|:---:|
| Uptime Kuma | Availability detection and alert generation | 🟢 |
| Discord Webhook | Remote availability and recovery notifications | 🟢 |
| Prometheus Alert Rules | Metrics-based alert evaluation | 🟡 |
| Alertmanager | Alert grouping, routing, and silencing | 🟡 |
| ntfy / Webhooks | Alertmanager notification delivery | ⚪ |
| Email Notifications | Additional notification channel | ⚪ |
| Log-Based Alerting | Actionable alerts derived from centralized logs | ⚪ |

## Availability Alerting

Uptime Kuma provides the current operational alerting path.

```text
Infrastructure / Service
          │
          ▼
      Uptime Kuma
          │
     Down Detected
          │
          ▼
    Discord Webhook
          │
          ▼
   Remote Notification
```

Availability notifications are generated when monitored infrastructure or services transition between availability states.

Current notification behavior includes:

- Initial notification when a monitor is determined to be down
- Repeated notification after every 10 consecutive failures while an outage persists
- Recovery notification when the monitored service becomes available again
- Remote notification through a dedicated Discord channel

Uptime Kuma monitors infrastructure across dependency layers, allowing alerts to provide context about whether a failure originates from network connectivity, DNS, core infrastructure, platform services, or applications.

Detailed monitor configuration and dependency-based monitoring are documented in `availability-monitoring.md`.

## Metrics Alerting

Prometheus provides the metrics evaluation layer for infrastructure alerting.

The target metrics alerting path is:

```text
Infrastructure
      │
      ▼
   Exporters
      │
      ▼
  Prometheus
      │
   Alert Rules
      │
      ▼
 Alertmanager
      │
      ▼
Notification Channels
```

Prometheus evaluates alert rules against collected time-series metrics.

Alertmanager is responsible for downstream alert management, including:

- grouping related alerts
- routing alerts
- suppressing unnecessary duplicate notifications
- silencing alerts during planned maintenance
- delivering alerts to configured notification channels

Metrics-based alerting remains in progress while normal infrastructure behavior and useful thresholds are established.

Potential alert conditions include:

- sustained high resource utilization
- low available storage
- failed Prometheus scrape targets
- container or host availability changes
- abnormal infrastructure resource conditions
- network interface or device health conditions

Alert thresholds should be based on observed normal behavior rather than arbitrary values wherever practical.

## Log-Based Alerting

Centralized logging is operational through the logging pipeline:

```text
Infrastructure
      │
      ▼
   rsyslog
      │
      ▼
Grafana Alloy
      │
      ▼
     Loki
      │
      ▼
   Grafana
```

Logs currently provide event context and investigation capabilities rather than serving as a primary alert source.

Log-based alerting may be introduced for specific conditions where an event represents a clear and actionable operational or security condition.

Examples may include:

- repeated authentication failures
- critical infrastructure events
- significant configuration changes
- service failures not represented by metrics
- specific security-relevant events

Individual error or warning messages should not automatically generate notifications without determining whether they represent actionable conditions.

## Alert Lifecycle

An alert should move through a predictable lifecycle:

```text
Condition Detected
        │
        ▼
Alert Evaluated
        │
        ▼
Notification Sent
        │
        ▼
Investigation
        │
        ▼
Condition Resolved
        │
        ▼
Recovery / Resolution
```

Monitoring telemetry remains available for investigation even when a condition does not warrant an alert.

This distinction prevents alerting from becoming a replacement for dashboards, metrics, or log analysis.

## Alert Design Principles

### Actionable

An alert should identify a condition that requires investigation or intervention.

Avoid notifying simply because telemetry exists or because a single event appears unusual.

### Impact-Oriented

Where possible, alerts should describe operational impact rather than every underlying symptom.

For example:

```text
Application unavailable
```

may be more useful than separate notifications for every failed dependency caused by the same infrastructure outage.

### Baseline Before Threshold

Metrics should be observed under normal operating conditions before aggressive thresholds are introduced.

```text
Collect
   │
   ▼
Observe
   │
   ▼
Establish Baseline
   │
   ▼
Define Threshold
   │
   ▼
Alert
```

This reduces unnecessary alerts caused by thresholds that do not reflect normal infrastructure behavior.

### Avoid Duplicate Notifications

Multiple monitoring systems may detect the same underlying failure.

```text
Host Failure
    │
    ├── Uptime Kuma detects host down
    ├── Prometheus detects scrape failure
    └── Applications become unavailable
```

Alerting should be designed so these signals provide useful context without creating excessive duplicate notifications.

### Preserve Independent Availability Alerting

Availability notifications should remain independent of the Prometheus and Alertmanager pipeline where practical.

```text
Uptime Kuma ──────► Discord

Prometheus ───────► Alertmanager ──────► Notifications
```

This provides separate detection paths for availability and metrics-based conditions.

## Severity

Alert severity should reflect the operational impact and required response.

A simple model can be used as alerting expands:

| Severity | Purpose | Example |
|---|---|---|
| **Critical** | Immediate infrastructure or service impact | Critical infrastructure or multiple dependent services unavailable |
| **Warning** | Condition requires investigation before impact becomes critical | Sustained resource pressure or low storage |
| **Informational** | Operational context that may be useful but does not require immediate action | Recovery or state-change notification |

Severity should be assigned based on operational impact rather than directly mirroring every severity value found in system logs.

## Notification Routing

The current notification path is:

```text
Uptime Kuma
     │
     ▼
Discord Webhook
     │
     ▼
Dedicated Notification Channel
```

The Discord webhook URL is treated as a secret and is never stored in repository documentation or committed to source control.

The planned Alertmanager path will provide centralized routing for metrics-based alerts:

```text
Prometheus
     │
     ▼
Alertmanager
     │
     ├──► ntfy
     ├──► Email
     └──► Webhooks
```

Notification channels should be selected based on reliability, accessibility, and the importance of the alert.

## Validation

Alerting should be tested end-to-end rather than assuming that a configured rule or integration will successfully deliver a notification.

Validation should follow the complete path:

```text
Generate Test Condition
        │
        ▼
Monitoring Detects Condition
        │
        ▼
Alert Generated
        │
        ▼
Notification Delivered
        │
        ▼
Condition Recovered
        │
        ▼
Recovery Confirmed
```

Availability alerting can be validated using controlled service interruptions or dedicated test monitors.

Metrics alerting should be validated with safe test rules before production thresholds are relied upon.

Testing should verify both the initial alert and the recovery path.

## Failure Considerations

Alerting itself is infrastructure and can fail.

```text
Monitoring Condition
        │
        ▼
Alerting Pipeline
        │
        ▼
External Notification
```

A failure anywhere in this path can prevent an otherwise valid alert from reaching the administrator.

The current monitoring architecture also places several monitoring services on the same Docker Monitoring Host. A failure of that host can therefore affect both detection and notification.

Separating critical availability monitoring from the primary monitoring host remains a future resilience improvement.

Detailed monitoring failure domains are documented in `architecture.md`.

## Current State

The current alerting capability is:

```text
Availability Detection       🟢
Discord Notifications        🟢
Recovery Notifications       🟢

Prometheus Alert Rules       🟡
Alertmanager                 🟡
Metrics Notification Routing 🟡

ntfy / Webhooks              ⚪
Email Notifications          ⚪
Log-Based Alerting           ⚪
```

Availability alerting provides the current operational notification capability.

The next stage is to establish useful metrics baselines, implement actionable Prometheus alert rules, and complete Alertmanager notification routing.

## Related Documentation

- `monitoring-strategy.md` — monitoring objectives and guiding principles
- `architecture.md` — component placement, telemetry flows, and failure domains
- `availability-monitoring.md` — Uptime Kuma monitoring and availability notifications
- `metric-monitoring.md` — Prometheus metrics collection and baselines
- `log-monitoring.md` — centralized logging and event investigation
- Docker Lab documentation — container-specific deployment and configuration

## Security

Notification integrations may contain credentials, webhook URLs, tokens, or other authentication material.

These values should:

- never be committed to source control
- never appear in public documentation
- be stored using appropriate application or environment configuration
- be rotated if accidentally exposed

Public documentation should contain only sanitized notification architecture and configuration examples.
