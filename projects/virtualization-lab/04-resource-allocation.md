# 📊 Proxmox Resource Allocation

Workload placement and capacity planning across the three-node Proxmox
virtualization lab.

## Host Overview

| Host | CPU | Cores / Threads | Memory | Primary VM Storage | Status |
|---|---|---:|---:|---|---|
| `prox-lab-01` | Intel Core i5-9500T | 6 / 6 | 32 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-02` | Intel Core i7-6700T | 4 / 8 | 16 GB | ~1 TB NVMe LVM-thin | Active |
| `prox-lab-03` | Intel Core i5-12400 | 6 / 12 | 16 GB | ~337 GB NVMe LVM-thin | Active |

The three-node architecture provides a combined **16 physical cores, 26 hardware
threads, and 64 GB of memory** for virtualization workloads.

> **Note:** Firewall and routing services are hosted on dedicated hardware and
> are excluded from Proxmox capacity calculations.



## Workload Placement

Workloads are distributed across virtualization nodes to balance resource
utilization and reduce the impact of individual host maintenance or failure.

```text
prox-lab-01
├── dc-lab-01
├── docker-lab-01
├── adguard-lab-01
├── win11-lab-01
└── win11-lab-02

prox-lab-02
├── dc-lab-02
└── monitor-lab-01

prox-lab-03
├── media-lab-01
├── adguard-lab-02
├── security-lab-01   (planned)
└── utility-lab-01    (planned)
```

Persistent services are intentionally distributed across all three
virtualization nodes. General Docker services remain on `prox-lab-01`,
monitoring services and the secondary domain controller are hosted on
`prox-lab-02`, and media workloads are assigned to `prox-lab-03`. Security and
utility workloads are planned for `prox-lab-03`.

The two domain controllers and the two AdGuard Home instances are each split
across separate nodes, so directory, internal DNS, and DNS filtering remain
available when any single node is offline.

This distribution reduces workload concentration on `prox-lab-02` while
making use of the available compute capacity on `prox-lab-03`.



## `prox-lab-01`

Primary virtualization node for persistent infrastructure, general
self-hosted applications, and endpoint testing.

### Capacity

| Resource | Host Capacity | Planned Allocation | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 6 cores / 6 threads | 14 vCPU | ~2.3:1 vCPU-to-core |
| Memory | 32 GB | 25 GB | ~7 GB unallocated |
| NVMe Storage | ~1 TB | Workload dependent | Expand as required |

### VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `dc-lab-01` | AD DS / DNS | 2 | 2 GB |
| `docker-lab-01` | Debian / Docker Host | 2 | 4 GB |
| `adguard-lab-01` | AdGuard Home DNS Filtering | 2 | 3 GB |
| `win11-lab-01` | Domain / Endpoint Testing | 4 | 8 GB |
| `win11-lab-02` | Additional Endpoint Testing | 4 | 8 GB |
| **Total** | | **14 vCPU** | **25 GB** |

### Capacity Notes

CPU is intentionally overcommitted at approximately **2.3:1**. These workloads
are not expected to sustain maximum CPU utilization simultaneously, and the
Windows endpoint VMs are not always running.

Approximately **7 GB of memory remains unallocated** for the hypervisor,
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

### VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `dc-lab-02` | Secondary AD DS / DNS | 2 | 2 GB |
| `monitor-lab-01` | Monitoring / Metrics / Logging | 2 | 2 GB |
| **Total** | | **4 vCPU** | **4 GB** |

### Capacity Notes

The processor provides **4 physical cores and 8 hardware threads**. Current
planned workloads leave substantial CPU capacity available for monitoring
growth and additional infrastructure services.

Approximately **12 GB of memory remains unallocated** for the hypervisor,
filesystem caching, virtualization overhead, monitoring growth, and temporary
workloads.

`monitor-lab-01` is intentionally given additional host-level capacity because
metrics and logging workloads may grow as additional systems, containers, and
network devices are integrated into the monitoring environment.

The secondary domain controller provides directory and DNS redundancy on a
different physical virtualization node from `dc-lab-01`.



## `prox-lab-03`

Third virtualization node providing media services and the secondary DNS
filtering instance, with security and utility workloads planned, while also
contributing compute capacity and cluster quorum.

### Capacity

| Resource | Host Capacity | Allocated | Remaining / Ratio |
|---|---:|---:|---:|
| CPU | 6 cores / 12 threads | 4 vCPU (8 with planned) | ~0.33:1 vCPU-to-thread (~0.67:1 with planned) |
| Memory | 16 GB | 6 GB (11 GB with planned) | ~10 GB unallocated (~5 GB with planned) |
| NVMe VM Storage | ~337 GB | Workload dependent | Expand as required |

### VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `media-lab-01` | Docker / Jellyfin Media Services | 2 | 3 GB |
| `adguard-lab-02` | AdGuard Home DNS Filtering | 2 | 3 GB |
| **Total** | | **4 vCPU** | **6 GB** |

### Planned VMs

| VM / Workload | Role | vCPU | RAM |
|---|---|---:|---:|
| `security-lab-01` | Security / SIEM Testing | 2 | 3 GB |
| `utility-lab-01` | Linux / Infrastructure Utilities | 2 | 2 GB |
| **Total** | | **4 vCPU** | **5 GB** |

### Capacity Notes

The processor provides **6 physical cores and 12 hardware threads**, the most
hardware threads of any node in the cluster.

CPU capacity is sufficient for the current and planned workloads, which are
not expected to sustain maximum utilization simultaneously.

The current workloads use **6 GB of the node's 16 GB**, leaving about 10 GB
for the hypervisor, overhead, and growth. Adding both planned VMs would bring
allocations to **11 GB**, leaving about **5 GB** unallocated.

The node's hardware was replaced in October 2026, doubling its memory from
8 GB to 16 GB. See the
[Replacement Record](./08-proxmox-node-replacement.md#replacement-record).

The primary NVMe drive hosts both the Proxmox installation and approximately
**337 GB of LVM-thin storage** for VM and container disks.

A secondary 1 TB HDD provides general-purpose storage and is not included in the
VM storage capacity shown above.



## Cluster Capacity

| Resource | `prox-lab-01` | `prox-lab-02` | `prox-lab-03` | Cluster Total |
|---|---:|---:|---:|---:|
| Physical Cores | 6 | 4 | 6 | **16** |
| Hardware Threads | 6 | 8 | 12 | **26** |
| Memory | 32 GB | 16 GB | 16 GB | **64 GB** |
| Allocated vCPU | 14 | 4 | 4 | **22** |
| Allocated VM Memory | 25 GB | 4 GB | 6 GB | **35 GB** |
| Unallocated Memory | ~7 GB | ~12 GB | ~10 GB | **~29 GB** |
| Planned VMs (not deployed) | — | — | 4 vCPU / 5 GB | **4 vCPU / 5 GB** |
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
reserved exclusively for future use. Media services and the secondary AdGuard
instance run on this node, and security and utility services are planned for
it, to reduce resource concentration on `prox-lab-02`.

With 16 GB of memory after its October 2026 hardware replacement, the node has
capacity for both the current and planned workloads.



## Related Documentation

- Proxmox Cluster
- Proxmox Storage
- Virtual Machine Deployment Baseline
- Hardware Inventory
