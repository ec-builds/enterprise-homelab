# 📶 Wireless Security

This document describes the wireless security configuration protecting the homelab and the security controls applied to the current wireless infrastructure.

## Purpose

The ASUS RT-AX5400 provides integrated wireless networking for the homelab. The wireless network is configured to provide secure client connectivity while minimizing unnecessary exposure through modern encryption and administrative hardening.

## Wireless Security Architecture

<p align="left">
  <img src="./diagrams/wireless_security_architecture.png" alt="Wireless Security Architecture" width="750">
</p>

## Current Configuration

### Wireless Networks

| Network | Purpose | Security |
|---|---|---|
| Main Wi-Fi | Trusted devices | WPA2/WPA3-Personal |
| Guest Wi-Fi | Guests and IoT devices | WPA2/WPA3-Personal (Guest Network) |

### Wireless Security

- WPA2/WPA3 mixed mode enabled
- Separate Guest Wi-Fi network
- Guest network isolated from the internal network
- Strong WPA passphrases
- SSID broadcasting enabled
- Built-in ASUS wireless access point
- WPS disabled

### Router Administration

- HTTPS management enabled
- WAN administration disabled
- Administrative access limited to the LAN or WireGuard VPN
- Router firmware kept current

## Validation

The wireless configuration was reviewed and tested to confirm the intended security controls and isolation boundaries.

| Validation | Result |
|---|:---:|
| Trusted wireless clients can access the internal network | ✅ |
| Guest / IoT wireless clients can access the Internet | ✅ |
| Guest / IoT wireless clients are isolated from trusted internal resources | ✅ |
| WPA2/WPA3 security enabled | ✅ |
| WPS disabled | ✅ |
| HTTPS router management enabled | ✅ |
| WAN administration disabled | ✅ |
| Router administration accessible from trusted LAN or WireGuard VPN | ✅ |

The current validation applies to the ASUS wireless environment. VLAN-backed SSIDs, WPA3-Enterprise, RADIUS authentication, and centralized wireless management remain future-state capabilities.

## Security Principles

- Encrypt wireless communications
- Separate trusted and untrusted devices
- Restrict administrative access
- Minimize exposed management services
- Keep network infrastructure firmware current
- Validate isolation boundaries before considering them operational

## Roadmap

- [ ] Deploy dedicated wireless access points
- [ ] Implement WPA3-Enterprise
- [ ] Integrate RADIUS authentication
- [ ] Separate SSIDs by VLAN
- [ ] Deploy multiple enterprise access points for roaming
- [ ] Enable centralized wireless management

## Security Note

Wireless credentials, SSIDs, and administrative passwords are never committed to this repository.
