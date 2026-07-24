# Alert Runbooks

## Host Offline

### Symptoms

- Uptime Kuma reports the host as down.
- Prometheus target is unreachable.

### Investigation

1. Verify network connectivity with `ping`.
2. Attempt an SSH connection.
3. Check the host's power and network status.
4. Review recent logs, if available.

### Resolution

- Restart the affected service if applicable.
- Reboot the host if unresponsive.
- Verify the host returns to a healthy state.

### Prevention

- Configure alert notifications.
- Monitor hardware health and resource utilization.
- Keep documentation and recovery procedures up to date.
