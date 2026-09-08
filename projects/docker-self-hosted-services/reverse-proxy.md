# Reverse Proxy Container

Deployment of a reverse proxy for web services hosted within the Docker lab.

## Overview

**Service:** Nginx Proxy Manager (NPM)  
**Platform:** Docker Compose  
**Host:** `docker-lab`  
**Status:** Planned

Nginx Proxy Manager will provide a centralized entry point for Docker-hosted web applications.

Instead of accessing services directly by IP address and port:

```text
http://<docker-host>:3000
http://<docker-host>:3001
http://<docker-host>:8096
```

services can eventually be accessed through DNS hostnames and HTTPS.

```text
Client
   │
   ▼
DNS
   │
   ▼
Nginx Proxy Manager
   │
   ├── Homepage
   ├── Uptime Kuma
   ├── Jellyfin
   └── Other Web Services
```

## Why Nginx Proxy Manager

As more web services are deployed, a reverse proxy provides centralized hostname routing and HTTPS management instead of requiring users to remember individual IP addresses and ports.

Nginx Proxy Manager was selected because it provides:

- Hostname-based reverse proxy routing
- Centralized HTTPS/TLS management
- Certificate management
- A web interface for configuring Nginx proxy hosts
- Docker-based deployment consistent with the rest of the lab

NPM uses Nginx underneath while simplifying its configuration and management.

## Deployment

The container will be deployed using Docker Compose under:

```text
/opt/docker/nginx-proxy-manager/
```

Planned workflow:

```text
Create Compose Stack
        │
        ▼
Deploy Nginx Proxy Manager
        │
        ▼
Configure Internal DNS
        │
        ▼
Create Proxy Hosts
        │
        ▼
Configure HTTPS
        │
        ▼
Validate Service Access
```

Initial deployment will be **LAN-only**. No Internet-facing router port forwarding is required.

## Configuration

Docker Compose configuration will be documented here once deployment begins.

## Validation

Deployment will be considered complete when:

- Nginx Proxy Manager is running and healthy
- The management interface is accessible
- Internal DNS resolves service hostnames
- Proxy hosts successfully route to backend services
- HTTPS is configured and validated
