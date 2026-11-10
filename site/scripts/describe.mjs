// Meta description for a synced doc: the opening prose, cut to fit a search snippet.
// Without this, every page falls back to the one site-wide description.

const MAX = 160;
const MIN = 110; // add the next paragraph while the text is shorter than this

const EMOJI = /[\p{Extended_Pictographic}\u{1F1E6}-\u{1F1FF}\u{FE0F}\u{200D}]/gu;

// Blocks that aren't prose: headings, images, HTML, tables, quotes, callouts, lists, rules, status lines.
const NOT_PROSE = /^(#|<|!\[|\||>|:::|[-*+]\s|\d+[.)]\s|---|\*\*\*|\*\*Status\b)/i;
const LIST = /^([-*+]|\d+[.)])\s/;

export const cleanName = (s) =>
  s.replace(EMOJI, '').replace(/^\s*\d+\s*[·.\-–—:)]\s*/u, '').replace(/\s*\([^)]*\)\s*$/, '').replace(/\s{2,}/g, ' ').trim();

function plain(s) {
  return s
    .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/<[^>]+>/g, '')
    .replace(/(\*\*|__|\*|`)/g, '')
    .replace(EMOJI, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function fit(text) {
  if (text.length <= MAX) return text;
  const cut = text.slice(0, MAX);
  const sentence = cut.lastIndexOf('. ');
  if (sentence >= 70) return cut.slice(0, sentence + 1);
  return cut.slice(0, cut.lastIndexOf(' ', MAX - 1)).replace(/[\s,;:–—-]+$/, '') + '…';
}

// md: the doc body (frontmatter and H1 removed). project: the project's name, for the fallback.
export function describe(md, title, project) {
  const blocks = md.replace(/^```[\s\S]*?^```[^\n]*$/gm, '').split(/\n\s*\n/).map((b) => b.trim()).filter(Boolean);
  let text = '';
  for (let i = 0; i < blocks.length; i++) {
    const b = blocks[i];
    // Skip captions (a paragraph that is only italics).
    const skip = NOT_PROSE.test(b) || /^\*[^*][\s\S]*\*$/.test(b) || /^_[\s\S]*_$/.test(b);
    if (skip) {
      if (text) break; // only join paragraphs that follow each other
      continue;
    }
    let t = plain(b);
    // "Divided into two networks:" followed by a list: fold the list in.
    if (/:$/.test(t) && LIST.test(blocks[i + 1] ?? '')) {
      const items = blocks[i + 1].split('\n').filter((l) => LIST.test(l.trim()))
        .map((l) => plain(l.trim().replace(LIST, '')).replace(/[.;]$/, ''));
      t = `${t} ${items.join('; ')}.`;
      i++;
    }
    if (t.length < 40 || /:$/.test(t)) {
      if (text) break;
      continue;
    }
    text = text ? `${text} ${t}` : t;
    if (text.length >= MIN) break;
  }
  if (text) return fit(text);
  const name = cleanName(title);
  return fit(project && project !== name
    ? `${name} from the ${project} project in the EC-Builds enterprise infrastructure homelab, documented by Emmanuel Casillas.`
    : `${name}: documentation from the EC-Builds enterprise infrastructure homelab by Emmanuel Casillas.`);
}
