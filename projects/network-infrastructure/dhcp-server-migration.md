# DHCP Server Migration

**Status: 🟡 In Progress**

## Overview

The homelab originally relied on an ASUS RT-AX5400 router for DHCP. As Active Directory services were introduced, DHCP was moved to two Windows Server domain controllers, `dc-lab-01` and `dc-lab-02`, configured with DHCP failover.

Rather than simply disabling DHCP on the ASUS and enabling the Windows scope, the migration was planned to avoid disrupting connected devices or creating duplicate IP addresses.

> **Note:** IP addresses and allocation ranges shown below are examples and do not represent the deployed environment.

## Migration Challenge

The ASUS router had already issued leases throughout the existing DHCP range.

Those leases remain valid even if DHCP is disabled on the router. The new Windows DHCP servers also have no knowledge of leases previously issued by the ASUS.

Activating Windows DHCP over the same range could therefore result in Windows assigning an address that was still being used by another device.

## Migration Strategy

The legacy and replacement DHCP servers were temporarily given separate, non-overlapping address ranges.

For example:

```text
ASUS RT-AX5400
Legacy DHCP
10.0.0.150 - 10.0.0.199
        │
        │ No overlap
        ▼
Windows DHCP
dc-lab-01 + dc-lab-02
10.0.0.200 - 10.0.0.254
```

The ASUS lease duration was temporarily reduced to one hour in order to accelerate lease turnover.

Existing clients could continue using their current leases and gradually renew into the temporary ASUS range. Once the replacement DHCP range was confirmed clear of active legacy leases, the Windows DHCP scope could be activated without overlapping allocations.

## Cutover

1. Move the ASUS DHCP pool to the temporary `10.0.0.150 - 10.0.0.199` range.
2. Reduce the ASUS DHCP lease duration.
3. Allow existing leases to renew into the temporary range.
4. Confirm `10.0.0.200 - 10.0.0.254` is clear of active legacy leases.
5. Activate the Windows DHCP scope on `dc-lab-01` and `dc-lab-02`.
6. Disable DHCP on the ASUS RT-AX5400.
7. Renew a test client.
8. Verify the new address, gateway, DNS servers, and DNS domain.
9. Confirm the lease appears in Windows DHCP.
10. Allow remaining clients to migrate normally.

## Rollback

If Windows DHCP does not operate as expected, the Windows scope can be deactivated and DHCP temporarily restored on the ASUS router while the issue is investigated.

## Outcome

Pending completion of client migration and retirement of DHCP services on the ASUS RT-AX5400.

## Lessons Learned

- Disabling a DHCP server does not invalidate leases it has already issued.
- A replacement DHCP server does not automatically know about legacy leases.
- Overlapping DHCP pools can create duplicate IP conflicts during migration.
- Temporary non-overlapping pools provide a safer transition between DHCP servers.
- Shortening the legacy lease duration can accelerate a planned migration.
- The replacement DHCP infrastructure should be validated before retiring the existing service.
