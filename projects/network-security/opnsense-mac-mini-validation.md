# OPNsense on Mac mini — Hardware Validation

**Result:** Failed validation. Deployment deferred until dedicated firewall hardware is available.  
**Tested:** November 2026

A 2014 Mac mini was tested as the platform for the planned OPNsense firewall, to see whether existing hardware could run it reliably. OPNsense installed and configured correctly, and the internal network worked, but connections to the internet were intermittent and the root cause couldn't be confirmed, so the Mac mini was rejected as the production firewall.

Replacement hardware requirements, acceptance criteria and next steps are in the [OPNsense Firewall Deployment](./TODO-opnsense-deployment-plan.md) plan. Addresses use the placeholder scheme from [Naming Conventions](../../docs/standards/naming-conventions.md).

## Test Platform

| Component | Specification |
|---|---|
| Platform | Apple Mac mini (2014), bare metal |
| Memory | 4 GB RAM |
| Storage | 256 GB Crucial SSD |
| Interface 1 | Built-in Broadcom Gigabit Ethernet |
| Interface 2 | Thunderbolt-to-Gigabit Ethernet adapter |
| Upstream / downstream | ASUS RT-AX5400 / Cisco Catalyst 3560CG |

The test used the planned double-NAT layout: OPNsense WAN on the ASUS household network (`10.0.20.0/24`) and OPNsense LAN taking over the homelab gateway (`10.0.0.1`). A Windows 11 client (`win11-lab-01`) behind OPNsense was used to test connectivity from the homelab side.

## Results

| Test | Result |
|---|---|
| Installation, web interface, interface detection | ✅ Passed |
| ARP resolution to the ASUS, routing table, outbound NAT | ✅ Passed |
| Firewall rules | ✅ Configured |
| Internal (LAN-side) connectivity | ✅ Passed |
| OPNsense updates | ✅ Downloaded when the WAN was up |
| WAN via DHCP | ⚠️ Worked, but intermittently |
| WAN via DHCP reservation | ❌ Failed |
| WAN via static address | ❌ Failed |
| External connectivity, from OPNsense and from `win11-lab-01` | ❌ Intermittent |
| WireGuard | ❌ Not validated |

## Troubleshooting

- **Physical:** confirmed cabling and interface detection, swapped network adapters, and looked into Thunderbolt Ethernet compatibility.
- **Data link:** checked ARP tables and confirmed MAC resolution with the ASUS; looked for stale entries and MAC conflicts.
- **Network:** checked subnets, the default gateway and the routing table; tested DHCP, a reservation and static addressing; pinged the ASUS and external hosts.
- **Transport and firewall:** checked outbound NAT and WAN/LAN rules; set up WireGuard on UDP 51820; confirmed private-network blocking was off on the WAN; ran packet captures on outbound traffic with missing replies.
- **Services:** checked DNS settings and upstream reachability; attempted WireGuard remote access.
- **Client testing:** used `win11-lab-01` behind OPNsense to compare internal and external access. Internal connections worked consistently; external connections were intermittent, matching what OPNsense itself showed. Testing from a real client confirmed the problem affected homelab traffic, not just the firewall's own tests.

## Findings

Internal traffic worked reliably; only external connections through the WAN side were intermittent, even though addressing, routing and NAT all appeared correct. On the WAN, DHCP worked some of the time and a reservation or static address broke it. Swapping adapters restored connectivity temporarily, but the platform never behaved consistently.

Suspected causes: Broadcom driver support in FreeBSD, the Thunderbolt adapter, interface initialization or state handling, DHCP reservation or ARP behavior on the ASUS, or general hardware and OS compatibility.

**The root cause wasn't confirmed.** The Thunderbolt adapter and its driver are the main suspects. The same built-in and Thunderbolt Ethernet hardware passed validation under Debian earlier (see [Mac mini Dual Ethernet](../../docs/reference/debian/debian-mac-mini-dual-ethernet-reference.md)), which points toward FreeBSD driver support rather than faulty hardware, but the evidence doesn't prove either.

## Decision

The Mac mini was rejected as the production firewall. The firewall is the homelab's single point of failure, and intermittent WAN loss would risk internet outages, lost remote access and unreliable recovery after changes. Its 4 GB of RAM would also have limited IDS/IPS.

OPNsense and the planned architecture are unchanged; only the hardware changes. The ASUS remains the gateway until replacement hardware passes validation, and the Mac mini stays available for non-critical testing.

## Lessons Learned

- Hardware compatibility matters as much as configuration for critical infrastructure.
- A successful install doesn't mean the system is production-ready.
- A DHCP lease and ARP resolution don't prove the connection is reliable.
- Packet captures need to be read alongside interface behavior and what the upstream router shows.
- External network adapters add a dependency that critical infrastructure should avoid.
- Keep confirmed observations separate from suspected causes.
- Failing a validation test is better than running an unreliable firewall.
