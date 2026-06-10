# 🏢 Active Directory Lab

**Status: 📋 Planned**

Enterprise identity and access management built on Windows Server and Active Directory Domain Services, running on the Proxmox lab.

## 🎯 Objectives

- Deploy and manage a Windows Server domain controller
- Design an OU structure modeling a real business
- Implement Group Policy for security baselines and configuration management
- Manage users, groups, and computers at scale with PowerShell
- Configure AD-integrated DNS and DHCP

## 🛠️ Technologies

- Windows Server (AD DS, DNS, DHCP)
- Group Policy Management Console
- PowerShell (bulk provisioning, reporting, automation)
- Windows 10/11 domain-joined clients

## 📋 Key Tasks

- [ ] Deploy Windows Server VM and promote to domain controller
- [ ] Build OU structure (departments, users, workstations, servers)
- [ ] Create security groups using AGDLP best practices
- [ ] Configure GPOs: password policy, account lockout, drive mappings, restrictions
- [ ] Bulk-create users with PowerShell
- [ ] Join client VMs to the domain and verify policy application
- [ ] Document DNS zones and DHCP scopes
- [ ] Generate user/group audit reports with PowerShell

## 🔗 Related Projects

- [microsoft-365-entra-id](../microsoft-365-entra-id/) — this domain syncs to Entra ID via Entra Connect for hybrid identity
- [security-operations-lab](../security-operations-lab/) — domain controller logs ship to the SIEM for detection work

## 📁 Folder Structure

```
active-directory-lab/
├── docs/            # Build notes, GPO documentation, lessons learned
├── configs/         # Exported GPO reports, DNS/DHCP documentation
├── scripts/         # PowerShell provisioning and reporting scripts
└── screenshots/     # Visual documentation
```
