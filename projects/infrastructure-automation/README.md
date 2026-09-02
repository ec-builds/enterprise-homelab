# ⚙️ Infrastructure Automation (IaC)

**Status: ⚪ Planned**

Infrastructure automation for the homelab with the long-term goal:

> **"I can rebuild my entire lab from this Git repository."**

## Objectives

- Provision infrastructure declaratively with **Terraform / OpenTofu** and **Bicep**
- Configure Linux systems and services with **Ansible**
- Automate administrative tasks with **PowerShell** and **Python**
- Use **Cloud-init** for initial VM configuration
- Version-control infrastructure and configuration changes with **Git**
- Align Terraform projects with **HashiCorp Terraform Associate** objectives

## Automation Model

```text
Git Repository
      │
      ▼
Terraform / Bicep
Infrastructure Provisioning
      │
      ▼
Cloud-init
Initial Configuration
      │
      ▼
Ansible
System Configuration
      │
      ▼
PowerShell / Python
Operational Automation
```

## Technologies

| Technology | Planned Role |
|---|---|
| **Terraform / OpenTofu** | Provision Proxmox VMs and Azure resources |
| **Ansible** | Configure Linux systems, users, SSH, packages, and services |
| **Bicep** | Define Azure-native infrastructure |
| **Cloud-init** | Perform initial Linux VM configuration |
| **PowerShell / Python** | Administrative and operational automation |
| **Git** | Version control for automation code and configuration |

## Key Tasks

- [ ] Provision Proxmox VMs from templates with Terraform
- [ ] Build an Ansible server baseline for users, SSH, packages, and security settings
- [ ] Recreate Azure lab resources using Terraform and Bicep
- [ ] Automate Docker host deployment
- [ ] Automate Active Directory administration with PowerShell
- [ ] Implement secure secrets management
- [ ] Document the full rebuild procedure
- [ ] Validate IaC through CI/CD ([ci-cd-pipelines](../ci-cd-pipelines/))

## Folder Structure

```text
infrastructure-automation/
├── terraform/       # Proxmox and Azure provisioning
├── bicep/           # Azure-native infrastructure
├── ansible/         # Playbooks, roles, and inventories
├── scripts/         # PowerShell and Python utilities
└── docs/            # Runbooks and implementation notes
```

## Security

Credentials, state files, vault passwords, private keys, and other secrets will not be committed to the repository.

Sanitized examples and templates will be used where configuration examples are required.

> [!NOTE]
> **Terraform / Bicep provision infrastructure → Cloud-init performs initial configuration → Ansible configures systems and services → PowerShell / Python automate operational tasks.**
