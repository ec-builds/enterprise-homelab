# Docker Networking

## Overview

Docker networks are segregated by purpose rather than placing all containers on a single shared network.

Containers should only be connected to networks required for communication with related services.

## Planned Networks

| Network | Purpose | Example Services |
|---|---|---|
| `monitoring` | Monitoring, metrics, logging, and alerting | Grafana, Prometheus, Loki, Alertmanager, Alloy, exporters |
| `proxy` | Reverse proxy access to web applications | Nginx Proxy Manager, Grafana, Homepage, Uptime Kuma |
| `media` | Media-related services | Jellyfin and future media services |
| Default Compose networks | Isolation for standalone services | Services that do not require shared container networking |

## Architecture

    Docker Host
    │
    ├── monitoring
    │   ├── Grafana
    │   ├── Prometheus
    │   ├── Loki
    │   ├── Alertmanager
    │   ├── Alloy
    │   └── Exporters
    │
    ├── proxy
    │   ├── Nginx Proxy Manager
    │   ├── Grafana
    │   ├── Homepage
    │   └── Uptime Kuma
    │
    ├── media
    │   └── Jellyfin
    │
    └── <service>_default
        └── Standalone / isolated services

Containers may belong to multiple networks when required.

For example, Grafana can belong to both `monitoring` and `proxy`:

    Prometheus ── monitoring ── Grafana ── proxy ── Nginx Proxy Manager

## Shared Networks

Purpose-based networks shared between separate Compose projects are created as external Docker networks.

Example:

    docker network create monitoring

A Compose service can then join the network:

    services:
      grafana:
        networks:
          - monitoring

    networks:
      monitoring:
        external: true

Services on the same Docker network should communicate using Docker DNS/service names rather than container IP addresses.

Example:

    http://prometheus:9090

Container IP addresses such as `172.x.x.x` should not be used in application configuration because they may change when containers or networks are recreated.

## Design Principle

> Segregate Docker networks by purpose and connect containers only to the networks required for their function.
