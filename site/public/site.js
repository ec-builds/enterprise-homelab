// External links open in a new tab, wide tables get keyboard focus, task checkboxes get labels.

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
})();
