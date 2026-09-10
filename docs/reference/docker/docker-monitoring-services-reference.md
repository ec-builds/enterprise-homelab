# Monitoring & Observability Lab Reference

A high-level reference for the services used or planned in the monitoring and observability lab.

The goal of this document is to explain **what each service does and how the services relate to one another**. Detailed configuration, query languages, alert rules, exporters, and implementation procedures are documented separately as the lab develops.

## Architecture Overview

```text
                              MONITORED SYSTEMS
                   Servers / VMs / Docker / Network / Apps
                                      │
             ┌────────────────────────┼────────────────────────┐
             │                        │                        │
             ▼                        ▼                        ▼
        Availability                Metrics                   Logs
             │                        │                        │
       ┌─────┴─────┐        ┌─────────┼──────────┐             │
       │           │        │         │          │             │
       ▼           ▼        ▼         ▼          ▼             ▼
  Uptime Kuma   Blackbox   Node     cAdvisor    SNMP          Alloy
                Exporter   Exporter   │         Exporter       │
                    │       │         │          │             ▼
                    └───────┴────┬────┴──────────┘            Loki
                                 │                             │
                                 ▼                             │
                             Prometheus                        │
                                 │                             │
                         ┌───────┴────────┐                    │
                         │                │                    │
                         ▼                ▼                    │
                    Alertmanager      Grafana ◄────────────────┘
                         │                │
                         ▼                ▼
                Email / Notifications  Dashboards
                                      Exploration
```

> This diagram represents the general direction of the lab. Individual integrations may change as the monitoring environment develops.

## Core Services

| Service | Primary Role | Think of it as |
|---|---|---|
| **Grafana** | Visualization | Dashboard and investigation interface |
| **Prometheus** | Metrics | Metrics database and monitoring engine |
| **Alertmanager** | Alert delivery | Notification router |
| **Loki** | Logs | Log storage and query backend |
| **Grafana Alloy** | Telemetry collection | Collector, processor, and forwarder |
| **Node Exporter** | Host metrics | Linux/server metrics source |
| **cAdvisor** | Container metrics | Docker/container metrics source |
| **SNMP Exporter** | Network device metrics | SNMP-to-Prometheus bridge |
| **Blackbox Exporter** | Availability metrics | External probe and availability checker |
| **Uptime Kuma** | Availability monitoring | Simple uptime/service checker |

## Grafana

**Purpose:** Visualization and investigation.

Grafana provides the primary graphical interface for monitoring the environment.

It can connect to different data sources and present their information through dashboards and exploration tools.

At a high level:

```text
Prometheus ──► Grafana ◄── Loki
               │
               ▼
          Dashboards
          Exploration
```

Prometheus provides metrics.

Loki provides logs.

Grafana provides the interface for viewing and analyzing that information.

Grafana generally does **not** collect or permanently store the underlying monitoring data itself.

## Prometheus

**Purpose:** Metrics collection, storage, and evaluation.

Prometheus works with numerical measurements over time.

Examples include:

- CPU utilization
- memory utilization
- disk usage
- network activity
- container resource usage
- service availability
- application metrics

Prometheus can obtain these metrics from specialized exporters:

```text
Node Exporter ──────┐
cAdvisor ───────────┤
SNMP Exporter ──────┼──► Prometheus
Blackbox Exporter ──┘
```

Prometheus stores metrics and evaluates alert rules.

Grafana can query those metrics for dashboards.

If an alert rule becomes true, Prometheus can send the alert to Alertmanager.

```text
Exporters
    │
    ▼
Prometheus
    │
    ├──► Grafana
    │
    └──► Alertmanager
```

## Node Exporter

**Purpose:** Host and operating system metrics.

Node Exporter exposes metrics about a Linux system so Prometheus can collect them.

Examples include:

- CPU usage
- memory usage
- filesystem usage
- disk activity
- network interfaces
- system load

Conceptually:

```text
Linux Host
    │
    ▼
Node Exporter
    │
    ▼
Prometheus
    │
    ▼
Grafana
```

A simple way to remember its role:

> **Node Exporter answers: How is the host doing?**

## cAdvisor

**Purpose:** Container resource metrics.

cAdvisor collects information about running containers and their resource consumption.

Examples include:

- container CPU usage
- container memory usage
- network activity
- filesystem usage

Conceptually:

```text
Docker
   │
   ▼
cAdvisor
   │
   ▼
Prometheus
   │
   ▼
Grafana
```

A simple way to remember its role:

> **cAdvisor answers: How are the containers doing?**

## SNMP Exporter

**Purpose:** Network device metrics.

SNMP Exporter allows Prometheus to collect information from devices that expose monitoring information through SNMP.

Typical devices may include:

- switches
- routers
- firewalls
- access points
- other network infrastructure

Conceptually:

```text
Network Device
      │
      │ SNMP
      ▼
 SNMP Exporter
      │
      ▼
  Prometheus
      │
      ▼
    Grafana
```

SNMP Exporter acts as a bridge between traditional SNMP-based monitoring and Prometheus.

A simple way to remember its role:

> **SNMP Exporter answers: How is the network device doing?**

## Blackbox Exporter

**Purpose:** External availability and connectivity metrics.

Blackbox Exporter probes systems from the outside rather than measuring their internal resource usage.

It can be used to determine whether a service or endpoint is reachable.

Conceptually:

```text
Target Service
      ▲
      │ probe
      │
Blackbox Exporter
      │
      ▼
  Prometheus
      │
      ▼
    Grafana
```

This complements Node Exporter and cAdvisor.

A server may have healthy CPU and memory metrics while an application running on it is still unreachable. Blackbox Exporter provides another perspective by testing the service itself.

A simple way to remember its role:

> **Blackbox Exporter answers: Can I reach the service?**

## Alertmanager

**Purpose:** Alert routing and notification delivery.

Alertmanager receives alerts generated by Prometheus.

```text
Prometheus
    │
    │ Alert
    ▼
Alertmanager
    │
    ├──► Email
    ├──► Webhook
    └──► Other notification systems
```

Prometheus determines **when something is wrong**.

Alertmanager determines **what happens with the alert**.

Alertmanager can group alerts, route them to different receivers, suppress notifications, and send resolved notifications.

## Loki

**Purpose:** Centralized log storage and querying.

Loki receives logs collected by another service such as Alloy.

```text
Docker
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

Loki is primarily a backend service.

On the write path:

```text
Alloy → Loki
```

Alloy sends logs to Loki for storage.

On the read path:

```text
Grafana → Loki → Grafana
```

Grafana queries Loki when an administrator searches or explores logs.

## Grafana Alloy

**Purpose:** Telemetry collection and forwarding.

Alloy sits close to the systems being monitored and collects telemetry.

Telemetry can include:

- logs
- metrics
- traces
- profiles

The initial lab use is Docker log collection:

```text
Docker Containers
       │
       ▼
     Alloy
       │
       ▼
      Loki
```

Alloy discovers containers, reads their logs, processes or labels them, and forwards them to Loki.

As the lab develops, Alloy can take on additional telemetry collection responsibilities.

## Uptime Kuma

**Purpose:** Simple availability and uptime monitoring.

Uptime Kuma answers straightforward questions such as:

> Is this service reachable?

It can monitor services using methods such as HTTP requests and network checks.

Conceptually:

```text
Uptime Kuma
     │
     ├──► Website
     ├──► Application
     ├──► Server
     └──► Network Service
```

Uptime Kuma operates as a straightforward availability-monitoring system with its own interface.

It overlaps somewhat with Blackbox Exporter, but they serve different roles in the lab.

```text
Uptime Kuma
     │
     └── Simple availability monitoring and status

Blackbox Exporter
     │
     └── Availability measurements collected by Prometheus
```

Uptime Kuma is useful when the primary question is simply whether a service is available.

Blackbox Exporter becomes useful when availability measurements need to become part of the broader Prometheus and Grafana monitoring system.

## Understanding the Exporters

The exporters provide specialized measurements that Prometheus can collect.

A simple way to remember them:

```text
Node Exporter
"How is the HOST doing?"

cAdvisor
"How are the CONTAINERS doing?"

SNMP Exporter
"How is the NETWORK DEVICE doing?"

Blackbox Exporter
"Can I REACH the service?"
```

Together:

```text
                    Prometheus
                        ▲
                        │
       ┌────────────────┼────────────────┐
       │                │                │
       │                │                │
 Node Exporter       cAdvisor      SNMP Exporter
 Host Metrics     Container Metrics Network Metrics
                                         
                        ▲
                        │
                 Blackbox Exporter
                Availability Metrics
```

The exporters generally expose measurements.

Prometheus collects and stores those measurements.

Grafana visualizes them.

Alertmanager handles alerts generated from them.

## Metrics vs Logs

A useful distinction in the monitoring lab is:

```text
METRICS
"CPU usage is 95%."

Prometheus
```

versus:

```text
LOGS
"Why did the application fail?"

Loki
```

Grafana provides a common interface for investigating both.

This creates a useful troubleshooting workflow:

```text
Grafana Dashboard
       │
       ▼
Metric looks abnormal
       │
       ▼
Prometheus identifies when
       │
       ▼
Loki logs help explain why
```

For example, a metric might show that a container suddenly began consuming excessive resources.

The corresponding logs in Loki may help explain what happened at that time.

## Collection vs Storage vs Visualization

The services become easier to understand when grouped by responsibility.

```text
COLLECTION / MEASUREMENT
    │
    ├── Alloy
    ├── Node Exporter
    ├── cAdvisor
    ├── SNMP Exporter
    └── Blackbox Exporter
         │
         ▼
STORAGE / QUERY
    │
    ├── Loki        → Logs
    └── Prometheus  → Metrics
         │
         ▼
VISUALIZATION
    │
    └── Grafana
         │
         ▼
ALERTING
    │
    └── Alertmanager
```

Prometheus is somewhat unique because it performs several responsibilities: it collects metrics from exporters, stores them, queries them, and evaluates alert rules.

Uptime Kuma operates alongside this stack as a simpler independent availability-monitoring service.

## Log Pipeline

The initial Alloy integration in the lab is centralized Docker logging.

```text
Docker Containers
       │
       │ logs
       ▼
 Grafana Alloy
       │
       │ push
       ▼
      Loki
       │
       │ LogQL queries
       ▼
    Grafana
       │
       ▼
 Administrator
```

This allows logs from multiple containers to be investigated from one interface rather than individually running commands such as:

```bash
docker logs <container>
```

## Host Metrics Pipeline

Node Exporter provides operating system metrics.

```text
Linux Host
    │
    ▼
Node Exporter
    │
    ▼
Prometheus
    │
    ▼
Grafana
```

This provides visibility into the health and resource utilization of the underlying host.

## Container Metrics Pipeline

cAdvisor provides container-level resource metrics.

```text
Docker Containers
       │
       ▼
    cAdvisor
       │
       ▼
   Prometheus
       │
       ▼
     Grafana
```

This complements Alloy.

Alloy provides the **logs generated by containers**.

cAdvisor provides the **resource metrics for containers**.

```text
Docker
   │
   ├── Logs ─────► Alloy ─────► Loki
   │
   └── Metrics ──► cAdvisor ──► Prometheus
                                      │
                 ┌────────────────────┘
                 ▼
              Grafana
```

## Network Metrics Pipeline

SNMP Exporter provides a path for network infrastructure metrics.

```text
Network Devices
       │
       │ SNMP
       ▼
 SNMP Exporter
       │
       ▼
   Prometheus
       │
       ▼
     Grafana
```

This extends monitoring beyond servers and containers to network infrastructure.

## Availability Metrics Pipeline

Blackbox Exporter provides availability measurements to Prometheus.

```text
Service / Endpoint
        ▲
        │ probe
        │
Blackbox Exporter
        │
        ▼
    Prometheus
        │
        ├──► Grafana
        │
        └──► Alertmanager
```

This allows service availability to participate in the same metrics, dashboard, and alerting system as other Prometheus data.

## Metrics and Alert Pipeline

The Prometheus and Alertmanager path operates separately from the log pipeline.

```text
Exporters
   │
   ▼
Prometheus
   │
   ├──────────────► Grafana
   │                 │
   │                 ▼
   │              Dashboard
   │
   ▼
Alert Rule
   │
   ▼
Alertmanager
   │
   ▼
Email / Notification
```

A simple way to remember the relationship:

> **Exporters measure. Prometheus collects and detects. Alertmanager notifies.**

## Combined Monitoring Model

Together, the services provide different views of system health:

```text
                              MONITORED SYSTEMS
                   Servers / VMs / Docker / Network / Apps
                                      │
             ┌────────────────────────┼────────────────────────┐
             │                        │                        │
             ▼                        ▼                        ▼
        Availability                Metrics                   Logs
             │                        │                        │
       ┌─────┴─────┐        ┌─────────┼──────────┐             │
       │           │        │         │          │             │
       ▼           ▼        ▼         ▼          ▼             ▼
  Uptime Kuma   Blackbox   Node     cAdvisor    SNMP          Alloy
                Exporter   Exporter   │         Exporter       │
                    │       │         │          │             ▼
                    └───────┴────┬────┴──────────┘            Loki
                                 │                             │
                                 ▼                             │
                             Prometheus                        │
                                 │                             │
                         ┌───────┴────────┐                    │
                         │                │                    │
                         ▼                ▼                    │
                    Alertmanager      Grafana ◄────────────────┘
                         │                │
                         ▼                ▼
                Email / Notifications  Dashboards
                                      Exploration
```

This provides several complementary perspectives:

```text
Uptime Kuma / Blackbox Exporter  → Is it reachable?

Node Exporter                    → Is the host healthy?

cAdvisor                         → Are the containers healthy?

SNMP Exporter                    → Is the network infrastructure healthy?

Prometheus                       → What do the metrics show over time?

Alloy + Loki                     → What happened in the logs?

Grafana                          → How can I investigate everything together?

Alertmanager                     → Who should be notified when something is wrong?
```

## Services Being Monitored

The monitoring stack exists separately from the applications and infrastructure it observes.

Examples of services that may be monitored include:

- containerized applications
- reverse proxies
- dashboards
- media services
- infrastructure management services
- servers and virtual machines
- network devices

These services may expose different forms of telemetry:

```text
Application / Infrastructure
          │
          ├── Logs ─────────► Alloy ─────────► Loki
          │
          ├── Host Metrics ─► Node Exporter ─► Prometheus
          │
          ├── Container ────► cAdvisor ──────► Prometheus
          │
          ├── Network ──────► SNMP Exporter ─► Prometheus
          │
          └── Availability ─► Blackbox ──────► Prometheus
                                           
                                         Grafana
```

This separation is important:

> **Applications provide services. The monitoring stack observes those services.**

## Planned Learning Progression

The monitoring lab can be developed incrementally:

1. **Availability** — understand what is online with Uptime Kuma.
2. **Metrics foundation** — collect and visualize measurements with Prometheus and Grafana.
3. **Alerting** — create useful Prometheus rules and route them through Alertmanager.
4. **Logs** — centralize Docker and system logs through Alloy and Loki.
5. **Host metrics** — add Node Exporter to understand host resource utilization.
6. **Container metrics** — add cAdvisor for Docker resource visibility.
7. **Network metrics** — add SNMP Exporter for network infrastructure monitoring.
8. **Availability metrics** — add Blackbox Exporter for Prometheus-based endpoint probing.
9. **Correlation** — use Grafana to investigate metrics and logs together.
10. **Expansion** — introduce additional telemetry such as traces or profiles when there is a practical reason to use them.

The objective is not simply to deploy monitoring tools, but to understand the role each component plays in an observability architecture.
