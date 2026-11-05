# EC-Builds site

The website for this repo, built with Astro + Starlight and deployed to Cloudflare Workers at **ec-builds.com**.

Every project page is generated from the Markdown in `../projects/`. Nothing is written twice:
update a doc, push, and the site rebuilds with the change.

## Run it locally

Needs Node 22 or newer (see `.node-version`).

```bash
cd site
npm install      # first time only
npm run dev      # syncs the docs, then serves http://localhost:4321
```

`npm run build` creates the static site in `dist/`, and `npm run preview` serves that build.

## How the sync works

`scripts/sync-repo.mjs` runs before every `dev` and `build`. For each Markdown file under `projects/` it:

1. Takes the page title from the first `# heading` and adds the frontmatter Starlight needs.
2. Rewrites links between docs to site pages (`./alerting.md` → `/projects/infrastructure-monitoring/alerting/`).
3. Rewrites links to configs, scripts and other repo files to GitHub.
4. Copies the images each page uses into `public/repo-assets/`. PNG/JPG files over 200 KB (the project
   banners, for example) are converted to WebP, at most 2000px wide, which cuts each from about 1.7 MB to
   about 100 KB with no visible change. The originals in the repo are not touched.
5. Adds an "Edit page" link to the file on GitHub.
6. Converts GitHub alerts (`> [!NOTE]`, `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`, `> [!TIP]`) into Starlight callouts.
7. Wraps tables in a bordered box that fills the column and scrolls sideways on small screens.
8. Turns status emoji in table cells (✅ 🟢 🟡 ⚪) into the same colored pills and dots as the home page.

**Plans:** `TODO-*.md` files and anything in a `planned/` folder are published with a "Planned" badge in the
sidebar and a gray "not yet deployed" banner. The `TODO-` prefix is dropped from their URLs.

**Not published:** anything in an `archive/` folder, Markdown inside `diagrams/`, `screenshots/` or `images/` folders, and empty files. Links to those go to GitHub instead.
Change `PLAN` or `SKIP` in the script to adjust.

`public/site.js` runs on every page and does three small things: links that leave the site (GitHub, LinkedIn,
the portfolio, outside references in the docs) open in a new tab, while links between pages stay in the same
tab; tables wide enough to scroll sideways can be reached and scrolled with the keyboard; and task-list
checkboxes (`- [ ]` in the docs) are labelled with their task text for screen readers.

Each page starts with a small "Synced from GitHub" chip linking to the file it was built from (full path on hover).

**Home page:** the project cards and status pills come from the table in `projects/README.md`.
Keep that table's format (`| [Name](./folder/) | Focus | 🟢 Operational |`) and the cards update themselves.

The generated folders are in `.gitignore`, and each run only updates what changed (unchanged pages and images are left alone). `sync-report.json` lists skipped files and any link the script couldn't resolve.

## Deploy (Cloudflare Workers Builds)

Connect the repo in Cloudflare → Workers & Pages → Create → Import a repository, with:

| Setting | Value |
|---|---|
| Repository | `ec-builds/enterprise-homelab` |
| Production branch | `main` |
| Root directory | `site` |
| Build command | `npm run build` |
| Deploy command | `npx wrangler deploy` |
| Build watch paths | Leave the default (any change triggers a build) |
| Custom domain | `ec-builds.com` |

The sync reads `../projects`, outside the root directory. The first build log should show `[sync] 91 pages…`.
If it stops with `[sync] No projects/ folder found`, leave Root directory blank and use
`cd site && npm ci && npm run build` and `cd site && npx wrangler deploy` instead.

`wrangler.jsonc` serves `dist/` as static assets, with no Worker code. `public/_headers` sets the security
and caching headers, including a Content-Security-Policy that only allows scripts, styles, images and fonts
from the site itself. If you add Cloudflare Web Analytics, an outside image or an embed, add its host to
the policy there (the comments in that file explain each part).

To deploy by hand instead: `npx wrangler login`, then `npm run deploy`.

## Design decisions

- **Sync instead of copying the docs.** The repo is the single source of truth. Copying the docs into the
  site would mean two versions to keep in step; syncing at build time means a doc pushed to GitHub is live
  on the site after the next build, with links and images fixed up on the way.
- **`'unsafe-inline'` in the CSP.** Starlight puts small inline scripts on every page (theme toggle, search)
  and code blocks use inline styles. Hashing each script would be stricter, but the hashes change whenever
  Starlight updates and a stale one silently breaks the page. Everything else is still locked to this site,
  and there are no logins, forms or user data to protect.
- **Incremental writes in the sync.** Deleting and rewriting every page and image on each run made
  anti-ransomware software flag the bulk file changes, and it restarts file watchers for nothing. Only
  changed files are written, and only files whose source is gone are removed.
- **Logo cut along the ring's actual edge.** The exported logo's ring isn't perfectly round or centered, so
  a plain circular crop left a thin white sliver on dark backgrounds. The trim follows the ring's measured
  outer edge all the way around.

## Files

Private notes, to-dos, logo sources and the icon/og-image generators live in `workspace/`, which is
git-ignored and never published.

```text
site/
├── astro.config.mjs        site settings and sidebar
├── wrangler.jsonc          Cloudflare Workers deployment
├── .node-version           Node version for Cloudflare builds
├── scripts/sync-repo.mjs   turns ../projects into site pages
├── public/
│   ├── _headers            security and cache headers (CSP, HSTS, etc.)
│   ├── .well-known/security.txt   how to report a vulnerability (RFC 9116)
│   ├── site.js             new-tab links, keyboard-scrollable tables, checkbox labels, back to top, 404 address
│   ├── og-image.png         social preview (1200×630) for LinkedIn, Slack, iMessage, etc.
│   ├── favicon.ico, favicon-32.png        browser tab icon (simplified EC mark)
│   ├── apple-touch-icon.png               iPhone home screen
│   ├── icon-192/512.png, icon-maskable-512.png   Android / installable app icons
│   └── site.webmanifest     app name, colors and icons
└── src/
    ├── pages/index.astro             home page
    ├── pages/404.astro               "page not found" (Starlight's own 404 is turned off in astro.config.mjs)
    ├── components/SiteTitle.astro    logo + EC-BUILDS wordmark
    ├── components/Footer.astro       slim site footer (logo, name, © line with Portfolio · GitHub · LinkedIn)
    ├── components/Pagination.astro   Previous/Next cards with project name and Planned pill
    ├── components/SocialIcons.astro  header icons: GitHub, LinkedIn, then portfolio (globe)
    ├── routeData.ts                  emoji-free tab titles; removes duplicate "Overview" in "On this page"
    ├── styles/theme.css              colors, fonts, tables, status pills
    └── assets/ec-logo.png
```

## Settings

| Variable | Default | Purpose |
|---|---|---|
| `REPO_DIR` | `..`, then `../enterprise-homelab` | where the repo is, relative to `site/` |
| `REPO_URL` | `https://github.com/ec-builds/enterprise-homelab` | base for GitHub links |
| `REPO_BRANCH` | `main` | branch used in GitHub links |
