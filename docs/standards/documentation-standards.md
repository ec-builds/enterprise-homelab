# Documentation Standards

**Status: ✅ Complete**

This document defines the documentation standards used across the EC-Builds enterprise homelab portfolio.

Documentation should be accurate, reusable, and sanitized. Document systems as they are built rather than reconstructing the process afterward.

## Repository Structure

Organize repository content into these primary areas:

```text
docs/
projects/
diagrams/
assets/
equipment/
```

Add new top-level directories only when necessary.

## Document Structure

Documents should generally include:

1. Title
2. Status badge
3. Overview
4. Body sections
5. Related Documentation

Project documentation should also include an **Outcome** section summarizing what was accomplished.

Use:

- `#` for the document title
- `##` for major sections
- `###` for subsections
- `####` sparingly

## Status

| Status | Badge |
|---|---|
| Complete | `✅ Complete` |
| In Progress | `🔨 In Progress` |
| Planned | `📋 Planned` |

Example:

```markdown
**Status: ✅ Complete**
```

## Writing Style

Use tense based on document type:

| Document Type | Tense |
|---|---|
| Standards | Present / instructional |
| Project documentation | Past |
| Reference | Present |

Standards describe what to do:

```text
Update the operating system before making additional changes.
```

Project documentation records what was done:

```text
The operating system was updated before additional configuration.
```

Keep documentation factual, concise, and focused on the actual implementation.

## Formatting

Use fenced code blocks for commands, configuration, paths, and terminal output.

```bash
sudo apt update
sudo apt upgrade -y
```

Use inline code for commands, packages, paths, and configuration values.

Use tables when they make structured information easier to read.

Use GitHub callouts for important context:

```markdown
> [!NOTE]
> Additional context.

> [!WARNING]
> Actions that could cause data loss or instability.
```

Emoji should primarily be reserved for status indicators rather than decorative body text.

## Naming and Sanitization

Use lowercase kebab-case for files and folders:

```text
debian-baseline.md
```

Before publishing, remove or sanitize:

- Hostnames
- Usernames
- IP addresses
- Domain names
- API keys and tokens
- Passwords and credentials
- VPN endpoints
- Other environment-specific identifiers

Use role-based names and documentation-safe addressing where examples are required.

See [Naming Conventions](./naming-conventions.md) for detailed naming and sanitization rules.

## Project Documentation

`README.md` serves as the project landing page. Keep detailed implementation information in dedicated documents.

A typical project structure is:

```text
projects/project-name/
├── README.md
├── architecture.md
├── hardware.md
├── diagrams/
├── lessons-learned.md
└── [topic].md
```

Project READMEs should include:

- Status
- Objectives
- Technologies used
- Completed work
- Future enhancements
- Navigation to project documentation

Only create documents that provide useful information for the project.

## Commit Messages

Keep commit messages concise and descriptive.

| Type | Example |
|---|---|
| Create | `Create debian-baseline.md` |
| Update | `Update README.md` |
| Revise | `Revise Debian baseline configuration` |
| Fix | `Fix broken documentation link` |
| Rename | `Rename old-name.md to new-name.md` |
| Add | `Add architecture diagram` |

## Review Checklist

Before publishing:

- [ ] Filename uses lowercase kebab-case
- [ ] Status is accurate
- [ ] Commands and configuration use code blocks
- [ ] Sensitive or environment-specific information is sanitized
- [ ] Related Documentation links are included and accurate

When applicable:

- [ ] Tense matches the document type
- [ ] Project documents include an Outcome
- [ ] Tables and callouts improve readability

Periodically review repository links, status badges, and sanitization.

## Related Documentation

- [Naming Conventions](./naming-conventions.md)
- [Repository README](../../README.md)
- [Documentation Folder](../README.md)
