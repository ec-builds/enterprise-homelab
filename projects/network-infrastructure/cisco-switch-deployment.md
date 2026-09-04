# 🔀 Cisco Switch Deployment

## Overview

A Cisco Catalyst switch was deployed as the primary managed switch for the network infrastructure lab.

The initial deployment establishes basic Layer 2 switching and secure remote management while maintaining the existing flat network architecture.

Current deployment:

- **Platform:** Cisco Catalyst 3560-CG
- **IOS:** Cisco IOS 15.2(2)E
- **Role:** Managed Layer 2 access switch
- **Management:** SSHv2
- **Management SVI:** VLAN 1
- **Topology:** Flat network
- **Future State:** Segmented VLAN architecture


## Deployment

The switch was factory reset before configuration to remove any configuration remaining from its previous environment.

The initial configuration included:

- Configuring the switch hostname
- Disabling automatic DNS lookup for invalid CLI commands
- Configuring a privileged administrator account
- Configuring an enable secret
- Assigning a static management IP
- Configuring the default gateway
- Generating a 2048-bit RSA host key
- Enabling SSH version 2
- Restricting VTY access to SSH
- Disabling Telnet access
- Saving the completed configuration to NVRAM


## Current Network Configuration

The switch currently operates on the existing flat network.

```text
                 Router / Firewall
                        │
                        │
                        ▼
              ┌───────────────────┐
              │   Catalyst Switch │
              │                   │
              │   VLAN 1 SVI      │
              │   Management IP   │
              └─────────┬─────────┘
                        │
             ┌──────────┼──────────┐
             │          │          │
             ▼          ▼          ▼
          Servers      NAS      Clients
```

All active access ports currently remain members of **VLAN 1**.

VLAN 1 is also temporarily used for the switch management SVI.

> [!NOTE]
> VLAN 1 is intentionally retained during the initial deployment to keep the existing network operational while the managed switching environment is established.


## Management

The switch is remotely managed using SSHv2.

The management configuration uses:

- Static IP addressing
- Local administrator authentication
- Privilege level 15 for administrative access
- RSA-2048 host keys
- SSH-only VTY access

Telnet is not enabled.

Because the switch runs a legacy IOS release, modern OpenSSH clients may require host-specific compatibility options for the older SSH algorithms supported by the platform.

Detailed configuration and compatibility procedures are documented separately in the Cisco SSH reference documentation.


## Validation

The deployment was validated by confirming:

- ✅ Factory configuration successfully cleared
- ✅ IOS image remained intact after reset
- ✅ Management SVI configured successfully
- ✅ Management interface reached `up/up`
- ✅ Default gateway configured
- ✅ Switch reachable over the network
- ✅ SSH version 2 enabled
- ✅ Remote administrator authentication successful
- ✅ Telnet excluded from VTY access
- ✅ Running configuration saved to startup configuration


## Current VLAN Strategy

The initial deployment intentionally uses a single VLAN:

```text
VLAN 1
  │
  ├── Network Infrastructure
  ├── Servers
  ├── Virtualization Hosts
  ├── Storage
  └── Client Devices
```

This provides a simple baseline for validating switching, management connectivity, and infrastructure services before introducing network segmentation.

VLAN 1 should therefore be considered an **initial deployment state rather than the final network design**.


## Planned VLAN Architecture

The network will eventually transition from the flat VLAN 1 topology to a segmented architecture.

Planned logical separation includes:

```text
Managed Switch
      │
      ├── Management VLAN
      │
      ├── Trusted / Client VLAN
      │
      ├── Server / Lab VLAN
      │
      ├── IoT VLAN
      │
      └── Guest VLAN
```

The switch management interface will eventually be migrated from VLAN 1 to a dedicated management VLAN.

Inter-VLAN routing and security policy will be handled by the network firewall/router rather than relying on the current flat Layer 2 topology.


## Deployment Strategy

```text
Factory Reset
      │
      ▼
Baseline Switch Configuration
      │
      ▼
VLAN 1 Management SVI
      │
      ▼
SSH Remote Management
      │
      ▼
Validate Layer 2 Connectivity
      │
      ▼
Current Flat Network
      │
      ▼
Future Firewall Deployment
      │
      ▼
VLAN Segmentation
      │
      ▼
Dedicated Management VLAN
```

## Status

**Current:** Baseline switch deployment complete.

**Next Phase:** Introduce VLAN segmentation after the firewall and supporting network infrastructure are ready.
