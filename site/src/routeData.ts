import { defineRouteMiddleware } from '@astrojs/starlight/route-data';

const stripEmoji = (s: string) =>
  s.replace(/[\p{Extended_Pictographic}\u{1F1E6}-\u{1F1FF}\u{FE0F}\u{200D}]/gu, '').replace(/\s{2,}/g, ' ').trim();

export const onRequest = defineRouteMiddleware((context) => {
  const route = context.locals.starlightRoute;

  // Tab and link-preview titles without the emoji (the page heading keeps it).
  for (const entry of route.head) {
    const isTitle =
      entry.tag === 'title' ||
      (entry.tag === 'meta' && ['og:title', 'twitter:title'].includes(String(entry.attrs?.property ?? entry.attrs?.name)));
    if (!isTitle) continue;
    if (entry.tag === 'title' && typeof entry.content === 'string') entry.content = stripEmoji(entry.content);
    else if (entry.attrs && typeof entry.attrs.content === 'string') entry.attrs.content = stripEmoji(entry.attrs.content);
  }

  // Docs with their own "## Overview" showed it twice in "On this page".
  const toc = route.toc;
  if (!toc || toc.items.length < 2) return;
  const [auto, ...rest] = toc.items;
  const hasOwnOverview = rest.some((item) => item.text.trim().toLowerCase() === auto.text.trim().toLowerCase());
  if (hasOwnOverview) toc.items = rest;
});
