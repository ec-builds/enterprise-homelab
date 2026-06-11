# 🔒 System Hardening

This document outlines planned security improvements for the Media Services Platform.

The current deployment resides on a trusted home network and is not exposed directly to the internet. As a result, security hardening has been intentionally limited during the initial deployment phase while core functionality and documentation were established.

This document serves as a roadmap for future security enhancements.

---

## Current Security Controls

The following measures have already been implemented:

- Read-only SMB media mount
- Dedicated service account for Jellyfin NAS access
- Separation of storage and application services
- Operating system updates applied during deployment
- Local network administration via SSH

---

## Planned Improvements

### SSH Key-Based Authentication

Replace password-based authentication with public/private key authentication.

Benefits include:

- Stronger authentication
- Reduced risk of password attacks
- Improved administrative security

---

### Disable Password Authentication

After SSH keys have been validated, password authentication may be disabled.

Benefits include:

- Reduced attack surface
- Protection against password guessing attacks

---

### Disable Root SSH Login

Administrative access should be performed using standard user accounts with elevated privileges when required.

Benefits include:

- Improved accountability
- Reduced exposure of privileged accounts

---

### Automated Security Updates

Evaluate automatic installation of security-related package updates.

Benefits include:

- Faster patch deployment
- Reduced maintenance requirements

---

### Service and Port Review

Periodically review active services and listening ports.

Goals include:

- Removing unnecessary services
- Reducing attack surface
- Maintaining minimal system exposure

---

## Future Considerations

Potential future enhancements include:

- Firewall configuration
- Intrusion detection
- Centralized logging
- Security monitoring
- VPN-based administrative access

These items will be evaluated as the homelab environment continues to grow.

---

## Related Documentation

- [SSH Configuration](./ssh-configuration.md)
- [Base System Configuration](./base-system-configuration.md)
- [Architecture](./architecture.md)

---

## Status

🚧 Work in Progress

System hardening is planned but has not yet been fully implemented. The current focus remains on learning, documentation, and establishing a stable platform before introducing additional security controls.
