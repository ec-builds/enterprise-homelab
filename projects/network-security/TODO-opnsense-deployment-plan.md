# OPNsense Deployment Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Network Security

## Overview

Introduce OPNsense as the homelab firewall/router with controlled migration from the existing ASUS gateway.

## Planned Work

1. Confirm dedicated hardware, NIC/interface layout, and rollback path.
2. Design WAN/LAN connectivity, management access, DNS/DHCP responsibilities, and routing. Preserve Windows Server DHCP and its existing failover configuration; plan DHCP relay for VLANs using Windows DHCP.
3. Preserve AD-integrated DNS and define AdGuard Home filtering/forwarding paths; document OPNsense DNS forwarding responsibilities.
4. Install and harden OPNsense; back up initial configuration.
5. Pilot behind the existing router before gateway cutover where practical.
6. Migrate firewall/NAT rules and validate client connectivity and service reachability.

## Dependencies / Decisions

- Hardware and switch connectivity
- IP addressing and VLAN plan
- Maintenance window and rollback procedure
- Existing Mac mini dual-NIC design documentation (verify final hardware/interface support)
- Windows DHCP relay per VLAN and DNS forwarding path

## Validation / Completion Criteria

- [ ] WAN/LAN routing and AD DNS/AdGuard resolution function as intended
- [ ] Windows DHCP failover remains authoritative; relay-tested VLAN clients receive correct leases
- [ ] Management access restricted and configuration backup tested
- [ ] Rollback documented

## Rollback / Recovery

- Export and securely retain the ASUS router configuration before cutover.
- Record cabling, prior gateway/DHCP settings, and a tested path to restore ASUS routing if OPNsense cutover fails.

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.
