# 📡 Active Directory DHCP

## Overview

This lab deploys redundant DHCP services within the Active Directory environment.

Two Windows Server domain controllers provide DHCP using a load-balanced failover relationship. The deployment provides centralized IPv4 address assignment, Active Directory-integrated DHCP authorization, redundant DNS configuration for clients, and DHCP service availability across both domain controllers.

Detailed deployment and validation procedures are maintained separately in the Windows Server DHCP reference documentation.


## Architecture

| Component | Configuration |
|---|---|
| DHCP Server 1 | `dc-lab-01` |
| DHCP Server 2 | `dc-lab-02` |
| Network | `10.0.0.0/24` |
| Default Gateway | `10.0.0.1` |
| DHCP Scope | `10.0.0.100–10.0.0.199` |
| Lease Duration | 1 day |
| DHCP Failover Mode | Load Balance |
| Load Balance | 50/50 |
| Maximum Client Lead Time | 1 hour |
| Automatic State Transition | Disabled |
| Failover Authentication | Enabled |


## DHCP Deployment

The Windows Server DHCP role was installed on both domain controllers.

Both DHCP servers were authorized in Active Directory before being used to service clients.

The deployment provides two authorized DHCP servers:

- `dc-lab-01`
- `dc-lab-02`


## DHCP Scope

A single IPv4 scope was created for the primary LAN.

| Setting | Value |
|---|---|
| Scope Name | `LAN` |
| Network | `10.0.0.0/24` |
| Start Address | `10.0.0.100` |
| End Address | `10.0.0.199` |
| Subnet Mask | `255.255.255.0` |
| Lease Duration | 1 day |

Infrastructure systems use addresses outside the DHCP allocation range.


## Scope Options

The scope distributes the network configuration required by DHCP clients.

| Option | Purpose | Configuration |
|---|---|---|
| 003 | Default Gateway | `10.0.0.1` |
| 006 | DNS Servers | `10.0.0.10`, `10.0.0.11` |
| 015 | DNS Domain Name | `lab.example.com` |

Clients therefore receive both Active Directory DNS servers for redundant domain name resolution.


## DHCP Failover

A DHCP failover relationship was established between `dc-lab-01` and `dc-lab-02`.

The relationship uses **Load Balance** mode with a 50/50 distribution. Both DHCP servers can participate in servicing clients while synchronizing DHCP lease and failover state information.

| Setting | Configuration |
|---|---|
| Mode | Load Balance |
| Local Server | 50% |
| Partner Server | 50% |
| Maximum Client Lead Time | 1 hour |
| Automatic State Transition | Disabled |
| Message Authentication | Enabled |
| Shared Secret | Stored securely outside the repository |

The failover relationship successfully replicated the LAN scope to the partner DHCP server.


## DNS Registration

DHCP-managed dynamic DNS registration is disabled to keep DHCP and DNS responsibilities separate.

Domain-joined Windows clients may securely register their own DNS records with Active Directory-integrated DNS. DNS records for infrastructure systems are managed separately.


## DHCP Cutover

DHCP service was migrated from the existing network DHCP service to the redundant Windows DHCP environment.

The previous DHCP allocation range was temporarily moved to prevent overlapping address assignment during migration. Existing clients were allowed to transition away from the original range before the Windows DHCP scopes were activated.

After validation, the previous DHCP service was disabled and Windows DHCP became the active DHCP service for the network.


## Failover Testing

DHCP availability was tested by shutting down each DHCP server independently.

Failure testing was performed in both directions, independently validating DHCP continuity with either server unavailable.

During each outage, the surviving server detected the loss of communication and entered the `CommunicationInterrupted` state. Clients were able to release and obtain DHCP leases from the remaining server with the expected gateway, DNS servers, domain suffix, and lease duration.

After each server was restored, the failover relationship automatically returned to the `Normal` state.

Automatic state transition remains disabled to prevent a communication failure alone from automatically declaring the partner unavailable. `PartnerDown` can be declared manually during a confirmed extended outage.


## Validation

The deployment was validated from both DHCP servers and DHCP clients.

Validation confirmed:

- Both DHCP servers are authorized in Active Directory
- The LAN scope exists and is active on both servers
- Scope configuration is consistent between servers
- DHCP failover relationship is established
- Failover state reports `Normal` during normal operation
- Load balancing is configured at 50/50
- Maximum Client Lead Time is configured for one hour
- Message authentication is enabled
- Clients receive the expected gateway, DNS servers, domain suffix, and lease duration
- Either DHCP server can continue servicing clients while its partner is unavailable
- Failover returns to `Normal` after partner recovery


## Current Deployment State

Windows DHCP is the active DHCP service for the network.

Both DHCP servers operate in a load-balanced failover relationship and provide redundant address assignment. Client cutover and bidirectional DHCP failure testing have been completed successfully.


## Status

| Component | Status |
|---|---|
| DHCP Role - `dc-lab-01` | ✅ Complete |
| DHCP Role - `dc-lab-02` | ✅ Complete |
| Active Directory Authorization | ✅ Complete |
| IPv4 Scope Configuration | ✅ Complete |
| DHCP Scope Options | ✅ Complete |
| DHCP Failover Relationship | ✅ Complete |
| Load Balance Configuration | ✅ Complete |
| Failover Authentication | ✅ Complete |
| Failover Validation | ✅ Complete |
| Client DHCP Cutover | ✅ Complete |
| DHCP Failure Testing | ✅ Complete |
