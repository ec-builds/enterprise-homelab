# Alert Runbooks

## Host Offline

### Symptoms
- Uptime Kuma alert
- Prometheus target down

### Investigation
1. Ping host
2. Check SSH
3. Verify power

### Resolution
- Restart service
- Reboot host
