# Proxmox Workload & Capacity Plan

Current and planned workload placement and capacity across the Proxmox virtualization lab.

## Host Overview

| Host | CPU | Cores / Threads | Memory | Primary VM Storage | Status |
|---|---|---:|---:|---|---|
| `prox-lab-01` | Intel Core i5-9500T | 6 / 6 | 32 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-02` | Intel Core i7-6700T | 4 / 8 | 16 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-03` | Pending | Pending | Pending | Pending | Planned |

`prox-lab-03` is planned as a third virtualization node with hardware similar to `prox-lab-02`. Final specifications will be documented after deployment and validation.

> **Note:** Firewall and routing services are hosted on dedicated hardware and are excluded from Proxmox capacity calculations.

## Workload Placement

Workloads are distributed across virtualization nodes to balance resource utilization and reduce the impact of individual host maintenance or failure.

```text
prox-lab-01
├── win11-lab-vm01
├── win11-lab-vm02
├── docker-lab-vm
└── dc-lab-vm

prox-lab-02
├── monitor-lab-vm
├── dc02-lab-vm
├── security-lab-vm
├── utility-lab-vm
└── media-lab-vm

prox-lab-03
└── Future workloads
```

Persistent services are intentionally distributed across nodes where practical. In particular, monitoring and media services are hosted on `prox-lab-02` rather than concentrating Docker, monitoring, and media workloads on `prox-lab-01`.

## `prox-lab-01`

Primary virtualization node for persistent infrastructure, general self-hosted applications, and endpoint testing.

### Capacity

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 6 cores / 6 threads | 12 vCPU | ~2:1 vCPU-to-core |
| Memory | 32 GB | 22 GB | ~10 GB unallocated |
| NVMe Storage | ~1 TB | Workload dependent | Expand as required |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `win11-lab-vm01` | Domain / Endpoint Testing | 4 | 8 GB |
| `win11-lab-vm02` | Additional Endpoint Testing | 4 | 8 GB |
| `docker-lab-vm` | Debian / Docker Host | 2 | 4 GB |
| `dc-lab-vm` | AD DS / DNS | 2 | 2 GB |
| **Total** | | **12 vCPU** | **22 GB** |

### Capacity Notes

CPU is intentionally overcommitted at approximately **2:1**. These workloads are not expected to sustain maximum CPU utilization simultaneously.

Approximately **10 GB of memory remains unallocated** for the hypervisor, filesystem caching, virtualization overhead, and temporary workloads.

## `prox-lab-02`

Secondary virtualization node for infrastructure redundancy, monitoring, security workloads, media services, and additional lab capacity.

### Capacity

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 4 cores / 8 threads | 10 vCPU | ~1.25:1 vCPU-to-thread |
| Memory | 16 GB | 14 GB | ~2 GB unallocated |
| NVMe Storage | ~1 TB | Workload dependent | Expand as required |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `monitor-lab-vm` | Monitoring / Metrics / Logging | 2 | 2 GB |
| `dc02-lab-vm` | Secondary AD DS / DNS | 2 | 2 GB |
| `security-lab-vm` | Security / SIEM Testing | 2 | 4 GB |
| `utility-lab-vm` | Linux / Infrastructure Utilities | 2 | 2 GB |
| `media-lab-vm` | Docker / Jellyfin Media Services | 2 | 4 GB |
| **Total** | | **10 vCPU** | **14 GB** |

### Capacity Notes

The processor provides **4 physical cores and 8 hardware threads**. The planned 10 vCPU allocation represents approximately **1.25:1 vCPU-to-thread** overcommit for workloads that are not expected to sustain maximum utilization simultaneously.

Approximately **2 GB of memory remains unallocated** for the hypervisor, filesystem caching, virtualization overhead, and temporary workloads.

Memory is the primary capacity constraint on this node and should be monitored as additional services are deployed.

`monitor-lab-vm` and `media-lab-vm` are intentionally hosted on `prox-lab-02` to distribute persistent services across virtualization nodes. This prevents general Docker, monitoring, and media services from depending on a single Proxmox host.

## `prox-lab-03`

Planned third virtualization node for additional compute capacity and workload distribution.

### Capacity

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

### Capacity Notes

`prox-lab-03` is expected to provide capabilities similar to `prox-lab-02`, but capacity planning will be based on validated hardware rather than assumed specifications.

Final CPU, memory, storage, and VM allocations will be documented after the host is deployed and baseline resource utilization is established.

## Cluster Capacity

| Resource | `prox-lab-01` | `prox-lab-02` | `prox-lab-03` | Current Known Capacity |
|---|---:|---:|---:|---:|
| Physical Cores | 6 | 4 | Pending | 10 |
| Hardware Threads | 6 | 8 | Pending | 14 |
| Memory | 32 GB | 16 GB | Pending | 48 GB |
| Planned vCPU | 12 | 10 | Pending | 22 |
| Planned VM Memory | 22 GB | 14 GB | Pending | 36 GB |
| Unallocated Memory | ~10 GB | ~2 GB | Pending | ~12 GB |
| NVMe VM Storage | ~1 TB | ~1 TB | Pending | ~2 TB |

> Combined capacity is useful for planning, but CPU and memory remain local to each virtualization node unless workloads are migrated between hosts.

## Placement Considerations

Workload placement should account for both available resources and operational dependencies.

- Avoid concentrating unrelated persistent services on a single virtualization node
- Distribute infrastructure services across nodes where practical
- Maintain sufficient memory for the Proxmox host and temporary workloads
- Place resource-intensive workloads on nodes with appropriate available capacity
- Consider hardware requirements such as media transcoding when selecting a host
- Reevaluate workload placement as utilization and hardware availability change

The addition of `prox-lab-03` will provide further flexibility for workload distribution and future infrastructure services.

## Related Documentation

- [Resource Allocation Strategy](resource-allocation.md)
- Virtual Machine Deployment Baseline
- Proxmox Architecture
- Hardware Inventory
