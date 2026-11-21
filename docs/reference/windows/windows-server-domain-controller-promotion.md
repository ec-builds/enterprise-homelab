# Windows Server Domain Controller Promotion

**Status: 🟢 Operational**

## Overview

This reference covers preparing a Windows Server VM and promoting it to a domain controller, either as the first domain controller in a new forest or as an additional domain controller in an existing domain. It assumes a VM cloned from a generalized Windows Server template.

Post-promotion checks for an additional domain controller are in [Additional Domain Controller Validation](./windows-additional-domain-controller-validation.md). DNS checks are in [Windows Server DNS Validation](./windows-server-DNS-validation.md).

> [!NOTE]
> Examples use sanitized names and addresses: `lab.example.com`, `dc-lab-01` (`10.0.0.10`), and `dc-lab-02` (`10.0.0.11`).

## Prepare the Server

### Set the Hostname

Set the permanent hostname before installing any roles. A domain controller's name is difficult to change after promotion.

**Server Manager → Local Server → Computer name**

Restart, then confirm:

```powershell
hostname
```

### Configure a Static IP Address

**Settings → Network & Internet → Ethernet → IP assignment → Edit → Manual**

| Setting | First domain controller | Additional domain controller |
|---|---|---|
| IP address | `10.0.0.10` | `10.0.0.11` |
| Subnet mask | `255.255.255.0` | `255.255.255.0` |
| Default gateway | `10.0.0.1` | `10.0.0.1` |
| DNS server | Existing network DNS (`10.0.0.1`) | An existing domain controller (`10.0.0.10`) |

An additional domain controller must use an existing domain controller for DNS, so it can locate the domain through SRV records.

Confirm DHCP is disabled and the settings are correct:

```powershell
ipconfig /all
```

### Validate Networking

Validate the network before installing Active Directory, so network problems are not confused with AD DS or DNS problems.

```powershell
ping 127.0.0.1                                  # local TCP/IP stack
ping 10.0.0.1                                   # default gateway
ping 8.8.8.8                                    # IPv4 routing, no DNS
nslookup microsoft.com                          # DNS resolution
Test-NetConnection microsoft.com -Port 443      # outbound HTTPS
```

For an additional domain controller, also confirm the domain can be located:

```powershell
nslookup -type=SRV _ldap._tcp.dc._msdcs.lab.example.com
```

## Install AD DS and DNS

**Server Manager → Manage → Add Roles and Features → Role-based or feature-based installation**

Select the local server, then under **Server Roles** enable:

```text
Active Directory Domain Services
DNS Server
```

Select **Add Features** when prompted. Windows adds Group Policy Management, the AD DS tools, the Active Directory PowerShell module, and the DNS Server tools.

PowerShell equivalent:

```powershell
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools
```

Installing the roles does not make the server a domain controller. Server Manager shows a notification that promotion is required.

## Promote the First Domain Controller (New Forest)

**Server Manager → Notifications → Promote this server to a domain controller**

| Wizard page | Setting |
|---|---|
| Deployment Configuration | **Add a new forest**; root domain name `lab.example.com` |
| Domain Controller Options | Forest and domain functional level; **DNS server** and **Global Catalog** checked; set the DSRM password |
| DNS Options | Leave delegation unchecked for an internal-only namespace |
| Additional Options | Confirm the NetBIOS name (`LAB`) |
| Paths | Database, logs, and SYSVOL (defaults are fine at lab scale) |
| Review Options | Confirm the settings |
| Prerequisites Check | Must pass before **Install** is available |

Expected warnings that do not block promotion:

- A static IPv6 address is not configured.
- A DNS delegation cannot be created because no authoritative parent zone exists.

The server restarts automatically after promotion.

> [!IMPORTANT]
> Store the DSRM password securely. It is needed for Directory Services Restore Mode and must never be added to the repository.

## Promote an Additional Domain Controller

**Server Manager → Notifications → Promote this server to a domain controller**

| Wizard page | Setting |
|---|---|
| Deployment Configuration | **Add a domain controller to an existing domain**; domain `lab.example.com`; supply domain admin credentials |
| Domain Controller Options | **DNS server** and **Global Catalog** checked; RODC unchecked; select the site; set the DSRM password |
| DNS Options | Leave delegation unchecked |
| Additional Options | **Replicate from:** select a specific domain controller, for example `dc-lab-01`, or leave **Any domain controller** |
| Paths | Database, logs, and SYSVOL |
| Review Options | Confirm the settings |
| Prerequisites Check | Must pass before **Install** is available |

During promotion, the server replicates the directory partitions, SYSVOL, and AD-integrated DNS zones from the source domain controller. Do not create zones or objects manually on the new server.

After the restart, set each domain controller's DNS client to use its partner as preferred and its own address as alternate.

## Post-Promotion Checks

```powershell
Get-WindowsFeature AD-Domain-Services, DNS     # Install State: Installed
Get-ADDomain
Get-ADForest
Get-ADDomainController -Filter *
Get-Service DNS                                # Status: Running
Get-DnsServerZone                              # domain and _msdcs zones
Resolve-DnsName dc-lab-01.lab.example.com
Resolve-DnsName -Type SRV _ldap._tcp.dc._msdcs.lab.example.com
netdom query fsmo
```

For an additional domain controller, continue with [Additional Domain Controller Validation](./windows-additional-domain-controller-validation.md).

## Related Documentation

- [Additional Domain Controller Validation](./windows-additional-domain-controller-validation.md)
- [Windows Server DNS Validation](./windows-server-DNS-validation.md)
- [Windows VM Templates](../proxmox/proxmox-windows-vm-template.md)
