## Lessons Learned

- Uptime Kuma is quick to deploy and easy to configure, making it an excellent starting point for infrastructure monitoring.
- The web interface is clean and intuitive, allowing new monitors to be added with minimal effort.
- The platform focuses on availability monitoring rather than full observability, so additional tools are needed for metrics, logging, and advanced alerting.
- Without configuring external notification services, outages must be identified by manually checking the dashboard.
- Because Uptime Kuma runs on a single server, the monitoring platform becomes unavailable if that host goes offline. A secondary monitoring instance or external uptime service would improve resilience.
