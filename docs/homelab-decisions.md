# ⚖️ Homelab Decisions

This document records major architectural, operational, and strategic decisions made throughout the lifecycle of the homelab.

The goal is to document **why** decisions were made, so future changes can be evaluated against past reasoning. Each decision is a single row — the **Why** column carries the reasoning that matters.

> [!NOTE]
> This log is intentionally lightweight so it stays current. If a single decision ever needs deeper explanation, it can graduate to its own file in `docs/decisions/` and be linked from the table.

## Decision Log

| Date | Decision | Why | Status |
|------|----------|-----|--------|
| 2026-06-13 | GitHub as documentation source of truth | Ends Obsidian/GitHub duplication and drift; adds version control, review via Git history, and a public portfolio. Trade-off: less convenient for quick note-taking. | Active |
| 2026-07-30 | OPNsense as primary firewall; Cisco switch stays Layer 2 | Routing and its rules must live on the same device — splitting them risks silent drops and policy gaps. OPNsense gives stateful rules, logging, and IDS/IPS in one control point; switch ACLs are stateless and weaker. Inter-VLAN volume at homelab scale doesn't need the switch's hardware routing. | Active |
| 2026-07-30 | Prioritize security, identity, and cloud over deep networking | Aligns with long-term, remote-friendly career goals. Each state (security → identity → cloud) builds the model the next reuses. The Cisco switch is foundational infrastructure, not the focus. Full breakdown in `docs/homelab-direction.md`. | Active |
| 2026-07-30 | Secrets: Bitwarden now, Vaultwarden as goal | Self-hosted secrets align with the lab's ownership model, but migration is gated behind research (secure export, hardening, backup/recovery, lockout risk). A misconfigured self-hosted secrets store is a serious risk, so this stays planned until vetted. | Proposed |
| 2026-07-30 | Simplify this decision log to a single-table format | The full multi-section ADR format was more than could realistically be maintained by hand — a current, honest log beats an elaborate, stale one. | Active |
| 2026-11-24 | Reject the Mac mini as the firewall platform; use dedicated hardware | OPNsense on the 2014 Mac mini had inconsistent WAN connectivity with no confirmed root cause. The firewall is a single point of failure, so it needs stable hardware with supported Intel network controllers and no external adapters. Details in [`opnsense-mac-mini-validation.md`](../projects/network-security/opnsense-mac-mini-validation.md). | Active |
| 2026-11-24 | Run the NUT UPS server natively on the standalone Mac mini | The UPS signals one machine over USB, and that machine has to stay up longest and shut itself down last. A low-power host outside the Proxmox cluster fits; a VM on a cluster node goes down with the node. NUT runs natively, not in Docker, because it must shut down its own host and trigger the UPS outlet power-cycle at the end of shutdown, and power protection shouldn't depend on Docker. Details in the [UPS Power Protection Plan](../projects/backup-disaster-recovery/TODO-ups-power-protection-plan.md). | Active |
| 2026-11-24 | One commit timer on the NUT server instead of per-client timers | A single 5-minute timer on the server forces every client to shut down at once, then the UPS power-cycles its outlets so all machines restart. One timer to maintain, no Wake-on-LAN, and no machine left half shut down if power returns mid-sequence. | Active |
| 2026-11-25 | One Discord webhook per alert source | Uptime Kuma, NUT, Proxmox and the Synology each post through their own webhook into the same alerts channel, so every message shows its source and one webhook can be revoked without touching the others. Proxmox keeps full detail in email; Discord gets short warnings and errors. | Active |

## Status Key

- **Active** — decided and in effect (built or being built).
- **Proposed** — decided in principle, not yet implemented (often pending research).
- **Superseded** — replaced by a later decision (link to the newer row).

## Decision Template

For a decision that graduates to its own file, see:
- `templates/homelab-decision-template.md`
