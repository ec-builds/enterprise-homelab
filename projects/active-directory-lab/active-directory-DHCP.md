# 📡 Active Directory DHCP

**Status: 🟢 Operational**

## Overview

Windows Server DHCP was deployed on both domain controllers in a 50/50 load-balanced failover relationship, replacing the previous network DHCP service.

Deployment and validation commands are in the [Windows Server DHCP Deployment and Failover](../../docs/reference/windows/windows-server-DHCP-deployment-and-failover.md) reference.

> [!NOTE]
> Hostnames, IP addresses, and domain names have been sanitized for public release.

## Scope

| Setting | Value |
|---|---|
| Scope name | `LAN` |
| Network | `10.0.0.0/24` |
| Range | `10.0.0.100`–`10.0.0.199` |
| Lease duration | 1 day |
| 003 Router | `10.0.0.1` |
| 006 DNS Servers | `10.0.0.10`, `10.0.0.11` |
| 015 DNS Domain Name | `lab.example.com` |

Infrastructure systems use static addresses outside the DHCP range.

## Failover

| Setting | Value |
|---|---|
| Partners | `dc-lab-01`, `dc-lab-02` |
| Mode | Load Balance, 50/50 |
| Maximum Client Lead Time | 1 hour |
| Automatic state transition | Disabled |
| Message authentication | Enabled (shared secret stored outside the repository) |

Both servers were authorized in Active Directory before servicing clients. The `LAN` scope was created on `dc-lab-01` and replicated to `dc-lab-02` through the failover relationship.

Automatic state transition was left disabled so that a communication failure alone does not mark the partner as down. `PartnerDown` is declared manually during a confirmed extended outage.

DHCP-managed dynamic DNS registration was disabled. See [Active Directory DNS](./active-directory-DNS.md#record-management).

## Cutover

1. The previous DHCP service's allocation range was moved so it would not overlap with the new scope.
2. Existing clients were allowed to renew away from the original range.
3. The Windows DHCP scope was activated and client leases were validated.
4. The previous DHCP service was disabled.

## Failover Testing

Each DHCP server was shut down in turn.

- The surviving server entered `CommunicationInterrupted`.
- Clients released and renewed leases from the surviving server and received the expected gateway, DNS servers, domain suffix, and lease duration.
- After the partner was restored, the relationship returned to `Normal` automatically.

## Validation

| Check | Result |
|---|---|
| Both servers authorized in AD | ✅ |
| `LAN` scope active and consistent on both servers | ✅ |
| Failover state `Normal` with 50/50 load balance | ✅ |
| Maximum Client Lead Time 1 hour, authentication enabled | ✅ |
| Clients receive expected options | ✅ |
| Service continues with either server offline | ✅ |
| Return to `Normal` after recovery | ✅ |

## Outcome

Windows DHCP became the network's active DHCP service, with either domain controller able to serve the full scope. Client cutover and failover testing in both directions completed successfully.

## Related Documentation

- [Active Directory Lab](./README.md)
- [Domain Controller Architecture](./domain-controller-architecture.md)
- [Active Directory DNS](./active-directory-DNS.md)
- [Windows Server DHCP Deployment and Failover](../../docs/reference/windows/windows-server-DHCP-deployment-and-failover.md)
