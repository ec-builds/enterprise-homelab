# Alerting

**Status: 🟡 In Progress**

How the homelab decides which conditions need attention and delivers notifications for them.

Uptime Kuma currently sends availability and recovery alerts to Discord. Metrics-based alerting through Prometheus and Alertmanager is being built as baselines and alert rules are developed.

## Objectives

- Notify when critical services become unavailable, and again when they recover
- Build metrics alerts from observed baselines
- Route and group alerts to cut noise
- Avoid duplicate alerts for the same underlying failure
- Test delivery from detection through notification

## Architecture

```text
Availability ──► Uptime Kuma ──► Discord Webhook ──► Remote Notification       🟢

Metrics ───────► Prometheus Alert Rules ──► Alertmanager ──► Notification Routing   🟡

Logs ──────────► Loki ──► Log-Based Alerting                                    ⚪
```

**Legend:** 🟢 Operational · 🟡 In Progress · ⚪ Planned

| Component | Purpose | Status |
|---|---|:---:|
| Uptime Kuma | Availability detection and alert generation | 🟢 |
| Discord Webhook | Remote availability and recovery notifications | 🟢 |
| Prometheus Alert Rules | Metrics alert evaluation | 🟡 |
| Alertmanager | Alert grouping, routing and silencing | 🟡 |
| ntfy / Webhooks | Alertmanager notification delivery | ⚪ |
| Email Notifications | Additional notification channel | ⚪ |
| Log-Based Alerting | Alerts on specific log events | ⚪ |

## Availability Alerting

Uptime Kuma alerts when a monitored service changes state:

- A first notification when a monitor goes down
- A repeat notification after every 10 consecutive failures while the outage lasts
- A recovery notification when the service comes back
- Delivery to a dedicated Discord channel

Monitors are grouped by dependency layer (network, DNS, core infrastructure, platform services, applications), so an alert shows where in the stack the failure is. Monitor configuration is in [Availability Monitoring](./availability-monitoring.md).

## Metrics Alerting

```text
Infrastructure ──► Exporters ──► Prometheus (alert rules) ──► Alertmanager ──► Notification Channels
```

Prometheus evaluates alert rules against collected metrics. Alertmanager groups related alerts, routes them, suppresses duplicates, silences alerts during planned maintenance and delivers them to the configured channels.

Likely alert conditions:

- Sustained high resource use
- Low free storage
- Failed Prometheus scrape targets
- Host or container availability changes
- Network interface or device health problems

Thresholds will be set from observed normal behavior, not picked arbitrarily.

## Log-Based Alerting

Logs are used for investigation today, not as an alert source. Log alerts may be added for specific events that clearly need action, such as:

- Repeated authentication failures
- Critical infrastructure events
- Significant configuration changes
- Service failures that metrics don't show
- Specific security events

An error or warning in a log shouldn't trigger a notification unless it needs action.

## Design Rules

- **Actionable.** An alert means something needs investigation or a fix.
- **Impact first.** One "application unavailable" alert is more useful than a separate alert for every dependency that failed in the same outage.
- **Baseline before threshold.** Collect, observe and set a baseline before defining alert limits.
- **Limit duplicates.** One host failure can trip Uptime Kuma, a Prometheus scrape failure and every application on the host. Alerts should give context without repeating the same failure several times.
- **Keep availability alerts independent.** Uptime Kuma notifies directly through Discord, separate from the Prometheus and Alertmanager path, so each has its own route.

Not every condition needs an alert. Dashboards and logs stay available for anything that doesn't.

## Severity

| Severity | Meaning | Example |
|---|---|---|
| **Critical** | Immediate impact on infrastructure or services | Critical infrastructure or several dependent services down |
| **Warning** | Needs investigation before it becomes critical | Sustained resource pressure or low storage |
| **Informational** | Useful context, no action needed | Recovery or state-change notice |

Severity reflects impact, not the severity label in the source log.

## Notification Routing

Current path: Uptime Kuma → Discord webhook → a dedicated channel. The webhook URL is treated as a secret and is never committed or published.

Planned path for metrics alerts:

```text
Prometheus ──► Alertmanager ──┬──► ntfy
                              ├──► Email
                              └──► Webhooks
```

Channels will be chosen by reliability, accessibility and how important the alert is.

## Validation

Each alert path is tested end to end, including recovery:

```text
Test condition ──► Detected ──► Alert generated ──► Notification delivered ──► Recovered ──► Recovery confirmed
```

Availability alerts are tested with controlled service interruptions or test monitors. Metrics alerts are tested with safe test rules before real thresholds are relied on.

## Failure Considerations

The alerting path can fail like any other system, and a failure anywhere in it can stop a valid alert from arriving. Several monitoring services share the Docker monitoring host, so losing that host affects both detection and notification. Moving critical availability monitoring off that host is a planned improvement. Failure domains are described in [Architecture](./architecture.md).

## Security

Notification integrations can contain webhook URLs, tokens and other credentials. These are never committed or published, are stored in application or environment configuration, and are rotated if exposed. Public docs show only sanitized architecture and examples.

## Current State

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

Next: set metrics baselines, write actionable Prometheus alert rules and finish Alertmanager routing.

## Related Documentation

- [Monitoring Strategy](./monitoring-strategy.md): goals and working rules
- [Architecture](./architecture.md): component placement, data flows and failure domains
- [Availability Monitoring](./availability-monitoring.md): Uptime Kuma checks and notifications
- [Metric Monitoring](./metric-monitoring.md): Prometheus collection and baselines
- [Log Monitoring](./log-monitoring.md): centralized logging and investigation
- Docker lab documentation: container deployment and configuration
