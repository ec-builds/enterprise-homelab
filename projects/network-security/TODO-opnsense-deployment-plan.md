# OPNsense Firewall Deployment Plan

**Status: ⚪ Planned**  
**Type:** Implementation plan  
**Lab:** Network Security

## Project Overview

This project introduces a dedicated OPNsense firewall into the enterprise homelab to establish a security boundary between household devices and protected infrastructure.

The deployment uses a double-NAT architecture, retaining the ASUS router as the primary internet gateway while delegating homelab routing, firewall enforcement and secure administrative access to OPNsense.

The implementation is designed to preserve existing infrastructure IP addresses, minimize service disruption and establish a foundation for future VLAN segmentation and intrusion detection and prevention.

> [!NOTE]
> Addresses in this document use the placeholder scheme from [Naming Conventions](../../docs/standards/naming-conventions.md). Live addresses, endpoints and credentials are not published.

> [!IMPORTANT]
> A 2014 Mac mini failed hardware validation as the firewall platform in November 2026; see [OPNsense on Mac mini — Hardware Validation](./opnsense-mac-mini-validation.md). Deployment waits for dedicated hardware that meets the [Firewall Hardware](#firewall-hardware) requirements.

| Project attribute | Details |
|---|---|
| Environment | Enterprise homelab |
| Deployment type | Physical firewall appliance |
| Architecture | Double NAT |
| Firewall platform | OPNsense |
| Remote access | WireGuard (migrated from ASUS) |
| Implementation approach | Phased migration |

## Project Objectives

- Establish a dedicated security boundary between household and homelab networks.
- Preserve existing server IP addresses and default gateway configurations.
- Maintain Active Directory, DNS and virtualization services during migration.
- Implement stateful firewall policies based on least privilege.
- Migrate administrative WireGuard access from the ASUS router to OPNsense without losing remote access.
- Retain centralized DNS filtering through AdGuard Home.
- Establish a foundation for VLAN segmentation and IDS/IPS deployment.
- Minimize disruption to household internet connectivity.

## Hardware and Technology Stack

| Component | Platform | Role |
|---|---|---|
| Edge router | ASUS RT-AX5400 | Internet gateway and household wireless access |
| Firewall appliance | Lenovo ThinkCentre M920q Tiny (planned purchase) | Routing, NAT, firewall and VPN; see [Firewall Hardware](#firewall-hardware) |
| Network interfaces | Built-in Intel I219-LM plus Intel i350-T4 quad-port card | WAN, LAN, and spare ports for a future network or dedicated management |
| Managed switch | Cisco Catalyst WS-C3560CG-8PC-S | Layer 2 switching and future VLAN segmentation |
| Virtualization | Proxmox VE | Virtual infrastructure |
| Identity services | Windows Server Active Directory | Identity, DHCP (failover pair) and internal DNS |
| DNS filtering | AdGuard Home (`adguard-lab-01`, `adguard-lab-02`) | Centralized DNS filtering |
| Storage | Synology NAS (`nas-lab`) | Network storage |
| VPN | WireGuard | Secure administrative access |

## Firewall Hardware

The Mac mini test showed that driver support and stability matter more than raw performance, and that external network adapters should be avoided.

| Component | Minimum | Preferred |
|---|---|---|
| Processor | Modern x86-64 | Intel N100 or better |
| Memory | 8 GB | 16 GB |
| Storage | 128 GB SSD | 256 GB SSD |
| Network interfaces | Two supported Ethernet ports | Four Intel Ethernet ports |
| Network controllers | Verified FreeBSD support | Intel i210, i350 or validated i226 |
| Connectivity | Built-in or PCIe Ethernet | No external adapters |
| Power recovery | Restarts automatically after power loss | Configurable BIOS power recovery |
| Power protection | UPS | UPS with monitoring |

### Selected hardware

A used Lenovo ThinkCentre M920q Tiny with an Intel i350-T4 quad-port card meets or exceeds every requirement above.

| Part | Selection | Notes |
|---|---|---|
| Base system | Lenovo ThinkCentre M920q Tiny, Intel Core i5-8500T or i5-8600T (6 cores), 8–16 GB DDR4, 256 GB NVMe SSD | Used business mini PC with a built-in Intel I219-LM port; two SO-DIMM slots for a later RAM upgrade |
| Expansion riser | Lenovo 01AJ940 PCIe riser with back bracket | Converts the M920q's internal expansion connector into a standard PCIe slot; the bracket is cut for an i350-T4 |
| Network card | Intel i350-T4 quad-port Gigabit, OEM server pull (for example, Cisco UCSC-PCIE-IRJ45) | Supported by the FreeBSD `igb` driver; bought as a server pull to avoid counterfeit cards |
| Power | Genuine Lenovo power adapter | Wattage confirmed against Lenovo's specification with the PCIe card installed |

The result is five Intel ports with no external adapters: one built-in port and four on the card.

Build checks:

- [ ] Confirm the riser supports the M920q's machine type before ordering.
- [ ] Check the card on arrival for genuine Intel components (Delta transformers, OEM label, full heatsink) and confirm OPNsense detects four `igb` interfaces.
- [ ] Remove any 2.5-inch drive; the riser and card don't fit alongside one.
- [ ] Disable the internal Wi-Fi card in the BIOS.
- [ ] Set the BIOS to power on automatically after power loss.
- [ ] If Intel AMT (vPro) is used for remote console access, enable it only on the LAN-side built-in port, set a strong password and keep firmware current; otherwise leave it disabled.

Estimated cost is about $200 for the base system, riser and card.

### Acceptance criteria

The replacement hardware must pass all of these before cutover:

- [ ] Seven days of continuous stable operation
- [ ] WAN works via DHCP
- [ ] WAN works via DHCP reservation, including renewal
- [ ] WAN works via static address
- [ ] Connectivity survives multiple cold boots
- [ ] Recovers automatically after upstream outages
- [ ] Sustained throughput test passes
- [ ] WireGuard handshake and remote administration work
- [ ] Internal DNS and Active Directory reachable
- [ ] Firewall policy and network isolation validated
- [ ] Configuration backup and restore tested
- [ ] Emergency management access procedure documented

## Virtual Test Lab

Before the hardware arrives, OPNsense is tested in a Proxmox VM on an isolated network. The VM is for learning and testing only; the production firewall stays on dedicated hardware outside the Proxmox cluster.

```text
Homelab LAN (vmbr0) ──► OPNsense VM WAN
                             │
                        OPNsense VM LAN
                             │
             vmbr1 (isolated bridge, no physical port)
                             │
                  Test VM (Windows 11 or Debian)
```

| Setting | Value |
|---|---|
| OPNsense VM | 2 vCPU, 2–4 GB RAM, 16–32 GB disk |
| Network interfaces | Two VirtIO interfaces: WAN on `vmbr0`, LAN on `vmbr1` |
| Test client | One VM attached only to `vmbr1`, receiving its address from OPNsense |

Safety rules:

- The VM never uses the homelab's live gateway address on any interface.
- OPNsense DHCP runs on `vmbr1` only, never on the WAN side, so it can't compete with Windows Server DHCP.
- "Block private networks" is turned off on the VM's WAN, which sits on a private network.
- Hardware checksum offload is disabled under Interfaces → Settings for the VirtIO interfaces.

Test plan:

- [ ] Create `vmbr1` and the OPNsense and test VMs.
- [ ] Build the firewall aliases and rules from the [Firewall Policy](#firewall-policy).
- [ ] Configure LAN-side DHCP and DNS.
- [ ] Set up WireGuard and connect from a household device to the VM's WAN.
- [ ] Run Suricata in IDS mode against test VM traffic and practice rule tuning.
- [ ] Export the configuration and test restoring it.

The exported configuration is restored onto the M920q at deployment, with interfaces reassigned to the new hardware's port names.

## Existing Network Architecture

Prior to implementation, the ASUS router serves as the default gateway for both household devices and homelab infrastructure.

All wired and trusted wireless devices share the same IPv4 subnet, providing limited network-level isolation between household endpoints and critical infrastructure. Guest and IoT wireless devices use the ASUS guest wireless network, which restricts internal access.

| Component | Current state |
|---|---|
| Subnet | `10.0.0.0/24` |
| Default gateway | `10.0.0.1` (ASUS) |
| DHCP | Windows Server DHCP failover |
| Remote access | WireGuard on the ASUS router |

### Identified limitations

- Household and infrastructure devices share a common broadcast domain.
- Limited granular firewall enforcement between internal devices.
- Increased potential for lateral movement following endpoint compromise.
- No dedicated firewall boundary protecting homelab infrastructure.
- Limited opportunities for enterprise firewall administration and network security monitoring.

## Target Network Architecture

The target architecture introduces OPNsense between the ASUS router and Cisco managed switch.

The existing homelab subnet remains unchanged, while household devices migrate to a new subnet.

### Logical topology

```text
Internet
    |
ASUS RT-AX5400
10.0.20.1/24
    |
    +-- Household devices and Wi-Fi
    |   10.0.20.0/24
    |
    +-- OPNsense WAN
        10.0.20.2/24
            |
        OPNsense Firewall
        NAT / Firewall / WireGuard
            |
        OPNsense LAN
        10.0.0.1/24
            |
        Cisco Catalyst 3560CG
            |
            +-- Proxmox Cluster
            +-- Active Directory
            +-- AdGuard Home
            +-- Synology NAS
            +-- Container Services
            +-- Monitoring Infrastructure
```

### Architectural decision

Rather than renumbering the existing homelab, the ASUS household network will migrate to a new subnet.

OPNsense will assume the existing default gateway address of `10.0.0.1`.

This approach reduces migration complexity and preserves existing server addressing, DNS records, DHCP scope options, application dependencies and infrastructure configurations.

## IP Addressing Plan

| Network | Subnet | Gateway |
|---|---|---|
| Household network | `10.0.20.0/24` | `10.0.20.1` |
| Protected homelab | `10.0.0.0/24` | `10.0.0.1` |
| WireGuard VPN | `10.0.100.0/24` | `10.0.100.1` |

### Infrastructure addressing

| Interface | IP address | Assignment |
|---|---|---|
| ASUS LAN | `10.0.20.1` | Static |
| OPNsense WAN | `10.0.20.2` | DHCP reservation |
| OPNsense LAN | `10.0.0.1` | Static |
| WireGuard interface | `10.0.100.1` | Static |
| Existing infrastructure | `10.0.0.x` | Unchanged |

## Routing and NAT Architecture

Internet-bound traffic originating from the protected homelab undergoes two stages of network address translation.

1. OPNsense translates homelab source addresses to its WAN address.
2. ASUS translates the OPNsense WAN address to the public internet address.

Household devices continue to use single NAT through the ASUS router.

### Example traffic flow

```text
Source: 10.0.0.150
        |
OPNsense NAT: 10.0.20.2
        |
ASUS NAT: <public-ip>
        |
Internet
```

### OPNsense baseline configuration

| Configuration | Setting |
|---|---|
| WAN IPv4 | DHCP (reserved on ASUS) |
| WAN IPv6 | Disabled initially |
| LAN IPv4 | Static |
| RFC1918 blocking on WAN | Disabled |
| Outbound NAT | Automatic initially |
| WAN firewall | Default deny |
| LAN firewall | Baseline outbound access |
| LAN DHCP | Disabled; Windows Server DHCP remains authoritative |
| Automatic DHCP/DNS registration | Disabled |
| Web GUI access | LAN, OPNsense WireGuard, and ASUS break-glass VPN only |
| IDS/IPS | Deferred; see [Firewall Capacity and IDS/IPS Readiness](#firewall-capacity-and-idsips-readiness) |

RFC1918 blocking is disabled because the OPNsense WAN interface operates within a private upstream network.

Household-to-homelab traffic arrives through the ASUS static route and is not translated, so homelab services see the original household client address. Automatic outbound NAT only affects connections initiated from the homelab. If homelab systems later need to initiate connections to household devices with their own source addresses, a hybrid outbound NAT rule excluding the household subnet will be added.

### Asymmetric return path

Household requests to the homelab travel client → ASUS → OPNsense, but OPNsense may reply directly to the client because both share the household subnet. Validation includes complete round trips from a household device, not only server-side logs.

## DHCP and DNS Architecture

Existing Active Directory infrastructure will retain responsibility for homelab DHCP and domain DNS.

| Service | Responsible platform |
|---|---|
| Household DHCP | ASUS |
| Homelab DHCP | Windows Server DHCP failover |
| Active Directory DNS | Windows Server |
| Household DNS filtering | AdGuard Home |
| Homelab gateway | OPNsense |
| VPN connectivity | OPNsense (ASUS retained as fallback during migration) |

Domain-joined devices will continue using Active Directory DNS to ensure proper domain discovery, authentication and service resolution.

Detailed DHCP and DNS configuration is documented in [DHCP Infrastructure](../network-infrastructure/03-dhcp-infrastructure.md) and [DNS Filtering with AdGuard Home](../network-infrastructure/04-dns-filtering-adguard-home.md). Existing DNS forwarders will be reviewed following migration. When VLANs are introduced, OPNsense will relay DHCP to Windows Server; see the VLAN plan.

### Cross-network DNS access

Household clients require controlled access to the AdGuard Home servers located within the protected homelab.

An ASUS static route will establish connectivity to the protected subnet.

| Static route parameter | Value |
|---|---|
| Destination | `10.0.0.0` |
| Subnet mask | `255.255.255.0` |
| Next hop | `10.0.20.2` |
| Interface | LAN |
| Metric | 1 |

OPNsense will permit TCP and UDP port 53 traffic from the household subnet to the designated AdGuard servers.

All other access will remain subject to explicit firewall policies.

### DNS dependency

Both AdGuard servers sit behind OPNsense, so household DNS depends on the firewall being available. This is an accepted trade-off. A public fallback resolver on the ASUS is not used, because clients use secondary resolvers unpredictably and would bypass filtering.

IPv6 on the ASUS LAN will be disabled, or its IPv6 DNS advertisement turned off, so that household clients cannot bypass AdGuard through IPv6 DNS.

## Security Zones

The architecture establishes three logical security zones.

### Household network

Trust level: Semi-trusted

Contains personal computers, mobile devices, televisions and household wireless endpoints. The ASUS guest wireless network remains in place for guest and IoT devices.

Access to protected infrastructure is restricted to explicitly authorized services.

### Protected homelab

Trust level: Restricted infrastructure

Contains virtualization hosts, identity services, storage, monitoring systems and application workloads.

Administrative services are not directly accessible from the household network by default.

### Administrative VPN

Trust level: Authenticated administrative access

Provides encrypted access to authorized infrastructure through individually configured WireGuard peers.

VPN authentication does not replace application-level authentication or authorization.

## Firewall Policy

The target firewall policy follows the principle of least privilege.

| Source | Destination | Service | Action |
|---|---|---|---|
| Household | AdGuard servers | TCP/UDP 53 | Allow |
| Household | Jellyfin (`media-lab-01`) | Approved application port | Allow |
| Household | Synology NAS | SMB, if household devices use shares | Allow (to be confirmed) |
| Household | Proxmox management | TCP 8006 | Deny |
| Household | Infrastructure SSH | TCP 22 | Deny |
| Household | Windows administration | TCP 3389 | Deny |
| Household | OPNsense web GUI | TCP 443 | Deny |
| ASUS break-glass VPN clients | OPNsense management (web GUI; SSH if enabled) | TCP 443 / 22 | Allow, on the WAN interface only |
| Household | OPNsense WAN | WireGuard UDP 51820 | Allow |
| Any (forwarded from ASUS) | OPNsense WAN | WireGuard UDP 51820 | Allow |
| Household | Other homelab services | Any | Deny |
| WireGuard | Authorized infrastructure | Approved management ports | Allow |
| Homelab | Household | Any | Deny unless explicitly authorized |
| Homelab | Internet | Approved outbound traffic | Allow |
| Internet | Protected infrastructure | Unsolicited traffic | Deny |

Remote WireGuard traffic forwarded by the ASUS arrives on the OPNsense WAN with public source addresses, so it requires its own allow rule; the household rule alone covers only local VPN connections.

Device discovery (mDNS, DLNA) does not cross subnets. Household media clients will connect to Jellyfin by address or hostname rather than automatic discovery.

Firewall aliases will be used to simplify policy management.

### Proposed aliases

- HOME_NETWORK
- HOMELAB_NETWORK
- ADGUARD_SERVERS
- MANAGEMENT_HOSTS
- MEDIA_SERVERS
- NAS_SERVERS
- ADMIN_VPN_NETWORK
- MANAGEMENT_PORTS

Stateful inspection will permit return traffic associated with authorized connections.

## Secure Administrative Access

WireGuard currently runs on the ASUS router. The primary administrative VPN will move to OPNsense so that administrative interfaces are reached through authorized VPN connections rather than open household access. Tunnel configuration, peer migration and validation are tracked in the [WireGuard VPN Migration](./TODO-wireguard-vpn-deployment-plan.md) plan.

The firewall policy in this plan assumes the tunnel network `10.0.100.0/24`, UDP 51820 on the OPNsense WAN, and split tunneling to the protected homelab.

### Break-glass access

Two independent break-glass paths cover the main firewall failure cases:

| Failure | Recovery path |
|---|---|
| OPNsense hung or unresponsive | Power-cycle the firewall with a smart plug, controlled through the plug vendor's cloud app |
| OPNsense running, but its WireGuard VPN unavailable | Connect to the ASUS WireGuard VPN and reach the OPNsense management interface from the WAN side |
| OPNsense running, but configuration broken | ASUS WireGuard to the management interface if WAN rules still permit it; otherwise local console access or the rollback procedure |
| ASUS or internet connection down | No remote recovery; local access required |

**Smart plug.** The plug sits on the isolated IoT wireless network and is controlled only through the vendor's cloud service, independent of both VPNs. It requires the ASUS and the internet connection to be available. Dependence on the vendor's cloud is an accepted risk: the plug is a last-resort recovery path, and the firewall can still be recovered locally. The firewall's BIOS is set to power on automatically when power returns, and this is verified before the plug is relied on.

**ASUS WireGuard.** The ASUS WireGuard service is retained permanently as a secondary path for reaching OPNsense when its own VPN is unavailable. Because household traffic is denied access to the OPNsense management interface, a dedicated WAN rule permits only ASUS break-glass VPN clients to reach the web GUI (and SSH, if enabled). Whether the ASUS assigns VPN clients their own subnet or translates them to its LAN address determines the source address this rule matches, and will be confirmed during deployment.

Private keys and OPNsense configuration backups are not stored in public repositories.

## Implementation Plan

### Step 1 — Preparation

- [ ] Back up ASUS and Cisco configurations.
- [ ] Document existing IP assignments.
- [ ] Review DHCP reservations and identify household reservations to move to the ASUS.
- [ ] Review DNS dependencies.
- [ ] Document existing VPN and port-forwarding configurations.
- [ ] Identify household devices connected to the Cisco switch.
- [ ] Establish local console access to OPNsense.
- [ ] Connect the firewall to a smart plug on the IoT wireless network, confirm remote control through the vendor app, and confirm automatic boot after power loss.
- [ ] Determine whether the ASUS assigns WireGuard clients their own subnet or translates them to its LAN address.

### Step 2 — Firewall Deployment

- [x] Test OPNsense on a 2014 Mac mini (failed validation; see [Hardware Validation](./opnsense-mac-mini-validation.md)).
- [ ] Build and test the [virtual test lab](#virtual-test-lab).
- [ ] Acquire the [selected hardware](#selected-hardware) and complete the build checks.
- [ ] Install OPNsense on the M920q and restore the tested configuration.
- [ ] Pass the [acceptance criteria](#acceptance-criteria).
- [ ] Validate physical interface assignments.
- [ ] Configure LAN addressing.
- [ ] Configure WAN DHCP.
- [ ] Restrict web GUI access to LAN and VPN, including the ASUS break-glass rule.
- [ ] Verify baseline firewall and NAT settings.
- [ ] Back up OPNsense configuration.

### Step 3 — Network Migration

- [ ] Disconnect ASUS from the Cisco switch.
- [ ] Move household wired devices from the Cisco switch to the ASUS.
- [ ] Change ASUS LAN subnet to the household network.
- [ ] Enable and configure ASUS DHCP, including household reservations.
- [ ] Disable IPv6 on the ASUS LAN, or its IPv6 DNS advertisement.
- [ ] Temporarily configure independent household DNS.
- [ ] Connect OPNsense WAN to ASUS.
- [ ] Reserve the OPNsense WAN IP.
- [ ] Connect OPNsense LAN to Cisco.
- [ ] Verify gateway ARP resolution.
- [ ] Reconnect or restart household devices that retain old leases.
- [ ] Remove household reservations from the Windows DHCP scope.
- [ ] Validate internet connectivity.

### Step 4 — Service Integration

- [ ] Configure ASUS static routing.
- [ ] Create firewall aliases.
- [ ] Permit cross-network DNS traffic.
- [ ] Validate AdGuard query logs.
- [ ] Restore household DNS filtering.
- [ ] Rebuild existing port forwards as ASUS → OPNsense → host.
- [ ] Verify Active Directory functionality.
- [ ] Verify virtualization and storage services.

### Step 5 — Secure Remote Access

- [ ] Deploy WireGuard on OPNsense.
- [ ] Configure administrative peers.
- [ ] Update ASUS WireGuard peers for the new household subnet.
- [ ] Validate local VPN connectivity.
- [ ] Validate remote VPN connectivity.
- [ ] Restrict direct management access.
- [ ] Test unauthorized access attempts.
- [ ] Reduce the ASUS WireGuard service to break-glass use and document its access scope.

### Step 6 — Security Hardening

- [ ] Restrict homelab-to-household traffic.
- [ ] Enable relevant firewall logging.
- [ ] Integrate firewall monitoring.
- [ ] Establish resource utilization baselines.
- [ ] Review firewall policies.
- [ ] Document final configurations.

## Validation and Testing

| Test | Expected result | Status |
|---|---|---|
| Household DHCP | Receives a household-network address | ⚪ Planned |
| Household internet | Internet accessible | ⚪ Planned |
| Homelab gateway | `10.0.0.1` reachable | ⚪ Planned |
| Homelab internet | Double NAT operational | ⚪ Planned |
| Active Directory DNS | Internal records resolve | ⚪ Planned |
| Domain authentication | Successful | ⚪ Planned |
| Windows DHCP failover | Both servers healthy; homelab clients receive leases | ⚪ Planned |
| Proxmox cluster | All nodes healthy | ⚪ Planned |
| Synology SMB | Existing shares accessible | ⚪ Planned |
| Cross-network DNS | Household queries resolve through AdGuard | ⚪ Planned |
| IPv6 DNS bypass | Household clients receive no IPv6 DNS server | ⚪ Planned |
| Household Jellyfin playback | Streams from a household device | ⚪ Planned |
| Unauthorized SSH | Blocked | ⚪ Planned |
| Unauthorized management access | Blocked, including OPNsense web GUI | ⚪ Planned |
| Local WireGuard | Successful connection | ⚪ Planned |
| Remote WireGuard | Successful connection | ⚪ Planned |
| ASUS fallback VPN | Reaches homelab through static route | ⚪ Planned |
| Remote power cycle | Firewall restarts and OPNsense returns after a smart-plug power cycle from the vendor app | ⚪ Planned |
| ASUS break-glass management | ASUS VPN client reaches the OPNsense web GUI; household clients are blocked | ⚪ Planned |
| VPN administrative access | Authorized services accessible | ⚪ Planned |
| Firewall resource utilization | Within acceptable limits | ⚪ Planned |

Validation results, screenshots and sanitized configuration excerpts will be collected following implementation.

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Duplicate gateway IP | Physically isolate networks before migration |
| Stale ARP entries | Clear affected neighbor caches |
| DNS interruption | Temporarily use independent household DNS |
| Household DNS depends on firewall | Accepted; restore OPNsense from console or roll back |
| IPv6 DNS bypass | Disable IPv6 or IPv6 DNS advertisement on the ASUS LAN |
| Competing DHCP servers | Maintain one DHCP authority per subnet |
| Stale household leases | Reconnect or restart affected devices |
| WAN IP changes | Configure DHCP reservation |
| Broken port forwards | Document and rebuild through both NAT layers |
| Firewall management lockout | Maintain local console access and ASUS VPN fallback |
| Firewall hang while remote | Power-cycle the firewall through the smart plug's vendor app |
| OPNsense VPN unavailable while remote | Reach OPNsense management through the ASUS break-glass VPN and its dedicated WAN rule |
| Smart plug depends on vendor cloud service | Accepted risk; the plug is a last-resort path and local console access remains available |
| Double-NAT limitations | Document routing and port-forwarding requirements |
| Unreliable or under-sized firewall hardware | Dedicated hardware with supported Intel network controllers must pass the acceptance criteria before cutover |
| Limited firewall memory for IDS/IPS | Phase the rollout (routing, then light IDS, then IPS after a capacity review) |
| Unauthorized lateral movement | Implement restrictive firewall policies |
| Firewall hardware failure | Maintain configuration backups and rollback procedure |
| Exposed configuration secrets | Store encrypted backups outside the repository |

OPNsense configuration backups contain WireGuard private keys and password hashes. Backups are stored encrypted and never committed to the repository.

## Rollback Procedure

If critical infrastructure becomes unavailable during migration:

1. Disconnect OPNsense WAN and LAN interfaces.
2. Restore the ASUS router LAN address to `10.0.0.1/24`.
3. Restore the previous DHCP and DNS configuration.
4. Reconnect ASUS to the Cisco switch.
5. Refresh affected ARP caches and DHCP leases.
6. Verify Active Directory, virtualization, storage and internet connectivity.
7. Review the failed implementation before attempting migration again.

Because existing homelab IP addresses remain unchanged, rollback does not require infrastructure renumbering.

## Future Enhancements

### VLAN segmentation

VLAN segmentation follows the firewall deployment. Proposed VLAN IDs, subnets and zones are tracked in the [VLAN Implementation](./TODO-vlan-implementation-plan.md) plan. OPNsense will route each VLAN over an 802.1Q trunk to the Cisco switch and enforce inter-VLAN policy.

Additional planned enhancements include:

- IEEE 802.1Q trunking between OPNsense and Cisco.
- Inter-VLAN firewall policies.
- DHCP relay to Windows Server DHCP for routed VLANs.
- Suricata intrusion detection, with prevention subject to firewall capacity.
- Centralized firewall logging through Loki.
- Grafana firewall monitoring dashboards.
- Automated configuration backups.
- IPv6 security and routing.
- Firewall throughput and latency benchmarking.
- Evaluation of OPNsense as the primary internet gateway.

### Firewall capacity and IDS/IPS readiness

Suricata's memory use grows with the number of enabled rules and the traffic inspected, and it competes with the firewall's routing, NAT, VPN and logging workloads. The Mac mini's 4 GB of RAM was a concern for IPS before it failed validation; the replacement hardware's 8–16 GB removes most of that constraint, but each stage is still measured before the next.

Deployment is phased so each stage is measured before the next begins:

1. **Router and firewall only.** OPNsense handles routing, NAT, firewall policy and WireGuard. A CPU, memory and throughput baseline is recorded under normal load.
2. **Light IDS.** Suricata runs in detection-only mode on a limited scope, such as a single interface and a reduced rule set, while memory use and throughput are compared against the baseline.
3. **IPS, only if resources allow.** Inline prevention is enabled only if light IDS runs with sufficient memory headroom and without a meaningful drop in throughput. Inline mode also depends on netmap support for the network drivers, which must be verified on the chosen hardware.

The [IDS/IPS Deployment](../security-operations/TODO-ids-ips-deployment-plan.md) plan tracks the Suricata work.

## Success Criteria

The project will be considered successfully implemented when:

- Existing homelab services operate without infrastructure renumbering.
- Household and homelab networks operate as separate security zones.
- Double NAT provides reliable internet connectivity.
- Household devices retain centralized DNS filtering.
- Administrative access is restricted to authorized connections.
- WireGuard provides reliable encrypted access from OPNsense.
- Unauthorized cross-network connections are blocked.
- Firewall performance remains acceptable under normal workloads.
- Configuration backups and validation evidence are documented.

## Related Documentation

- [Network Security Architecture](./architecture.md)
- [WireGuard VPN Migration](./TODO-wireguard-vpn-deployment-plan.md)
- [VLAN Implementation](./TODO-vlan-implementation-plan.md)
- [IDS/IPS Deployment](../security-operations/TODO-ids-ips-deployment-plan.md)
- [Naming Conventions](../../docs/standards/naming-conventions.md)

## Follow-up Plans to Create

Planning documents to draft for work related to this deployment:

| Plan | Owner project | Scope | Status |
|---|---|---|:---:|
| OPNsense hardening and management access | Network Security | Admin accounts, web GUI MFA, SSH disabled or key-only, GUI limited to LAN and VPN, update cadence, encrypted configuration backups | ⚪ |
| Firewall policy and rule management | Network Security | Aliases, per-zone rules, rule naming and documentation convention, per-rule logging, periodic rule review | ⚪ |
| Firewall logging and monitoring | Infrastructure Monitoring | OPNsense syslog to rsyslog and Loki, Grafana firewall dashboard, CPU, memory and state metrics; provides the resource baseline for the IDS phases | ⚪ |
| Threat intelligence blocklists | Network Security | Known-malicious address lists as firewall aliases, with blocked traffic logged; low memory cost while IDS/IPS is limited | ⚪ |
| OPNsense backup and recovery | Backup & Disaster Recovery | Scheduled encrypted configuration backups and a tested restore to replacement hardware, supporting a future hardware upgrade | ⚪ |

DHCP relay and Cisco trunking are covered by the [VLAN Implementation](./TODO-vlan-implementation-plan.md) plan and the Network Infrastructure port map rather than separate plans.
