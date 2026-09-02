# 🖥️ Domain Controller Deployment

## Overview

This document outlines the deployment process for the primary Windows Server
domain controller in the Active Directory lab.

The deployment establishes the initial Windows Server infrastructure required
for Active Directory Domain Services (AD DS), DNS, and DHCP.

The deployment workflow is:

```text
Windows Server Template
        │
        ▼
     Full Clone
        │
        ▼
Configure Hostname
        │
        ▼
Configure Static IP
        │
        ▼
Validate Networking
        │
        ▼
Install AD DS + DNS
        │
        ▼
Promote to Domain Controller
        │
        ▼
Configure DHCP
        │
        ▼
Validate Active Directory
```

> [!NOTE]
> Hostnames, IP addresses, domain names, and other environment-specific
> identifiers shown in this document are sanitized for public documentation.


## Server Configuration

The primary domain controller uses the following baseline configuration.

| Component | Configuration |
|---|---|
| VM Name | `dc-lab-01` |
| Hostname | `dc-lab-01` |
| Operating System | Windows Server 2025 Standard Evaluation |
| Installation | Desktop Experience |
| CPU | 2 vCPU |
| Memory | 2 GB |
| Storage | 64 GB |
| Network | Static IPv4 |
| Planned Roles | AD DS, DNS, DHCP |


## Configure Hostname

After deploying the Windows Server VM from the generalized template, assign
the server its permanent hostname before installing Active Directory roles.

The primary domain controller uses the sanitized hostname:

```text
dc-lab-01
```

The hostname can be changed through:

**Server Manager → Local Server → Computer name**

or through Windows Settings.

Restart the server after changing the hostname.

Verify the hostname:

```powershell
hostname
```

Expected result:

```text
dc-lab-01
```


## Configure Static IP Address

Domain controllers provide foundational infrastructure services and should
use stable network addressing.

Configure the server with a static IPv4 address through:

**Settings → Network & Internet → Ethernet → IP Assignment → Edit**

Change the IP assignment from:

```text
Automatic (DHCP)
```

to:

```text
Manual
```

Enable IPv4 and configure the appropriate network settings.

Example sanitized configuration:

```text
IP Address:      10.0.0.10
Subnet Mask:     255.255.255.0
Default Gateway: 10.0.0.1
DNS Server:      10.0.0.1
```

At this stage, the existing network DNS server remains configured because
the new domain controller is not yet providing DNS services.

After AD DS and DNS are configured, domain clients will use the domain
controllers as their DNS servers.

> [!IMPORTANT]
> The static address assigned to the domain controller will also become the
> address used to reach the DNS service hosted by that domain controller.

Verify the configuration:

```powershell
ipconfig /all
```

Confirm:

- DHCP is disabled
- The intended IPv4 address is assigned
- The subnet mask is correct
- The default gateway is correct
- A functioning DNS server is configured


## Validate Network Connectivity

Network connectivity should be validated before installing Active Directory.

This separates basic network problems from problems introduced later during
AD DS or DNS configuration.


### Validate Local TCP/IP

Test the local TCP/IP stack:

```powershell
ping 127.0.0.1
```

Expected result:

```text
0% packet loss
```


### Validate Default Gateway

Ping the configured gateway.

Example:

```powershell
ping 10.0.0.1
```

A successful response confirms connectivity between the server and the local
network gateway.


### Validate IPv4 Internet Routing

Test connectivity to an external IPv4 address without relying on DNS:

```powershell
ping 8.8.8.8
```

A successful response confirms that IPv4 routing through the default gateway
is functioning.


### Validate DNS Resolution

Test external DNS resolution:

```powershell
nslookup microsoft.com
```

A successful lookup confirms that the configured DNS infrastructure can
resolve external names.


### Validate HTTPS Connectivity

Test outbound HTTPS connectivity:

```powershell
Test-NetConnection microsoft.com -Port 443
```

Verify:

```text
TcpTestSucceeded : True
```

Successful completion of these tests establishes the following network path:

```text
Domain Controller
      │
      ├── Local TCP/IP          ✓
      │
      ├── Local Gateway         ✓
      │
      ├── IPv4 Routing          ✓
      │
      ├── DNS Resolution        ✓
      │
      └── HTTPS Connectivity    ✓
```


## Install Active Directory Domain Services

Active Directory Domain Services and DNS are installed through Windows
Server Manager.

Open:

**Server Manager → Manage → Add Roles and Features**

Select:

```text
Role-based or feature-based installation
```

Select the local Windows Server as the destination server.


### Select Server Roles

Under **Server Roles**, enable:

```text
Active Directory Domain Services
DNS Server
```

When prompted, select:

**Add Features**

Windows automatically selects the supporting management components required
for the roles.

These include:

```text
Group Policy Management

Remote Server Administration Tools
└── Role Administration Tools
    ├── AD DS and AD LDS Tools
    │   ├── Active Directory module for Windows PowerShell
    │   ├── AD DS Tools
    │   ├── Active Directory Administrative Center
    │   └── AD DS Snap-Ins and Command-Line Tools
    │
    └── DNS Server Tools
```

DHCP Server is intentionally not installed during this stage.

The initial deployment order is:

```text
AD DS
  │
  └── DNS
       │
       ▼
Domain Promotion
       │
       ▼
AD/DNS Validation
       │
       ▼
DHCP
```

This allows Active Directory and DNS to be established and validated before
introducing DHCP configuration.


## Deployment Screenshots

The following screenshots document the AD DS and DNS role installation.


### Server Role Selection

<!-- SCREENSHOT PLACEHOLDER: DC-add-roles-and-features.png -->

<p align="left">
  <img src="../diagrams/DC-add-roles-and-features.png" alt="Windows Server AD DS and DNS role selection" width="800">
</p>

*Active Directory Domain Services and DNS Server selected for installation.*


### Feature Selection

<!-- SCREENSHOT PLACEHOLDER: DC-features.png -->

<p align="left">
  <img src="../diagrams/DC-features.png" alt="Windows Server feature selection" width="800">
</p>

*Supporting Active Directory management features selected automatically.*


### Installation Confirmation

<!-- SCREENSHOT PLACEHOLDER: DC-confirm-settings.png -->

<p align="left">
  <img src="../diagrams/DC-confirm-settings.png" alt="AD DS and DNS installation confirmation" width="800">
</p>

*AD DS, DNS, Group Policy Management, and administration tools ready for installation.*


### Role Installation

<!-- SCREENSHOT PLACEHOLDER: DC-installation.png -->

<p align="left">
  <img src="../diagrams/DC-installation.png" alt="AD DS and DNS role installation progress" width="800">
</p>

*Installation of Active Directory Domain Services, DNS, and supporting management tools.*


## Promote Server to Domain Controller

**Status: ⏳ Pending**

After AD DS and DNS installation completes, Server Manager reports that
additional configuration is required.

The next deployment stage will be initiated through:

**Server Manager → Notifications → Promote this server to a domain controller**

Because this server will establish a new Active Directory environment, the
deployment will use:

```text
Add a new forest
```

The following items will be documented during the promotion process:

- Active Directory root domain name
- Forest functional level
- Domain functional level
- DNS Server configuration
- Global Catalog configuration
- Directory Services Restore Mode (DSRM) password
- DNS delegation
- NetBIOS domain name
- AD DS database paths
- SYSVOL path
- Prerequisite validation
- Domain controller promotion
- Post-promotion restart

> [!NOTE]
> Domain promotion configuration will be added after the initial forest and
> domain design is finalized.


## Configure DHCP

**Status: ⏳ Pending**

DHCP will be installed after the domain controller has been successfully
promoted and AD-integrated DNS has been validated.

Planned configuration includes:

- DHCP Server role installation
- DHCP authorization in Active Directory
- IPv4 scope creation
- Address pool configuration
- Exclusion ranges
- Default gateway option
- AD DNS server options
- DNS domain option
- Lease configuration
- DHCP validation


## Post-Deployment Validation

**Status: ⏳ Pending**

After domain promotion and DHCP configuration, validation will include:

```text
AD DS
├── Domain available
├── Domain controller discoverable
├── SYSVOL available
└── NETLOGON available

DNS
├── AD DNS zone created
├── Domain controller records registered
├── Forward lookup working
└── External DNS forwarding working

DHCP
├── Server authorized
├── Scope active
├── Client receives address
├── Client receives AD DNS server
└── Client receives correct gateway
```

Additional validation will be added as each deployment stage is completed.


## Deployment Status

| Stage | Status |
|---|---|
| Windows Server Deployment | ✅ Complete |
| Hostname Configuration | ✅ Complete |
| Static IP Configuration | ✅ Complete |
| Network Validation | ✅ Complete |
| AD DS Installation | 🟡 In Progress |
| DNS Server Installation | 🟡 In Progress |
| Domain Promotion | ⚪ Pending |
| AD/DNS Validation | ⚪ Pending |
| DHCP Installation | ⚪ Pending |
| DHCP Configuration | ⚪ Pending |
| Final Validation | ⚪ Pending |
