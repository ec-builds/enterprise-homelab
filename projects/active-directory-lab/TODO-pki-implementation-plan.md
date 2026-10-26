# PKI Implementation Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Active Directory Lab

## Overview

Use AD CS certificates to secure native-HTTPS infrastructure and manage certificate lifecycles.

## Planned Work

1. Define server/client certificate templates and least-privilege enrollment permissions.
2. Configure Windows autoenrollment where applicable; plan manual or automated enrollment for Linux appliances.
3. Distribute CA trust to domain and non-domain clients as needed.
4. Install unique certificates on native-HTTPS services such as Proxmox and Synology, validating hostname and chain.
5. Define certificate validity periods, renewal ownership, deployment/reload procedures, revocation, and certificate replacement for each service.
6. Plan renewal automation where feasible; AD CS does not natively expose ACME, so non-Windows enrollment/deployment requires a defined workflow.
7. Monitor certificate expiration (for example, Prometheus blackbox exporter with 30-day warning) and verify alert delivery.

## Dependencies / Decisions

- AD CS deployment and working CRL/AIA distribution
- Service-specific certificate installation and renewal support
- Trust-store distribution for domain-joined Windows, Linux, Proxmox, Synology, macOS, and other relevant clients
- Certificate renewal ownership and safe storage of private keys

## Validation / Completion Criteria

- [ ] Trusted clients connect to native-HTTPS services without certificate warnings
- [ ] Renewal and revocation behavior verified
- [ ] Expiration warning and service certificate replacement tested
- [ ] Relevant non-domain clients trust the CA chain

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.
