# Proxmox Resource Allocation Strategy

Resource allocation and capacity planning for the Proxmox virtualization lab.

## Core Principles

- Start small and scale based on actual utilization
- Maintain capacity for the hypervisor and temporary workloads
- Avoid allocating resources "just in case"
- Moderate CPU overcommitment is acceptable for non-concurrent lab workloads
- Distribute workloads across nodes when resource contention develops

## Host Overview

| Host | CPU | Cores / Threads | Memory | Primary VM Storage | Status |
|---|---|---:|---:|---|---|
| `prox-lab-01` | Intel Core i5-9500T | 6 / 6 | 32 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-02` | Intel Core i7-6700T | 4 / 8 | 16 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-03` | Pending | Pending | Pending | Pending | Planned |

`prox-lab-03` is planned as a third virtualization node with hardware similar to `prox-lab-02`. Final specifications will be documented after deployment and validation.

> **Note:** Firewall and routing services are hosted on dedicated hardware and are excluded from Proxmox resource calculations.

## `prox-lab-01`

Primary virtualization node for persistent infrastructure, applications, monitoring, and endpoint testing.

### Capacity and Allocation

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 6 cores / 6 threads | 14 vCPU | ~2.3:1 vCPU-to-core |
| Memory | 32 GB | 24 GB | ~8 GB unallocated |
| NVMe Storage | ~1 TB | Workload dependent | Expand as required |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `win11-lab-vm01` | Domain / Endpoint Testing | 4 | 8 GB |
| `win11-lab-vm02` | Additional Endpoint Testing | 4 | 8 GB |
| `docker-lab-vm` | Debian / Docker Host | 2 | 4 GB |
| `monitor-lab-vm` | Monitoring / Metrics / Logging | 2 | 2 GB |
| `dc-lab-vm` | AD DS / DNS | 2 | 2 GB |
| **Total** | | **14 vCPU** | **24 GB** |

### Considerations

CPU is intentionally overcommitted at approximately **2.3:1**. Assigned vCPUs represent schedulable capacity rather than dedicated physical cores, making moderate overcommitment appropriate for lab workloads that are not expected to sustain maximum utilization simultaneously.

Approximately **8 GB of memory remains unallocated** for the hypervisor, filesystem caching, virtualization overhead, and temporary workloads.

## `prox-lab-02`

Secondary virtualization node for infrastructure redundancy, security workloads, media services, and additional lab capacity.

### Capacity and Allocation

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 4 cores / 8 threads | 8 vCPU | 1:1 vCPU-to-thread |
| Memory | 16 GB | 12 GB | ~4 GB unallocated |
| NVMe Storage | ~1 TB | Workload dependent | Expand as required |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `dc02-lab-vm` | Secondary AD DS / DNS | 2 | 2 GB |
| `security-lab-vm` | Security / SIEM Testing | 2 | 4 GB |
| `utility-lab-vm` | Linux / Infrastructure Utilities | 2 | 2 GB |
| `media-lab-vm` | Docker / Jellyfin Media Services | 2 | 4 GB |
| **Total** | | **8 vCPU** | **12 GB** |

### Considerations

The processor provides **4 physical cores and 8 hardware threads**. The planned 8 vCPU allocation remains reasonable for workloads that are not expected to sustain maximum CPU utilization simultaneously.

Approximately **4 GB of memory remains unallocated** for the hypervisor, filesystem caching, virtualization overhead, and temporary workloads. Memory remains the primary capacity constraint on this node and should be monitored as additional services are deployed.

`media-lab-vm` is intentionally hosted on `prox-lab-02` to distribute persistent workloads across virtualization nodes rather than concentrating Docker, monitoring, and media services on `prox-lab-01`.

Resource-intensive workloads should be distributed across available nodes based on observed utilization and workload requirements.

## `prox-lab-03`

Planned third virtualization node for additional compute capacity and workload distribution.

### Capacity and Allocation

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | Pending | Pending | Pending |
| Memory | Pending | Pending | Pending |
| VM Storage | Pending | Pending | Pending |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| Pending | Additional Lab Workloads | Pending | Pending |
| Pending | Testing / Infrastructure | Pending | Pending |
| **Total** | | **Pending** | **Pending** |

### Considerations

`prox-lab-03` is expected to provide capabilities similar to `prox-lab-02`, but resource planning will be based on validated hardware rather than assumed specifications.

Final CPU, memory, storage, and VM allocations will be documented after the host is deployed and baseline resource utilization is established.

## Cluster Capacity

| Resource | `prox-lab-01` | `prox-lab-02` | `prox-lab-03` | Current Known Capacity |
|---|---:|---:|---:|---:|
| Physical Cores | 6 | 4 | Pending | 10 |
| Hardware Threads | 6 | 8 | Pending | 14 |
| Memory | 32 GB | 16 GB | Pending | 48 GB |
| Planned vCPU | 14 | 8 | Pending | 22 |
| Planned VM Memory | 24 GB | 12 GB | Pending | 36 GB |
| Unallocated Memory | ~8 GB | ~4 GB | Pending | ~12 GB |
| NVMe VM Storage | ~1 TB | ~1 TB | Pending | ~2 TB |

> Combined capacity is useful for planning, but CPU and memory remain local to each virtualization node unless workloads are migrated between hosts.

## Scaling Strategy

### CPU

Start most infrastructure workloads with **2 vCPU** and increase allocation when sustained utilization demonstrates a need.

Moderate CPU overcommitment is acceptable because assigned vCPUs represent schedulable capacity rather than dedicated physical cores.

If sustained contention develops, reduce unnecessary vCPU allocations or redistribute workloads across available nodes.

### RAM

Increase memory based on observed workload requirements while maintaining sufficient unallocated capacity for:

- Hypervisor operation
- Filesystem caching
- Virtualization overhead
- Temporary workloads

Avoid allocating all available physical memory to VMs.

Memory utilization should be monitored particularly closely on `prox-lab-02`, where the planned media workload reduces available memory headroom.

### Storage

Keep virtual disks appropriately sized and expand them as required.

- **File Storage** — ISOs, templates, and backups
- **VM Storage** — VM and container disks

Use NVMe-backed storage for primary VM workloads where the additional performance is beneficial.

## Rule of Thumb

> **Allocate for current requirements, monitor utilization, then scale.**

**Allocate conservatively → Monitor utilization → Adjust resources → Distribute workloads when necessary**
