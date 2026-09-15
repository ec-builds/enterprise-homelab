# 🌐 Active Directory DNS

## Overview

DNS was deployed alongside Active Directory Domain Services (AD DS) to provide name resolution and service discovery for the Active Directory domain.

The first domain controller established the AD-integrated DNS namespace. A second DNS-enabled domain controller was later deployed to provide DNS and domain controller redundancy.

> [!NOTE]
> Hostnames, IP addresses, domain names, and other environment-specific identifiers shown in this document have been sanitized for public release.

## Architecture

The completed DNS architecture consists of two DNS-enabled domain controllers.

```text
                    lab.example.com
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        dc-lab-01                  dc-lab-02
        10.0.0.10                  10.0.0.11
              │                         │
          AD DS + DNS               AD DS + DNS
          Global Catalog            Global Catalog
              │                         │
              └──── AD Replication ─────┘
```

Both servers provide authoritative DNS for the Active Directory namespace.

The primary AD-integrated zones are:

```text
lab.example.com
_msdcs.lab.example.com
```

Because the zones are stored in Active Directory, DNS data replicates between the domain controllers through Active Directory replication rather than requiring manually maintained secondary zones.

## Active Directory DNS

Active Directory uses DNS for both name resolution and service discovery.

Domain members use DNS records to locate services including:

```text
Domain Controllers
LDAP
Kerberos
Global Catalog
```

For example, domain controller discovery uses SRV records under:

```text
_ldap._tcp.dc._msdcs.lab.example.com
```

Domain members therefore use the internal Active Directory DNS infrastructure rather than public or router-provided DNS servers.

External DNS queries are handled by the DNS Server service through forwarding or recursive resolution.

## Initial DNS Deployment

DNS was installed with AD DS during deployment of the first domain controller.

Promotion created the AD-integrated DNS zones and registered the DNS records required by Active Directory.

The initial deployment established:

```text
dc-lab-01
10.0.0.10
     │
     ├── Active Directory Domain Services
     ├── DNS Server
     ├── Global Catalog
     │
     └── AD-Integrated DNS
           ├── lab.example.com
           └── _msdcs.lab.example.com
```

Validation confirmed:

- DNS Server service operational
- AD-integrated domain and `_msdcs` zones available
- Secure dynamic DNS registration functional
- Domain controller host record registered
- LDAP service records registered
- Kerberos service records registered
- External DNS resolution functional
- Active Directory DNS diagnostics passing

Detailed DNS validation procedures are maintained separately in the **Windows Server DNS Validation** reference document.

## DNS Redundancy

A second domain controller was deployed with the DNS Server role and Global Catalog enabled.

The existing AD-integrated zones replicated automatically through Active Directory:

```text
dc-lab-01
     │
     ├── Domain Partition
     ├── Configuration
     ├── Schema
     ├── DomainDnsZones
     └── ForestDnsZones
              │
              │ AD Replication
              ▼
         dc-lab-02
```

No DNS zones were manually recreated on the second server.

Post-promotion validation confirmed:

- Bidirectional Active Directory replication
- `DomainDnsZones` replication
- `ForestDnsZones` replication
- AD-integrated zones available on both DNS servers
- Host records for both domain controllers
- LDAP SRV records advertising both domain controllers
- Kerberos SRV records advertising both domain controllers
- Global Catalog DNS registration
- Secure dynamic DNS updates
- Internal DNS resolution
- External DNS resolution
- DNS diagnostics passing

Detailed domain controller validation is maintained separately in the **Additional Domain Controller Validation** reference document.

## Service Discovery

With both domain controllers operational, Active Directory DNS advertises both servers for directory and authentication services.

```text
LDAP :389
├── dc-lab-01.lab.example.com
└── dc-lab-02.lab.example.com

Kerberos :88
├── dc-lab-01.lab.example.com
└── dc-lab-02.lab.example.com
```

This allows domain members to discover either domain controller through standard Active Directory DNS service records.

## DNS Resolution Model

The resulting DNS architecture separates internal Active Directory resolution from external DNS resolution.

```text
Domain Client
     │
     ▼
AD DNS
     │
     ├── lab.example.com
     │       │
     │       └── Authoritative Resolution
     │
     └── External Domain
             │
             ▼
       Forwarder / Recursion
             │
             ▼
        Internet DNS
```

Public DNS resolvers are not configured directly on domain member or domain controller network adapters.

## Validation

The deployment was validated at both the Active Directory and DNS layers.

```text
AD DS
 │
 ├── DC Discovery             ✓
 ├── Bidirectional Replication ✓
 ├── SYSVOL / NETLOGON        ✓
 └── Global Catalog           ✓
 │
DNS
 │
 ├── AD-Integrated Zones      ✓
 ├── DomainDnsZones           ✓
 ├── ForestDnsZones           ✓
 ├── Host Registration        ✓
 ├── LDAP SRV Registration    ✓
 ├── Kerberos SRV Registration ✓
 ├── Dynamic DNS              ✓
 └── External Resolution      ✓
```

Detailed commands and repeatable procedures are maintained in the corresponding validation reference documents rather than duplicated here.

## Deployment Status

| Stage | Status |
|---|---|
| Primary DNS Server | ✅ Complete |
| AD-Integrated DNS | ✅ Complete |
| Secondary DNS Server | ✅ Complete |
| AD DNS Replication | ✅ Complete |
| LDAP / Kerberos Service Discovery | ✅ Complete |
| Dynamic DNS | ✅ Complete |
| External DNS Resolution | ✅ Complete |
| DNS Diagnostics | ✅ Complete |
| DNS Client Redundancy Configuration | ⏳ In Progress |
| DNS Failure Testing | ⚪ Pending |
