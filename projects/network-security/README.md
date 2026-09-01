# 🔒 Network Security

**Status: 🟡 In Progress**

This project focuses on the *prevention* side of security by hardening the network infrastructure through segmentation, filtering, and secure remote access.

**Scope:** Detection and response live in [security-operations-lab](../security-operations-lab/). This project builds the defenses.

## Objectives

- Segment the network into trusted, IoT, guest, lab, and management VLANs
- Deploy a stateful firewall with least-privilege inter-VLAN rules
- Filter DNS requests across the network
- Enable intrusion detection and prevention (IDS/IPS)
- Secure remote administration with WireGuard

## Network Security Architecture

<p align="left">
  <img src="./diagrams/network-security-architecture.png" alt="Network Security Architecture" width="750">
</p>

## Current Environment

- ASUS RT-AX5400
- WireGuard VPN
- WPA3/WPA2 mixed mode

## Design Principles

- Default deny between VLANs
- Least privilege
- Defense in depth
- Secure by default
- Minimize exposed services
- Keep critical network infrastructure independent of the virtualization cluster
- Document infrastructure as code and documentation

## Target Environment

- OPNsense dedicated firewall
- Cisco managed switch
- Windows Server (DNS/DHCP) or Technitium DNS
- Suricata IDS/IPS
- VLAN-capable wireless access points

The target architecture places OPNsense on dedicated hardware rather than within the Proxmox virtualization cluster. This keeps routing and firewall availability independent of virtualization host maintenance, reboots, and lab experimentation.

The dedicated OPNsense system will repurpose hardware currently used by the media services environment. Existing Docker-based media workloads will be migrated to a Linux VM on the Proxmox cluster, allowing the system to be dedicated exclusively to firewall and routing services.

This separates application workloads from critical network infrastructure while consolidating general-purpose services within the virtualization environment.

```text
Internet
   │
   ▼
OPNsense
   │
   ▼
Managed Network
   │
   ├── Trusted VLAN
   ├── IoT VLAN
   ├── Guest VLAN
   ├── Lab VLAN
   └── Management VLAN
```

## Current Status

#### Completed

- ✅ Deploy WireGuard VPN
- ✅ Update router firmware
- ✅ Enable secure remote administration
- ✅ Disable UPnP
- ✅ Select OPNsense as the target firewall platform
- ✅ Design dedicated firewall deployment outside the virtualization cluster

#### Next Steps

- [ ] Migrate Docker-based media workloads to Proxmox
- [ ] Repurpose existing media services hardware for OPNsense
- [ ] Deploy OPNsense on dedicated hardware
- [ ] Configure WAN and LAN interfaces
- [ ] Implement VLAN segmentation
- [ ] Configure least-privilege inter-VLAN firewall rules
- [ ] Configure network-wide DNS filtering
- [ ] Enable Suricata IDS/IPS
- [ ] Migrate secure remote access to the target firewall architecture
- [ ] Centralize firewall and IDS logs

## Folder Structure

```text
network-security/
│
├── diagrams/
├── README.md
├── firewall.md
├── wireguard-vpn.md
├── wireguard-security.md
├── network-segmentation.md (Planned)
├── dns-filtering.md (Planned)
├── ids-ips.md (Planned)
└── security-policies.md (Planned)
```

| Document | Primary Question |
|----------|------------------|
| `firewall.md` | How is OPNsense used to protect and control network traffic? |
| `wireguard-vpn.md` | How is secure remote access provided? |
| `wireguard-security.md` | How is the WireGuard deployment hardened? |
| `network-segmentation.md` | How is the network divided into trust zones? |
| `dns-filtering.md` | How is DNS secured? |
| `ids-ips.md` | How are threats detected and prevented? |
| `security-policies.md` | What security principles guide the environment? |

## Security Note

Sanitize all configurations before committing them to the repository. Never include public IP addresses, VPN keys, certificates, passwords, or other sensitive information.
