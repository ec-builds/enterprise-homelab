# Intrusion Detection & Prevention System (IDS/IPS) Deployment Plan

**Status: ⚪ Planned**  
**Type:** Implementation plan / placeholder  
**Lab:** Security Operations

## Overview

Deploy Suricata to provide network intrusion detection and prevention capabilities across the homelab.

Implementation will follow a multi-step approach, beginning with passive intrusion detection (IDS) to establish visibility, evaluate alerts, and tune detection rules before enabling active intrusion prevention (IPS).

## Hardware Constraint

The OPNsense firewall was first tested on a 2014 Mac mini with 4 GB of RAM, which would have limited IPS. That hardware failed validation, and the replacement is planned with 8 GB minimum and 16 GB preferred (see [Firewall Hardware](../network-security/TODO-opnsense-deployment-plan.md#firewall-hardware)). Suricata's memory use still grows with the number of enabled rules and the volume of inspected traffic, so each phase is measured before the next.

The deployment is therefore phased:

1. OPNsense is deployed as router and firewall first, and a resource baseline is recorded.
2. Light IDS: detection-only mode on a limited scope, such as one interface and a reduced rule set.
3. IPS after a capacity review confirms sufficient memory headroom and throughput.

See [Firewall Capacity and IDS/IPS Readiness](../network-security/TODO-opnsense-deployment-plan.md#firewall-capacity-and-idsips-readiness) in the OPNsense plan.

## Planned Work

### Step 1 — Intrusion Detection (IDS)

1. Determine Suricata deployment architecture: OPNsense-integrated or dedicated network sensor.
2. Identify monitored interfaces and VLANs, ensuring appropriate traffic visibility.
3. Deploy Suricata in detection-only mode on a limited scope, such as one interface and a reduced rule set.
4. Configure detection rules, establish baseline network activity, and measure firewall memory, CPU and throughput against the pre-IDS baseline.
5. Integrate security events with the existing Loki/Grafana monitoring stack.
6. Configure actionable alerts and document investigation procedures.
7. Validate detection using safe, authorized testing scenarios.

### Step 2 — Intrusion Prevention (IPS)

1. Confirm the firewall has sufficient memory headroom and throughput for inline inspection; if not, defer this step until the firewall hardware is upgraded.
2. Evaluate IDS findings and tune rules to minimize false positives.
3. Configure Suricata for inline intrusion prevention on supported OPNsense interfaces.
4. Enable blocking for selected, validated detection rules.
5. Test threat prevention and confirm legitimate traffic remains unaffected.
6. Establish procedures for reviewing blocked traffic, managing exceptions, and reverting problematic rules.
7. Monitor IPS effectiveness and adjust policies as needed.

## Dependencies / Decisions

- OPNsense deployment and network architecture
- Dedicated firewall hardware that has passed the OPNsense acceptance criteria, with measured memory headroom before IPS
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
- [ ] Firewall memory, CPU and throughput with IDS enabled are recorded against the pre-IDS baseline.

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

**Implementation sequence:** router baseline → light IDS → monitoring integration → rule tuning → capacity review → IPS activation (current or upgraded hardware) → prevention validation.

Do not mark the project complete until both detection and prevention capabilities have been tested and documented. If IPS is deferred for hardware, record that decision and the measured resource figures that led to it.