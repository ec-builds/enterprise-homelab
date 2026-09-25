# Portainer CE Deployment

**Status:** 🟢 Operational

## Overview

Portainer Community Edition (CE) is deployed as the centralized Docker management interface for the homelab.

A single Portainer Server manages three Docker environments distributed across the three-node Proxmox VE cluster.

Portainer provides:

- Centralized container visibility and health status
- Log and console access
- Image, network, and storage inspection
- Routine container administration
- Remote management across Docker hosts

Portainer complements the existing Docker management workflow rather than replacing it:

```text
Docker Compose = Service configuration and deployment
Docker CLI     = Direct administration and troubleshooting
Portainer CE   = Centralized management and visibility
```

## Architecture

The Docker environment consists of three Debian virtual machines distributed across separate Proxmox hosts.

```text
                         Proxmox VE Cluster
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
              ▼                 ▼                 ▼
        prox-lab-01       prox-lab-02       prox-lab-03
              │                 │                 │
              ▼                 ▼                 ▼
       docker-lab-01      monitor-lab-01     media-lab-01
              │                 │                 │
       Portainer CE       Portainer Agent    Portainer Agent
          Server             TCP 9001           TCP 9001
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                                ▼
                      Centralized Docker
                          Management
```

| Docker VM | Portainer Role | Connection | Workload |
|---|---|---|---|
| `docker-lab-01` | Portainer CE Server | Local | General applications |
| `monitor-lab-01` | Portainer Agent | TCP 9001 | Monitoring |
| `media-lab-01` | Portainer Agent | TCP 9001 | Media services |

`docker-lab-01` hosts the Portainer CE Server and connects directly to its local Docker Engine.

`monitor-lab-01` and `media-lab-01` run Portainer Agent, allowing their Docker Engines to be managed remotely from the central Portainer interface.

Portainer manages Docker inside these virtual machines. The underlying Proxmox hosts and VM lifecycle remain managed separately through Proxmox VE.

## Deployment

### Portainer Server

Portainer CE Server is deployed as a container on `docker-lab-01`.

```text
docker-lab-01
      │
      ├── Docker Engine
      │       ▲
      │       │ docker.sock
      │       │
      └── Portainer CE
```

The Docker socket provides Portainer with administrative access to the local Docker Engine.

Persistent Portainer data is stored outside the ephemeral container filesystem so the Portainer container can be recreated without losing its configuration.

### Portainer Agents

Portainer Agent is deployed on the two remote Docker hosts:

- `monitor-lab-01`
- `media-lab-01`

```text
                    Portainer CE
                    docker-lab-01
                         │
               ┌─────────┴─────────┐
               │                   │
           TCP 9001            TCP 9001
               │                   │
               ▼                   ▼
        monitor-lab-01       media-lab-01
        Portainer Agent      Portainer Agent
               │                   │
               ▼                   ▼
         Docker Engine         Docker Engine
```

This provides centralized management while preserving workload separation between general applications, monitoring, and media services.

## Configuration Model

Docker Compose remains the source of truth for the Portainer deployment and other important containerized services.

Example `docker-compose.yaml` configurations for both Portainer CE Server and Portainer Agent are maintained in the repository under `/configs/docker`.

```text
/configs/docker
├── portainer/
│   └── docker-compose.yaml
│
└── portainer-agent/
    └── docker-compose.yaml
```

These configurations document the Compose-based deployment used for:

- Portainer CE Server on `docker-lab-01`
- Portainer Agent on `monitor-lab-01`
- Portainer Agent on `media-lab-01`

The overall management model is:

```text
Repository Configuration
          │
          ▼
     Docker Compose
          │
          ▼
      Docker Engine
        │       │
        ▼       ▼
 Docker CLI   Portainer CE
```

Docker Compose defines service configuration such as container images, ports, networks, persistent storage, environment configuration, and restart behavior.

Portainer operates as a management and visibility layer over the resulting Docker environments.

This keeps deployments reproducible and prevents important service configuration from existing only inside Portainer.

## Security

Portainer is treated as part of the privileged infrastructure management plane.

The deployment follows several security principles:

- Portainer is accessible only from trusted networks or through VPN access.
- Portainer and Agent interfaces are not intentionally exposed to the public Internet.
- TCP 9001 is treated as a privileged Agent management interface.
- Docker socket access is limited to components that require Docker Engine administration.
- Credentials and secrets are excluded from public repository content.
- Persistent Portainer data is maintained separately from the container lifecycle.
- Docker Compose configuration is maintained independently of the Portainer database.

Access to the Docker socket effectively provides administrative control over the Docker host, so the Portainer Server and Agents are treated as privileged infrastructure components.

## Failure Behavior

Portainer is a management layer and is not required for deployed containers to continue operating.

```text
Portainer Unavailable
        │
        X
Central Management
        │
        ▼
Docker Hosts Continue Running
        │
        ▼
Containers Continue Running
```

If the Portainer Server becomes unavailable, containers across all three Docker hosts continue operating.

Likewise, loss of communication with an individual Portainer Agent affects centralized management of that environment but does not stop its containers.

This prevents a Portainer outage from becoming an application outage.

## Design Decisions

### Centralized Management

A single Portainer CE Server provides visibility across all three Docker environments instead of deploying independent management interfaces on each host.

### Workload Separation

General applications, monitoring, and media services remain on separate Docker VMs across the Proxmox cluster.

Portainer centralizes management without removing this operational separation.

### Compose as Source of Truth

Important services remain defined through Docker Compose rather than being created exclusively through the Portainer interface.

Example `docker-compose.yaml` configurations for the Portainer Server and Portainer Agent deployments are maintained under `/configs`.

This keeps deployments reproducible, portable, and independently recoverable.

### CLI Remains Available

Portainer provides convenience and centralized visibility, while direct Docker administration remains available for troubleshooting, scripting, detailed inspection, and automation.

## Current Deployment State

| Capability | Status |
|---|---|
| Portainer CE Server | 🟢 Operational |
| `docker-lab-01` local environment | 🟢 Connected |
| `monitor-lab-01` Agent | 🟢 Connected |
| `media-lab-01` Agent | 🟢 Connected |
| Centralized three-host management | 🟢 Operational |
| Compose-based service management | 🟢 Operational |
| Portainer Server Compose example | 🟢 Documented in `/configs` |
| Portainer Agent Compose example | 🟢 Documented in `/configs` |
