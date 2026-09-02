# 🔁 Ansible Configuration Management

**Status: ⚪ Planned**

Ansible will provide centralized configuration management for Linux systems in the homelab.

Its primary role is to apply repeatable, version-controlled configuration after systems are provisioned.

## Role in the Lab

Ansible sits between infrastructure provisioning and day-to-day administration.

```text
Terraform / OpenTofu
        │
        ▼
Provision VM
        │
        ▼
Cloud-init
Initial Access
        │
        ▼
Ansible
System Configuration
        │
        ▼
Application / Service Deployment
```

## Planned Uses

Ansible may be used to automate:

- Administrative user creation
- SSH public key deployment
- `sudo` configuration
- Package installation
- Operating system updates
- SSH hardening
- Agent installation
- Configuration file deployment
- Service configuration
- Baseline validation

## SSH Administration Model

The administrative workstation will retain the private SSH key.

Only the corresponding public key will be deployed to managed systems.

```text
Admin Workstation
      │
      │ Private SSH Key
      │
      ▼
    Ansible
      │
      ├────────► prox01
      ├────────► prox02
      ├────────► docker01
      └────────► monitor01
                   │
                   ▼
              Admin Account
              + Public Key
```

The private key will never be stored on managed servers or committed to Git.

## Initial Baseline

A future Linux baseline playbook may configure:

```text
Create Admin User
        │
        ▼
Deploy SSH Public Key
        │
        ▼
Configure sudo
        │
        ▼
Install Baseline Packages
        │
        ▼
Apply SSH Security Settings
        │
        ▼
Validate Configuration
```

Potential SSH settings include:

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

Password authentication should only be disabled after public-key authentication has been successfully validated.

## Inventory

Managed systems will be organized into inventory groups.

Example:

```ini
[proxmox]
prox01
prox02

[linux_servers]
docker01
monitor01
```

Groups allow configuration to be applied consistently across similar systems while still permitting host-specific settings when required.

## Planned Repository Structure

```text
ansible/
├── inventories/     # Managed hosts and groups
├── playbooks/       # Automation workflows
├── roles/           # Reusable configuration components
├── group_vars/      # Group-specific variables
├── host_vars/       # Host-specific variables
└── README.md        # Usage and implementation notes
```

## Secrets Management

Sensitive values will not be stored in plaintext or committed to Git.

Potential approaches include:

- Ansible Vault
- Environment variables
- External secret stores

Sanitized example files will be committed where configuration templates are useful.

## Implementation Strategy

Ansible will be introduced gradually as repeated manual configuration becomes inefficient.

The initial implementation target is the existing Debian server baseline, including:

- Administrative access
- SSH configuration
- Baseline packages
- Common system settings

Additional roles can be added later for services such as Docker, monitoring, and other Linux workloads.

> [!NOTE]
> **Terraform provisions the system → Cloud-init establishes initial configuration → Ansible applies the reusable server baseline and service configuration.**
