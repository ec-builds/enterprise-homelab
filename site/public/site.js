// External links open in a new tab, wide tables get keyboard focus, task checkboxes get labels,
// back-to-top (footer link, plus a floating button on phones after 1.5 screens of scrolling),
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

  // Shown after 1.5 screens of scrolling (the same on short and long pages), hidden again while
  // the footer (which has its own link) is on screen.
  let footerVisible = false;
  const update = () => {
    const show = scrollY >= innerHeight * 1.5 && !footerVisible;
    btn.classList.toggle('show', show);
  };
  const footer = document.querySelector('.ec-site-footer');
  if (footer && 'IntersectionObserver' in window) {
    new IntersectionObserver(([entry]) => { footerVisible = entry.isIntersecting; update(); }).observe(footer);
  }
  addEventListener('scroll', update, { passive: true });
  addEventListener('resize', update);
  update();

  // Click-to-enlarge for screenshots and diagrams in the docs, on screens 700px and wider only (on phones,
  // pinch-zoom already works). Native <dialog>: Esc closes, focus returns to the image for keyboard users.
  // Skipped: images inside links (they already go somewhere) and banners.
  const prose = document.querySelector('.sl-markdown-content');
  const imgs = prose
    ? Array.from(prose.querySelectorAll('img')).filter((img) => !img.closest('a') && !/banner/i.test(img.getAttribute('src') || ''))
    : [];
  if (imgs.length && typeof HTMLDialogElement === 'function') {
    const box = document.createElement('dialog');
    box.className = 'ec-lightbox';
    box.setAttribute('aria-label', 'Enlarged image');
    box.innerHTML = '<button class="ec-lightbox__close" type="button" aria-label="Close enlarged image"><svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true"><path d="M6 6l12 12M18 6L6 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" fill="none"/></svg></button>';
    const big = document.createElement('img');
    big.className = 'ec-lightbox__img';
    big.alt = '';
    const cap = document.createElement('p');
    cap.className = 'ec-lightbox__caption';
    box.append(big, cap);
    document.body.append(box);

    const wide = matchMedia('(min-width: 700px)');
    let opener = null;
    let byKeyboard = false;
    const open = (btn, img, keyboard) => {
      opener = btn;
      byKeyboard = keyboard;
      big.src = img.currentSrc || img.src;
      big.alt = img.alt;
      cap.textContent = img.alt;
      cap.hidden = !img.alt;
      box.showModal();
    };
    // Wrap each image in a button on wide screens; unwrap it on narrow ones so it is a plain image again.
    const apply = () => {
      for (const img of imgs) {
        const wrapped = img.parentElement && img.parentElement.classList.contains('ec-zoomable');
        if (wide.matches && !wrapped) {
          const btn = document.createElement('button');
          btn.type = 'button';
          btn.className = 'ec-zoomable';
          btn.setAttribute('aria-label', img.alt ? `Enlarge image: ${img.alt}` : 'Enlarge image');
          btn.addEventListener('click', (e) => open(btn, img, e.detail === 0)); // detail 0 = Enter/Space
          img.replaceWith(btn);
          btn.append(img);
        } else if (!wide.matches && wrapped) {
          img.parentElement.replaceWith(img);
        }
      }
      if (!wide.matches && box.open) box.close();
    };
    apply();
    wide.addEventListener('change', apply);
    box.querySelector('.ec-lightbox__close').addEventListener('click', () => box.close());
    // A click on the enlarged image or the backdrop closes it.
    box.addEventListener('click', (e) => { if (e.target === box || e.target === big) box.close(); });
    box.addEventListener('close', () => {
      big.removeAttribute('src');
      if (!opener || !opener.isConnected) return;
      if (byKeyboard) opener.focus();
      else opener.blur();
    });
  }

  // 404 page: show the address the visitor tried.
  for (const el of document.querySelectorAll('[data-404-path]')) {
    el.textContent = location.pathname;
    el.title = location.pathname;
  }
})();
