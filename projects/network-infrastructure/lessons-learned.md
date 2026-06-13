# Lessons Learned

Document notable decisions, discoveries, challenges, and improvements encountered while designing, implementing, and maintaining the network infrastructure.

---

## 2026-06-13 — GitHub as the Documentation Source of Truth

### Context

Network documentation was originally maintained in Obsidian. As the homelab matured and project documentation expanded, maintaining information across multiple platforms introduced duplication and increased the risk of documentation drift.

### Lesson Learned

Infrastructure documentation is most effective when maintained alongside the projects it describes.

### Outcome

- GitHub became the authoritative source of homelab documentation.
- Project documentation is maintained within each project directory.
- Shared standards, runbooks, and decisions are maintained under the repository's `docs/` directory.
- Bitwarden remains the source of truth for passwords, secrets, and sensitive information.

---

## 2026-06-13 — Document the Current State Before Designing the Future State

### Context

Initial planning focused heavily on future technologies such as VLANs, Proxmox, managed switching, and dedicated firewall appliances.

### Lesson Learned

Documenting the existing environment first provides a stronger foundation for future planning and avoids documenting infrastructure that does not yet exist.

### Outcome

The Network Infrastructure project now reflects the current environment:

- ASUS RT-AX5400 router
- Synology DS718+
- Debian media server
- Guest Wi-Fi isolation for IoT devices
- DHCP reservations for infrastructure devices

Future enhancements remain documented separately as planned work.

---

## 2026-06-13 — Separate Topology Documentation from IP Address Documentation

### Context

Early topology diagrams attempted to include both connectivity and IP addressing information.

### Lesson Learned

Network topology diagrams should focus on device relationships and connectivity. IP addressing information should be maintained separately.

### Outcome

- Topology diagrams document how devices connect.
- IP assignments are maintained within `ip-addressing-plan.md`.
- Documentation remains easier to maintain as devices change.

---

## 2026-06-13 — Use DHCP Reservations Instead of Static IP Configuration

### Context

Infrastructure devices required predictable addressing while maintaining centralized management.

### Lesson Learned

DHCP reservations provide the benefits of static addressing while simplifying device management and reducing configuration drift.

### Outcome

Infrastructure devices receive reserved addresses through the router while continuing to use DHCP on the endpoint.

Examples include:

- Synology NAS
- Media Server
- Future network infrastructure devices

---

## 2026-06-13 — Design an Addressing Scheme Before It Is Needed

### Context

The current environment contains relatively few devices but is expected to grow with virtualization, monitoring, automation, and security projects.

### Lesson Learned

Establishing an addressing standard early prevents future rework and improves consistency across projects.

### Outcome

The network uses a structured allocation model:

- Core Infrastructure
- Service Infrastructure
- Static Endpoints
- Homelab Infrastructure
- DHCP Clients

This approach provides room for future expansion without requiring renumbering.

---

## 2026-06-13 — Keep Public Documentation Sanitized

### Context

The repository is intended to serve as both documentation and a public portfolio.

### Lesson Learned

Public documentation should describe systems and architectures without exposing sensitive operational information.

### Outcome

The repository excludes:

- Passwords
- API keys
- Recovery codes
- Public IP addresses
- Dynamic DNS hostnames
- VPN endpoints
- Personally identifying infrastructure details

Sensitive information is maintained separately within Bitwarden.


