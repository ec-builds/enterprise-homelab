# 📊 Monitoring

**Status: 🟢 Operational**

The Media Services Platform uses **Uptime Kuma** for basic availability and service monitoring.

The goal is to provide quick visibility into whether the media server, Jellyfin service, storage infrastructure, and supporting network connectivity are available.

## Current Monitoring



![uptime-kuma](../infrastructure-monitoring/diagrams/uptime-kuma.png)



| Target | Monitor | Purpose |
|---|---|---|
| Jellyfin | HTTP | Verify application availability |
| Uptime Kuma | HTTP | Verify monitoring service availability |
| Media Server | Ping | Verify host reachability |
| Media Server | SSH | Verify remote administration availability |
| NAS | Ping | Verify storage host reachability |
| NAS | HTTPS | Verify NAS service availability |
| Router | Ping / HTTPS | Verify local network infrastructure |
| External DNS | Ping | Verify Internet connectivity |

The monitoring path can be summarized as:

```text
Uptime Kuma
    │
    ├── Jellyfin
    ├── Media Server
    ├── NAS
    ├── Router
    └── Internet
```

Using both host and service checks helps distinguish between different failure conditions.

For example:

```text
Ping succeeds + HTTP fails
        ↓
Host is reachable
        ↓
Application/service may be unavailable
```

## Storage Monitoring

The NAS is monitored for network and service availability.

This verifies that the storage system is reachable, but does not currently confirm that the SMB media share is mounted successfully on the media server.

The distinction became relevant during testing when the media server started before network storage was available following a power interruption.

## Scope

Uptime Kuma currently provides **availability monitoring**, rather than detailed infrastructure telemetry.

Metrics such as CPU utilization, memory usage, disk health, temperatures, historical performance data, and centralized logging are outside the scope of this project.

Those capabilities will be implemented separately as part of the dedicated **Infrastructure Monitoring Lab**.

## 🔗 Related Documentation

- [Architecture](./architecture.md)
- [Jellyfin Deployment](./jellyfin-deployment.md)
- [Backup Strategy](./backup-strategy.md)
- [Lessons Learned](./lessons-learned.md)

## ✅ Outcome

The Media Services Platform now has centralized monitoring for its primary application and supporting infrastructure.

Uptime Kuma provides a simple health view across:

```text
Jellyfin → Media Server → Storage → Network → Internet
```

More advanced observability will be developed separately in the Monitoring Lab.
