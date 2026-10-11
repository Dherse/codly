export function revealCollapsibleTarget(target) {
  let section = target?.closest('details.collapsible');
  while (section) {
    section.open = true;
    section = section.parentElement?.closest('details.collapsible');
  }
}

// Native details work without JavaScript. This adds deep links to content that
// starts hidden, including links clicked again after a section was closed.
export function initializeCollapsibles(doc = document, win = window) {
  function targetFor(hash) {
    if (!hash || hash === '#') return null;
    try { return doc.getElementById(decodeURIComponent(hash.slice(1))); }
    catch { return null; }
  }
  function revealHash() {
    const target = targetFor(win.location.hash);
    if (!target) return;
    revealCollapsibleTarget(target);
    if (target.closest('details.collapsible')) {
      win.requestAnimationFrame(() => target.scrollIntoView({ block: 'start' }));
    }
  }
  doc.addEventListener('click', event => {
    if (event.defaultPrevented) return;
    const link = event.target.closest?.('a[href]');
    if (!link) return;
    const url = new URL(link.href, win.location.href);
    if (url.origin !== win.location.origin || url.pathname !== win.location.pathname) return;
    revealCollapsibleTarget(targetFor(url.hash));
  });
  win.addEventListener('hashchange', revealHash);
  revealHash();
}
