# Metrics Monitoring

This document will describe the centralized metrics monitoring architecture used in the homelab, including how infrastructure metrics are collected, stored, queried, visualized, and eventually used for alerting.

> **Status:** 🟡 In Progress

Centralized log monitoring has been implemented. The next stage of the Infrastructure Monitoring Lab is to expand metrics collection across the environment and build a dedicated **Metrics Overview** dashboard in Grafana.

This document serves as the working placeholder for that implementation.

## Objective

The goal is to establish consistent metrics monitoring across the homelab so infrastructure health can be evaluated from a centralized location.

The metrics platform should answer questions such as:

- Are monitored systems reachable and reporting?
- Are hosts experiencing high CPU or memory utilization?
- Is storage capacity approaching a threshold?
- Are containers consuming abnormal resources?
- Are network interfaces operational?
- How much network traffic is being transmitted and received?
- Are monitored endpoints responding successfully?
- Has system behavior changed significantly over time?

Metrics provide the quantitative side of the monitoring environment, complementing centralized logs.

```text
Metrics
   │
   └── What is happening?

Logs
   │
   └── What happened around it?
```

Together, metrics and logs provide complementary information for infrastructure monitoring and troubleshooting.

## Target Architecture

The metrics architecture will use **Prometheus** as the centralized metrics backend and **Grafana** as the primary visualization and investigation interface.

```text
                         MONITORED SYSTEMS
                  Hosts / Containers / Network / Apps
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
          ▼                    ▼                    ▼
        Hosts              Containers            Network
          │                    │                    │
          ▼                    ▼                    ▼
        Node                cAdvisor              SNMP
      Exporter                                    Exporter
          │                    │                    │
          └────────────────────┼────────────────────┘
                               │
                               ▼
                           Prometheus
                               │
                               ▼
                            Grafana
                               │
                               ▼
                       Metrics Overview
```

Additional metrics sources can be incorporated as monitoring requirements expand.

## Monitoring Components

The initial metrics platform will use the following components:

| Component | Role | Status |
|---|---|:---:|
| **Prometheus** | Central metrics collection, storage, and querying | 🟡 |
| **Grafana** | Metrics visualization and investigation | 🟢 |
| **Node Exporter** | Linux host metrics | 🟡 |
| **cAdvisor** | Docker container metrics | 🟡 |
| **SNMP Exporter** | Network infrastructure metrics | 🟡 |
| **Blackbox Exporter** | Endpoint probing and availability metrics | 🟡 |
| **Alertmanager** | Metrics-based alert routing | 🟡 |

Component deployment and container-specific configuration are maintained separately in the Docker Lab.

This document will focus on how these components work together as a metrics monitoring system.

## Planned Monitoring Coverage

Metrics collection will be expanded across the infrastructure in stages.

### Host Metrics

Linux systems will be monitored using Node Exporter where appropriate.

Example lab systems may include:

```text
prox-lab-01
prox-lab-02
prox-lab-03
docker-lab-01
monitor-lab-01
```

Target metrics include:

- CPU utilization
- memory utilization
- filesystem utilization
- disk activity
- system load
- network traffic
- network errors
- system uptime

The goal is to establish consistent baseline host monitoring across infrastructure systems that support exporter-based collection.

### Container Metrics

Docker environments will be monitored using cAdvisor.

Example Docker hosts may include:

```text
docker-lab-01
monitor-lab-01
```

Target metrics include:

- running container count
- container CPU utilization
- container memory utilization
- container network activity
- container lifecycle information
- resource consumption by workload

Container metrics will supplement host-level metrics by providing visibility into individual workloads.

### Network Metrics

Supported network infrastructure will be monitored through SNMP.

Example lab devices may include:

```text
switch-lab-01
router-lab-01
firewall-lab-01
```

Target metrics include:

- interface operational state
- interface traffic
- interface errors
- interface discards
- device uptime
- other useful device telemetry exposed through SNMP

The exact metrics available will depend on the capabilities of each monitored device.

### Endpoint Metrics

Blackbox Exporter will provide active probing of selected endpoints.

Target metrics include:

- endpoint availability
- HTTP response time
- probe duration
- probe success
- other supported probe results

This provides an external perspective on whether a service can actually be reached rather than relying only on host health.

## Prometheus

Prometheus will serve as the centralized metrics backend.

Its responsibilities include:

```text
Prometheus
├── Discover configured targets
├── Scrape metrics
├── Store time-series data
├── Provide PromQL queries
├── Evaluate alerting rules
└── Supply metrics to Grafana
```

The general collection model is:

```text
Monitored System
      │
      ▼
Exporter / Metrics Endpoint
      │
      ▼
   Prometheus
      │
      ▼
    Grafana
```

Prometheus target configuration, scrape intervals, metric selection, and retention will be documented as the metrics implementation is expanded.

## Grafana Metrics Overview

Grafana will provide a dedicated **Metrics Overview** dashboard separate from the existing Logs Overview dashboard.

The dashboard should provide a concise environment-wide view before allowing deeper investigation into individual systems.

The initial dashboard is expected to include areas such as:

```text
Metrics Overview
│
├── Environment Health
│
├── Host Resources
│   ├── CPU
│   ├── Memory
│   └── Disk
│
├── Container Health
│
├── Endpoint Availability
│
├── Network Interfaces
│
└── Network Traffic
```

The exact panel layout will be determined during implementation.

The goal is not to display every available Prometheus metric. The dashboard should prioritize metrics that provide useful operational information and support troubleshooting.

## Initial Dashboard Coverage

The existing Grafana deployment already demonstrates several metrics that can form the foundation of the expanded Metrics Overview dashboard.

Current examples include:

- Docker host CPU utilization
- Docker host memory utilization
- Docker host disk utilization
- running container count
- HTTP endpoint status
- HTTP response time
- network interface status
- network RX/TX traffic

These existing panels provide a starting point rather than the final dashboard design.

The next stage will expand monitoring coverage beyond the initial Docker and network views.

## Dashboard Design Principles

The Metrics Overview dashboard should follow several principles:

- Provide an environment-wide view first.
- Prioritize actionable infrastructure metrics.
- Avoid displaying metrics simply because they are available.
- Keep the primary dashboard readable.
- Use consistent units and naming.
- Allow filtering or drill-down where useful.
- Separate specialized monitoring into dedicated dashboards when appropriate.
- Use metrics for trends and measurable system state.
- Use logs for event-level investigation and additional context.

Device-specific or application-specific metrics should not overwhelm the general infrastructure dashboard.

As the environment expands, specialized dashboards may be created for areas such as:

```text
Metrics Overview
├── Overall infrastructure health
├── Resource utilization
├── Availability
└── Network health

Host Metrics
├── CPU
├── Memory
├── Filesystems
└── System activity

Docker Metrics
├── Container resources
├── Container activity
└── Workload trends

Network Metrics
├── Interface state
├── Throughput
├── Errors
└── Discards
```

## Metrics and Logs

Metrics monitoring is designed to work alongside the centralized logging platform.

```text
                    Grafana
                       │
           ┌───────────┴───────────┐
           │                       │
           ▼                       ▼
    Metrics Overview          Logs Overview
           │                       │
           ▼                       ▼
       Prometheus                  Loki
           │                       │
           ▼                       ▼
   Quantitative State        Event Context
```

For example, metrics may identify:

```text
CPU utilization increased
```

while logs can help determine what activity occurred during the same period.

Similarly:

```text
Endpoint probe failed
```

can be correlated with:

```text
Service events
Network events
Application errors
System warnings
```

Neither telemetry source replaces the other.

## Alerting

Metrics-based alerting will be developed after useful baseline metrics and thresholds have been established.

The planned flow is:

```text
Prometheus
     │
     │ Alert Rules
     ▼
Alertmanager
     │
     ▼
Notifications
```

Alerting should focus on conditions that require attention rather than every unusual metric value.

Potential alert categories include:

- host unavailable
- exporter unavailable
- sustained resource exhaustion
- low disk capacity
- endpoint failure
- network interface failure
- other infrastructure conditions requiring action

Thresholds and alert rules will be determined after normal operating behavior has been observed.

## Validation

Each metrics integration should be validated through the complete monitoring path.

```text
Monitored System
      │
      ▼
Exporter
      │
      ▼
Prometheus Target
      │
      ▼
Prometheus Query
      │
      ▼
Grafana Panel
```

Validation should confirm that:

1. the exporter or metrics endpoint is available
2. Prometheus successfully scrapes the target
3. expected metrics are present
4. PromQL returns the expected data
5. Grafana correctly visualizes the metric

A running exporter alone does not confirm that the complete monitoring path is operational.

## Implementation Steps

The metrics implementation will proceed incrementally.

### Step 1 — Inventory

Identify systems that should provide metrics and determine the appropriate collection method for each.

```text
System
├── Linux Host → Node Exporter
├── Docker Host → Node Exporter + cAdvisor
├── Network Device → SNMP Exporter
├── Web Endpoint → Blackbox Exporter
└── Other System → Appropriate supported integration
```

### Step 2 — Collection

Deploy or validate the required exporters and metrics endpoints.

Confirm that each monitored system exposes the expected telemetry.

### Step 3 — Prometheus

Add and validate Prometheus scrape targets.

Confirm:

- target availability
- scrape health
- expected metrics
- consistent labels
- appropriate scrape intervals

### Step 4 — Grafana

Build the Metrics Overview dashboard.

Start with environment-wide operational metrics before adding specialized panels.

### Step 5 — Baselines

Observe normal infrastructure behavior over time.

Use this information to identify meaningful utilization ranges, capacity trends, and failure conditions.

### Step 6 — Alerting

Create Prometheus alert rules and Alertmanager routing based on established operational thresholds.

Avoid creating alerts before normal system behavior is understood.

### Step 7 — Documentation

Document:

- monitored systems
- metrics sources
- Prometheus targets
- important PromQL queries
- dashboard structure
- alerting rules
- validation procedures
- troubleshooting procedures

## Current State

Centralized logging provides the first completed observability pipeline:

```text
Log Sources
     │
     ▼
Collection / Processing
     │
     ▼
    Loki
     │
     ▼
  Grafana
     │
     ▼
Logs Overview
```

The next implementation stage will establish equivalent environment-wide coverage for metrics:

```text
Infrastructure
     │
     ▼
Metrics Sources
     │
     ▼
 Prometheus
     │
     ▼
  Grafana
     │
     ▼
Metrics Overview
```

As implementation progresses, this document will be updated from a planning document into the operational reference for metrics monitoring.

## Design Principles

The metrics monitoring architecture will follow several principles:

- Centralize infrastructure metrics.
- Monitor systems consistently where practical.
- Use the appropriate exporter or collection method for each system type.
- Keep Prometheus labels consistent and low-cardinality.
- Prioritize useful operational metrics over collecting everything available.
- Establish baselines before creating aggressive alert thresholds.
- Keep general dashboards focused on environment-wide health.
- Use specialized dashboards for detailed device or application monitoring.
- Validate the complete collection path.
- Correlate metrics with logs during investigation.
- Keep deployment-specific configuration with the applicable Docker service documentation.

## Purpose

The Metrics Monitoring project will provide centralized quantitative visibility into infrastructure health, performance, availability, and capacity.

Prometheus will provide the primary metrics collection and storage platform, while Grafana will provide the Metrics Overview dashboard used for visualization and investigation.

Together with the existing centralized logging platform, the completed metrics implementation will provide two complementary monitoring views:

```text
Metrics Overview
└── Infrastructure state, performance, and trends

Logs Overview
└── Events, severity, and investigation context
```

This document will evolve as metrics coverage is expanded across the environment and the Metrics Overview dashboard is developed.
