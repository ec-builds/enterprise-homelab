## 2026- — Plan IP Addressing for Growth and Documentation

**Context**

While defining the network addressing plan, I needed to organize address ranges for infrastructure, endpoints, reserved devices, and future expansion. The documentation also needed to be useful publicly without exposing unnecessary details about the internal network.

**Lesson**

An IP addressing plan should account for future growth before devices and services are deployed. Public documentation should communicate the design and reasoning while sanitizing internal addressing details where appropriate.

**Result**

- Defined structured address ranges instead of assigning addresses ad hoc.
- Reserved capacity for future infrastructure, endpoints, and network services.
- Reduced the likelihood of address conflicts and future renumbering.
- Established sanitized addressing examples for public-facing documentation.

## 2026- — Reserve DHCP Capacity for Static Infrastructure

**Context**

While configuring DHCP, I needed to ensure that dynamically assigned clients would not consume addresses intended for infrastructure and other devices requiring predictable addressing. The DHCP pool was configured as `10.0.0.150–10.0.0.249`, leaving addresses outside the pool available for static assignments and reservations.

**Lesson**

Define DHCP scopes with intentional space outside the dynamic pool so infrastructure and devices requiring predictable addresses can be added without redesigning the addressing scheme.

**Result**

- Configured the DHCP pool as `10.0.0.150–10.0.0.249`.
- Preserved address space for statically addressed infrastructure and reserved devices.
- Reduced the risk of conflicts between dynamic and manually assigned addresses.
- Created room for future network growth without changing the DHCP scope.

## 2026- — Verify Guest and IoT Network Isolation

**Context**

A guest network was configured for IoT and other less-trusted devices. Intranet access was disabled to prevent those devices from reaching the primary LAN, and client isolation was tested to confirm devices on the guest network could not communicate directly with one another.

**Lesson**

Network isolation should be validated rather than assumed from configuration settings. Segmentation is only useful when the intended traffic restrictions are confirmed through testing.

**Result**

- Disabled intranet access for the guest/IoT network.
- Prevented less-trusted devices from accessing the primary internal network.
- Verified that isolated clients could not communicate directly with each other.
- Established a basic segmentation boundary for IoT devices pending future VLAN-based segmentation.

