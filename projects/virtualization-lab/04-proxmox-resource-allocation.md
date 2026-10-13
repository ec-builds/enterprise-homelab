# 📊 Proxmox Resource Allocation

Workload placement and capacity planning across the three-node Proxmox
virtualization lab.

## Host Overview

| Host | CPU | Cores / Threads | Memory | Primary VM Storage | Status |
|---|---|---:|---:|---|---|
| `prox-lab-01` | Intel Core i5-9500T | 6 / 6 | 32 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-02` | Intel Core i7-6700T | 4 / 8 | 16 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-03` | Intel Core i7-6700T | 4 / 8 | 8 GB | ~337 GB NVMe LVM-thin | Active |

The three-node architecture provides a combined **14 physical cores, 22 hardware
threads, and 56 GB of memory** for virtualization workloads.

> **Note:** Firewall and routing services are hosted on dedicated hardware and
> are excluded from Proxmox capacity calculations.



## Workload Placement

Workloads are distributed across virtualization nodes to balance resource
utilization and reduce the impact of individual host maintenance or failure.

```text
prox-lab-01
├── win11-lab-vm01
├── win11-lab-vm02
├── docker-lab-vm
└── dc01-lab-vm

prox-lab-02
├── monitor-lab-vm
└── dc02-lab-vm

prox-lab-03
├── security-lab-vm
├── utility-lab-vm
└── media-lab-vm
```

Persistent services are intentionally distributed across all three
virtualization nodes. General Docker services remain on `prox-lab-01`,
monitoring services and the secondary domain controller are hosted on
`prox-lab-02`, while security, utility, and media workloads are assigned to
`prox-lab-03`.

This distribution reduces workload concentration on `prox-lab-02` while
making use of the available compute capacity on `prox-lab-03`.



## `prox-lab-01`

Primary virtualization node for persistent infrastructure, general
self-hosted applications, and endpoint testing.

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
| `dc01-lab-vm` | AD DS / DNS | 2 | 2 GB |
| **Total** | | **12 vCPU** | **22 GB** |

### Capacity Notes

CPU is intentionally overcommitted at approximately **2:1**. These workloads
are not expected to sustain maximum CPU utilization simultaneously.

Approximately **10 GB of memory remains unallocated** for the hypervisor,
filesystem caching, virtualization overhead, and temporary workloads.



## `prox-lab-02`

Secondary virtualization node for infrastructure redundancy and centralized
monitoring services.

### Capacity

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 4 cores / 8 threads | 4 vCPU | ~0.5:1 vCPU-to-thread |
| Memory | 16 GB | 4 GB | ~12 GB unallocated |
| NVMe Storage | ~1 TB | Workload dependent | Expand as required |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `monitor-lab-vm` | Monitoring / Metrics / Logging | 2 | 2 GB |
| `dc02-lab-vm` | Secondary AD DS / DNS | 2 | 2 GB |
| **Total** | | **4 vCPU** | **4 GB** |

### Capacity Notes

The processor provides **4 physical cores and 8 hardware threads**. Current
planned workloads leave substantial CPU capacity available for monitoring
growth and additional infrastructure services.

Approximately **12 GB of memory remains unallocated** for the hypervisor,
filesystem caching, virtualization overhead, monitoring growth, and temporary
workloads.

`monitor-lab-vm` is intentionally given additional host-level capacity because
metrics and logging workloads may grow as additional systems, containers, and
network devices are integrated into the monitoring environment.

The secondary domain controller provides directory and DNS redundancy on a
different physical virtualization node from `dc01-lab-vm`.



## `prox-lab-03`

Third virtualization node providing security, utility, and media workloads
while also contributing compute capacity and cluster quorum.

### Capacity

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 4 cores / 8 threads | 6 vCPU | ~0.75:1 vCPU-to-thread |
| Memory | 8 GB | 8 GB | No planned memory reserve |
| NVMe VM Storage | ~337 GB | Workload dependent | Expand as required |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `security-lab-vm` | Security / SIEM Testing | 2 | 3 GB |
| `utility-lab-vm` | Linux / Infrastructure Utilities | 2 | 2 GB |
| `media-lab-vm` | Docker / Jellyfin Media Services | 2 | 3 GB |
| **Total** | | **6 vCPU** | **8 GB** |

### Capacity Notes

The processor provides **4 physical cores and 8 hardware threads**, providing
compute capability similar to `prox-lab-02`.

CPU capacity is sufficient for the planned workloads, which are not expected
to sustain maximum utilization simultaneously.

Memory is the primary capacity constraint on this node. The planned
allocations consume the node's current **8 GB of RAM**, so actual memory
utilization should be monitored and workloads should not be expected to
consume their full allocations simultaneously.

A future memory upgrade would provide additional operating margin and allow
these workloads to grow without requiring redistribution to another node.

The primary NVMe drive hosts both the Proxmox installation and approximately
**337 GB of LVM-thin storage** for VM and container disks.

A secondary HDD provides general-purpose storage and is not included in the
VM storage capacity shown above.



## Cluster Capacity

| Resource | `prox-lab-01` | `prox-lab-02` | `prox-lab-03` | Cluster Total |
|---|---:|---:|---:|---:|
| Physical Cores | 6 | 4 | 4 | **14** |
| Hardware Threads | 6 | 8 | 8 | **22** |
| Memory | 32 GB | 16 GB | 8 GB | **56 GB** |
| Planned vCPU | 12 | 4 | 6 | **22** |
| Planned VM Memory | 22 GB | 4 GB | 8 GB | **34 GB** |
| Unallocated Memory | ~10 GB | ~12 GB | ~0 GB | **~22 GB** |
| NVMe VM Storage | ~1 TB | ~1 TB | ~337 GB | **~2.3 TB** |

> **Note:** Combined capacity is useful for planning, but CPU and memory remain
> local to each virtualization node. Cluster totals do not represent a single
> shared resource pool unless workloads are migrated between hosts.



## Placement Considerations

Workload placement should account for both available resources and operational
dependencies.

- Avoid concentrating unrelated persistent services on a single virtualization node
- Distribute infrastructure services across nodes where practical
- Maintain sufficient memory for the Proxmox host and virtualization overhead
- Place resource-intensive workloads on nodes with appropriate available capacity
- Consider hardware requirements such as media transcoding when selecting a host
- Preserve spare capacity for migration, maintenance, and temporary lab workloads
- Reevaluate workload placement as utilization and hardware availability change

`prox-lab-03` now provides active workload capacity rather than remaining
reserved exclusively for future use. Security, utility, and media services are
placed on this node to reduce resource concentration on `prox-lab-02`.

Its current **8 GB memory capacity is the primary limitation** of this
placement. Increasing memory capacity in the future would provide additional
headroom for these workloads while maintaining the current distribution
strategy.



## Related Documentation

- Proxmox Cluster
- Proxmox Storage
- Virtual Machine Deployment Baseline
- Hardware Inventory
