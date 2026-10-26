# VLAN Segmentation Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Network Security

## Overview

Segment management, server, trusted, IoT, and guest networks with least-privilege inter-VLAN access.

## Planned Work

1. Review proposed VLAN IDs for management, server, trusted, IoT, and guest zones against current addressing; do not finalize IDs until the subnet plan is approved.
2. Design subnets, gateways, DHCP scopes, and DNS reachability.
3. Validate VLAN-aware access point requirements before wireless migration; the current ASUS RT-AX5400 consumer configuration may not support per-SSID VLAN tagging. Configure switch trunks/access ports and compatible AP SSIDs.
4. Create OPNsense interfaces and default-deny inter-VLAN firewall policy with explicit exceptions.
5. Specify Proxmox management and corosync network placement, including cluster reachability, before migration.
6. Test isolation and required paths for monitoring, DNS, administration, and IoT.

## Dependencies / Decisions

- OPNsense interfaces and managed switch configuration
- Wireless hardware capability review and VLAN-aware AP decision
- Windows DHCP scopes/relay and DNS reachability for each VLAN

## Validation / Completion Criteria

- [ ] Each VLAN receives expected addressing
- [ ] Blocked inter-VLAN paths remain blocked
- [ ] Approved services remain reachable

## Rollback / Recovery

- Save switch, AP, and OPNsense configurations before changes.
- Migrate one test VLAN at a time; preserve an out-of-band or known-good management path and restore port/VLAN settings if connectivity fails.

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.
