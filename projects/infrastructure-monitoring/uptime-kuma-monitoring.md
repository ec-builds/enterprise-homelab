# Uptime Kuma

**Status:** 🟢 Operational

Uptime Kuma provides independent availability and synthetic monitoring for infrastructure and services across the Enterprise Homelab.

The monitoring strategy is organized around infrastructure dependencies so failures can be quickly isolated to the local network, Internet connection, DNS infrastructure, core systems, platform services, or applications.

#### Uptime Kuma Dashboard

![uptime-kuma](./diagrams/uptime-kuma.png)

*Uptime Kuma dashboard monitoring the availability and health of infrastructure and services across the Enterprise Homelab.*


## Objectives

- Monitor infrastructure and service availability
- Detect outages and connectivity failures
- Track uptime and response times
- Validate critical network dependencies
- Perform basic synthetic service checks
- Provide a simple availability layer independent of the broader monitoring stack
- Organize monitoring around infrastructure dependencies to simplify troubleshooting


## Deployment

| Component | Value |
|---|---|
| Platform | Debian |
| Deployment | Docker Compose |
| Image | `louislam/uptime-kuma:2` |
| Database | SQL Lite |
| Interface | Port 3001 |
| Storage | Docker Volume at /opt/docker/uptime-kuma |


## Monitoring Strategy

Uptime Kuma answers:

> **Is the service available and functioning?**

Performance metrics, resource utilization, historical telemetry, and deeper infrastructure analysis are handled separately by Prometheus and Grafana.

Monitoring is organized into six dependency layers:

```text
Layer 1 - LAN
Gateway
   │
   ▼
Layer 2 - Internet
├── Cloudflare DNS
└── Google DNS
   │
   ▼
Layer 3 - DNS
├── dc-lab-01 DNS
└── dc-lab-02 DNS
   │
   ▼
Layer 4 - Core Infrastructure
├── dc-lab-01
├── dc-lab-02
├── prox-lab-01
├── prox-lab-02
├── prox-lab-03
└── nas-lab-01
   │
   ▼
Layer 5 - Platform Services
├── docker-lab-01
├── Prometheus
├── Loki
└── Nginx Proxy Manager
   │
   ▼
Layer 6 - Applications
├── Grafana
├── Jellyfin
├── Homepage
├── Portainer
├── Uptime Kuma
└── Additional Applications
```

Each layer provides context for the layers above it.

```text
Gateway Available
        │
        ▼
Internet Available
        │
        ▼
DNS Available
        │
        ▼
Infrastructure Available
        │
        ▼
Platform Available
        │
        ▼
Application Available
```

This dependency model helps distinguish an application failure from a failure in the infrastructure supporting it.


## Layer 1 - LAN

The first monitoring layer validates basic connectivity between the monitoring system and the network gateway.

| Monitor | Type | Purpose |
|---|---|---|
| Gateway | Ping | Validate local network and gateway reachability |

A gateway failure may indicate a local network, routing, or gateway problem and can explain failures across multiple higher monitoring layers.


## Layer 2 - Internet

External IP addresses are monitored independently of DNS.

| Monitor | Target | Type | Purpose |
|---|---|---|---|
| Cloudflare DNS | `1.1.1.1` | Ping | Validate external IP connectivity |
| Google DNS | `8.8.8.8` | Ping | Provide an independent Internet reachability test |
| External HTTPS | Public HTTPS endpoint | HTTP(s) | Validate outbound DNS, TCP, TLS, and HTTP connectivity |

Multiple external targets help distinguish an Internet connection failure from an individual external service becoming unavailable.


## Layer 3 - DNS

Both Active Directory DNS servers are monitored independently.

| Monitor | Type | Purpose |
|---|---|---|
| `dc-lab-01` DNS | DNS | Validate DNS resolution through the first DNS server |
| `dc-lab-02` DNS | DNS | Validate DNS resolution through the second DNS server |
| External Resolution via `dc-lab-01` | DNS | Validate external resolution through the first DNS server |
| External Resolution via `dc-lab-02` | DNS | Validate external resolution through the second DNS server |

DNS monitoring tests actual name resolution rather than relying exclusively on host reachability.

This allows monitoring to distinguish between:

```text
Server Reachable
      │
      └── DNS Service Failed

and

Server Unreachable
      │
      └── DNS Unavailable
```


## Layer 4 - Core Infrastructure

Core infrastructure systems are monitored independently from the services they provide.

| System | Recommended Monitor | Purpose |
|---|---|---|
| `dc-lab-01` | Ping | Domain controller availability |
| `dc-lab-02` | Ping | Domain controller availability |
| `prox-lab-01` | HTTP(s) | Hypervisor management availability |
| `prox-lab-02` | HTTP(s) | Hypervisor management availability |
| `prox-lab-03` | HTTP(s) | Hypervisor management availability |
| `nas-lab-01` | HTTP(s) | NAS management availability |
| NAS SMB | TCP Port | Validate SMB service availability |

Critical domain controller services can also be monitored independently:

| Service | Port | Monitor |
|---|---:|---|
| DNS | 53 | DNS |
| Kerberos | 88 | TCP Port |
| LDAP | 389 | TCP Port |

These checks provide basic service availability monitoring. Detailed Active Directory health and replication validation are handled separately from Uptime Kuma.


## Layer 5 - Platform Services

Platform services provide functionality used by applications or other infrastructure components.

| Service | Recommended Monitor | Purpose |
|---|---|---|
| `docker-lab-01` | Ping | Container host availability |
| Prometheus | HTTP(s) | Metrics backend availability |
| Loki | HTTP(s) / Readiness Endpoint | Logging backend availability |
| Nginx Proxy Manager | HTTP(s) | Reverse proxy availability |

Platform monitoring helps distinguish application failures from failures of their supporting services.


## Layer 6 - Applications

Application monitors validate that user-facing services are responding.

| Application | Recommended Monitor |
|---|---|
| Grafana | HTTP(s) |
| Jellyfin | HTTP(s) |
| Homepage | HTTP(s) |
| Portainer | HTTP(s) |
| Uptime Kuma | HTTP(s) |
| Additional Web Applications | HTTP(s) |

Where an application provides a dedicated health or readiness endpoint, that endpoint should be preferred over simply monitoring the root web page.


## Dependency-Based Troubleshooting

The monitoring layers provide a troubleshooting hierarchy.

```text
Application Failure
        │
        ▼
Platform Service?
        │
        ▼
Core Infrastructure?
        │
        ▼
DNS?
        │
        ▼
Internet?
        │
        ▼
LAN / Gateway?
```

Example failure patterns:

```text
Gateway          UP
Cloudflare       DOWN
Google           DOWN

→ Investigate WAN / ISP connectivity
```

```text
Gateway          UP
Cloudflare       UP
Google           UP
dc-lab-01 DNS    DOWN
dc-lab-02 DNS    UP

→ Investigate dc-lab-01 DNS
```

```text
NAS              UP
SMB              UP
Media Server     UP
Jellyfin         DOWN

→ Investigate Jellyfin rather than network or storage
```


## Default Monitor Settings

Recommended baseline settings for most monitors:

| Setting | Recommended Value |
|---|---|
| Heartbeat Interval | 60 seconds |
| Retries | 2 |
| Request Timeout | 10 seconds |
| HTTP Method | GET |
| Accepted HTTP Status | 200-299 |
| IP Family | Auto Select |

Critical connectivity monitors may use shorter intervals:

| Monitor Category | Interval |
|---|---:|
| Gateway | 30 seconds |
| Internet Reachability | 30 seconds |
| DNS | 30-60 seconds |
| Core Infrastructure | 60 seconds |
| Platform Services | 60 seconds |
| Applications | 60 seconds |


## Current Monitors

The initial monitoring deployment includes:

- Internet connectivity
- Network gateway
- NAS
- Jellyfin
- Uptime Kuma self-monitoring

Additional monitors are being deployed according to the layered monitoring strategy.


## Monitor Types

Uptime Kuma provides several monitor types used throughout the environment.

| Monitor Type | Primary Use |
|---|---|
| HTTP(s) | Web applications, APIs, and management interfaces |
| Ping | Hosts, gateways, and external IP connectivity |
| TCP Port | Specific network services |
| DNS | Internal and external name resolution |

Monitor type is selected based on what needs to be validated rather than using ICMP availability for every system.


## Role in Monitoring Architecture

Uptime Kuma serves as the dedicated availability and synthetic monitoring layer alongside the broader observability platform.

```text
                 Uptime Kuma
                      │
          Availability / Synthetic Tests
                      │
     ┌────────────────┼────────────────┐
     │                │                │
   Network         Services       Applications
     │                │                │
     └────────────────┼────────────────┘
                      │
                 Is it working?


              Prometheus / Grafana
                      │
              Metrics / Telemetry
                      │
     ┌────────────────┼────────────────┐
     │                │                │
    CPU             Memory           Storage
  Network          Containers        Trends
     │                │                │
     └────────────────┼────────────────┘
                      │
            How is it performing?
```

Prometheus and its exporters collect infrastructure and application metrics, while Grafana provides centralized visualization and analysis.

Uptime Kuma remains focused on availability, reachability, synthetic testing, and outage detection.


## Monitoring Scope

Uptime Kuma is primarily responsible for:

- Availability monitoring
- Service reachability
- DNS resolution testing
- TCP port availability
- HTTP/HTTPS availability
- External connectivity testing
- Basic synthetic service checks
- Outage notifications

Metrics such as CPU utilization, memory utilization, disk usage, network throughput, container resource consumption, historical trends, and capacity planning are handled by Prometheus and Grafana.


## Related Documentation

- Infrastructure Monitoring
- Monitoring Architecture
- Prometheus
- Grafana


## Security Note

Hostnames, addresses, endpoints, and other environment-specific identifiers should be sanitized before public release.

Never include credentials, API tokens, public IP addresses, notification secrets, or other sensitive configuration data in repository documentation.
