# Homelab Decisions

This document records major architectural, operational, and strategic decisions made throughout the lifecycle of the homelab.

The goal is to document **why** decisions were made, so future changes can be evaluated against past reasoning. Each decision is a single row — the **Why** column carries the reasoning that matters.

> [!NOTE]
> This log is intentionally lightweight so it stays current. If a single decision ever needs deeper explanation, it can graduate to its own file in `docs/decisions/` and be linked from the table.

## Decision Log

| Date | Decision | Why | Status |
|------|----------|-----|--------|
| 2026-06-13 | GitHub as documentation source of truth | Ends Obsidian/GitHub duplication and drift; adds version control, review via Git history, and a public portfolio. Trade-off: less convenient for quick note-taking. | Active |
| 2026-07-30 | OPNsense as primary firewall; Cisco switch stays Layer 2 | Routing and its rules must live on the same device — splitting them risks silent drops and policy gaps. OPNsense gives stateful rules, logging, and IDS/IPS in one control point; switch ACLs are stateless and weaker. Inter-VLAN volume at homelab scale doesn't need the switch's hardware routing. | Active |
| 2026-07-30 | Prioritize security, identity, and cloud over deep networking | Aligns with long-term, remote-friendly career goals. Each phase (security → identity → cloud) builds the model the next reuses. The Cisco switch is foundational infrastructure, not the focus. Full breakdown in `docs/homelab-direction.md`. | Active |
| 2026-07-30 | Secrets: Bitwarden now, Vaultwarden as goal | Self-hosted secrets align with the lab's ownership model, but migration is gated behind research (secure export, hardening, backup/recovery, lockout risk). A misconfigured self-hosted secrets store is a serious risk, so this stays planned until vetted. | Proposed |
| 2026-07-30 | Simplify this decision log to a single-table format | The full multi-section ADR format was more than could realistically be maintained by hand without AI. A lean table with a substantive Why column keeps the documented-reasoning value while staying maintainable unaided — a current, honest log beats an elaborate, stale one. | Active |

## Status Key

- **Active** — decided and in effect (built or being built).
- **Proposed** — decided in principle, not yet implemented (often pending research).
- **Superseded** — replaced by a later decision (link to the newer row).

## Decision Template

For a decision that graduates to its own file, see:
- `templates/homelab-decision-template.md`
