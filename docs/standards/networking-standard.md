# 🌐 Networking Standard

## Purpose

Establish consistent network configuration and addressing practices across homelab infrastructure.

Implementation details and platform-specific procedures are maintained separately in project and reference documentation.

## Standard

Networked infrastructure should:

- Use documented and predictable addressing.
- Use static IP addressing for servers and infrastructure services where persistent addressing is required.
- Use DHCP for client devices and systems that do not require manually configured addresses.
- Use DHCP reservations where predictable addressing is required but DHCP-managed configuration is preferred.
- Use DNS names instead of IP addresses for service access where practical.
- Use the appropriate default gateway and DNS servers for the assigned network.
- Avoid configuring both static and DHCP addressing on the same interface unless intentionally required.
- Use approved network bridges and interfaces for virtualized workloads.
- Document infrastructure addressing and significant network configuration changes.
- Sanitize internal addressing and environment-specific identifiers in public documentation.

## Addressing

The addressing method should be selected according to the system's role.

| System Type | Preferred Method |
|---|---|
| Servers and infrastructure services | Static IP |
| Infrastructure managed through DHCP | DHCP reservation |
| Client devices | DHCP |
| Temporary or test systems | DHCP |

Exceptions are acceptable when required by the platform or service.

## Validation

After network configuration or addressing changes, verify:

- Correct IP address and subnet
- Default gateway
- DNS server configuration
- Local network connectivity
- DNS resolution
- Required service connectivity
- No unintended duplicate addresses

## Related Documentation

- [Naming Conventions](./naming-conventions.md)
- [Virtual Machine Deployment Standard](./vm-deployment-standard.md)
- [Proxmox Networking Reference](../reference/proxmox/proxmox-networking.md)
- [Network Infrastructure Lab](../../projects/network-infrastructure/)
