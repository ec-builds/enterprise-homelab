# Intrusion Detection & Prevention System (IDS/IPS) Deployment Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Security Operations

## Overview

Deploy Suricata to provide network intrusion detection and prevention capabilities across the homelab.

Implementation will follow a multi-step approach, beginning with passive intrusion detection (IDS) to establish visibility, evaluate alerts, and tune detection rules before enabling active intrusion prevention (IPS).

## Planned Work

### Step 1 — Intrusion Detection (IDS)

1. Determine Suricata deployment architecture: OPNsense-integrated or dedicated network sensor.
2. Identify monitored interfaces and VLANs, ensuring appropriate traffic visibility.
3. Deploy Suricata in detection-only mode.
4. Configure detection rules and establish baseline network activity.
5. Integrate security events with the existing Loki/Grafana monitoring stack.
6. Configure actionable alerts and document investigation procedures.
7. Validate detection using safe, authorized testing scenarios.

### Step 2 — Intrusion Prevention (IPS)

1. Evaluate IDS findings and tune rules to minimize false positives.
2. Configure Suricata for inline intrusion prevention on supported OPNsense interfaces.
3. Enable blocking for selected, validated detection rules.
4. Test threat prevention and confirm legitimate traffic remains unaffected.
5. Establish procedures for reviewing blocked traffic, managing exceptions, and reverting problematic rules.
6. Monitor IPS effectiveness and adjust policies as needed.

## Dependencies / Decisions

- OPNsense deployment and network architecture
- VLAN segmentation and firewall policies
- Suricata deployment method and traffic inspection placement
- Existing Loki/Grafana logging and monitoring infrastructure
- IDS rule sources and update strategy
- IPS compatibility with selected network interfaces, drivers, and inline inspection mode (including netmap support where applicable)

## Validation / Completion Criteria

### IDS

- [ ] Suricata monitors intended network interfaces and VLANs.
- [ ] Detection rules generate alerts during controlled testing.
- [ ] Alerts include source, destination, timestamp, and rule context.
- [ ] Security events are accessible through the monitoring stack.
- [ ] Detection rules and false-positive tuning are documented.

### IPS

- [ ] Suricata operates in inline prevention mode.
- [ ] Selected malicious traffic is successfully blocked during controlled testing.
- [ ] Legitimate network traffic remains operational.
- [ ] Blocking events are logged and available for investigation.
- [ ] Rule exceptions and rollback procedures are documented.

## Rollback / Recovery

- Keep IDS detection-only configuration available as the fallback.
- If IPS blocks legitimate traffic or disrupts connectivity, disable inline blocking and restore the last validated rule set.

## Implementation Notes

> Placeholder: Record final architecture, Suricata configuration, monitored interfaces, detection rules, alerting integrations, test results, screenshots, and lessons learned as implementation progresses.

**Implementation sequence:** IDS deployment → monitoring integration → rule tuning → IPS activation → prevention validation.

Do not mark the project complete until both detection and prevention capabilities have been tested and documented.