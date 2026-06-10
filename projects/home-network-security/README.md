# 🔒 Home Network Security

**Status: 📋 Planned**

The *prevention* side of security: hardening the home network with enterprise-grade defensive design — segmentation, filtering, and secure remote access.

**Scope note:** Detection and response live in [security-operations-lab](../security-operations-lab/). This project builds the defenses; that one watches them.

## 🎯 Objectives

- Segment the network with VLANs (trusted, IoT, guest, lab, management)
- Deploy a stateful firewall with explicit inter-VLAN rules (default deny)
- Implement network-wide DNS filtering
- Enable intrusion detection/prevention (IDS/IPS)
- Provide secure remote access via VPN instead of port forwarding

## 🛠️ Technologies

- Firewall platform (pfSense, OPNsense, or UniFi)
- VLAN-capable switches and access points
- DNS filtering (Pi-hole or AdGuard Home)
- IDS/IPS (Suricata)
- VPN (WireGuard or Tailscale)

## 📋 Key Tasks

- [ ] Implement the VLAN design from [network-infrastructure](../network-infrastructure/)
- [ ] Configure firewall rules with least-privilege inter-VLAN access
- [ ] Isolate IoT devices from trusted networks
- [ ] Deploy DNS filtering for all VLANs
- [ ] Enable and tune Suricata rulesets
- [ ] Stand up WireGuard VPN for remote administration
- [ ] Disable WPS/UPnP; enforce WPA3 where possible
- [ ] Document the rule base; schedule periodic reviews
- [ ] Feed firewall/IDS logs to the [SIEM](../security-operations-lab/)

## 📁 Folder Structure

```
home-network-security/
├── docs/            # Security policy, rule documentation, lessons learned
├── configs/         # Sanitized firewall/IDS configs
└── screenshots/     # Visual documentation
```

## ⚠️ Security Note

Configs are sanitized before commit — no public IPs, PSKs, certificates, or VPN keys.
