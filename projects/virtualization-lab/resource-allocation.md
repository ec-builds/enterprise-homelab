# Proxmox Resource Allocation Strategy

Simple, scalable guidelines for allocating compute resources across the homelab.

## Core Principles

- Start small and scale based on actual utilization
- Core infrastructure and security boundaries get dedicated VMs
- Lightweight applications share container hosts
- Avoid allocating resources "just in case"
- Maintain spare capacity for testing and temporary workloads
- Review utilization before increasing CPU or RAM

## Initial Allocation

| VM | Role | vCPU | RAM |
|---|---|---:|---:|
| `opnsense-lab-vm` | Firewall / Routing / VPN | 2 | 3 GB |
| `ad-dc-lab-vm` | AD DS / DNS | 2 | 4 GB |
| `docker-lab-vm` | Debian / Docker Host | 2–4 | 6 GB |
| `win11-lab-vm` | Domain / Endpoint Testing | 2–4 | 6 GB |
| **Total** | | **8–12** | **19 GB** |

**Example host:** 6C/6T CPU · 32 GB RAM

Leave remaining capacity available for the hypervisor, filesystem caching, temporary workloads, and future growth.

## Scaling Strategy

### RAM

Increase RAM when workload utilization demonstrates a need.

2 GB → 4 GB → 6 GB → 8 GB → ...

Avoid allocating all physical RAM to VMs.

### CPU

Start most infrastructure VMs with **2 vCPU**.

Increase allocation when sustained CPU utilization demonstrates a need.

Moderate CPU overcommitment is acceptable because VMs rarely require all assigned vCPUs simultaneously.

### Storage

Keep VM disks appropriately sized and expand as required.

- **File Storage** — ISOs, templates, backups
- **VM Storage** — VM and container disks

Avoid oversized virtual disks without a workload requirement.

## Workload Isolation

Create a dedicated VM when a workload represents:

- Security boundary
- Core infrastructure role
- Different operating system
- Independent failure domain
- Dedicated testing environment

Otherwise, consider containerization.

```text
Proxmox Host
│
├── opnsense-lab-vm
│   └── Firewall / Routing / VPN
│
├── ad-dc-lab-vm
│   └── AD DS / DNS
│
├── win11-lab-vm
│   └── Endpoint Testing
│
└── docker-lab-vm
    ├── Dashboard
    ├── Monitoring
    ├── Metrics
    ├── Logging
    └── Other Lightweight Services
```

## Future Growth

| Future VM | Purpose |
|---|---|
| `ad-dc02-lab-vm` | AD DS / DNS redundancy |
| `security-lab-vm` | Security / SIEM tooling |
| `win11-02-lab-vm` | Additional endpoint testing |
| `docker02-lab-vm` | Application isolation / additional capacity |
| `opnsense-test-vm` | Firewall / network experimentation |

When a host regularly approaches comfortable capacity, **scale out to another virtualization node rather than continually overloading the existing host**.

## Naming Convention

Use descriptive, generic hostnames that identify the workload and its purpose.

Examples:

- `opnsense-lab-vm`
- `ad-dc-lab-vm`
- `docker-lab-vm`
- `win11-lab-vm`
- `security-lab-vm`

Avoid publishing:

- Personal names
- Physical locations
- IP addresses
- Account names
- Organization-specific identifiers

## Rule of Thumb

> **Allocate for current requirements, monitor utilization, then scale.**

**Infrastructure boundary → VM**  
**Application/service → usually container**  
**Unused capacity → keep available**
