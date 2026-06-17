# Dashboard Catalog

## Infrastructure Overview
**Purpose:** High-level view of overall homelab health and availability.

**Metrics Monitored:**
- Host status
- CPU utilization
- Memory utilization
- Disk utilization
- Active alerts
- Service availability

---

## Docker Services
**Purpose:** Monitor container health, resource usage, and service availability.

**Metrics Monitored:**
- Container status
- CPU utilization
- Memory utilization
- Container restarts
- Network traffic
- Storage usage

**Data Sources:**
- cAdvisor
- Docker Engine

---

## Synology Storage
**Purpose:** Monitor NAS performance, capacity, and hardware health.

**Metrics Monitored:**
- Storage utilization
- Volume health
- Disk SMART status
- Disk temperature
- Network throughput
- Memory utilization

**Data Sources:**
- SNMP
- Synology DSM

---

## Network Health
**Purpose:** Monitor network infrastructure and connectivity.

**Metrics Monitored:**
- Router availability
- Network latency
- Bandwidth utilization
- Interface status
- Packet loss
- WAN connectivity

**Data Sources:**
- SNMP
- Ping probes
- Uptime Kuma

---

## Uptime Overview
**Purpose:** Track service availability and outage history.

**Metrics Monitored:**
- Service uptime percentage
- Response times
- SSL certificate status
- Endpoint availability
- Historical outages

**Data Sources:**
- Uptime Kuma
