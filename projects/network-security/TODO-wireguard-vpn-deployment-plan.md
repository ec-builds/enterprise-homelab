# WireGuard VPN Migration to OPNsense Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Network Security

## Overview

Migrate existing WireGuard remote access from the ASUS router to OPNsense while preserving secure connectivity to approved homelab resources.

## Planned Work

1. Inventory the existing ASUS WireGuard setup, active peers, DNS, and access policies; define the OPNsense endpoint and allowed client networks.
2. Plan VPN address range, DNS resolution, and split-tunnel versus full-tunnel policy.
3. Generate and securely store per-device keys; configure peers and endpoint access.
4. Restrict VPN clients with firewall rules to approved management and service networks.
5. Test connectivity, DNS, access restrictions, key revocation, and reconnection before retiring the ASUS endpoint.
6. Migrate clients in stages and document the cutover.

## Dependencies / Decisions

- OPNsense routing and firewall baseline
- VLAN access policies and public reachability/DDNS plan
- Existing ASUS VPN configuration and peer inventory

## Validation / Completion Criteria

- [ ] Authorized remote peer connects and resolves internal DNS
- [ ] Unauthorized VLAN access blocked
- [ ] Lost-device key revocation documented

## Rollback / Recovery

- Retain the ASUS WireGuard configuration and known-good peer profiles until OPNsense connectivity is verified.
- Document how to restore the prior endpoint, DNS/DDNS, and port-forwarding configuration if migration fails.

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.

**Existing documentation:** Review `projects/network-security/02-wireguard-vpn.md` before implementation to avoid duplicating prior design work.
