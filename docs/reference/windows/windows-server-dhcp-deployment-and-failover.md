# Windows Server DHCP Deployment and Failover

## Overview

This document provides a reusable deployment and configuration reference for implementing Windows Server DHCP with two Active Directory domain controllers.

The deployment includes:

- DHCP Server role installation
- Active Directory authorization
- IPv4 scope creation
- DHCP scope options
- Active Directory DNS configuration for DHCP clients
- DHCP failover
- Load-balanced DHCP services
- Failover message authentication
- Configuration validation

The example environment uses sanitized hostnames, domain names, and IP addresses. Values should be adapted to the target environment.


## Example Environment

| Component | Example |
|---|---|
| Domain | `lab.example.com` |
| DHCP Server 1 | `dc-lab-01.lab.example.com` |
| DHCP Server 2 | `dc-lab-02.lab.example.com` |
| Network | `10.0.0.0/24` |
| Default Gateway | `10.0.0.1` |
| DNS Server 1 | `10.0.0.10` |
| DNS Server 2 | `10.0.0.11` |
| DHCP Range | `10.0.0.100–10.0.0.199` |
| Lease Duration | 3 days |
| Failover Mode | Load Balance |
| Load Balance | 50/50 |


## Prerequisites

Before deploying DHCP:

- Active Directory Domain Services should be operational.
- DNS should be operational and resolving the domain correctly.
- Both DHCP servers should have static IP configurations.
- Administrative credentials with permission to authorize DHCP servers in Active Directory should be available.
- The intended DHCP address range should not overlap statically assigned infrastructure addresses.
- Any existing DHCP service should remain active until the new Windows DHCP environment has been configured and validated.

> [!IMPORTANT]
> Do not activate competing DHCP services on the same broadcast domain during deployment. If an existing router or DHCP server is providing addresses, leave the Windows DHCP scope inactive until a controlled cutover is performed.


# Install the DHCP Server Role

Open **Server Manager** and select:

**Manage → Add Roles and Features**

Proceed through the wizard and select:

**DHCP Server**

Accept the required management tools and complete the installation.

Repeat the role installation on the second DHCP server.

<!-- IMAGE: AD-add-DHCP.png -->


## Complete DHCP Post-Install Configuration

After installation, Server Manager displays a DHCP post-deployment configuration notification.

Select:

**Complete DHCP configuration**

<!-- IMAGE: DHCP-config-wizard.png -->

The post-install wizard creates the local DHCP security groups and provides the option to authorize the server in Active Directory.


## Authorize DHCP in Active Directory

Use an account with sufficient Active Directory permissions to authorize the DHCP server.

Complete the authorization process for each DHCP server.

<!-- IMAGE: DHCP-authorize.png -->

Authorization prevents unauthorized Windows DHCP servers from servicing domain-connected networks.

The authorized DHCP servers can be verified with PowerShell:

```powershell
Get-DhcpServerInDC
```

Expected output should contain both authorized servers:

```text
IPAddress    DnsName
---------    -------
10.0.0.10    dc-lab-01.lab.example.com
10.0.0.11    dc-lab-02.lab.example.com
```

> [!NOTE]
> Do not include administrative usernames or other credential information in public deployment documentation.


# Create the IPv4 Scope

Open:

**Server Manager → Tools → DHCP**

Expand the first DHCP server and right-click:

**IPv4 → New Scope**

<!-- IMAGE: DHCP-new-scope.png -->


## Define the Scope

Provide a descriptive name for the network.

Example:

```text
Name: LAN
Description: Primary LAN DHCP scope
```

<!-- IMAGE: dhcp-new-scope-2.png -->


## Configure the Address Range

Configure the IPv4 allocation range.

Example:

```text
Start IP address: 10.0.0.100
End IP address:   10.0.0.199
Subnet mask:      255.255.255.0
Prefix length:    /24
```

<!-- IMAGE: dhcp-scope-range.png -->

Keep infrastructure addresses outside the dynamic allocation range where practical.

For example:

```text
10.0.0.1      Default gateway
10.0.0.10     Domain Controller / DNS
10.0.0.11     Domain Controller / DNS

10.0.0.100
     ↓         DHCP allocation range
10.0.0.199
```


## Configure Exclusions

Add exclusions when addresses located inside the scope range must never be dynamically assigned.

<!-- IMAGE: dhcp-exclusions.png -->

If all infrastructure addresses are already outside the DHCP range, exclusions may not be necessary.


## Configure Lease Duration

Configure the desired DHCP lease duration.

Example:

```text
3 days
```

<!-- IMAGE: dhcp-lease-duration.png -->

Lease duration should be selected based on network size, client turnover, and operational requirements.


# Configure DHCP Scope Options

Configure the scope options during scope creation or afterward through DHCP Manager.

<!-- IMAGE: dhcp-options.png -->


## Option 003 - Router

Configure the default gateway distributed to DHCP clients.

Example:

```text
10.0.0.1
```

<!-- IMAGE: dhcp-router-default-gateway.png -->


## Option 006 - DNS Servers

For an Active Directory environment, DHCP clients should receive the DNS servers hosting the Active Directory DNS namespace.

Example:

```text
10.0.0.10
10.0.0.11
```

The preferred ordering can be selected according to the environment's DNS architecture.

> [!IMPORTANT]
> Domain-joined clients should use the Active Directory DNS servers rather than a router or public DNS resolver as their directly configured DNS servers.


## Option 015 - DNS Domain Name

Configure the Active Directory DNS domain.

Example:

```text
lab.example.com
```

<!-- IMAGE: dhcp-domain-name.png -->

The resulting core scope options are:

| DHCP Option | Configuration |
|---|---|
| 003 Router | `10.0.0.1` |
| 006 DNS Servers | `10.0.0.10`, `10.0.0.11` |
| 015 DNS Domain Name | `lab.example.com` |


## WINS

WINS configuration is not required unless the environment specifically depends on legacy NetBIOS name resolution.

Leave WINS configuration blank when it is not required.

<!-- IMAGE: dhcp-wins-server.png -->


# Keep the Scope Inactive During Deployment

If another DHCP service is currently servicing the network, do not activate the new Windows DHCP scope yet.

During the New Scope Wizard, select:

**No, I will activate this scope later**

<!-- IMAGE: dhcp-activate-scope.png -->

Complete the scope creation.

<!-- IMAGE: dhcp-finish.png -->

The scope can be verified with:

```powershell
Get-DhcpServerv4Scope
```

Before cutover, the expected state is:

```text
State : Inactive
```


# Configure DHCP Failover

Windows Server DHCP failover allows two DHCP servers to maintain synchronized lease and failover state information for an IPv4 scope.

The scope should be created on the first DHCP server. Do not manually create a duplicate scope on the second server.

The failover configuration process replicates the required scope configuration to the partner.


## Start the Failover Wizard

In DHCP Manager on the server containing the scope:

1. Expand **IPv4**.
2. Right-click the scope.
3. Select **Configure Failover**.
4. Select the scope to include.

<!-- IMAGE: dhcp-failover.png -->


## Select the Partner Server

Select the second authorized DHCP server as the failover partner.

Example:

```text
dc-lab-02.lab.example.com
```

If an authorized server does not immediately appear in the graphical server list, verify Active Directory authorization:

```powershell
Get-DhcpServerInDC
```

If the server is correctly authorized, its FQDN can be supplied directly to the failover wizard.


# Configure the Failover Relationship

Create a descriptive relationship name.

Example:

```text
DCLAB01-DCLAB02-LAN-DHCP
```

Configure the relationship according to the intended availability model.

Example configuration:

| Setting | Value |
|---|---|
| Mode | Load Balance |
| Load Balance | 50/50 |
| Maximum Client Lead Time | 1 hour |
| Automatic State Transition | Disabled |
| Message Authentication | Enabled |
| Shared Secret | Stored securely outside documentation |

<!-- IMAGE: dhcp-failover-config.png -->


## Load Balance Mode

Load Balance mode allows both DHCP servers to actively service clients.

A 50/50 configuration is appropriate when the two servers are equivalent peers and are expected to remain continuously available.

```text
                 DHCP Clients
                      │
               DHCP Requests
                ┌─────┴─────┐
                ▼           ▼
          dc-lab-01     dc-lab-02
              50%           50%
                │           │
                └─────┬─────┘
                      │
               Failover State
              Synchronization
```

Hot Standby is an alternative architecture in which one server primarily services clients while another provides standby capacity.


## Maximum Client Lead Time

The **Maximum Client Lead Time (MCLT)** controls how far one failover partner can extend a client's lease beyond the lease information known by the other partner.

Example:

```text
1 hour
```

MCLT is an important part of preventing conflicting lease ownership during failover and recovery.


## State Switchover Interval

When communication between DHCP failover partners is interrupted, the surviving server does not necessarily assume immediately that the partner has completely failed.

The relationship can initially enter a communication-interrupted condition.

Automatic state transition can be configured to move the relationship toward a partner-down state after a defined interval.

For an initial lab deployment, automatic state transition may be left disabled so failover states can be observed and controlled manually during testing.

This can later be enabled if automatic recovery is required.


## Message Authentication

Enable message authentication for the DHCP failover relationship.

Both DHCP servers use a shared secret to authenticate failover communications.

The shared secret should:

- Be unique to the DHCP failover service
- Be randomly generated
- Be stored in an appropriate password or secrets manager
- Never be committed to source control
- Never appear in screenshots or public documentation

Example documentation should record only:

```text
Message Authentication: Enabled
Shared Secret: Stored securely outside the repository
```

> [!IMPORTANT]
> Message authentication should not be interpreted as encryption of all DHCP failover traffic. Its purpose is to authenticate failover messages between the partner servers.


# Create the Failover Relationship

Review the configuration before completing the wizard.

<!-- IMAGE: dhcp-failover-relationship.png -->

Complete the failover configuration.

The wizard should:

- Create the failover relationship on the local server
- Create the relationship on the partner server
- Replicate the selected scope
- Configure the partner scope
- Establish failover synchronization

<!-- IMAGE: dhcp-failover-success.png -->


# Validate DHCP Failover

Validate the relationship from both DHCP servers.

Run:

```powershell
Get-DhcpServerv4Failover
```

A healthy relationship should report values similar to:

```text
Mode                : LoadBalance
LoadBalancePercent  : 50
MaxClientLeadTime   : 01:00:00
State               : Normal
AutoStateTransition : False
EnableAuth          : True
```

The most important operational state is:

```text
State : Normal
```


## Validate the Replicated Scope

Run on both DHCP servers:

```powershell
Get-DhcpServerv4Scope
```

Confirm that:

- The scope exists on both servers
- Start and end ranges match
- Subnet masks match
- Lease durations match
- Scope configuration is consistent


## Validate Scope State Before Cutover

When an existing DHCP server is still servicing the network, confirm that the Windows scope remains inactive:

```powershell
Get-DhcpServerv4Scope
```

Expected:

```text
ScopeId      : 10.0.0.0
StartRange   : 10.0.0.100
EndRange     : 10.0.0.199
State        : Inactive
SubnetMask   : 255.255.255.0
```

This provides a safe stopping point before migration.


# Existing DHCP Service Cutover

A DHCP migration requires additional planning when the existing and replacement DHCP servers use the same address pool.

For example:

```text
Existing DHCP pool:
10.0.0.100–10.0.0.199

Windows DHCP pool:
10.0.0.100–10.0.0.199
```

The new Windows DHCP servers do not automatically know about leases previously issued by an unrelated DHCP server.

A client may therefore continue using an existing valid lease while the new DHCP server initially considers that address available.

> [!CAUTION]
> Do not simply activate the replacement DHCP scope while the previous DHCP service is still operating. Existing leases and address ownership should be considered before cutover to prevent duplicate address assignments.

The exact migration procedure should be selected based on the existing DHCP server, its lease duration, available lease information, and the ability to renew or migrate existing clients.


# Post-Cutover Client Validation

After a controlled DHCP cutover, validate a test Windows client before migrating the broader environment.

Display the client's complete network configuration:

```powershell
ipconfig /all
```

Verify that the client receives:

```text
IPv4 Address:   10.0.0.100–10.0.0.199
Subnet Mask:    255.255.255.0
Default Gateway: 10.0.0.1
DNS Servers:    10.0.0.10
                10.0.0.11
DNS Suffix:     lab.example.com
```

When appropriate for the test client, request a new lease:

```powershell
ipconfig /release
ipconfig /renew
```

Then validate Active Directory DNS resolution:

```powershell
Resolve-DnsName lab.example.com
```

Validate domain controller service discovery:

```powershell
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com
```

Finally, validate external DNS resolution:

```powershell
Resolve-DnsName microsoft.com
```


# Failover Testing

After normal DHCP operation has been validated, test DHCP availability with each partner unavailable independently.

A controlled test should verify:

1. Normal failover relationship state before the test.
2. Behavior when one DHCP server becomes unavailable.
3. Failover state reported by the surviving server.
4. DHCP lease renewal while one partner is unavailable.
5. Recovery after the unavailable server returns.
6. Return of the failover relationship to `Normal`.

Detailed failure testing should be performed only after the DHCP service has been placed into operation and normal client behavior has been validated.


# Validation Checklist

| Validation | Expected Result |
|---|---|
| DHCP role installed on Server 1 | Pass |
| DHCP role installed on Server 2 | Pass |
| Both DHCP servers authorized in AD | Pass |
| IPv4 scope created | Pass |
| Gateway option configured | Pass |
| Both AD DNS servers distributed | Pass |
| DNS domain option configured | Pass |
| Failover relationship created | Pass |
| Scope replicated to partner | Pass |
| Failover mode | Load Balance |
| Load distribution | 50/50 |
| MCLT | 1 hour |
| Message authentication | Enabled |
| Failover state | `Normal` |
| Client cutover | Validate separately |
| Failure testing | Validate separately |


# Security Considerations

- Keep DHCP servers patched and maintained.
- Authorize domain DHCP servers through Active Directory.
- Do not expose administrative credentials in documentation.
- Use unique secrets for service-specific authentication.
- Store shared secrets outside source-controlled documentation.
- Do not expose MAC addresses, GUIDs, administrative usernames, or other unnecessary unique identifiers in public documentation.
- Domain clients should use Active Directory DNS servers rather than public DNS resolvers directly.
- Avoid operating multiple uncoordinated DHCP servers on the same broadcast domain.


# Related Documentation

- Active Directory Domain Controller Deployment
- Additional Domain Controller Validation
- Windows Server DNS Validation
- Active Directory DNS
- DHCP Failure Testing
