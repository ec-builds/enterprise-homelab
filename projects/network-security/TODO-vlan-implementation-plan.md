# VLAN Segmentation Plan

**Status: ⚪ Planned**  
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

## Proposed VLAN IDs

These IDs are proposed and not final until the subnet plan is approved. Addresses use the placeholder scheme from [Naming Conventions](../../docs/standards/naming-conventions.md).

| VLAN | Subnet | Zone |
|---|---|---|
| — | `10.0.0.0/24` | Current flat network on VLAN 1; systems migrate to their zones |
| 10 | `10.0.10.0/24` | Management |
| 20 | `10.0.20.0/24` | Trusted clients (the ASUS household network until a VLAN-aware access point is deployed) |
| 30 | `10.0.30.0/24` | Servers |
| 40 | `10.0.40.0/24` | IoT |
| 50 | `10.0.50.0/24` | Guest |
| 60 | `10.0.60.0/24` | Security testing |
| 70 | `10.0.70.0/24` | DMZ |

The WireGuard tunnel network (`10.0.100.0/24`) is not a VLAN.

- Management moves off VLAN 1 to VLAN 10, including the Cisco switch management interface.
- VLANs are carried on an 802.1Q trunk between OPNsense and the Cisco switch; the trunk's native VLAN is set to an unused VLAN once migration is complete.
- Windows Server DHCP remains authoritative; OPNsense relays DHCP for each routed VLAN.

## Dependencies / Decisions

- OPNsense interfaces and managed switch configuration ([OPNsense Deployment](./TODO-opnsense-deployment-plan.md))
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
