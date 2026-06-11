# 🖥️ Virtualization Lab (Proxmox)

**Status: 🔨 In Progress** — current project and the foundation of the entire lab.

Bare-metal hypervisor deployment using Proxmox VE. Every subsequent project (Active Directory, Docker, Kubernetes, monitoring) runs on this platform.

## Objectives

- Install and configure Proxmox VE on repurposed hardware
- Master the VM lifecycle: create, clone, snapshot, backup, migrate
- Build reusable VM templates with cloud-init
- Design virtual networking (Linux bridges, VLAN-aware configuration)
- Plan storage for VM disks, ISOs, and backups

## Technologies

- Proxmox VE (KVM/QEMU, LXC containers)
- Cloud-init for template-based provisioning
- ZFS or LVM-thin storage
- Linux bridge networking / VLAN tagging

## Key Tasks

- [ ] Install Proxmox VE and complete post-install configuration
- [ ] Configure storage pools (VM disks, ISO storage, backup target)
- [ ] Create a Debian/Ubuntu cloud-init template
- [ ] Create a Windows Server template (for the AD lab)
- [ ] Configure VLAN-aware bridge for segmented lab networks
- [ ] Test snapshots, clones, and live restore
- [ ] Configure scheduled VM backups
- [ ] Document host specs, storage layout, and naming conventions

## Downstream Projects

This lab provides the platform for: [active-directory-lab](../active-directory-lab/), [docker-self-hosted-services](../docker-self-hosted-services/), [kubernetes-lab](../kubernetes-lab/), [infrastructure-monitoring](../infrastructure-monitoring/), and [security-operations-lab](../security-operations-lab/). VM provisioning will later be automated in [infrastructure-automation](../infrastructure-automation/).

## Folder Structure

```
virtualization-lab/
├── docs/            # build-notes.md, troubleshooting.md, lessons-learned.md
├── configs/         # Sanitized host/network configs
├── scripts/         # Template build and maintenance scripts
└── screenshots/     # Visual documentation
```
