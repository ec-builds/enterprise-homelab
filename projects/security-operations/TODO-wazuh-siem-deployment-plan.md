# Wazuh SIEM Deployment Plan

**Status: ⚪ Planned**  
**Type:** Implementation plan / placeholder  
**Lab:** Security Operations

## Overview

Deploy Wazuh as the homelab SIEM to centralize security-relevant logs from Windows, Active Directory and Linux systems, generate alerts, and support investigation and response.

Wazuh is the foundation for the project's other detection work. Active Directory monitoring, Sysmon telemetry, authentication dashboards and incident reports all depend on it. Unlike IDS/IPS, it does not depend on OPNsense or VLAN segmentation, so it can be deployed first.

## Planned Work

### Step 1 — Platform Deployment

1. Confirm VM sizing and Proxmox placement. The Wazuh all-in-one quickstart is sized at 4 vCPU, 8 GB RAM and 50 GB storage for up to 25 agents with 90 days of indexed data.
2. Select the operating system. The quickstart supports Ubuntu and RHEL-family distributions; Debian is not on the listed set, so decide between an Ubuntu VM and a documented exception to the [Linux Server Standard](../../docs/standards/linux-server-standard.md).
3. Deploy `security-lab-01` following the [VM Deployment Standard](../../docs/standards/vm-deployment-standard.md).
4. Install the Wazuh indexer, server and dashboard using the all-in-one installation.
5. Secure the dashboard: change default credentials, store them outside the repository, and restrict access to management systems.
6. Add `security-lab-01` to existing availability and metric monitoring.

### Step 2 — Log Collection

1. Deploy Wazuh agents to the domain controllers and collect Windows Security, System and Directory Service logs.
2. Deploy agents to Windows 11 endpoints.
3. Deploy Sysmon with a tuned configuration on Windows systems and forward its events.
4. Deploy agents to Linux hosts and collect authentication and system logs.
5. Confirm agent enrollment, connectivity and event flow for every enrolled system.

### Step 3 — Detection and Alerting

1. Review the default Wazuh rule set and enable rules relevant to the lab.
2. Configure alerts for authentication failures, account lockouts, privileged group membership changes and new account creation.
3. Build an authentication monitoring dashboard.
4. Generate controlled test activity, such as repeated failed logons, and confirm detection.
5. Tune noisy rules and document false-positive decisions.

### Step 4 — Operations

1. Define index retention based on available storage.
2. Document agent deployment, upgrade and removal procedures.
3. Back up Wazuh configuration and custom rules.

## Dependencies / Decisions

- Proxmox host with sufficient CPU, memory and storage for an always-on indexer
- Operating system choice (supported Ubuntu release or a documented Debian exception)
- Agent coverage: which domain controllers, endpoints and Linux hosts are enrolled first
- Sysmon configuration baseline
- Relationship to the existing Loki/Grafana log pipeline (which logs stay in Loki and which move to Wazuh)
- Network placement after segmentation; agents must reach the Wazuh server once VLANs and firewall policies are in place
- Later integration with Suricata alerts from the [IDS/IPS Deployment](./TODO-ids-ips-deployment-plan.md)

## Validation / Completion Criteria

- [ ] Wazuh indexer, server and dashboard run on `security-lab-01`.
- [ ] Default credentials are changed and stored outside the repository.
- [ ] Domain controller, Windows endpoint and Linux agents report as active.
- [ ] Windows Security and Sysmon events are searchable in the dashboard.
- [ ] Controlled failed-logon activity generates the expected alert.
- [ ] A privileged group membership change generates the expected alert.
- [ ] Retention, backups and agent procedures are documented.
- [ ] Rule tuning and false-positive decisions are documented.

## Rollback / Recovery

- Take a Proxmox snapshot or backup of `security-lab-01` before upgrades and major configuration changes.
- Agents can be stopped or uninstalled without affecting the monitored systems.
- If resource use affects other workloads, reduce retention or move the VM to another Proxmox host.

## Implementation Notes

> Placeholder: Record final sizing, operating system, agent coverage, Sysmon configuration, custom rules, dashboards, test results, screenshots and lessons learned as implementation progresses.

**Implementation sequence:** platform deployment → Windows and AD log collection → Sysmon → Linux log collection → detection tuning → operational documentation.

Do not mark the deployment complete until log collection and detections have been tested and documented.

## Related Documentation

- [Security Operations README](./README.md)
- [IDS/IPS Deployment](./TODO-ids-ips-deployment-plan.md)
- [Active Directory Lab](../active-directory-lab/README.md)
- [Infrastructure Monitoring](../infrastructure-monitoring/README.md)
