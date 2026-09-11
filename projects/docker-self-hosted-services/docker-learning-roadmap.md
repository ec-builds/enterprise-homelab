# Docker Learning Roadmap

Tracks Docker concepts learned during the project and identifies future areas for study.

## Current Progress

| Concept | Status |
|----------|--------|
| Images | ✅ Learned |
| Containers | ✅ Learned |
| Volumes | ✅ Learned |
| Docker Compose | ✅ Basic Understanding |
| Container Recreation | ✅ Learned |
| Container Naming | ✅ Learned |
| Port Mapping | ✅ Learned |
| Bind Mounts | ✅ Learned |
| Networking | 🟡 Started |
| Health Checks | 🟡 Started |
| Logs | 🟡 Basic Understanding |
| Environment Variables | 🟡 Started |
| Container Updates | 🟡 Started |
| Reverse Proxies | 🟡 Started |
| Internal DNS | 📋 Planned |
| TLS / HTTPS | 📋 Planned |
| Secrets Management | 📋 Planned |
| Resource Limits | 📋 Planned |
| Multi-Container Applications | 📋 Planned |
| Docker Registries | 📋 Planned |
| Backup & Recovery | 📋 Planned |



## Status Definitions

| Status | Meaning |
|--------|---------|
| ✅ Learned | Concept has been studied and applied in the homelab. |
| 🟡 Started | Concept has been encountered or partially applied but requires deeper understanding. |
| 📋 Planned | Concept has not yet been fully explored and is planned for future study. |



## Next Learning Priorities

### Priority 1

Concepts that directly support current homelab projects:

- Reverse Proxies
- Internal DNS
- TLS / HTTPS
- Networking
- Health Checks
- Logs

### Priority 2

Concepts needed as additional services are deployed:

- Environment Variables
- Container Updates
- Multi-Container Applications
- Backup & Recovery

### Priority 3

Advanced operational concepts:

- Resource Limits
- Secrets Management
- Docker Registries



## Current Learning Path

The current service deployments provide a progression from basic container operation toward a more complete self-hosted application platform.

```text
Images & Containers
        │
        ▼
Docker Compose
        │
        ▼
Volumes & Bind Mounts
        │
        ▼
Port Mapping
        │
        ▼
Container Networking
        │
        ▼
Reverse Proxy
        │
        ▼
Internal DNS
        │
        ▼
HTTPS / TLS
        │
        ▼
Monitoring & Logging
        │
        ▼
Backup & Recovery
        │
        ▼
Security & Operations
```

The immediate focus is moving from direct IP-and-port access toward hostname-based access through an internal reverse proxy.

Nginx Proxy Manager will be used to apply reverse proxy concepts, followed by internal DNS and HTTPS/TLS configuration.



## Related Documentation

See [Docs / Reference](../../docs/reference).

Relevant project documentation:

- [README.md](README.md)
- [architecture.md](architecture.md)
- [reverse-proxy.md](reverse-proxy.md)
- [lessons-learned.md](lessons-learned.md)



## Notes

This roadmap should be updated as concepts are learned, documented, and applied within the homelab environment.

A concept should generally move to **Learned** after it has been both understood and applied in the lab rather than simply encountered during deployment.
