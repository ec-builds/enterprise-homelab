# Additional Domain Controller Validation

## Overview

This document provides a validation procedure for an additional Windows Server 2025 domain controller after promotion into an existing Active Directory domain.

The checks verify that:

- The additional domain controller is discoverable in Active Directory
- The server is operating as a Global Catalog when intended
- Active Directory replication functions in both directions
- Domain, Configuration, and Schema partitions replicate successfully
- AD-integrated DNS partitions replicate successfully
- SYSVOL and NETLOGON are available
- DNS service and records are available
- LDAP and Kerberos records advertise both domain controllers

Two levels of validation are provided:

- **Quick Validation** — Practical minimum checks for routine post-promotion validation
- **Extended Validation** — More detailed checks useful for initial deployment, troubleshooting, documentation, and hands-on learning

> [!NOTE]
> The extended validation procedure is intentionally more thorough than normally required for routine administration. These checks are useful during the initial lab deployment because they expose the individual Active Directory components that broader diagnostic tools validate automatically.

## Example Environment

| Component | Value |
|---|---|
| Operating System | Windows Server 2025 |
| Domain | `lab.example.com` |
| Existing Domain Controller | `dc-lab-01` |
| Additional Domain Controller | `dc-lab-02` |
| Existing DC IPv4 | `10.0.0.10` |
| Additional DC IPv4 | `10.0.0.11` |
| AD Site | `Default-First-Site-Name` |
| Roles | AD DS, DNS |
| Global Catalog | Enabled |

> [!NOTE]
> Hostnames, domain names, and IP addresses in this document are sanitized example values and should be adjusted to match the deployment environment.

## Quick Validation

For routine validation after promoting an additional domain controller, the following commands provide a practical minimum set of checks.

Confirm that Active Directory recognizes both domain controllers:

```powershell
Get-ADDomainController -Filter * |
Select-Object HostName,IPv4Address,Site,IsGlobalCatalog
```

Check replication health:

```powershell
repadmin /replsummary
```

Run the standard domain controller diagnostic:

```powershell
dcdiag
```

Run the DNS diagnostic:

```powershell
dcdiag /test:dns
```

Confirm that:

- Both domain controllers are discovered
- The additional domain controller has the expected IP address
- Global Catalog status is correct
- Replication reports zero failures
- Domain controller diagnostics pass
- DNS diagnostics pass

> [!NOTE]
> The remainder of this document provides extended validation. Running every command is generally unnecessary for routine domain controller health checks. The additional commands are good practice during initial deployment and are useful for troubleshooting, research, documentation, and learning Active Directory replication behavior.

## Extended Validation

### Validate Domain Controller Discovery

Run:

```powershell
Get-ADDomainController -Filter * |
Select-Object HostName,IPv4Address,Site,IsGlobalCatalog
```

Example:

```text
HostName                  IPv4Address   Site                     IsGlobalCatalog
--------                  -----------   ----                     ---------------
dc-lab-01.lab.example.com 10.0.0.10    Default-First-Site-Name True
dc-lab-02.lab.example.com 10.0.0.11    Default-First-Site-Name True
```

Verify:

- Both domain controllers are returned
- IP addresses are correct
- Both servers belong to the expected Active Directory site
- Global Catalog status matches the intended design

In a typical small two-domain-controller environment, both domain controllers can operate as Global Catalog servers.

### Validate Replication Summary

Run:

```powershell
repadmin /replsummary
```

After replication has initialized, both domain controllers should appear as replication sources and destinations.

Example:

```text
Source DSA          largest delta    fails/total
dc-lab-01                         0 / 5
dc-lab-02                         0 / 5

Destination DSA     largest delta    fails/total
dc-lab-01                         0 / 5
dc-lab-02                         0 / 5
```

The important result is:

```text
0 replication failures
```

This confirms that replication is functioning in both directions.

### Validate Detailed Replication

On the additional domain controller:

```powershell
repadmin /showrepl
```

Verify successful inbound replication from the existing domain controller.

The following naming contexts should normally appear:

```text
Domain
Configuration
Schema
DomainDnsZones
ForestDnsZones
```

Each should report a successful replication attempt:

```text
Last attempt ... was successful.
```

### Validate Replication from the Existing Domain Controller

From the additional domain controller, inspect the existing domain controller:

```powershell
repadmin /showrepl dc-lab-01
```

This verifies that the existing domain controller is also receiving replication from the additional domain controller.

Successful results for both servers establish bidirectional replication:

```text
dc-lab-01
     │
     │ AD Replication
     ▼
dc-lab-02

dc-lab-01
     ▲
     │ AD Replication
     │
dc-lab-02
```

### Validate Active Directory Naming Contexts

Detailed replication should confirm successful replication of the major Active Directory partitions.

#### Domain Partition

Contains domain-specific objects such as:

- Users
- Computers
- Groups
- Organizational Units

Example:

```text
DC=lab,DC=example,DC=com
```

#### Configuration Partition

Contains forest-wide configuration information including sites, services, and replication topology.

Example:

```text
CN=Configuration,DC=lab,DC=example,DC=com
```

#### Schema Partition

Contains Active Directory object and attribute definitions.

Example:

```text
CN=Schema,CN=Configuration,DC=lab,DC=example,DC=com
```

#### Domain DNS Partition

Contains domain-scoped AD-integrated DNS data.

Example:

```text
DC=DomainDnsZones,DC=lab,DC=example,DC=com
```

#### Forest DNS Partition

Contains forest-scoped AD-integrated DNS data.

Example:

```text
DC=ForestDnsZones,DC=lab,DC=example,DC=com
```

Successful replication of both DNS partitions confirms that AD-integrated DNS data is participating in Active Directory replication.

### Validate SYSVOL and NETLOGON

Verify that the additional domain controller publishes the required shares:

```powershell
Get-SmbShare -Name SYSVOL,NETLOGON
```

Expected:

```text
Name
-------
NETLOGON
SYSVOL
```

These shares are important for domain functionality.

`SYSVOL` contains domain-wide files such as Group Policy data.

`NETLOGON` provides the domain logon script share and is part of normal domain controller operation.

Both should be available after successful domain controller promotion and SYSVOL initialization.

### Validate DNS Service

If the additional domain controller also hosts DNS, verify that the service is running:

```powershell
Get-Service DNS
```

Expected:

```text
Status   Name
------   ----
Running  DNS
```

### Validate AD-Integrated DNS Zones

Run:

```powershell
Get-DnsServerZone
```

Verify that the expected Active Directory zones were replicated to the additional domain controller.

Example:

```text
ZoneName                    ZoneType   IsDsIntegrated
--------                    --------   --------------
_msdcs.lab.example.com      Primary    True
lab.example.com             Primary    True
```

The zones should not need to be manually recreated on the additional domain controller.

AD-integrated DNS data is replicated through Active Directory.

### Validate Domain Controller Host Records

Query the additional DNS server directly for both domain controllers:

```powershell
Resolve-DnsName dc-lab-01.lab.example.com -Server 10.0.0.11
Resolve-DnsName dc-lab-02.lab.example.com -Server 10.0.0.11
```

Expected:

```text
dc-lab-01.lab.example.com → 10.0.0.10
dc-lab-02.lab.example.com → 10.0.0.11
```

This verifies that the additional DNS server can independently serve records for both domain controllers.

### Validate LDAP SRV Registration

Query the additional DNS server:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com -Server 10.0.0.11
```

Both domain controllers should normally appear.

Example:

```text
dc-lab-01.lab.example.com    Port 389
dc-lab-02.lab.example.com    Port 389
```

These records allow Active Directory clients to discover domain controllers providing LDAP services.

### Validate Kerberos SRV Registration

Run:

```powershell
Resolve-DnsName -Type SRV _kerberos._tcp.dc._msdcs.lab.example.com -Server 10.0.0.11
```

Both domain controllers should normally appear.

Example:

```text
dc-lab-01.lab.example.com    Port 88
dc-lab-02.lab.example.com    Port 88
```

This verifies that both domain controllers are advertised for Kerberos authentication.

### Validate External DNS Resolution

If the additional domain controller provides DNS, verify external resolution through that specific DNS server:

```powershell
Resolve-DnsName microsoft.com -Server 10.0.0.11
```

Successful A and/or AAAA responses confirm that external DNS resolution is functioning through the additional DNS server.

### Run Detailed DNS Diagnostics

Run:

```powershell
dcdiag /test:dns /v
```

Review the DNS summary.

A healthy result should normally show:

```text
Auth    PASS
Basc    PASS
Forw    PASS
Del     PASS
Dyn     PASS
RReg    PASS
```

The diagnostic verifies functionality including:

- Authentication
- DNS Server service
- DNS client configuration
- AD-integrated zones
- DNS forwarders
- Delegations
- Secure dynamic updates
- Domain controller A records
- LDAP SRV records
- Kerberos SRV records
- Global Catalog records
- DNS record registration

The domain should conclude with:

```text
passed test DNS
```

## Full Domain Controller Diagnostic

After the targeted replication and DNS checks have succeeded, run the broader domain controller diagnostic:

```powershell
dcdiag
```

This checks additional domain controller components beyond DNS.

Review the results for unexpected failures or warnings.

For routine administration, this command can also serve as one of the primary high-level domain controller health checks.

## Validation Workflow

A thorough initial validation can follow this sequence:

```text
Domain Controller Discovery
        │
        ▼
Replication Summary
        │
        ▼
Detailed Inbound Replication
        │
        ▼
Bidirectional Replication
        │
        ▼
Domain / Configuration / Schema
        │
        ▼
DomainDnsZones / ForestDnsZones
        │
        ▼
SYSVOL / NETLOGON
        │
        ▼
DNS Service
        │
        ▼
AD-Integrated DNS Zones
        │
        ▼
DC Host Records
        │
        ▼
LDAP / Kerberos SRV Records
        │
        ▼
External DNS Resolution
        │
        ▼
DNS Diagnostics
        │
        ▼
Domain Controller Diagnostics
```

For routine administration, the shorter workflow is generally sufficient:

```text
Get-ADDomainController
        │
        ▼
repadmin /replsummary
        │
        ▼
dcdiag
        │
        ▼
dcdiag /test:dns
```

If one of these higher-level checks reports a problem, the extended procedure can be used to isolate the affected Active Directory component.

## Validation Checklist

### Routine Validation

- [ ] Both domain controllers are discoverable
- [ ] Expected Global Catalog status is confirmed
- [ ] `repadmin /replsummary` reports zero failures
- [ ] `dcdiag` reports no significant failures
- [ ] `dcdiag /test:dns` passes

### Extended Replication Validation

- [ ] Existing domain controller replicates to additional domain controller
- [ ] Additional domain controller replicates to existing domain controller
- [ ] Domain partition replication succeeds
- [ ] Configuration partition replication succeeds
- [ ] Schema partition replication succeeds
- [ ] `DomainDnsZones` replication succeeds
- [ ] `ForestDnsZones` replication succeeds

### Domain Controller Services

- [ ] SYSVOL share is available
- [ ] NETLOGON share is available
- [ ] Global Catalog is enabled when intended

### DNS Validation

- [ ] DNS Server service is running
- [ ] Domain DNS zone is available
- [ ] `_msdcs` zone is available
- [ ] AD DNS zones are directory integrated
- [ ] Both domain controller A records resolve
- [ ] LDAP SRV records advertise both domain controllers
- [ ] Kerberos SRV records advertise both domain controllers
- [ ] Dynamic DNS registration succeeds
- [ ] External DNS resolution succeeds
- [ ] Detailed DNS diagnostics pass

## Validation Complete

The additional domain controller can be considered successfully validated when:

- Active Directory discovers both domain controllers
- Replication functions successfully in both directions
- All required Active Directory naming contexts replicate
- SYSVOL and NETLOGON are available
- AD-integrated DNS data is available on the additional domain controller
- Both domain controllers are advertised through Active Directory DNS
- Domain controller and DNS diagnostics complete without significant failures

The extended validation procedure does not need to be performed for every routine health check. Its primary value is during initial deployment, significant infrastructure changes, troubleshooting, documentation, and hands-on study of Active Directory replication and redundancy.
