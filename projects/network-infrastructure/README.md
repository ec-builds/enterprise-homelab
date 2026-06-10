# 🌐 Network Infrastructure

**Status: 📋 Planned**

The physical and logical foundation of the homelab — routing, switching, wireless, IP design, and core network services.

## 🎯 Objectives

- Design and document a structured network topology
- Implement a scalable IP addressing scheme and VLAN plan
- Configure routing, switching, and wireless for performance and manageability
- Establish reliable internal DNS and DHCP
- Document everything so the network can be rebuilt from the docs alone

## 🛠️ Technologies

- Router/firewall appliance (pfSense, OPNsense, or UniFi gateway)
- Managed switches (VLAN trunking)
- Wireless APs with multi-SSID/VLAN mapping
- Internal DNS & DHCP

## 📋 Key Tasks

- [ ] Document physical topology (devices, ports, cabling)
- [ ] Define IP addressing plan and subnet allocations per VLAN
- [ ] Configure VLAN trunks between firewall, switches, APs, and the Proxmox host
- [ ] Map SSIDs to VLANs (trusted, IoT, guest, lab)
- [ ] Set up DHCP scopes with reservations for infrastructure
- [ ] Configure internal DNS with forward/reverse zones
- [ ] Implement config backups for all network devices
- [ ] Maintain an IPAM record (spreadsheet or NetBox)

## 🔗 Related Projects

- [virtualization-lab](../virtualization-lab/) — VLAN-aware bridge connects lab VMs to this network design
- [home-network-security](../home-network-security/) — firewall policy and segmentation built on this foundation

## 📁 Folder Structure

```
network-infrastructure/
├── docs/            # IP plan, port maps, build notes, lessons learned
├── configs/         # Sanitized device configs
├── scripts/         # Backup/automation scripts
└── screenshots/     # Visual documentation
```
