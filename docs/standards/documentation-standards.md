# Documentation Standards

This document defines the documentation standards used across the 
EC-Builds enterprise homelab portfolio. All project documentation 
should follow these conventions to ensure consistency, professionalism, 
and repeatability across the environment.

---

## Philosophy

Documentation is part of the build process, not a separate task.

Every project in this lab is documented as it is built — capturing 
architecture decisions, configuration steps, lessons learned, and 
operational procedures in real time rather than reconstructing them 
after the fact.

The goal is documentation that is:

- **Accurate** — reflects the actual implementation, not the ideal
- **Honest** — clearly indicates what is complete, in progress, or planned
- **Reusable** — written so that any system can be rebuilt from the docs alone
- **Sanitized** — free of operational details that could expose the live environment

---

## Repository Structure

Repository content should be organized into the following major areas:

- docs/
- projects/
- diagrams/
- assets/
- equipment/

New top-level directories should only be added when a clear organizational need exists.

---

## Document Structure

Every document should follow this general structure:

1. **Title** — descriptive, matches the filename
2. **Status badge** — reflects current state of the document
3. **Overview** — brief explanation of what the document covers
4. **Body sections** — organized with `##` headers
5. **Related Documentation** — links to relevant files
6. **Outcome** — one paragraph summarizing what was accomplished


---


## Status Badges

Every document should include a status badge near the top to clearly 
communicate its current state.

| Status | Badge | Meaning |
|---|---|---|
| Complete | `✅ Complete` | Fully implemented and documented |
| In Progress | `🔨 In Progress` | Actively being built or documented |
| Planned | `📋 Planned` | Not yet started |
| Work in Progress | `🚧 Work in Progress` | Started but incomplete |

Example usage:

```markdown
**Status: ✅ Complete**
```

---

## Tense Convention

| Document Type | Tense | Reason |
|---|---|---|
| Standards | Present / Instructional | Reusable templates — written to be followed |
| Runbooks | Present / Instructional | Step-by-step procedures — written to be executed |
| Project documentation | Past | Records of what was built and decided |
| Reference | Present | Factual quick-reference material |

### Examples

**Standards and runbooks** — instructional present:
```
Update the operating system before making any additional changes.
```

**Project documentation** — past tense narrative:
```
The operating system was updated prior to additional configuration.
```

---

## Heading Conventions

- `#` — Document title only. One per document.
- `##` — Major sections
- `###` — Subsections within a major section
- `####` — Use sparingly. If needed frequently, consider splitting the document.

---

## Formatting Conventions

### Code Blocks

All commands, configuration snippets, file paths, and terminal output 
must be wrapped in fenced code blocks with the appropriate language tag.

```bash
sudo apt update
sudo apt upgrade -y
```

```text
/etc/fstab
```

### Inline Code

Use backticks for inline references to commands, package names, file 
paths, and configuration values.

Example: Install `cifs-utils` before configuring SMB mounts.

### Tables

Use tables for:
- Package summaries
- Configuration option explanations
- Comparison of approaches
- Hardware specifications
- Status summaries

### Callout Notes

Use GitHub-flavored markdown callouts for important notices.

```markdown
> [!NOTE]
> Use this for additional context or learning observations.

> [!WARNING]
> Use this for actions that could cause data loss or system instability.
```

### Emoji Usage

Emoji are used selectively and consistently. They are not decorative — 
each one carries a specific meaning.

| Emoji | Meaning |
|---|---|
| ✅ | Complete |
| 🔨 | In progress |
| 📋 | Planned |
| 🚧 | Work in progress |
| 📁 | Folder or file reference |
| 🔐 | Security-related content |
| 📊 | Monitoring or metrics |
| 🎬 | Media-related content |

Avoid using emoji in body text or section headers. Reserve them for 
status indicators and document titles where established above.

---

## Naming Conventions

All files and folders use lowercase kebab-case.

```text
debian-baseline.md        ✅
Debian-Baseline.md        ❌
debian_baseline.md        ❌
debianBaseline.md         ❌
```

For full naming and sanitization standards, see:
- [Naming Conventions](./naming-conventions.md)

---

## Section Conventions

### Overview Section

Every document should open with a brief overview that explains:
- What the document covers
- Why it exists
- Who should use it

### Related Documentation Section

Every document should close with a Related Documentation section 
linking to relevant files in the repository. Use relative links.

```markdown
## Related Documentation

- [Naming Conventions](./naming-conventions.md)
- [SSH Hardening](./ssh-hardening.md)
- [Project README](../../projects/media-services-platform/README.md)
```

### Outcome Section

Project documents should end with a one-paragraph Outcome section 
summarizing what was accomplished. Keep it factual and concise.

Standards and runbooks do not require an Outcome section.

---

## Sanitization Requirements

All documentation must be reviewed for operational details before 
publishing. Never include:

- Real hostnames
- Real usernames
- IP addresses (use RFC 5737 ranges if needed)
- Domain names
- API keys or tokens
- Passwords or credentials
- VPN endpoints

Use role-based sanitized names as defined in:
- [Naming Conventions](./naming-conventions.md)

---

## Project Documentation Structure

Every project folder should follow this structure:

```text
projects/project-name/
├── README.md              ← Project overview and navigation table
├── architecture.md        ← System design and component relationships
├── hardware.md            ← Hardware specifications (if applicable)
├── diagrams/              ← Architecture diagrams and screenshots
├── lessons-learned.md     ← Key takeaways and reflections
└── [topic].md             ← Additional documentation as needed
```

The `README.md` must include:
- Status badge
- Project objectives
- Technologies used
- Completed work checklist
- Future enhancements
- Navigation table linking to all documents in the folder

---

## Commit Message Conventions

Commit messages should be clear, concise, and describe what changed 
and why.

| Type | Format | Example |
|---|---|---|
| Create | `Create [filename]` | `Create debian-baseline.md` |
| Update | `Update [filename]` | `Update README.md` |
| Revise | `Revise [topic]` | `Revise Debian baseline configuration` |
| Fix | `Fix [issue]` | `Fix broken lessons-learned link` |
| Rename | `Rename [old] to [new]` | `Rename ssh-hardening-standard.md to ssh-hardening.md` |
| Add | `Add [what]` | `Add architecture diagram` |

---

## Review Checklist

Before committing any documentation:

- [ ] Status badge is present and accurate
- [ ] Tense is correct for the document type
- [ ] All commands are in fenced code blocks
- [ ] No real hostnames, IPs, or credentials present
- [ ] Related Documentation links are accurate and resolve correctly
- [ ] Filename uses lowercase kebab-case
- [ ] Tables are formatted correctly
- [ ] Outcome section present (project docs only)

---

## Related Documentation

- [Naming Conventions](./naming-conventions.md)
- [Repository README](../../README.md)
- [Documentation Folder](../README.md)
