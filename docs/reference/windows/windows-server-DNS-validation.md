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

## Example Environment

| Component | Value |
|---|---|
| Operating System | Windows Server 2025 |
| Server | `dc-lab-01` |
| Domain | `lab.example.com` |
| IPv4 Address | `10.0.0.10` |
| Gateway | `10.0.0.1` |
| Roles | AD DS, DNS |

> [!NOTE]
> Hostnames, domain names, and IP addresses in this document are sanitized example values and should be adjusted to match the deployment environment.

## Validate Installed Roles

Confirm that Active Directory Domain Services and DNS Server are installed:

```powershell
Get-WindowsFeature AD-Domain-Services,DNS
```

Expected state:

```text
[X] Active Directory Domain Services    Installed
[X] DNS Server                          Installed
```

## Validate the DNS Service

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

## Validate DNS Zones

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

## Validate DNS Client Configuration

Check which DNS servers the domain controller itself is configured to use:

```powershell
Get-DnsClientServerAddress -AddressFamily IPv4
```

A domain controller should use an internal Active Directory DNS server rather than a public DNS resolver.

In a single-domain-controller deployment, the local DNS service may be configured through the loopback address:

```text
127.0.0.1
```

When additional domain controllers are deployed, DNS client configuration should be reviewed as part of the redundant DNS design.

## Run the Active Directory DNS Diagnostic

Run the built-in domain controller DNS test:

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

The final summary should report that the domain controller and domain passed the DNS test.

Example:

```text
Domain: lab.example.com
   dc-lab-01    PASS PASS PASS PASS PASS PASS n/a

lab.example.com passed test DNS
```

The diagnostic also validates important Active Directory DNS functionality, including:

- DNS service availability
- Domain controller host records
- LDAP SRV records
- Kerberos SRV records
- Global Catalog records
- Dynamic record registration
- DNS delegation
- Forwarding and recursion

## Validate Domain Controller Resolution

Confirm that the domain controller's FQDN resolves:

```powershell
Resolve-DnsName dc-lab-01.lab.example.com
```

Expected IPv4 result:

```text
dc-lab-01.lab.example.com    A    10.0.0.10
```

IPv6 records may also be returned when IPv6 is enabled.

## Validate Active Directory SRV Records

Query the DNS records used by clients to locate domain controllers:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com
```

The response should identify an available domain controller.

Example:

```text
NameTarget    : dc-lab-01.lab.example.com
Port          : 389
```

These SRV records are critical because Active Directory clients use DNS service records to discover services such as LDAP and Kerberos.

## Validate External DNS Resolution

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
dc-lab-01
     │
     ├── lab.example.com → resolved internally
     │
     └── External domain → DNS forwarder / recursion
```

## Validation Checklist

DNS validation is complete when:

- [ ] AD DS and DNS roles are installed
- [ ] DNS Server service is running
- [ ] Domain DNS zone exists
- [ ] `_msdcs` DNS zone exists
- [ ] AD DNS zones are directory integrated
- [ ] Domain controller uses internal DNS
- [ ] `dcdiag /test:dns /v` passes
- [ ] Domain controller FQDN resolves
- [ ] Active Directory LDAP SRV record resolves
- [ ] Dynamic DNS registration succeeds
- [ ] External DNS names resolve

## Multi-Domain-Controller Considerations

After deploying an additional domain controller such as `dc-lab-02`, repeat the validation procedure on both servers.

Because the DNS zones are Active Directory-integrated, zone data should replicate through Active Directory rather than being manually recreated on the second DNS server.

Additional validation should include:

- AD replication between domain controllers
- DNS zone replication
- DNS records for both domain controllers
- SRV records advertising both domain controllers
- DNS client configuration using redundant internal DNS servers
- Name resolution when either DNS server is unavailable
