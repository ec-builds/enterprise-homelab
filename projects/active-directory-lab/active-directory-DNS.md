# 🌐 Active Directory DNS

## Overview

This document covers the DNS infrastructure deployed for the Active Directory
lab.

DNS was installed alongside Active Directory Domain Services (AD DS) when the
first domain controller was deployed. Domain controller promotion created the
AD-integrated DNS zones and registered the records required for Active
Directory service discovery.

This document focuses on validating the DNS environment after domain
controller deployment.

The validation workflow is:

```text
AD DS + DNS Installed
        │
        ▼
Domain Controller Promoted
        │
        ▼
Validate DNS Role + Service
        │
        ▼
Validate AD-Integrated Zones
        │
        ▼
Validate DNS Client Configuration
        │
        ▼
Validate Host Records
        │
        ▼
Validate AD SRV Records
        │
        ▼
Validate External Resolution
        │
        ▼
Run DNS Diagnostics
        │
        ▼
DNS Validation Complete
```

> [!NOTE]
> Hostnames, IP addresses, domain names, and other environment-specific
> identifiers shown in this document have been sanitized for public release.


## DNS Architecture

The initial DNS environment consists of the DNS service hosted by the primary
domain controller.


```text
Active Directory
lab.example.com
        │
        ▼
   dc-lab-01
   10.0.0.10
        │
        ├── Active Directory Domain Services
        ├── DNS Server
        └── Global Catalog
```

The DNS server provides authoritative name resolution for the Active Directory
namespace.

The primary AD-integrated zones are represented as:

```text
lab.example.com
_msdcs.lab.example.com
```

These zones contain the host and service records used by Active Directory
clients and domain controllers.


## DNS and Active Directory

Active Directory depends heavily on DNS.

DNS is used not only for resolving server names to IP addresses, but also for
locating Active Directory services.

Domain members use DNS records to discover services including:

```text
Domain Controllers
LDAP
Kerberos
Global Catalog
```

For example, Active Directory domain controller discovery uses SRV records
under paths such as:

```text
_ldap._tcp.dc._msdcs.lab.example.com
```

Because of this dependency, domain members should use the Active Directory DNS
servers rather than public or router-provided DNS servers for normal DNS
resolution.

External DNS resolution can still be provided through the DNS server using
forwarding or recursive resolution.


## Validate DNS Role

Verify that the DNS Server role is installed:

```powershell
Get-WindowsFeature DNS
```

Expected state:

```text
Installed
```

The Active Directory Domain Services role can also be verified at the same
time:

```powershell
Get-WindowsFeature AD-Domain-Services,DNS
```

Both roles should report:

```text
Install State: Installed
```


## Validate DNS Service

Verify that the Windows DNS Server service is running:

```powershell
Get-Service DNS
```

Expected status:

```text
Status   Name   DisplayName
------   ----   -----------
Running  DNS    DNS Server
```

A running DNS service confirms that the server is actively providing DNS
services.


## Validate AD-Integrated DNS Zones

Display the DNS zones hosted by the server:

```powershell
Get-DnsServerZone
```

The Active Directory deployment should include the domain zone and the
forest-wide `_msdcs` zone.

```text
_msdcs.lab.example.com
lab.example.com
```

The Active Directory zones should report:

```text
ZoneType        : Primary
IsDsIntegrated  : True
```

`IsDsIntegrated` confirms that the DNS zone is stored within Active Directory
rather than in a standalone DNS zone file.

This allows DNS information to participate in Active Directory replication
when additional DNS-enabled domain controllers are deployed.


## Validate DNS Client Configuration

A domain controller should use Active Directory-aware DNS rather than a public
DNS server or router DNS service.

Display the configured IPv4 DNS servers:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

After the initial domain controller is established, its DNS client
configuration should reference the Active Directory DNS service.

A single-domain-controller environment may initially reference the local DNS
service.

Example:

```text
127.0.0.1
```

Public DNS servers should not be configured directly on the domain
controller's network adapter.

External resolution should instead occur through the DNS Server service.


## Validate Domain Controller Host Record

Verify that the domain controller registered its DNS host record:

```powershell
Resolve-DnsName dc-lab-01.lab.example.com
```

Expected IPv4 result:

```text
Name                           Type   IPAddress
----                           ----   ---------
dc-lab-01.lab.example.com      A      10.0.0.10
```

Successful resolution confirms that the domain controller's host record is
available through the Active Directory DNS infrastructure.


## Validate Active Directory SRV Records

Active Directory registers SRV records that allow clients to discover
directory services.

### LDAP Domain Controller Discovery

Query the LDAP domain controller SRV records:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com
```

The result should identify the domain controller as an LDAP service endpoint.


```text
NameTarget : dc-lab-01.lab.example.com
Port       : 389
```

This confirms that clients can use DNS to locate a domain controller providing
LDAP services.


### Kerberos Service Discovery

Kerberos authentication also depends on DNS SRV records.

Query the Kerberos service records:

```powershell
Resolve-DnsName -Type SRV _kerberos._tcp.dc._msdcs.lab.example.com
```

The result should identify the domain controller as a Kerberos service
endpoint.

The standard Kerberos service port is:

```text
88
```


## Validate External DNS Resolution

Active Directory clients also require normal Internet DNS resolution.

Test an external domain:

```powershell
Resolve-DnsName microsoft.com
```

Successful resolution confirms that the DNS server can resolve names outside
the internal Active Directory namespace.

The resolution path is conceptually:

```text
Domain Client
      │
      ▼
AD DNS Server
      │
      ├── Internal AD namespace
      │       └── Answer locally
      │
      └── External namespace
              │
              ▼
        External Resolution
```


## Validate DNS Forwarders

Display the DNS server forwarder configuration:

```powershell
Get-DnsServerForwarder
```

Forwarders allow the Active Directory DNS server to send queries for external
names to an upstream DNS resolver.

The general resolution model is:

```text
Client
  │
  ▼
AD DNS
  │
  ├── lab.example.com
  │       └── Authoritative answer
  │
  └── External domain
          │
          ▼
      DNS Forwarder
          │
          ▼
       Internet DNS
```

> [!IMPORTANT]
> Domain clients should not bypass Active Directory DNS by configuring public
> DNS resolvers directly on their network adapters. Doing so can prevent
> reliable Active Directory domain and service discovery.


## Run Active Directory DNS Diagnostics

Windows Server includes DNS-specific Active Directory diagnostics through
`dcdiag`.

Run:

```powershell
dcdiag /test:dns /v
```

The diagnostic performs multiple DNS tests associated with the domain
controller.

Validation includes areas such as:

```text
Authentication
Basic DNS connectivity
DNS forwarding
Delegation
Dynamic updates
Record registration
Active Directory service records
```

The DNS summary should report successful results for the tested categories.

A healthy result is represented conceptually as:

```text
                     Auth  Basc  Forw  Del  Dyn  RReg
                     ----  ----  ----  ---  ---  ----
dc-lab-01            PASS  PASS  PASS  PASS PASS PASS
```

Successful completion confirms that the domain controller's DNS service is
supporting Active Directory correctly.


## Validate Dynamic DNS

Active Directory relies on dynamic DNS registration for many domain
controller and client records.

The DNS diagnostic can verify dynamic updates through:

```powershell
dcdiag /test:dns /v
```

Successful dynamic update testing confirms that DNS records can be registered
within the AD-integrated zone.

This functionality becomes increasingly important as additional domain
controllers and domain clients are introduced.


## DNS Validation Result

The primary domain controller DNS deployment was validated successfully.

The validated environment is represented as:

```text
dc-lab-01
10.0.0.10
     │
     ├── DNS Server                     ✓
     │
     ├── AD-Integrated DNS
     │     ├── lab.example.com          ✓
     │     └── _msdcs.lab.example.com  ✓
     │
     ├── Host Registration              ✓
     ├── LDAP SRV Registration          ✓
     ├── Kerberos SRV Registration      ✓
     ├── Dynamic DNS                    ✓
     └── External Resolution            ✓
```

At this stage, DNS is operating correctly as the name-resolution and service
discovery infrastructure for the Active Directory domain.


## DNS Redundancy

**Status: ⏳ In Progress**

The next stage of the DNS deployment introduces a second DNS-enabled domain
controller.

Target architecture:

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
              │                         │
              └──── AD Replication ─────┘
```

Because the DNS zones are AD-integrated, the Active Directory zones will
replicate to the additional domain controller as part of Active Directory
replication.

The zones should not be manually recreated on the second DNS server.

After the additional domain controller is deployed, validation will confirm:

```text
DNS Redundancy
├── AD-integrated zones replicated
├── Both domain controllers registered
├── LDAP SRV records include both DCs
├── Kerberos SRV records include both DCs
├── Both DNS servers resolve internal records
├── Both DNS servers resolve external records
└── DNS remains available during single-DC failure
```

Detailed deployment and promotion of the additional domain controller is
documented separately.


## Deployment Status

| Stage | Status |
|---|---|
| DNS Server Role | ✅ Complete |
| DNS Service Validation | ✅ Complete |
| AD-Integrated Domain Zone | ✅ Complete |
| `_msdcs` Zone | ✅ Complete |
| Domain Controller Host Record | ✅ Complete |
| LDAP SRV Records | ✅ Complete |
| Kerberos SRV Records | ✅ Complete |
| Dynamic DNS Validation | ✅ Complete |
| External DNS Resolution | ✅ Complete |
| DNS Diagnostics | ✅ Complete |
| Secondary DNS Server | ⏳ In Progress |
| DNS Replication Validation | ⚪ Pending |
| DNS Redundancy Testing | ⚪ Pending |
