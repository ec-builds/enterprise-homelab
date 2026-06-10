# 🛡️ Security Operations Lab

**Status: 📋 Planned**

The *detect and respond* side of security: SIEM deployment, log collection, detection engineering, and documented incident triage.

**Scope note:** Prevention (firewalls, segmentation, hardening) lives in [home-network-security](../home-network-security/). This project is about visibility — catching and investigating activity.

## 🎯 Objectives

- Deploy a SIEM and centralize security-relevant logs from the entire lab
- Ship Windows event logs from the AD lab and syslog from Linux hosts
- Write and tune detection rules for realistic scenarios
- Generate test attack activity and document detection → triage → response
- Explore Microsoft Sentinel as the cloud-native SIEM counterpart

## 🛠️ Technologies

- Wazuh (free SIEM/XDR — agents, rules, dashboards)
- Windows Event Forwarding / Sysmon
- Linux auditd and syslog
- Microsoft Sentinel (Azure-side, with KQL queries)
- Atomic Red Team or manual test cases for safe attack simulation

## 📋 Key Tasks

- [ ] Deploy Wazuh server on a dedicated VM
- [ ] Install agents on Linux hosts and the [AD lab](../active-directory-lab/) domain controller
- [ ] Deploy Sysmon on Windows endpoints with a tuned config
- [ ] Build a dashboard for authentication events across the lab
- [ ] Simulate failed-logon bursts; verify and tune the detection
- [ ] Simulate a port scan; document detection and triage
- [ ] Write one full incident report: what happened, how it was caught, response
- [ ] Connect Microsoft Sentinel to Entra ID sign-in logs; write 2-3 KQL detections
- [ ] Document alert tuning decisions (what was noisy, what mattered)

## 📁 Folder Structure

```
security-operations-lab/
├── detections/      # Detection rules and KQL queries
├── incident-reports/# Documented triage exercises
├── configs/         # Agent/Sysmon configs (sanitized)
├── docs/            # Build notes, lessons learned
└── screenshots/     # Visual documentation
```
