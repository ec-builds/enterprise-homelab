# Homelab Decisions

This document records major architectural, operational, and strategic decisions made throughout the lifecycle of the homelab.

The goal is to document **why** decisions were made so future changes can be evaluated against previous assumptions and requirements.

---

## Decision Log

| Date | Decision | Status |
|--------|----------|---------|
| 2026-06-13 | GitHub Becomes Documentation Source of Truth | Active |

---

# 2026-06-13 — GitHub Becomes Documentation Source of Truth

## Status

**Active**

## Context

Network and homelab documentation was originally maintained in Obsidian.

As project documentation matured and multiple projects were created, maintaining documentation in both Obsidian and GitHub introduced duplicated effort and increased the risk of documentation drift.

## Decision

GitHub repositories will serve as the authoritative source of documentation for the homelab.

## Rationale

- Eliminates duplicate documentation maintenance.
- Provides version control for all documentation changes.
- Keeps documentation close to the infrastructure it describes.
- Enables documentation review through Git history.
- Creates a public portfolio demonstrating technical documentation practices.
- Simplifies disaster recovery and backup procedures.

## Consequences

### Positive

- Single source of truth.
- Better organization and discoverability.
- Documentation evolves alongside projects.
- Historical change tracking through Git.

### Negative

- Less flexibility for quick note-taking.
- Draft ideas may require additional organization before publication.

## Implementation

### GitHub

Used for:

- Project documentation
- Architecture diagrams
- Build guides
- Runbooks
- IP addressing plans
- Device inventories
- Lessons learned
- Screenshots
- Configuration examples

### Bitwarden

Used for:

- Passwords
- API keys
- Recovery codes
- Sensitive configuration values
- Network secrets

### Temporary Notes

May be stored elsewhere until mature enough for inclusion in GitHub documentation.




How is the decision applied in practice?

### Related Projects

- project-name
