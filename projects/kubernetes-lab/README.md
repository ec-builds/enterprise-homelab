# ☸️ Kubernetes Lab

**Status: 📋 Planned**

Container orchestration from homelab to cloud: a k3s cluster on Proxmox VMs, then Azure Kubernetes Service (AKS) — a core differentiator for cloud engineering roles.

## 🎯 Objectives

- Deploy a multi-node k3s cluster on the Proxmox lab
- Learn core Kubernetes objects: Deployments, Services, Ingress, ConfigMaps, Secrets, PersistentVolumes
- Deploy real applications with proper health checks and resource limits
- Practice operational tasks: upgrades, scaling, troubleshooting with kubectl
- Graduate to AKS in the [Azure lab](../azure-administration-lab/) and compare managed vs self-hosted
- Skills alignment: **CKA / AZ-305** trajectory

## 🛠️ Technologies

- k3s (lightweight Kubernetes)
- kubectl, Helm
- Ingress controller (Traefik ships with k3s)
- Persistent storage (local-path, then Longhorn or NFS)
- Azure Kubernetes Service (later phase)

## 📋 Key Tasks

- [ ] Provision cluster VMs (ideally via Terraform from [infrastructure-automation](../infrastructure-automation/))
- [ ] Bootstrap k3s: one server node, two agent nodes
- [ ] Deploy a stateless app with Deployment + Service + Ingress
- [ ] Deploy a stateful app with persistent storage
- [ ] Manage configuration with ConfigMaps and Secrets
- [ ] Install an app with Helm and document the chart workflow
- [ ] Simulate node failure; document the recovery behavior
- [ ] Deploy AKS and migrate one workload; compare operations
- [ ] Wire deployments into [ci-cd-pipelines](../ci-cd-pipelines/)

## 📁 Folder Structure

```
kubernetes-lab/
├── manifests/       # YAML manifests by application
├── helm/            # Helm values files
├── docs/            # Build notes, troubleshooting, lessons learned
├── scripts/         # Cluster bootstrap/maintenance scripts
└── screenshots/     # Visual documentation
```
