# WireGuard VPN Migration to OPNsense Plan

**Status: ⚪ Planned**  
**Type:** Implementation plan / placeholder  
**Lab:** Network Security

## Overview

Migrate existing WireGuard remote access from the ASUS router to OPNsense while preserving secure connectivity to approved homelab resources. The ASUS WireGuard service is retained as break-glass access after the migration.

## Planned Work

1. Inventory the existing ASUS WireGuard setup, active peers, DNS, and access policies; define the OPNsense endpoint and allowed client networks.
2. Plan VPN address range, DNS resolution, and split-tunnel versus full-tunnel policy.
3. Generate and securely store per-device keys; configure peers and endpoint access.
4. Restrict VPN clients with firewall rules to approved management and service networks.
5. Test connectivity, DNS, access restrictions, key revocation, and reconnection before moving clients to the OPNsense endpoint.
6. Migrate clients in stages and document the cutover.
7. Reduce the ASUS WireGuard service to break-glass use and document its access scope.

## Target Configuration

| Parameter | Configuration |
|---|---|
| VPN platform | WireGuard on OPNsense |
| Tunnel subnet | `10.0.100.0/24` |
| Server tunnel IP | `10.0.100.1` |
| Listening port | UDP 51820 |
| Authentication | Public/private key pairs, one peer per device |
| Default routing mode | Split tunnel |
| Protected destination | `10.0.0.0/24` (later, approved VLANs) |
| Local endpoint | `10.0.20.2:51820` |
| Remote endpoint | `<public-ip>` or DDNS hostname |

Remote access requires an ASUS port forward to the OPNsense WAN interface, and a reachable public IP; carrier-grade NAT would prevent inbound connections.

## Coexistence with ASUS Break-Glass Access

- Both services run at the same time, so they use different external ports. The ASUS forwards a separate external port to UDP 51820 on the OPNsense WAN.
- Forwarded traffic reaches the OPNsense WAN with public source addresses and needs its own WAN allow rule; local household peers are covered by a separate rule.
- After the household network moves to `10.0.20.0/24`, ASUS peer configurations must include the household subnet and the routes needed to reach the OPNsense WAN.
- The ASUS VPN is a secondary path to the OPNsense management interface when the OPNsense VPN is unavailable. A dedicated OPNsense WAN rule permits only ASUS VPN clients to reach the web GUI (and SSH, if enabled); household traffic remains blocked.
- Confirm whether the ASUS assigns VPN clients their own subnet or translates them to its LAN address, since this determines the rule's source address.
- If OPNsense is hung, recovery uses the smart plug through its vendor app, independent of either VPN; see [Break-glass access](./TODO-opnsense-deployment-plan.md#break-glass-access).

## Dependencies / Decisions

- OPNsense routing and firewall baseline ([OPNsense Deployment](./TODO-opnsense-deployment-plan.md))
- VLAN access policies and public reachability/DDNS plan
- Existing ASUS VPN configuration and peer inventory

## Validation / Completion Criteria

- [ ] Authorized remote peer connects and resolves internal DNS
- [ ] Unauthorized VLAN access blocked
- [ ] Lost-device key revocation documented
- [ ] Remote peer connects through the ASUS port forward and double NAT
- [ ] ASUS break-glass peer reaches the OPNsense management interface; household clients cannot

## Rollback / Recovery

- Retain the ASUS WireGuard configuration and known-good peer profiles; the ASUS endpoint remains available as break-glass access.
- Document how to restore the prior endpoint, DNS/DDNS, and port-forwarding configuration if migration fails.

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.

**Existing documentation:** Review `projects/network-security/02-wireguard-vpn.md` before implementation to avoid duplicating prior design work.
