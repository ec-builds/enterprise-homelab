# 🔒 Home Network Security

**Status: 📋 Planned**

The *prevention* side of security: hardening the home network with enterprise-grade design through segmentation, filtering, and secure remote access.

**Scope note:** Detection and response live in [security-operations-lab](../security-operations-lab/). This project focuses on building the defenses.

## Objectives

- Segment the network with VLANs (trusted, IoT, guest, lab, management)
- Deploy a stateful firewall with least-privilege inter-VLAN rules
- Implement network-wide DNS filtering
- Enable intrusion detection/prevention (IDS/IPS)
- Provide secure remote access through WireGuard

## Current Environment

- ASUS RT-AX5400
- WireGuard VPN
- WPA3/WPA2 mixed mode

## Target Environment

- OPNsense or pfSense
- Cisco managed switch
- Windows Server DNS/DHCP or Technitium DNS
- Suricata IDS/IPS
- VLAN-capable wireless access points

## Current Status

### Completed

- ✅ WireGuard VPN deployed
- ✅ Router firmware updated
- ✅ Remote administration enabled
- ✅ UPnP disabled

### Next Steps

- VLAN segmentation
- Dedicated firewall
- DNS filtering
- IDS/IPS
- Centralized logging

## Folder Structure

```text
home-network-security/
├── docs/            # Security policy, rule documentation, lessons learned
├── configs/         # Sanitized firewall/IDS configurations
└── screenshots/     # Visual documentation
```

## Security Note

Configurations are sanitized before commit. No public IP addresses, VPN keys, certificates, passwords, or other sensitive information are stored in the repository.
