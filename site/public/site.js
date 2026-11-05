// External links open in a new tab, wide tables get keyboard focus, task checkboxes get labels,
// back-to-top (footer link, plus a floating button on phones past halfway down the page),
// and the tried address on the 404 page.

(() => {
  for (const a of document.querySelectorAll('a[href]')) {
    let url;
    try { url = new URL(a.href); } catch { continue; }
    if (/^https?:$/.test(url.protocol) && url.host !== location.host) {
      a.target = '_blank';
      a.rel = `${a.rel} noopener`.trim();
    }
  }

  const tables = document.querySelectorAll('.ec-table-wrap');
  const headingBefore = (el) => {
    for (let n = el.previousElementSibling; n; n = n.previousElementSibling) {
      if (/^H[2-6]$/.test(n.tagName)) return n.textContent.trim();
      const h = n.querySelector?.('h2, h3, h4, h5, h6');
      if (n.classList?.contains('sl-heading-wrapper') && h) return h.textContent.trim();
    }
    return '';
  };
  const updateTables = () => {
    for (const wrap of tables) {
      if (wrap.scrollWidth > wrap.clientWidth + 1) {
        const heading = headingBefore(wrap);
        wrap.tabIndex = 0;
        wrap.setAttribute('role', 'region');
        wrap.setAttribute('aria-label', heading ? `Table: ${heading} (scrolls sideways)` : 'Table (scrolls sideways)');
      } else {
        wrap.removeAttribute('tabindex');
        wrap.removeAttribute('role');
        wrap.removeAttribute('aria-label');
      }
    }
  };
  updateTables();
  let resizeTimer;
  addEventListener('resize', () => { clearTimeout(resizeTimer); resizeTimer = setTimeout(updateTables, 150); });

  for (const box of document.querySelectorAll('li > input[type="checkbox"]')) {
    if (box.labels?.length || box.hasAttribute('aria-label')) continue;
    const text = box.parentElement.textContent.trim();
    if (text) box.setAttribute('aria-label', text);
  }

  // Back to top: smooth unless the visitor prefers reduced motion; focus moves to the page title.
  const reduce = matchMedia('(prefers-reduced-motion: reduce)');
  const toTop = () => {
    scrollTo({ top: 0, behavior: reduce.matches ? 'auto' : 'smooth' });
    document.getElementById('_top')?.focus({ preventScroll: true });
  };
  const title = document.getElementById('_top');
  if (title && !title.hasAttribute('tabindex')) title.setAttribute('tabindex', '-1');
  for (const link of document.querySelectorAll('[data-to-top]')) {
    link.addEventListener('click', (e) => { e.preventDefault(); toTop(); });
  }

  const btn = document.createElement('button');
  btn.type = 'button';
  btn.className = 'ec-to-top';
  btn.setAttribute('aria-label', 'Back to top');
  btn.innerHTML = '<svg aria-hidden="true" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.25" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19V5"/><path d="m5 12 7-7 7 7"/></svg>';
  btn.addEventListener('click', toTop);
  document.body.append(btn);

  // Shown once past halfway, hidden again while the footer (which has its own link) is on screen.
  let footerVisible = false;
  const update = () => {
    const max = document.documentElement.scrollHeight - innerHeight;
    const show = max > 0 && scrollY >= max / 2 && !footerVisible;
    btn.classList.toggle('show', show);
  };
  const footer = document.querySelector('.ec-site-footer');
  if (footer && 'IntersectionObserver' in window) {
    new IntersectionObserver(([entry]) => { footerVisible = entry.isIntersecting; update(); }).observe(footer);
  }
  addEventListener('scroll', update, { passive: true });
  addEventListener('resize', update);
  update();

  // 404 page: show the address the visitor tried.
  for (const el of document.querySelectorAll('[data-404-path]')) {
    el.textContent = location.pathname;
    el.title = location.pathname;
  }
})();
