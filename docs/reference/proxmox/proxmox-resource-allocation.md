# Proxmox Resource Allocation Strategy

Resource sizing and allocation standards for virtual machines in the Proxmox virtualization lab.

This document defines how CPU, memory, and storage should be assigned to workloads. Current host capacity, workload placement, and VM allocations are maintained separately in the [Proxmox Capacity Plan](capacity-plan.md).

## Core Principles

- Start with the minimum practical resource allocation
- Scale based on observed utilization rather than anticipated demand
- Avoid allocating resources "just in case"
- Maintain sufficient physical resources for the hypervisor and virtualization overhead
- Moderate CPU overcommitment is acceptable for non-concurrent lab workloads
- Treat memory as a more restrictive resource than CPU
- Size virtual disks conservatively and expand them when required
- Reevaluate allocations when workload behavior changes

## CPU Allocation

### Starting Point

Most Linux infrastructure VMs should begin with:

```text
2 vCPU
```

Increase CPU allocation only when workload utilization demonstrates a sustained need.

Desktop operating systems or computationally heavier workloads may require larger initial allocations.

### CPU Overcommitment

Assigned vCPUs represent schedulable processor capacity rather than dedicated physical CPU cores.

This allows the combined vCPU allocation across VMs to exceed the number of physical cores when workloads are not simultaneously CPU-intensive.

For example:

```text
6 physical cores

VM 1    4 vCPU
VM 2    4 vCPU
VM 3    2 vCPU
VM 4    2 vCPU
VM 5    2 vCPU
       -------
        14 vCPU
```

This represents approximately a **2.3:1 vCPU-to-core allocation ratio**.

Such overcommitment can be appropriate for lab environments where many VMs spend significant time idle or at low utilization.

### When to Increase vCPU

Increase CPU allocation when monitoring shows:

- Sustained high CPU utilization
- CPU saturation during normal workload operation
- Consistent performance limitations attributable to CPU availability
- Application requirements that exceed the existing allocation

Short CPU spikes alone generally do not justify increasing vCPU allocation.

### When to Reduce vCPU

Reduce CPU allocation when:

- A VM consistently uses only a small portion of its assigned CPU capacity
- Excessive vCPU allocation contributes to scheduling contention
- Resources would be more useful for other workloads

More vCPUs do not automatically improve VM performance.

## Memory Allocation

Memory should be allocated more conservatively than CPU because assigned RAM consumes finite host capacity.

### Starting Points

Typical starting allocations:

| Workload | Starting RAM |
|---|---:|
| Lightweight Linux infrastructure VM | 2 GB |
| General-purpose Debian / Docker host | 4 GB |
| Monitoring or security workload | 2–4 GB |
| Windows 11 lab VM | 8 GB |

These values are starting points rather than fixed requirements.

Actual allocations should be adjusted based on observed utilization and application requirements.

### Host Memory Reserve

Do not plan to allocate all physical host memory to VMs.

Maintain unallocated memory for:

- Proxmox VE
- Linux filesystem caching
- Virtualization overhead
- Temporary workloads
- Operational flexibility

For example:

```text
32 GB physical memory
24 GB planned VM allocation
 8 GB remaining capacity
```

The remaining memory is intentional capacity rather than wasted resources.

### When to Increase RAM

Increase memory when:

- Sustained memory utilization approaches the VM's available capacity
- The guest begins relying heavily on swap
- Applications experience memory pressure
- Additional services materially increase memory requirements

### When to Reduce RAM

Consider reducing memory when a VM consistently maintains substantial unused capacity and that memory could provide useful headroom elsewhere.

Avoid repeatedly resizing memory based on short-term fluctuations.

## Storage Allocation

Virtual disks should be sized for realistic current requirements with reasonable growth capacity.

Avoid excessively large initial virtual disks when storage can be expanded later.

### Storage Roles

Proxmox storage should be treated according to purpose:

- **File Storage** — ISOs, templates, backups, and other file-based content
- **VM Storage** — VM and container disks

NVMe-backed storage should be preferred for active VM workloads where its performance provides a practical benefit.

### Thin Provisioning

LVM-thin allows virtual disk capacity to be allocated without immediately consuming the full virtual disk size on physical storage.

For example:

```text
64 GB virtual disk
        │
        ▼
Only blocks actually written by the VM
consume physical thin-pool capacity
```

This makes moderately sized virtual disks practical while still requiring monitoring of actual thin-pool utilization.

Thin provisioning should not be treated as unlimited storage. Physical storage consumption must still be monitored.

### Disk Expansion

Prefer expanding an existing virtual disk when additional capacity is required rather than significantly oversizing disks during initial deployment.

Before expanding storage:

1. Confirm the workload actually requires additional capacity
2. Verify sufficient physical storage is available
3. Expand the virtual disk
4. Expand the guest partition, logical volume, or filesystem as required
5. Validate the new capacity from within the guest

## Resource Monitoring

Resource allocation decisions should be based on observed behavior.

Useful indicators include:

### CPU

- Average CPU utilization
- Sustained utilization
- Load during normal workload activity
- Host-level CPU contention

### Memory

- Guest memory utilization
- Swap activity
- Host memory utilization
- Available host memory

### Storage

- Guest filesystem utilization
- Thin-pool utilization
- Storage latency
- Available physical storage

A resource allocation should not be increased solely because unused physical capacity exists.

## Scaling Process

Use the following process when deploying and adjusting workloads:

```text
Determine workload requirements
        │
        ▼
Assign conservative starting resources
        │
        ▼
Deploy workload
        │
        ▼
Monitor normal utilization
        │
        ▼
Identify sustained resource pressure
        │
        ▼
Adjust allocation if required
        │
        ▼
Continue monitoring
```

This process keeps VM sizing tied to actual requirements rather than assumptions.

## Temporary Workloads

Temporary lab VMs should use conservative allocations and should not permanently consume capacity intended for persistent infrastructure.

When temporary testing requires additional resources:

- Use currently available host capacity
- Shut down unused workloads when practical
- Reduce temporary allocations after testing
- Move workloads to another node when resource contention develops

Temporary capacity should not automatically become permanent allocation.

## Resource Contention

When a virtualization node begins experiencing sustained resource contention:

1. Identify the constrained resource
2. Verify which workloads are consuming it
3. Reduce unnecessary VM allocations where appropriate
4. Move suitable workloads to another virtualization node
5. Increase physical host resources only when redistribution and right-sizing are insufficient

Adding hardware should not be the first response to inefficient resource allocation.

## Allocation vs. Capacity Planning

Resource allocation and capacity planning serve different purposes.

**Resource allocation** determines how much CPU, memory, and storage an individual workload should receive.

**Capacity planning** determines whether the virtualization hosts have sufficient resources to support the combined workload environment and where those workloads should run.

```text
Resource Allocation
        │
        └── How much does this VM need?

Capacity Planning
        │
        └── Where should it run, and does the host have capacity?
```

Current host specifications, VM placement, planned allocations, and remaining cluster capacity are documented in the [Proxmox Capacity Plan](capacity-plan.md).

## Rule of Thumb

> **Allocate for current requirements, monitor utilization, then scale.**

```text
Allocate conservatively
        ↓
Monitor utilization
        ↓
Identify sustained demand
        ↓
Adjust resources
        ↓
Reevaluate
```
