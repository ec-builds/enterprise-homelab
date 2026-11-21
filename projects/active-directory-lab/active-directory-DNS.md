# 🌐 Active Directory DNS

**Status: 🟢 Operational**

## Overview

DNS was deployed with Active Directory Domain Services on both domain controllers. AD DNS is authoritative for the internal namespace and forwards external queries to two AdGuard Home instances.

Validation commands are in the [Windows Server DNS Validation](../../docs/reference/windows/windows-server-DNS-validation.md) reference.

> [!NOTE]
> Hostnames, IP addresses, and domain names have been sanitized for public release.

## Configuration

| Setting | Value |
|---|---|
| DNS servers | `dc-lab-01` (`10.0.0.10`), `dc-lab-02` (`10.0.0.11`) |
| AD-integrated zones | `lab.example.com`, `_msdcs.lab.example.com` |
| Zone replication | Through AD (`DomainDnsZones`, `ForestDnsZones`) |
| Dynamic updates | Secure only |
| Forwarders | `adguard-lab-01`, `adguard-lab-02` (on both domain controllers) |
| DC DNS client | Partner domain controller preferred, local DNS alternate |
| Client DNS | Both domain controllers, assigned by DHCP option 006 |

## Resolution Path

```text
              Domain client
                    │
         ┌──────────┴──────────┐
         ▼                     ▼
     dc-lab-01             dc-lab-02
       AD DNS                AD DNS
         │                     │
         ├── lab.example.com ──┤   authoritative, answered locally
         │                     │
         └──── external ───────┘
                    │
                    ▼
     adguard-lab-01 / adguard-lab-02
         filtering + DoH upstream
                    │
                    ▼
           Public DNS resolvers
```

Public resolvers are not configured on any domain member or domain controller network adapter. Every query goes through AD DNS first.

DNS-over-HTTPS covers only the AdGuard-to-public-resolver leg. Traffic between clients, AD DNS, and AdGuard stays standard DNS on the internal network.

## Zone Deployment

The zones were created when `dc-lab-01` was promoted as the first domain controller in the forest. When `dc-lab-02` was promoted with the DNS role, the zones replicated to it through Active Directory. No zones were created manually on the second server.

## Record Management

| Record source | Method |
|---|---|
| Domain controllers | Registered automatically by the DC, including LDAP, Kerberos, and GC SRV records |
| Domain-joined Windows systems | Secure dynamic registration by the client |
| Static infrastructure and selected non-domain systems | Manual A and PTR records |
| DHCP | No registration; DHCP dynamic DNS is disabled |

Manual records are kept only for systems that need consistent name-based access, such as statically addressed infrastructure and selected DHCP reservations.

## Service Discovery

Both domain controllers are advertised through SRV records, so clients can find either one for directory and authentication services:

```text
_ldap._tcp.dc._msdcs.lab.example.com      → dc-lab-01, dc-lab-02   (LDAP :389)
_kerberos._tcp.dc._msdcs.lab.example.com  → dc-lab-01, dc-lab-02   (Kerberos :88)
```

## Validation

| Check | Result |
|---|---|
| AD-integrated zones present on both servers | ✅ |
| `DomainDnsZones` / `ForestDnsZones` replication | ✅ |
| Host records for both domain controllers | ✅ |
| LDAP and Kerberos SRV records for both domain controllers | ✅ |
| Global Catalog registration | ✅ |
| Secure dynamic updates | ✅ |
| Manual A / PTR records | ✅ |
| External resolution through each DNS server | ✅ |
| `dcdiag /test:dns` | ✅ Passed |

## Failure Testing

- **One domain controller offline:** a client kept resolving internal and external names through the remaining DNS server, and Internet access continued. Normal operation resumed after the server was restored.
- **One AdGuard instance offline:** tested in both directions. External resolution continued through the remaining instance.

## Outcome

AD DNS was deployed on both domain controllers with zones replicated through Active Directory, SRV records advertising both servers, and redundant filtered forwarding for external names. Losing any single DNS server or forwarder did not interrupt client name resolution.

## Related Documentation

- [Active Directory Lab](./README.md)
- [Domain Controller Architecture](./domain-controller-architecture.md)
- [Active Directory DHCP](./active-directory-DHCP.md)
- [Windows Server DNS Validation](../../docs/reference/windows/windows-server-DNS-validation.md)
- [Additional Domain Controller Validation](../../docs/reference/windows/windows-additional-domain-controller-validation.md)
- [Network Infrastructure](../network-infrastructure/)
