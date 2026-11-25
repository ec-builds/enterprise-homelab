# Domain Controller Recovery Runbook

**Status: ⚪ Planned**  
**Targets:** see [DR Overview](../dr-overview.md#recovery-targets)

## Scenario

`dc-lab-01` and `dc-lab-02` run on separate Proxmox hosts and replicate Active Directory, DNS and DHCP (failover partners). Losing one DC is an inconvenience; losing both is an outage.

## One DC Lost

The surviving DC keeps authentication, DNS and DHCP running.

1. Confirm the survivor is healthy: `dcdiag`, `repadmin /replsummary`, DNS resolution and DHCP leases.
2. Check which DC holds the FSMO roles: `netdom query fsmo`. If the lost DC held them, seize them on the survivor.
3. Don't restore the lost DC from an old backup and rejoin it. An outdated DC can cause replication problems (USN rollback).
4. Remove the lost DC from AD: metadata cleanup, its DNS records and its DHCP failover relationship.
5. Build a new DC from the Windows Server template and promote it as an additional domain controller.
6. Recreate DHCP failover with the new partner.

## Both DCs Lost

1. Restore one DC from the latest PBS backup and start it isolated if possible.
2. Confirm AD, DNS and SYSVOL are working on the restored DC.
3. Clean up the second DC's metadata, then promote a new second DC rather than restoring it too.
4. Re-establish DHCP failover.

## Validation

- [ ] `dcdiag` and `repadmin` clean on both DCs
- [ ] Clients authenticate, resolve names and get DHCP leases
- [ ] Group Policy applies (`gpresult /r` on a client)
- [ ] Time to recover recorded in the [DR Test Log](../dr-test-log.md)

Test with isolated restores first. Practicing a seizure or metadata cleanup against the live domain changes it permanently.
