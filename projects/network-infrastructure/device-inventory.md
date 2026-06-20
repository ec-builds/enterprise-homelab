# Device Inventory

**Project:** Network Infrastructure  
**Status:** 🟢 Active

## Overview

This document defines how device inventory is managed within the homelab environment.

The authoritative hardware inventory is maintained in:

```text
equipment/README.md
```

All infrastructure devices, servers, workstations, networking equipment, storage systems, and peripherals should be documented there.

---

## Source of Truth

The following document serves as the official inventory repository:

```text
equipment/README.md
```

Information maintained in the inventory includes:

- Device Name
- Device Type
- Hardware Specifications
- Assigned Role
- Operational Status
- Asset Documentation
- Supporting Configuration Files

---

## Inventory Categories

The inventory may contain devices in the following categories:

### Network Infrastructure

- Routers
- Switches
- Access Points
- Network Appliances

### Compute

- Servers
- Hypervisors
- Virtualization Hosts
- Workstations

### Storage

- NAS Systems
- Backup Devices
- External Storage

### Endpoints

- Laptops
- Desktops
- Mobile Devices

### Peripherals

- Printers
- Monitors
- Docking Stations
- UPS Devices

---

## Documentation Standards

When adding a new device:

1. Add the device to `equipment/README.md`
2. Create a dedicated device document if applicable
3. Assign the appropriate role and status
4. Update topology documentation if required
5. Update IP reservations if applicable

---

## Related Documentation

- ip-addressing-plan.md
- network-services.md
- network-topology.md
- disaster-recovery.md
- equipment/README.md
