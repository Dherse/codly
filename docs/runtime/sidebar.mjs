export function initializeSidebar(sidebar) {
  const current = sidebar.querySelector('.chapter a[aria-current="page"]');
  for (const [index, item] of [...sidebar.querySelectorAll('.chapter li')].entries()) {
    const section = item.querySelector(':scope > ol.section');
    const row = item.querySelector(':scope > .chapter-link-wrapper');
    const link = row?.querySelector('a');
    if (!section || !link) continue;
    section.id = `sidebar-section-${index}`;
    const toggle = document.createElement('button');
    toggle.type = 'button';
    toggle.className = 'chapter-toggle';
    toggle.setAttribute('aria-controls', section.id);
    toggle.innerHTML = '<svg viewBox="0 0 16 16" aria-hidden="true" focusable="false"><path d="m6 3 5 5-5 5"/></svg>';
    function setExpanded(expanded) {
      section.hidden = !expanded;
      item.classList.toggle('expanded', expanded);
      toggle.setAttribute('aria-expanded', String(expanded));
      toggle.setAttribute('aria-label', `${expanded ? 'Collapse' : 'Expand'} ${link.textContent}`);
    }
    setExpanded(!!current && item.contains(current));
    toggle.addEventListener('click', () => setExpanded(section.hidden));
    row.append(toggle);
  }

  function revealCurrent() {
    requestAnimationFrame(() => {
      if (!current || !sidebar.getClientRects().length || sidebar.querySelector('input:focus')) return;
      const item = current.getBoundingClientRect();
      const container = sidebar.getBoundingClientRect();
      sidebar.scrollTop += item.top - container.top - (sidebar.clientHeight - item.height) / 2;
    });
  }
  revealCurrent();
  document.fonts.ready.then(revealCurrent);
  window.addEventListener('resize', revealCurrent);
  window.addEventListener('pageshow', revealCurrent);
  return { revealCurrent };
}
