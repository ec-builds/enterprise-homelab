# Network Services

**Project:** Network Infrastructure  
**Status:** 🟢 Active

## Overview

This document inventories and documents the core network services used throughout the homelab environment. These services provide connectivity, name resolution, time synchronization, remote administration, file sharing, monitoring, and infrastructure management.

For IP address assignments, network ranges, DHCP reservations, and VLAN planning, see **ip-addressing-plan.md**.

---

## Service Inventory

| Service | Purpose | Status |
|----------|----------|----------|
| DHCP | Dynamic IP Address Assignment | Active |
| DNS | Name Resolution | Active |
| NTP | Time Synchronization | Active |
| SSH | Remote Administration | Active |
| SMB | Network File Sharing | Active |
| HTTPS | Secure Web Access | Active |
| ICMP | Connectivity Monitoring | Active |
| SNMP | Infrastructure Monitoring | Planned |

---

## DHCP

### Description

Dynamic Host Configuration Protocol (DHCP) automatically assigns IP addresses and network configuration information to clients on the network.

### Responsibilities

- IP Address Assignment
- Default Gateway Distribution
- DNS Server Distribution
- Lease Management

### Related Documentation

- ip-addressing-plan.md

---

## DNS

### Description

Domain Name System (DNS) provides hostname-to-IP address resolution for internal and external resources.

### Responsibilities

- Name Resolution
- DNS Forwarding
- Service Discovery
- Future Internal DNS Records

### Related Documentation

- dns-records.md (planned)

---

## NTP

### Description

Network Time Protocol (NTP) ensures consistent time synchronization across infrastructure systems.

### Time Source

```text
pool.ntp.org
```

### Importance

- Log Correlation
- Monitoring Accuracy
- TLS Certificate Validation
- Scheduled Task Execution

---

## SSH

### Description

Secure Shell (SSH) provides encrypted remote administration access to infrastructure systems.

### Standards

- SSH Version 2
- Key-Based Authentication Preferred
- Principle of Least Privilege
- Sudo for Administrative Access

### Typical Use Cases

- System Administration
- Remote Troubleshooting
- Configuration Management
- Automation Tasks

---

## SMB

### Description

Server Message Block (SMB) provides network file sharing across supported operating systems.

### Use Cases

- Shared Storage
- Media Libraries
- Backup Repositories
- Cross-Platform File Access

---

## HTTPS

### Description

Hypertext Transfer Protocol Secure (HTTPS) provides encrypted web-based access to infrastructure services.

### Typical Services

- Administrative Interfaces
- Monitoring Dashboards
- Self-Hosted Applications
- Infrastructure Portals

---

## ICMP

### Description

Internet Control Message Protocol (ICMP) is used for connectivity testing and availability monitoring.

### Monitoring Objectives

- Availability Monitoring
- Latency Measurement
- Packet Loss Detection
- Connectivity Verification

---

## SNMP

### Description

Simple Network Management Protocol (SNMP) provides infrastructure telemetry and device monitoring.

### Planned Metrics

- CPU Utilization
- Memory Utilization
- Interface Statistics
- Bandwidth Usage
- Hardware Health

### Planned Integrations

- Prometheus
- SNMP Exporter
- Grafana

---

## Future Services

### Reverse Proxy

**Status:** Planned

Potential Capabilities:

- Centralized Service Access
- TLS Termination
- Service Routing
- Authentication Integration

---

### Monitoring Platform

**Status:** Planned

Components:

- Uptime Kuma
- Prometheus
- Grafana
- Loki
- Alerting

---

### Remote Access

**Status:** Planned

Potential Solutions:

- VPN
- Mesh VPN
- Zero-Trust Access

---

## Service Dependencies

```text
Internet
│
├── DNS
├── NTP
│
Network Infrastructure
│
├── DHCP
├── DNS Forwarding
│
Infrastructure Services
│
├── SSH
├── SMB
├── HTTPS
│
Monitoring Platform
│
├── Availability Monitoring
├── Metrics Collection
├── Visualization
└── Alerting
```

---

## Related Documentation

- ip-addressing-plan.md
- device-inventory.md
- monitoring-endpoints.md
- dns-records.md (planned)
