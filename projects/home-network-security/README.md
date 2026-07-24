# 🔒 Home Network Security

**Status: 🚧 In Progress**

This project focuses on the *prevention* side of security by hardening the home network through segmentation, filtering, and secure remote access.

**Scope:** Detection and response live in [security-operations-lab](../security-operations-lab/). This project builds the defenses.

## Objectives

- Segment the network into trusted, IoT, guest, lab, and management VLANs
- Deploy a stateful firewall with least-privilege inter-VLAN rules
- Filter DNS requests across the network
- Enable intrusion detection and prevention (IDS/IPS)
- Secure remote administration with WireGuard

## Design Principles

- Default deny between VLANs
- Least privilege
- Defense in depth
- Secure by default
- Minimize exposed services
- Document infrastructure as code and documentation

## Current Environment

- ASUS RT-AX5400
- WireGuard VPN
- WPA3/WPA2 mixed mode

## Target Environment

- OPNsense or pfSense
- Cisco managed switch
- Windows Server (DNS/DHCP) or Technitium DNS
- Suricata IDS/IPS
- VLAN-capable wireless access points

## Current Status

### Completed

- ✅ Deploy WireGuard VPN
- ✅ Update router firmware
- ✅ Enable secure remote administration
- ✅ Disable UPnP

### Next Steps

- [ ] Implement VLAN segmentation
- [ ] Deploy a dedicated firewall
- [ ] Configure network-wide DNS filtering
- [ ] Enable IDS/IPS
- [ ] Centralize firewall and IDS logs

## Folder Structure

```text
home-network-security/
├── docs/            # Security policies, rule documentation, lessons learned
├── configs/         # Sanitized firewall and IDS configurations
└── screenshots/     # Visual documentation
```

## Security Note

Sanitize all configurations before committing them to the repository. Never include public IP addresses, VPN keys, certificates, passwords, or other sensitive information.
