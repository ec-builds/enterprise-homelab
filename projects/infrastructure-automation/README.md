# ⚙️ Infrastructure Automation (IaC)

**Status: 🟡 In Progress**

<img src="./diagrams/infrastructure-automation-banner.png" alt="Infrastructure & Automation Lab Banner" width="1000">

Infrastructure automation for the homelab, combining declarative provisioning, configuration management, operational scripting, and CI/CD workflows.

The long-term goal:

> **"I can rebuild my entire lab from this Git repository."**

## Objectives

- Provision infrastructure declaratively with **Terraform / OpenTofu** and **Bicep**
- Configure Linux systems and services with **Ansible**
- Automate administrative tasks with **PowerShell** and **Python**
- Use **Cloud-init** for initial VM configuration
- Version-control infrastructure and configuration changes with **Git**
- Implement automated repository validation with **GitHub Actions**
- Align Terraform projects with **HashiCorp Terraform Associate** objectives

## Automation Model

```text
                  Git Repository
                        │
            ┌───────────┴───────────┐
            │                       │
            ▼                       ▼
     Infrastructure            GitHub Actions
      Automation               CI/CD Validation
            │                       │
            ▼                       ▼
    Terraform / Bicep         Documentation Checks
     Provisioning             Link Validation
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

Infrastructure provisioning and configuration management remain planned. GitHub Actions-based documentation validation is operational.

## Technologies

| Technology | Role | Status |
|---|---|---|
| **Terraform / OpenTofu** | Provision Proxmox VMs and Azure resources | ⚪ Planned |
| **Ansible** | Configure Linux systems, users, SSH, packages, and services | ⚪ Planned |
| **Bicep** | Define Azure-native infrastructure | ⚪ Planned |
| **Cloud-init** | Perform initial Linux VM configuration | ⚪ Planned |
| **PowerShell / Python** | Administrative and operational automation | ⚪ Planned |
| **Git** | Version control for automation code and configuration | 🟢 Operational |
| **GitHub Actions** | Automated repository validation and CI/CD workflows | 🟢 Operational |
| **Lychee** | Automated Markdown link validation | 🟢 Operational |

## Documentation Quality Automation

GitHub Actions provides automated quality checks for the Enterprise Homelab repository.

| Workflow | Trigger | Purpose | Status |
|---|---|---|---|
| Internal Link Validation | Push / Pull Request | Validate local Markdown links and image references | 🟢 Operational |
| External Link Monitoring | Weekly / Manual | Check external URLs and create GitHub issues for broken references | 🟡 Testing |

### Internal Link Validation

The `.github/workflows/internal-links.yml` workflow uses Lychee to validate repository documentation automatically.

**Implementation:**

- Runs on repository pushes and pull requests.
- Validates relative Markdown links and local image references.
- Uses offline validation to avoid external network dependencies.
- Fails when broken references are detected.
- Provides validation results through GitHub Actions.

**Validation Results:**

| Metric | Result |
|---|---:|
| Total references | 419 |
| Successful | 377 |
| Excluded | 42 |
| Errors | **0** |
| Workflow status | ✅ Passed |

The workflow successfully identified 39 broken references during initial testing. After correcting the documentation, a subsequent run completed with zero errors.

### External Link Monitoring

The `.github/workflows/external-links.yml` workflow is intended to provide scheduled validation of external documentation references.

**Configuration:**

- Runs weekly on Mondays.
- Supports manual execution through GitHub Actions.
- Checks HTTP and HTTPS references.
- Uses retries and timeouts to reduce transient failures.
- Is designed to create or update a GitHub issue when broken external links are detected.
- Does not fail the overall workflow solely because an external website is unavailable.

External link monitoring remains under validation.

## Key Tasks

### Completed

- [x] Establish Git-based version control
- [x] Implement GitHub Actions for internal documentation validation
- [x] Configure automated Markdown link checking with Lychee
- [x] Resolve initial broken internal references
- [x] Validate successful CI execution with zero link errors

### In Progress

- [ ] Validate scheduled external link monitoring and GitHub issue creation

### Planned

- [ ] Provision Proxmox VMs from templates with Terraform
- [ ] Build an Ansible server baseline for users, SSH, packages, and security settings
- [ ] Recreate Azure lab resources using Terraform and Bicep
- [ ] Automate Docker host deployment
- [ ] Automate Active Directory administration with PowerShell
- [ ] Implement secure secrets management
- [ ] Document the full rebuild procedure

## Folder Structure

```text
infrastructure-automation/
├── terraform/       # Proxmox and Azure provisioning
├── bicep/           # Azure-native infrastructure
├── ansible/         # Playbooks, roles, and inventories
├── scripts/         # PowerShell and Python utilities
└── docs/            # Runbooks and implementation notes
```

Repository-wide CI/CD workflows are maintained separately:

```text
.github/
└── workflows/
    ├── internal-links.yml
    └── external-links.yml
```

## Security

Credentials, state files, vault passwords, private keys, and other secrets will not be committed to the repository.

Sanitized examples and templates will be used where configuration examples are required.

GitHub Actions workflows use restricted repository permissions appropriate to their functions.

> [!NOTE]
> **Infrastructure automation:** Terraform / Bicep provision infrastructure → Cloud-init performs initial configuration → Ansible configures systems and services → PowerShell / Python automate operational tasks.
>
> **Repository automation:** GitHub Actions executes automated validation → Lychee checks documentation references → Results are reported through CI/CD workflows.