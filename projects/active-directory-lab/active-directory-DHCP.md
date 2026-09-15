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
| Lease Duration | 3 days |
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
| Lease Duration | 3 days |

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
| Automatic State Transition | Disabled (**will be used later**) |
| Message Authentication | Enabled |
| Shared Secret | Stored securely outside the repository |

The failover relationship successfully replicated the LAN scope to the partner DHCP server.


## Validation

The deployment was validated from both DHCP servers.

Validation confirmed:

- Both DHCP servers are authorized in Active Directory
- The LAN scope exists on both servers
- Scope configuration is consistent between servers
- DHCP failover relationship is established
- Failover state reports `Normal`
- Load balancing is configured at 50/50
- Maximum Client Lead Time is configured for one hour
- Message authentication is enabled
- Automatic state transition is disabled


## Current Deployment State

The Windows DHCP environment has been configured and validated but has not yet been placed into service.

The DHCP scopes remain **inactive** while the existing network DHCP service continues to provide addresses. Client migration and production cutover will be performed separately to avoid conflicts with existing DHCP leases.


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
| Client DHCP Cutover | ⏳ Pending |
| DHCP Failure Testing | ⏳ Pending |
