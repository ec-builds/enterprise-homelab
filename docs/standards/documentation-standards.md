# Documentation Standards

**Status: 🟢 Operational**

## Overview

This document defines the documentation standards for the EC-Builds enterprise homelab repository. Documentation should be accurate, reusable, and sanitized. Document systems as they are built rather than reconstructing the process afterward.

Naming and sanitization rules are in [Naming Conventions](./naming-conventions.md).

## Repository Structure

| Folder | Contents |
|---|---|
| `projects/` | One folder per lab; published to the site |
| `docs/reference/` | Repeatable procedures and command references, grouped by platform |
| `docs/standards/` | Standards for building and documenting the lab |
| `docs/templates/` | Templates for projects, decisions, and lessons learned |
| `docs/` (root) | Repository-wide documents: roadmap, decisions, direction, equipment inventory, tool catalog |
| `configs/` | Configuration files and Docker Compose definitions, grouped by service |
| `diagrams/` | Shared banners, architecture diagrams, and screenshots used outside a single project |
| `scripts/` | Repository scripts |
| `site/` | Astro + Starlight site that publishes `projects/` |
| `.github/` | Link-check workflows |

Add new top-level folders only when an existing folder does not fit.

## Project Structure

Each project folder contains:

```text
projects/project-name/
├── README.md          Project landing page
├── [topic].md         Lab documents
├── TODO-[topic].md    Planned work (optional)
└── diagrams/          Images used by this project
```

The `README.md` is the landing page. It should include status, objectives, technologies, completed work, next steps, and links to the project's documents. Keep implementation detail in the lab documents.

Only create documents that provide useful information for the project.

## Document Structure

### Every Document

1. **Title:** a single `#` heading. Use `##` for sections and `###` for subsections, and `####` sparingly. Do not use additional `#` headings as section headings.
2. **Opening:** the first paragraph after the title states what the document covers in a complete sentence or two. It can sit under any heading, such as Overview or Purpose, or under no heading.
3. **Body:** the content of the document.

### Project READMEs

A project `README.md` also includes:

- **Status:** the status line directly below the title
- **Overview:** a `## Overview` section

### Optional

- **Status in other documents:** a lab document may include a status line where it adds information, such as a document for a service or component that is tracked on its own within the project, or a document at a different stage from its project, for example a document that is In Progress inside an Operational project. Reference documents and standards do not need a status.
- **Outcome:** recommended for project documents that record a build or deployment. Summarize what was accomplished and what was validated.
- **Related Documentation:** links to closely related documents.

Documents that only record information, such as inventories, catalogs, and reference tables, do not need an Outcome.

## Status

Status is required in project READMEs. Wherever a status line is used, it uses exactly this format, directly below the title:

```markdown
**Status: 🟢 Operational**
```

| Status | Meaning |
|---|---|
| 🟢 Operational | Deployed, documented, and working as intended |
| 🟡 In Progress | Currently being built, configured, or tested |
| ⚪ Planned | Defined and included in the project roadmap |

Status and checklist tables may also use ✅ for a completed stage or a passed check.

## Writing Style

Use the tense that matches the document type:

| Document Type | Tense |
|---|---|
| Standards | Present / instructional |
| Project documentation | Past |
| Reference | Present |

Step-by-step instructions belong in reference documents. Project documents record what was done and link to the reference document for the steps.

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

Use inline code for commands, packages, paths, hostnames, and configuration values.

Use tables when they make structured information easier to read.

Use GitHub callouts for important context:

```markdown
> [!NOTE]
> Additional context.

> [!WARNING]
> Actions that could cause data loss or instability.
```

### Emoji

- Titles may start with one emoji, for example `# 🌐 Active Directory DNS`.
- Status lines and status tables use the status emoji above.
- Avoid decorative emoji in body text.

## File Naming

Use lowercase kebab-case for files and folders:

```text
debian-baseline.md
```

Exceptions:

- `README.md`
- The `TODO-` prefix for planned work
- Common acronyms may stay uppercase for readability, for example `DNS`, `DHCP`, `CLI`, `PCI`, and `USB`:

```text
active-directory-DNS.md
proxmox-PCI-device-passthrough.md
```

Links are case-sensitive on GitHub. A link must match the filename's case exactly.

## Sanitization

Sanitize every document, diagram, and screenshot before publishing. See [Naming Conventions](./naming-conventions.md) for the placeholder names, domains, and addressing to use.

## Publishing to the Site

The site at `ec-builds.com` is generated from the repository at build time by `site/scripts/sync-repo.mjs`. Edit documents in the repository, never the generated copies under `site/`.

| Content | On the site |
|---|---|
| `projects/**` | Published as pages |
| `README.md` | Becomes the project's **Overview** page |
| `TODO-*.md` | Published with a **Planned** badge; `TODO-` is dropped from the URL |
| `archive/` and `diagrams/` folders | Not published as pages; images are copied for pages that use them |
| `docs/` | Not published; links to these files open on GitHub |
| `projects/README.md` table | Builds the project cards on the home page |

How documents are converted:

- **URLs:** filenames are lowercased, so `active-directory-DNS.md` becomes `/active-directory-dns/`.
- **Title:** the `#` heading becomes the page title. A leading emoji is removed from the sidebar label.
- **Description:** the first prose paragraph becomes the search and link-preview description. Headings, the status line, images, tables, and lists are skipped, so a document that opens with a table or diagram needs a sentence before it.
- **Callouts:** GitHub callouts become site callouts.
- **Status emoji:** status emoji in table cells become status pills.

Use relative links to other repository files and relative paths for images, for example `./diagrams/image.png`. The sync rewrites both for the site.

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

- [ ] Title is a single `#` heading
- [ ] The first paragraph states what the document covers
- [ ] Filename follows the naming rules
- [ ] Commands and configuration use code blocks
- [ ] Content is sanitized per [Naming Conventions](./naming-conventions.md)
- [ ] Links resolve, with case matching the filename

When applicable:

- [ ] Project READMEs have a status line in the standard format and an Overview
- [ ] Any status line is accurate and in the standard format
- [ ] Tense matches the document type
- [ ] Step-by-step instructions are in a reference document
- [ ] Project build documents include an Outcome

## Related Documentation

- [Naming Conventions](./naming-conventions.md)
