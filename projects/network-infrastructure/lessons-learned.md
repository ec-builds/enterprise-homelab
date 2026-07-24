# Lessons Learned

Key decisions and implementation lessons from building and maintaining the Enterprise Homelab.

## 2026-07-23 — Validate Vendor Defaults First

**Context**

Modified the WireGuard configuration before verifying the default deployment.

**Lesson**

Always establish a known-good baseline before making customizations.

**Result**

- Verified the default configuration.
- Confirmed VPN connectivity.
- Customized the VPN only after validation.

## 2026-07-24 — Document While Building

**Context**

Writing documentation after deployments made details easier to forget.

**Lesson**

Document infrastructure during implementation, not afterward.

**Result**

- Documentation stays accurate.
- Decisions are recorded while fresh.
- Less rework and fewer omissions.

## 2026-06-13 — GitHub as the Source of Truth

**Context**

Documentation was split across multiple platforms.

**Lesson**

Maintain documentation alongside the infrastructure it describes.

**Result**

- GitHub stores all project documentation.
- Bitwarden stores passwords and secrets.

## 2026-06-13 — Document the Current Environment First

**Context**

Planning focused on future infrastructure before documenting what already existed.

**Lesson**

Document the current environment before designing future improvements.

**Result**

- Current infrastructure is fully documented.
- Future work remains separate from production documentation.

## 2026-06-13 — Separate Topology from IP Documentation

**Context**

Topology diagrams became cluttered with IP addressing details.

**Lesson**

Each document should have a single purpose.

**Result**

- Topology diagrams show connectivity.
- IP addresses are documented separately.

## 2026-06-13 — Use DHCP Reservations

**Context**

Infrastructure devices required consistent IP addresses.

**Lesson**

Prefer DHCP reservations over static endpoint configuration.

**Result**

- Centralized IP management.
- Easier maintenance.
- Reduced configuration drift.

## 2026-06-13 — Design for Growth

**Context**

The homelab is expected to expand significantly.

**Lesson**

Define standards before they become necessary.

**Result**

- Structured IP allocation.
- Consistent device organization.
- Room for future expansion.

## 2026-06-13 — Keep Public Documentation Sanitized

**Context**

The repository is publicly accessible.

**Lesson**

Share architecture, not sensitive information.

**Result**

- Credentials remain in Bitwarden.
- Public documentation excludes sensitive data.
