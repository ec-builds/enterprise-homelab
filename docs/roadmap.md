# 🗺️ Roadmap

![Homelab Roadmap](../diagrams/roadmap.png)

## Overview

This roadmap describes how the homelab is built in stages, from the underlying platform through enterprise operations, security, identity, automation, and cloud.

It complements the [Homelab Direction](homelab-direction.md) document: the direction document defines *what the lab is for and which capabilities matter most*, while this roadmap describes *the order in which the environment is built and matured*.

The lab is currently completing **Phase 2 (Build & Explore)** while actively progressing into **Phase 3 (Integrate & Automate)**. Core infrastructure is operational, including the three-node virtualization platform, centralized storage, redundant Active Directory and network services, Linux systems, containerized workloads, DNS filtering, media services, availability monitoring, and an initial observability stack.

The phases are not strictly linear. Documentation, security, monitoring, backup, and automation are ongoing threads that mature alongside the infrastructure rather than waiting for a single phase to be completely finished.

## Phases

### Status Legend

| Status | Meaning |
|--------|---------|
| 🟢 Complete | Built, documented, and working as intended |
| 🟡 In Progress | Currently being built, expanded, configured, or tested |
| ⚪ Upcoming | Planned, not yet started |
| 📍 You Are Here | Current focus of active work |

### 1. Foundation 🟢 Complete

- Hardware Evaluation
- Operating Systems
- Networking Fundamentals
- Documentation Standards

### 2. Build & Explore 🟡 📍 You Are Here

- [x] Linux Services
- [x] Active Directory Infrastructure
- [x] Storage Integration
- [x] Three-Node Proxmox VE Cluster
- [x] Containerized Services
- [x] Redundant DNS and DHCP
- [x] DNS Filtering and Encrypted Upstream Resolution
- [x] Remote Access
- [ ] Continue Network Infrastructure Expansion
- [ ] Continue Identity Infrastructure Development

The core compute, storage, identity, networking, and application platforms are operational. Remaining work focuses on expanding and refining the infrastructure before moving more of the lab's focus toward integration and automation.

### 3. Integrate & Automate 🟡 In Progress

- [x] Availability Monitoring
- [x] Metrics Collection and Visualization
- [x] Centralized Logging
- [x] Alerting and Notifications
- [x] Initial Backup Integration
- [ ] Complete Permanent Monitoring Deployment
- [ ] Expand Infrastructure Monitoring Coverage
- [ ] Standardize Infrastructure Automation
- [ ] Expand Backup and Recovery Workflows
- [ ] Automate Repeatable Administrative Tasks
- [ ] Continue Infrastructure Documentation

Monitoring and observability capabilities have been deployed and validated, with Uptime Kuma providing dedicated availability monitoring and the broader Prometheus, Grafana, Loki, Alloy, and Alertmanager stack being prepared for permanent deployment. Automation, backup, and operational standardization will continue to expand as the environment matures.

### 4. Optimize & Secure ⚪ Upcoming

- [ ] Deploy OPNsense Firewall
- [ ] Implement VLAN Segmentation
- [ ] Implement Inter-VLAN Firewall Policies
- [ ] Expand System Hardening
- [ ] Expand Identity and Access Controls
- [ ] Implement Security Monitoring
- [ ] Introduce Vulnerability Management
- [ ] Develop Disaster Recovery Procedures
- [ ] Validate Recovery and Service Continuity

Existing controls such as perimeter firewalling, WireGuard remote access, wireless isolation, redundant DNS services, DNS filtering, and encrypted upstream DNS provide the current security baseline. This phase will focus on deeper segmentation, dedicated firewalling, detection capabilities, hardening, and recovery engineering.

### 5. Operate & Grow ⚪ Upcoming

- [ ] Continuous Improvement
- [ ] Advanced Infrastructure Projects
- [ ] Cloud Technologies
- [ ] Entra ID Integration
- [ ] Hybrid Identity
- [ ] Cloud Administration and Security
- [ ] Infrastructure as Code
- [ ] CI/CD Integration
- [ ] Kubernetes
- [ ] Enterprise Architecture Concepts

The long-term goal is to evolve the homelab from a collection of functioning infrastructure services into an integrated environment for practicing enterprise operations, identity, security, automation, cloud technologies, and modern infrastructure engineering.
