# Windows Server DNS Validation

## Overview

This document provides a validation procedure for DNS running on a Windows Server 2025 domain controller.

The checks verify that:

- The DNS Server role is installed and running
- Active Directory-integrated DNS zones are available
- The domain controller is configured to use internal DNS
- Domain controller DNS records are registered
- Active Directory service records are available
- Dynamic DNS updates function correctly
- External DNS resolution functions through the configured forwarder
- Multiple DNS servers contain and serve the expected Active Directory records

Two levels of validation are provided:

- **Quick Validation** — Practical minimum checks for routine administration
- **Extended Validation** — More detailed checks for initial deployment, troubleshooting, infrastructure changes, documentation, and hands-on learning

> [!NOTE]
> The extended validation procedure is intentionally more thorough than normally required for routine DNS administration. These checks are useful for understanding the individual DNS components that higher-level diagnostic tools validate automatically.

## Example Environment

| Component | Value |
|---|---|
| Operating System | Windows Server 2025 |
| Primary Server | `dc-lab-01` |
| Additional Server | `dc-lab-02` |
| Domain | `lab.example.com` |
| Primary Server IPv4 | `10.0.0.10` |
| Additional Server IPv4 | `10.0.0.11` |
| Gateway | `10.0.0.1` |
| Roles | AD DS, DNS |

> [!NOTE]
> Hostnames, domain names, and IP addresses in this document are sanitized example values and should be adjusted to match the deployment environment.

## Quick Validation

For routine administration, the following commands provide a practical minimum validation of DNS on an Active Directory domain controller.

Verify that the DNS Server service is running:

```powershell
Get-Service DNS
```

Verify that the expected DNS zones are available:

```powershell
Get-DnsServerZone
```

Run the built-in Active Directory DNS diagnostic:

```powershell
dcdiag /test:dns
```

Confirm that:

- The DNS Server service is running
- The expected Active Directory-integrated zones are present
- The domain and `_msdcs` zones are available
- `dcdiag /test:dns` completes without DNS test failures

In a multi-domain-controller environment, also verify that the expected domain controllers are advertised through DNS:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com
```

Both domain controllers should normally appear in the response.

> [!NOTE]
> The remainder of this document provides extended validation. Running every command is generally unnecessary for routine DNS health checks. The additional checks are good practice during initial deployment and are useful for troubleshooting, documentation, research, and learning how Active Directory DNS operates.

## Extended Validation

### Validate Installed Roles

Confirm that Active Directory Domain Services and DNS Server are installed:

```powershell
Get-WindowsFeature AD-Domain-Services,DNS
```

Expected state:

```text
[X] Active Directory Domain Services    Installed
[X] DNS Server                          Installed
```

### Validate the DNS Service

Verify that the DNS Server service is running:

```powershell
Get-Service DNS
```

Expected result:

```text
Status   Name   DisplayName
------   ----   -----------
Running  DNS    DNS Server
```

### Validate DNS Zones

Display the zones hosted by the DNS server:

```powershell
Get-DnsServerZone
```

For an Active Directory-integrated deployment, verify that the domain and `_msdcs` zones exist and are directory integrated.

Example:

```text
ZoneName                    ZoneType   IsDsIntegrated
--------                    --------   --------------
_msdcs.lab.example.com      Primary    True
lab.example.com             Primary    True
```

The following zones may also exist automatically:

```text
0.in-addr.arpa
127.in-addr.arpa
255.in-addr.arpa
TrustAnchors
```

The Active Directory domain zone should normally support secure dynamic updates:

```text
DynamicUpdate : Secure
```

AD-integrated DNS zones replicate through Active Directory rather than requiring traditional primary-to-secondary DNS zone transfers between domain controllers.

### Validate DNS Client Configuration

Check which DNS servers the domain controller itself is configured to use:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

A domain controller should use internal Active Directory DNS servers rather than public DNS resolvers.

In a single-domain-controller deployment, the local DNS service may be configured through the loopback address:

```text
127.0.0.1
```

When additional domain controllers are deployed, DNS client configuration should be reviewed as part of the redundant DNS design.

Public DNS resolvers should not be configured directly on the network adapters of Active Directory domain controllers.

External DNS resolution should instead be handled by the DNS Server service through configured forwarders or root hints.

### Run the Active Directory DNS Diagnostic

Run the detailed built-in domain controller DNS test:

```powershell
dcdiag /test:dns /v
```

Review the output for the following tests:

```text
Authentication       PASS
Basic                PASS
Forwarders           PASS
Delegations          PASS
Dynamic Update       PASS
Records Registration PASS
```

Example summary:

```text
Domain: lab.example.com
   dc-lab-01    PASS PASS PASS PASS PASS PASS n/a

lab.example.com passed test DNS
```

The diagnostic validates important Active Directory DNS functionality including:

- DNS service availability
- DNS client configuration
- Active Directory zone availability
- Domain controller host records
- LDAP SRV records
- Kerberos SRV records
- Global Catalog records
- Dynamic record registration
- DNS delegation
- Forwarding and recursion

A successful dynamic update test also confirms that the diagnostic record can be created and removed from the Active Directory DNS zone.

### Validate Domain Controller Resolution

Confirm that the domain controller's FQDN resolves:

```powershell
Resolve-DnsName dc-lab-01.lab.example.com
```

Expected IPv4 result:

```text
dc-lab-01.lab.example.com    A    10.0.0.10
```

For an additional domain controller:

```powershell
Resolve-DnsName dc-lab-02.lab.example.com
```

Expected IPv4 result:

```text
dc-lab-02.lab.example.com    A    10.0.0.11
```

IPv6 records may also be returned when IPv6 is enabled.

The presence of an AAAA record does not by itself indicate that routed IPv6 connectivity is available. DNS record availability and IPv6 network connectivity are separate functions.

### Validate LDAP SRV Records

Query the DNS records used by clients to locate domain controllers for LDAP:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com
```

In a two-domain-controller deployment, the response should normally advertise both domain controllers.

Example:

```text
NameTarget : dc-lab-01.lab.example.com
Port       : 389

NameTarget : dc-lab-02.lab.example.com
Port       : 389
```

Active Directory clients use these records to discover domain controllers providing LDAP services.

### Validate Kerberos SRV Records

Verify that domain controllers are advertised for Kerberos authentication:

```powershell
Resolve-DnsName -Type SRV _kerberos._tcp.dc._msdcs.lab.example.com
```

In a two-domain-controller deployment, both domain controllers should normally appear.

Example:

```text
NameTarget : dc-lab-01.lab.example.com
Port       : 88

NameTarget : dc-lab-02.lab.example.com
Port       : 88
```

Successful LDAP and Kerberos SRV registration confirms that DNS is advertising the domain controllers for directory and authentication services.

### Validate External DNS Resolution

Verify that the DNS server can resolve a public hostname:

```powershell
Resolve-DnsName microsoft.com
```

A successful response containing public A and/or AAAA records confirms that external name resolution is functioning.

The general resolution path is:

```text
Domain Client
     │
     ▼
AD DNS Server
     │
     ├── lab.example.com → Resolved internally
     │
     └── External domain
              │
              ▼
        Forwarder / Root Hints
```

### Validate DNS Forwarders

Review the forwarders configured on the DNS server:

```powershell
Get-DnsServerForwarder
```

Verify that each configured forwarder is:

- Intentional
- Reachable
- Appropriate for the current network design

Remove obsolete forwarders left behind by previous network configurations.

Forwarders are configured on the DNS Server service and are separate from the DNS servers configured on the server's network adapter.

## Multi-Domain-Controller Validation

When multiple domain controllers also provide DNS, validate each DNS server independently.

### Validate Records Through a Specific DNS Server

Query the primary domain controller through the additional DNS server:

```powershell
Resolve-DnsName dc-lab-01.lab.example.com -Server 10.0.0.11
```

Expected:

```text
dc-lab-01.lab.example.com    A    10.0.0.10
```

Query the additional domain controller through the same DNS server:

```powershell
Resolve-DnsName dc-lab-02.lab.example.com -Server 10.0.0.11
```

Expected:

```text
dc-lab-02.lab.example.com    A    10.0.0.11
```

Repeat the tests against the other DNS server:

```powershell
Resolve-DnsName dc-lab-01.lab.example.com -Server 10.0.0.10
Resolve-DnsName dc-lab-02.lab.example.com -Server 10.0.0.10
```

Using the `-Server` parameter is useful because it tests a specific DNS server rather than relying on the operating system to select a resolver.

This helps distinguish:

```text
Can the client resolve the record?
```

from:

```text
Does this specific DNS server contain and serve the record?
```

### Validate LDAP Records Through a Specific DNS Server

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com -Server 10.0.0.11
```

Both domain controllers should normally be returned.

Repeat against the other DNS server:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com -Server 10.0.0.10
```

### Validate Kerberos Records Through a Specific DNS Server

```powershell
Resolve-DnsName -Type SRV _kerberos._tcp.dc._msdcs.lab.example.com -Server 10.0.0.11
```

Repeat against the other DNS server:

```powershell
Resolve-DnsName -Type SRV _kerberos._tcp.dc._msdcs.lab.example.com -Server 10.0.0.10
```

Both DNS servers should advertise the expected domain controllers.

### Validate External Resolution Through Each DNS Server

```powershell
Resolve-DnsName microsoft.com -Server 10.0.0.10
Resolve-DnsName microsoft.com -Server 10.0.0.11
```

Both DNS servers should successfully resolve the external hostname.

### Validate AD-Integrated DNS Replication

Because the DNS zones are Active Directory-integrated, DNS data should replicate through Active Directory rather than being manually recreated on each domain controller.

Useful replication checks include:

```powershell
repadmin /replsummary
```

For detailed troubleshooting:

```powershell
repadmin /showrepl
```

Verify successful replication of:

```text
DomainDnsZones
ForestDnsZones
```

These checks are primarily Active Directory replication diagnostics but are useful when troubleshooting AD-integrated DNS replication.

## Extended Validation Workflow

A thorough initial DNS validation can follow this sequence:

```text
DNS Role
   │
   ▼
DNS Service
   │
   ▼
AD-Integrated Zones
   │
   ▼
DNS Client Configuration
   │
   ▼
Domain Controller A Records
   │
   ▼
LDAP SRV Records
   │
   ▼
Kerberos SRV Records
   │
   ▼
Cross-Server DNS Queries
   │
   ▼
External Resolution
   │
   ▼
Forwarders
   │
   ▼
dcdiag DNS Validation
```

For routine administration, the shorter workflow is generally sufficient:

```text
DNS Service
   │
   ▼
DNS Zones
   │
   ▼
dcdiag /test:dns
   │
   ▼
LDAP SRV Discovery
```

If one of these higher-level checks reports a problem, the extended validation procedure can be used to isolate the affected DNS component.

## Validation Checklist

### Routine Validation

- [ ] DNS Server service is running
- [ ] Expected AD-integrated DNS zones exist
- [ ] `dcdiag /test:dns` passes
- [ ] Expected domain controllers are advertised through LDAP SRV records

### Extended Validation

- [ ] AD DS and DNS roles are installed
- [ ] DNS Server service is running
- [ ] Domain DNS zone exists
- [ ] `_msdcs` DNS zone exists
- [ ] AD DNS zones are directory integrated
- [ ] Secure dynamic updates are enabled
- [ ] Domain controller uses internal DNS
- [ ] Domain controller FQDN resolves
- [ ] LDAP SRV records resolve
- [ ] Kerberos SRV records resolve
- [ ] Dynamic DNS registration succeeds
- [ ] External DNS names resolve
- [ ] DNS forwarders are valid
- [ ] `dcdiag /test:dns /v` passes

### Multi-Domain-Controller Validation

- [ ] DNS zones are available on each DNS server
- [ ] Each domain controller has the expected A record
- [ ] Each DNS server resolves records for the other domain controller
- [ ] LDAP SRV records advertise all expected domain controllers
- [ ] Kerberos SRV records advertise all expected domain controllers
- [ ] External resolution succeeds through each DNS server
- [ ] `DomainDnsZones` replication succeeds
- [ ] `ForestDnsZones` replication succeeds
- [ ] DNS client configuration provides redundant internal DNS resolution

## Validation Complete

DNS validation is complete when the required routine checks pass and any deployment-specific extended checks have been verified.

The extended procedure does not need to be repeated for every routine health check. Its primary value is during initial deployment, major infrastructure changes, troubleshooting, documentation, and hands-on study of Active Directory DNS.
