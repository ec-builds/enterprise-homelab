# ⚙️ Infrastructure Automation (IaC)

**Status: 📋 Planned**

Infrastructure as Code for the entire lab — the goal is a single sentence: **"I can rebuild my entire lab from this git repo."**

## 🎯 Objectives

- Provision Proxmox VMs and Azure resources declaratively with **Terraform**
- Manage configuration with **Ansible** (idempotent, version-controlled)
- Author Azure-native IaC with **Bicep** alongside Terraform
- Automate operational tasks with PowerShell and Python
- Treat all infrastructure changes as code review + git history
- Skills alignment: **HashiCorp Terraform Associate** certification objectives

## 🛠️ Technologies

- Terraform / OpenTofu (Proxmox provider, AzureRM provider)
- Ansible (playbooks, roles, inventories, Vault for secrets)
- Bicep (Azure-native declarative templates)
- PowerShell & Python (task automation, reporting)
- Git (all automation code version-controlled)
- Cloud-init (first-boot VM configuration)

## 📋 Key Tasks

- [ ] Write Terraform configs to provision VMs from Proxmox templates
- [ ] Build Ansible baseline playbook (updates, users, SSH hardening, agents)
- [ ] Recreate the Azure lab environment in Terraform and Bicep
- [ ] Automate Docker host setup end-to-end
- [ ] Automate AD user provisioning with PowerShell
- [ ] Manage secrets properly (Ansible Vault / env vars — never in git)
- [ ] Document the full "rebuild from zero" procedure
- [ ] Validate IaC in CI ([ci-cd-pipelines](../ci-cd-pipelines/))

## 📁 Folder Structure

```
infrastructure-automation/
├── terraform/       # Proxmox + Azure provisioning
├── bicep/           # Azure-native templates
├── ansible/         # Playbooks, roles, inventories
├── scripts/         # PowerShell / Python utilities
└── docs/            # Runbooks, build notes, lessons learned
```

## ⚠️ Security Note

State files, vault passwords, and credentials are excluded from version control. Sanitized `*.example` templates are committed instead.
