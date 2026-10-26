# AD CS Deployment Plan

**Status:** Planned  
**Type:** Implementation plan / placeholder  
**Lab:** Active Directory Lab

## Overview

Deploy an Active Directory-integrated certification authority to issue and manage internal certificates.

## Planned Work

1. Confirm CA topology and decide whether to use a lab-only enterprise issuing CA or an offline-root/issuing-CA hierarchy.
2. Select a dedicated Windows Server VM (not the domain controller), backup approach, DNS names, and administrative roles.
3. Install AD CS Certification Authority role and configure CA settings.
4. Publish reachable CRL/AIA locations and verify chain and revocation availability.
5. Back up CA database, private key, and configuration; document recovery procedure.

## Dependencies / Decisions

- Working Active Directory domain and DNS
- Decide and record CA name, Enterprise vs. Standalone CA, and CA hierarchy before installation; changing these later generally requires migration/rebuild
- Plan HTTP-reachable CRL/AIA publication for non-domain clients

## Validation / Completion Criteria

- [ ] CA issues a test certificate; client validates trust and revocation
- [ ] CA backup and recovery procedure recorded

## Implementation Notes

> Placeholder: record final architecture, configuration references, test results, screenshots, and lessons learned when implementation begins. Do not mark complete before validation.
