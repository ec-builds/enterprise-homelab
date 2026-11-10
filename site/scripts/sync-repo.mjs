// Generates the site's project pages from ../projects (or REPO_DIR).
// Outputs are git-ignored: edit the docs in the repo, not these.

import fs from 'node:fs';
import path from 'node:path';
import { describe, cleanName } from './describe.mjs';

// sharp comes with Astro; without it, images are copied unconverted.
const sharp = await import('sharp').then((m) => m.default).catch(() => null);

const SITE = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const candidates = process.env.REPO_DIR ? [process.env.REPO_DIR] : ['..', '../enterprise-homelab'];
const REPO = candidates.map((c) => path.resolve(SITE, c)).find((r) => fs.existsSync(path.join(r, 'projects')));
const GITHUB = process.env.REPO_URL ?? 'https://github.com/ec-builds/enterprise-homelab';
const BRANCH = process.env.REPO_BRANCH ?? 'main';

if (!REPO) {
  console.error(`[sync] No projects/ folder found. Looked in: ${candidates.join(', ')} (relative to site/).\n` +
    `       Put site/ inside the enterprise-homelab repo, or set REPO_DIR.`);
  process.exit(1);
}

// Not published (links to these go to GitHub instead).
const SKIP = [/(^|\/)archive\//i, /(^|\/)(diagrams|screenshots|images)\//i];
// Published with a Planned badge and banner.
const PLAN = [/(^|\/)TODO-[^/]*\.md$/i, /(^|\/)planned\//i];

const GITHUB_MARK = 'M8 0c4.42 0 8 3.58 8 8a8.013 8.013 0 0 1-5.45 7.59c-.4.08-.55-.17-.55-.38 0-.27.01-1.13.01-2.2 0-.75-.25-1.23-.54-1.48 1.78-.2 3.65-.88 3.65-3.95 0-.88-.31-1.59-.82-2.15.08-.2.36-1.02-.08-2.12 0 0-.67-.22-2.2.82-.64-.18-1.32-.27-2-.27-.68 0-1.36.09-2 .27-1.53-1.03-2.2-.82-2.2-.82-.44 1.1-.16 1.92-.08 2.12-.51.56-.82 1.28-.82 2.15 0 3.06 1.86 3.75 3.64 3.95-.23.2-.44.55-.51 1.07-.46.21-1.61.55-2.33-.66-.15-.24-.6-.83-1.23-.82-.67.01-.27.38.01.53.34.19.73.9.82 1.13.16.45.68 1.31 2.69.94 0 .67.01 1.3.01 1.49 0 .21-.15.45-.55.38A7.995 7.995 0 0 1 0 8c0-4.42 3.58-8 8-8Z';

const SRC = path.join(REPO, 'projects');
const OUT_DOCS = path.join(SITE, 'src/content/docs/projects');
const OUT_ASSETS = path.join(SITE, 'public/repo-assets');
const ROUTE_BASE = '/projects';

const report = {
  repo: REPO, pages: 0, pagesWritten: 0, skipped: [], images: 0, imagesCopied: 0, removed: 0,
  linksToPages: 0, linksToGitHub: 0, unresolved: [],
};

// Write only what changed. A full delete-and-rewrite on every run trips anti-ransomware tools.
const produced = new Set();

function writeText(dest, content) {
  produced.add(dest);
  if (fs.existsSync(dest) && fs.readFileSync(dest, 'utf8') === content) return false;
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, content);
  return true;
}

function copyIfChanged(from, dest) {
  const first = !produced.has(dest);
  produced.add(dest);
  if (fs.existsSync(dest)) {
    const s = fs.statSync(from), d = fs.statSync(dest);
    if (s.size === d.size && d.mtimeMs >= s.mtimeMs) return first;
  }
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.copyFileSync(from, dest);
  report.imagesCopied++;
  return first;
}

// Banners are 1.5 to 2 MB PNGs. 2000px wide covers 2x screens at the 1000px they're shown.
const WEBP_MIN_BYTES = 200 * 1024;
const WEBP_MAX_WIDTH = 2000;
const conversions = [];

function shouldConvert(from) {
  return sharp && /\.(png|jpe?g)$/i.test(from) && fs.statSync(from).size >= WEBP_MIN_BYTES;
}

function convertIfChanged(from, dest) {
  // Same image on two pages: convert once (two writes to one file at the same time can corrupt it).
  if (produced.has(dest)) return false;
  produced.add(dest);
  if (fs.existsSync(dest) && fs.statSync(dest).mtimeMs >= fs.statSync(from).mtimeMs) return true;
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  conversions.push(
    sharp(from)
      .resize({ width: WEBP_MAX_WIDTH, withoutEnlargement: true })
      .webp({ quality: 82 })
      .toFile(dest)
      .then(() => { report.imagesConverted = (report.imagesConverted ?? 0) + 1; }),
  );
  return true;
}

function prune(dir) {
  if (!fs.existsSync(dir)) return;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const abs = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      prune(abs);
      if (fs.readdirSync(abs).length === 0) fs.rmdirSync(abs);
    } else if (!produced.has(abs) && entry.name !== '.DS_Store') {
      fs.unlinkSync(abs);
      report.removed++;
    }
  }
}
const toPosix = (p) => p.split(path.sep).join('/');
const isSkipped = (relFromProjects) => SKIP.some((re) => re.test(toPosix(relFromProjects)));
const isPlan = (relFromProjects) => PLAN.some((re) => re.test(toPosix(relFromProjects)));

// README.md -> index.md, lowercase file names, no todo- prefix in URLs.
function outRel(relFromProjects) {
  const dir = path.dirname(relFromProjects);
  const base = path.basename(relFromProjects);
  const name = /^readme\.md$/i.test(base) ? 'index.md' : base.toLowerCase().replace(/^todo-/, '');
  return toPosix(path.join(dir.toLowerCase(), name));
}

function routeFor(relFromProjects) {
  const o = outRel(relFromProjects).replace(/\.md$/, '');
  const r = o === 'index' ? '' : o.replace(/\/index$/, '');
  return `${ROUTE_BASE}/${r}${r ? '/' : ''}`;
}

const isExternal = (u) => /^(?:[a-z]+:|\/\/|#|\/)/i.test(u);

// Doc link or image path -> site URL, copied asset, or GitHub URL.
function rewriteTarget(target, fromFile, kind) {
  if (!target || isExternal(target)) return target;
  const [rawPath, hash = ''] = target.split('#');
  const anchor = hash ? `#${hash}` : '';
  let decoded;
  try { decoded = decodeURIComponent(rawPath); } catch { decoded = rawPath; }
  const abs = path.resolve(path.dirname(fromFile), decoded);
  const repoRel = toPosix(path.relative(REPO, abs));
  const from = toPosix(path.relative(REPO, fromFile));
  if (repoRel.startsWith('..')) {
    report.unresolved.push({ file: from, target, reason: 'points outside the repo' });
    return target;
  }
  const exists = fs.existsSync(abs);
  const isDir = exists && fs.statSync(abs).isDirectory();
  const projRel = toPosix(path.relative(SRC, abs));
  const inProjects = !projRel.startsWith('..');

  if (kind === 'image') {
    if (!exists) {
      report.unresolved.push({ file: from, target, reason: 'image not found' });
      return target;
    }
    const assetRel = shouldConvert(abs) ? repoRel.replace(/\.(png|jpe?g)$/i, '.webp') : repoRel;
    const added = assetRel === repoRel
      ? copyIfChanged(abs, path.join(OUT_ASSETS, assetRel))
      : convertIfChanged(abs, path.join(OUT_ASSETS, assetRel));
    if (added) report.images++;
    return `/repo-assets/${assetRel.split('/').map(encodeURIComponent).join('/')}`;
  }

  if (inProjects && exists && !isSkipped(projRel)) {
    if (isDir) {
      const readme = fs.readdirSync(abs).find((f) => /^readme\.md$/i.test(f));
      if (readme && !isSkipped(path.join(projRel, readme))) {
        report.linksToPages++;
        return routeFor(path.join(projRel, readme)) + anchor;
      }
    } else if (/\.md$/i.test(abs)) {
      report.linksToPages++;
      return routeFor(projRel) + anchor;
    }
  }
  if (!exists) report.unresolved.push({ file: from, target, reason: 'target not found in repo' });
  report.linksToGitHub++;
  return `${GITHUB}/${isDir ? 'tree' : 'blob'}/${BRANCH}/${repoRel}${anchor}`;
}

// GitHub alerts -> Starlight callouts. There's no green callout, so tip uses purple like important.
const ALERTS = {
  note: ['note', 'Note'],
  tip: ['tip', 'Tip'],
  important: ['tip', 'Important'],
  warning: ['caution', 'Warning'],
  caution: ['danger', 'Caution'],
};

function convertAlerts(chunk) {
  const lines = chunk.split('\n');
  const out = [];
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^\s*>\s*\[!(note|tip|important|warning|caution)\]\s*(.*)$/i);
    if (!m) { out.push(lines[i]); continue; }
    const [type, title] = ALERTS[m[1].toLowerCase()];
    const body = m[2] ? [m[2]] : [];
    while (i + 1 < lines.length && /^\s*>/.test(lines[i + 1])) body.push(lines[++i].replace(/^\s*>\s?/, ''));
    out.push(`:::${type}[${title}]`, ...body, ':::');
  }
  return out.join('\n');
}

// Wrap tables so wide ones scroll in their own box. The blank lines keep the table parsed as Markdown.
// Status cells: short label -> pill, emoji only -> dot, long text/code/links -> dot + text.
const STATUS = {
  '✅': ['ok', 'Complete'], '🟢': ['ok', 'Operational'],
  '🟡': ['wip', 'In progress'],
  '⚪': ['plan', 'Planned'], '⬜': ['plan', 'Planned'],
};
const escapeHtml = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

function statusCells(row) {
  return row.replace(/\|(\s*)(✅|🟢|🟡|⚪|⬜)️?\s*([^|]*?)\s*(?=\|)/gu, (_, sp, emoji, rawText) => {
    const [cls, label] = STATUS[emoji];
    const text = rawText.replace(/^\*\*(.*)\*\*$/, '$1').trim();
    if (!text) return `|${sp}<span class="ec-dot ${cls}" role="img" aria-label="${label}" title="${label}"></span> `;
    if (text.length > 24 || /[`[<]/.test(text)) return `|${sp}<span class="ec-dot ${cls}" aria-hidden="true"></span> ${rawText} `;
    return `|${sp}<span class="ec-pill ${cls}">${escapeHtml(text)}</span> `;
  });
}

function wrapTables(chunk) {
  const lines = chunk.split('\n');
  const out = [];
  const isRow = (l) => /^\s*\|/.test(l ?? '');
  const isDelimiter = (l) => /^\s*\|?\s*:?-{3,}:?\s*(\|\s*:?-{3,}:?\s*)*\|?\s*$/.test(l ?? '');
  for (let i = 0; i < lines.length; i++) {
    if (isRow(lines[i]) && isDelimiter(lines[i + 1])) {
      const table = [];
      while (i < lines.length && isRow(lines[i])) table.push(lines[i++]);
      i--;
      const styled = table.map((row, r) => (r < 2 ? row : statusCells(row)));
      out.push('<div class="ec-table-wrap">', '', ...styled, '', '</div>');
    } else {
      out.push(lines[i]);
    }
  }
  return out.join('\n');
}

function rewriteBody(md, fromFile) {
  // Skip fenced code blocks.
  const parts = md.split(/(^```[\s\S]*?^```[^\n]*$)/m);
  return parts.map((chunk, i) => {
    if (i % 2 === 1) return chunk;
    return wrapTables(convertAlerts(chunk))
      .replace(/!\[([^\]]*)\]\(\s*<?([^)\s>]+)>?(\s+"[^"]*")?\s*\)/g,
        (_, alt, t, title = '') => `![${alt}](${rewriteTarget(t, fromFile, 'image')}${title})`)
      .replace(/(^|[^!])\[([^\]]*)\]\(\s*<?([^)\s>]+)>?(\s+"[^"]*")?\s*\)/g,
        (_, pre, text, t, title = '') => `${pre}[${text}](${rewriteTarget(t, fromFile, 'link')}${title})`)
      .replace(/(<img\b[^>]*?\bsrc=")([^"]+)(")/gi, (_, a, t, b) => a + rewriteTarget(t, fromFile, 'image') + b)
      .replace(/(<a\b[^>]*?\bhref=")([^"]+)(")/gi, (_, a, t, b) => a + rewriteTarget(t, fromFile, 'link') + b);
  }).join('');
}

function prettify(name) {
  return name.replace(/\.md$/i, '').replace(/[-_]+/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

// Project name for a doc (from its project's README H1), used in descriptions and generic titles.
const projectNames = new Map();
function projectName(rel) {
  const dir = toPosix(rel).split('/')[0];
  if (!dir || dir === toPosix(rel)) return '';
  if (!projectNames.has(dir)) {
    const readme = path.join(SRC, dir, 'README.md');
    const h1 = fs.existsSync(readme) ? fs.readFileSync(readme, 'utf8').match(/^#\s+(.+?)\s*#*\s*$/m) : null;
    projectNames.set(dir, cleanName(h1 ? h1[1] : prettify(dir)));
  }
  return projectNames.get(dir);
}

// Titles shared by several projects get the project name in the browser tab and search result.
const GENERIC_TITLE = /^(overview|architecture|troubleshooting|lessons learned|roadmap|deployment)$/i;

function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const abs = path.join(dir, entry.name);
    if (entry.isDirectory()) { walk(abs); continue; }
    if (!/\.md$/i.test(entry.name)) continue;

    const rel = path.relative(SRC, abs);
    if (isSkipped(rel)) { report.skipped.push(toPosix(rel)); continue; }

    let md = fs.readFileSync(abs, 'utf8').replace(/\r\n/g, '\n');
    if (!md.trim()) { report.skipped.push(`${toPosix(rel)} (empty)`); continue; }

    // Title comes from the first H1. A description in the doc's own frontmatter wins over the generated one.
    const frontmatter = md.match(/^---\n([\s\S]*?)\n---\n/)?.[1] ?? '';
    const ownDescription = frontmatter.match(/^description:\s*(.+?)\s*$/m)?.[1]?.replace(/^(["'])(.*)\1$/, '$2');
    md = md.replace(/^---\n[\s\S]*?\n---\n/, '');
    const isReadme = /^readme\.md$/i.test(entry.name);
    let title = prettify(isReadme ? path.basename(path.dirname(abs)) : entry.name);
    const h1 = md.match(/^#\s+(.+?)\s*#*\s*$/m);
    if (h1) { title = h1[1].trim(); md = md.replace(h1[0], ''); }

    // Sidebar: README shows as Overview; other labels drop leading emoji and step numbers ("01 · ").
    const navLabel = isReadme ? 'Overview' : title
      .replace(/[\p{Extended_Pictographic}️‍]/gu, '')
      .replace(/^\s*\d+\s*[·.\-–—:)]\s*/u, '')
      .trim();
    const sourcePath = toPosix(path.relative(REPO, abs));
    const editUrl = `${GITHUB}/blob/${BRANCH}/${sourcePath}`;
    const plan = isPlan(rel);
    const project = projectName(rel);
    const description = ownDescription || describe(md, title, project);
    const pageTitle = !isReadme && project && GENERIC_TITLE.test(cleanName(title)) ? `${project} ${cleanName(title)}` : null;
    const front = [
      '---',
      `title: ${JSON.stringify(title)}`,
      `description: ${JSON.stringify(description)}`,
      ...(pageTitle ? [
        'head:',
        '  - tag: title',
        `    content: ${JSON.stringify(`${pageTitle} | EC-Builds`)}`,
        '  - tag: meta',
        '    attrs:',
        '      property: og:title',
        `      content: ${JSON.stringify(pageTitle)}`,
      ] : []),
      `editUrl: ${JSON.stringify(editUrl)}`,
      'sidebar:',
      `  label: ${JSON.stringify(navLabel)}`,
      ...(isReadme ? ['  order: 0'] : []),
      ...(plan ? ['  badge:', '    text: Planned', '    class: ec-planned'] : []),
      ...(plan ? ['banner:', '  content: "Planned. This implementation plan is not deployed yet."'] : []),
      '---',
      '',
    ].join('\n');
    const source =
      `<p class="ec-synced-wrap"><a class="ec-synced" href="${editUrl}" title="${sourcePath}" ` +
      `aria-label="Synced from GitHub: view ${sourcePath} on GitHub">` +
      `<svg aria-hidden="true" viewBox="0 0 16 16" width="14" height="14" fill="currentColor"><path d="${GITHUB_MARK}"/></svg>` +
      `Synced from GitHub<span aria-hidden="true">↗</span></a></p>\n\n`;

    if (writeText(path.join(OUT_DOCS, outRel(rel)), front + source + rewriteBody(md, abs))) report.pagesWritten++;
    if (plan) report.plans = (report.plans ?? 0) + 1;
    report.pages++;
  }
}

walk(SRC);

// Home page cards come from the table in projects/README.md.
const projects = [];
const table = fs.readFileSync(path.join(SRC, 'README.md'), 'utf8');
for (const m of table.matchAll(/^\|\s*\[([^\]]+)\]\(\.\/([^)]+?)\/?\)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|$/gm)) {
  const [, name, dir, focus, statusCell] = m;
  const status = /operational/i.test(statusCell) ? 'Operational' : /progress/i.test(statusCell) ? 'In progress' : 'Planned';
  projects.push({ name: name.replace(/-/g, ' '), dir, focus, status, href: routeFor(path.join(dir, 'README.md')) });
}
writeText(path.join(SITE, 'src/data/projects.json'), JSON.stringify(projects, null, 2));

for (const rel of ['diagrams/homelab-architecture-simple.png']) {
  const from = path.join(REPO, rel);
  if (fs.existsSync(from)) copyIfChanged(from, path.join(OUT_ASSETS, rel));
}

await Promise.all(conversions);

// Remove outputs whose source was renamed, deleted, or is now skipped.
prune(OUT_DOCS);
prune(OUT_ASSETS);

fs.writeFileSync(path.join(SITE, 'sync-report.json'), JSON.stringify(report, null, 2));
console.log(`[sync] repo: ${REPO}`);
console.log(`[sync] ${report.pages} pages (${report.plans ?? 0} plans), ${report.skipped.length} skipped, ${report.images} images, ` +
  `${report.linksToPages} internal links, ${report.linksToGitHub} links to GitHub, ` +
  `${report.unresolved.length} unresolved (see sync-report.json)`);
console.log(`[sync] changed: ${report.pagesWritten} pages written, ${report.imagesCopied} images copied, ` +
  `${report.imagesConverted ?? 0} converted to WebP, ${report.removed} removed`);
