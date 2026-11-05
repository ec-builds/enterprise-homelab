// @ts-check
import fs from 'node:fs';
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// One sidebar group per project folder, labelled with its README title.
const PROJECT_DOCS = new URL('./src/content/docs/projects/', import.meta.url);
const stripEmoji = (s) => s.replace(/[\p{Extended_Pictographic}️‍]/gu, '').trim();
const projectGroups = fs.existsSync(PROJECT_DOCS)
  ? fs.readdirSync(PROJECT_DOCS, { withFileTypes: true })
      .filter((d) => d.isDirectory())
      .map((d) => {
        const index = new URL(`${d.name}/index.md`, PROJECT_DOCS);
        const title = fs.existsSync(index)
          ? (fs.readFileSync(index, 'utf8').match(/^title:\s*"(.*)"$/m)?.[1] ?? d.name)
          : d.name;
        return {
          label: stripEmoji(JSON.parse(`"${title}"`)),
          collapsed: true,
          items: [{ autogenerate: { directory: `projects/${d.name}` } }],
        };
      })
      .sort((a, b) => a.label.localeCompare(b.label))
  : [];

export default defineConfig({
  site: 'https://ec-builds.com',
  integrations: [
    starlight({
      title: 'EC-Builds',
      disable404Route: true, // custom page in src/pages/404.astro
      description: 'Enterprise Infrastructure Homelab, built and documented like an enterprise IT environment.',
      logo: { src: './src/assets/ec-logo.png', alt: 'EC-Builds' },
      // Starlight adds the other og:/twitter: tags itself.
      favicon: '/favicon.ico',
      head: [
        { tag: 'link', attrs: { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/favicon-32.png' } },
        { tag: 'link', attrs: { rel: 'apple-touch-icon', href: '/apple-touch-icon.png' } },
        { tag: 'link', attrs: { rel: 'manifest', href: '/site.webmanifest' } },
        { tag: 'meta', attrs: { name: 'theme-color', content: '#f6f9fe' } },
        { tag: 'meta', attrs: { property: 'og:image', content: 'https://ec-builds.com/og-image.png' } },
        { tag: 'meta', attrs: { property: 'og:image:width', content: '1200' } },
        { tag: 'meta', attrs: { property: 'og:image:height', content: '630' } },
        { tag: 'meta', attrs: { property: 'og:image:alt', content: 'EC-Builds: Enterprise Infrastructure Homelab' } },
        { tag: 'meta', attrs: { name: 'twitter:image', content: 'https://ec-builds.com/og-image.png' } },
        { tag: 'script', attrs: { src: '/site.js', defer: true } },
      ],
      social: [
        { icon: 'github', label: 'GitHub', href: 'https://github.com/ec-builds/enterprise-homelab' },
        { icon: 'linkedin', label: 'LinkedIn', href: 'https://www.linkedin.com/in/casillasemmanuel' },
      ],
      customCss: [
        '@fontsource/inter/400.css',
        '@fontsource/inter/500.css',
        '@fontsource/inter/600.css',
        '@fontsource/inter/700.css',
        '@fontsource/montserrat/700.css',
        '@fontsource/montserrat/800.css',
        '@fontsource/jetbrains-mono/400.css',
        './src/styles/theme.css',
      ],
      // No highlighter for these; render as plain text.
      expressiveCode: { shiki: { langAlias: { logql: 'txt', promql: 'txt', conf: 'ini' } } },
      routeMiddleware: './src/routeData.ts',
      components: {
        SiteTitle: './src/components/SiteTitle.astro',
        Footer: './src/components/Footer.astro',
        Pagination: './src/components/Pagination.astro',
        SocialIcons: './src/components/SocialIcons.astro',
      },
      sidebar: [
        { label: 'Home', link: '/' },
        {
          label: 'Projects',
          items: [{ label: 'All projects', slug: 'projects' }, ...projectGroups],
        },
      ],
    }),
  ],
});
