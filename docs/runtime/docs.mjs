import { validateWidgets, widgetDefaults, exampleSource } from './widgets.mjs';
import { initializeVersionSelector } from './versions.mjs';
const root = new URL(document.body.dataset.root || './', location.href);
const themeSwitch = document.querySelector('#theme');
const fontSelect = document.querySelector('#code-font');
initializeVersionSelector({ selector: document.querySelector('#docs-version'), pageRoot: document.body.dataset.root });
fontSelect.value = document.documentElement.dataset.font;
const cards = [...document.querySelectorAll('.example')];
const states = new Map();
let worker, active, counter = 0, queue = [], timeout;
const cache = new Map();
let highlighter;
const theme = () => document.documentElement.dataset.theme;
const font = () => fontSelect.value;
const key = state => JSON.stringify([state.source, theme(), font()]);

function status(state, text, error = false) {
  state.status.textContent = text;
  state.status.classList.toggle('error', error);
}
function showSvg(state, svg) {
  if (state.blob) URL.revokeObjectURL(state.blob);
  state.blob = URL.createObjectURL(new Blob([svg], { type: 'image/svg+xml' }));
  let img = state.card.querySelector('.live-preview');
  if (!img) { img = new Image(); img.className = 'live-preview'; img.alt = 'Rendered output of the Typst example'; state.card.querySelector('.preview').append(img); }
  img.src = state.blob;
  state.card.dataset.live = 'true';
  status(state, 'Rendered on your device');
}
function startNext() {
  if (active || !queue.length) return;
  const job = queue.shift();
  if (job.key !== key(job.state)) { startNext(); return; }
  active = job;
  status(job.state, worker ? 'Compiling…' : 'Loading local compiler (~29 MB)…');
  if (!worker) {
    worker = new Worker(new URL('assets/worker.js', root), { type: 'module' });
    worker.onmessage = ({ data }) => {
      if (!active || data.id !== active.id) return;
      clearTimeout(timeout);
      const finished = active; active = null;
      if (finished.key === key(finished.state)) {
        if (data.error) { status(finished.state, 'Showing original preview. ' + data.error, true); finished.state.card.removeAttribute('data-live'); }
        else {
          cache.set(finished.key, data.svg);
          if (cache.size > 16) cache.delete(cache.keys().next().value);
          showSvg(finished.state, data.svg);
        }
      }
      startNext();
    };
    worker.onerror = () => failWorker('The compiler could not start. Check your connection and use Run again.');
  }
  timeout = setTimeout(() => failWorker('Compilation timed out. Shorten the example and run again.'), 45000);
  worker.postMessage({ id: job.id, source: job.state.source, theme: theme(), font: font() });
}
function failWorker(message) {
  clearTimeout(timeout);
  worker?.terminate(); worker = undefined;
  if (active) status(active.state, message, true);
  for (const job of queue) status(job.state, 'Compiler stopped. Use Run to retry.', true);
  active = null; queue = [];
}
function schedule(state) {
  if (state.source.length > 30000) { status(state, 'Keep examples under 30,000 characters.', true); return; }
  const currentKey = key(state);
  if (cache.has(currentKey)) { showSvg(state, cache.get(currentKey)); return; }
  queue = queue.filter(job => job.state !== state);
  if (active?.state === state && active.key === currentKey) return;
  queue.push({ id: ++counter, state, key: currentKey });
  status(state, 'Queued…'); startNext();
}
function updateLinks() {
  for (const a of document.querySelectorAll('a[href]')) {
    const url = new URL(a.href);
    if (url.origin !== location.origin || !/\.html$|\/$/.test(url.pathname)) continue;
    if (a.closest('.chapter')) {
      const current = url.pathname.replace(/\/index\.html$/, '/') === location.pathname.replace(/\/index\.html$/, '/');
      a.classList.toggle('active', current);
      if (current) a.setAttribute('aria-current', 'page'); else a.removeAttribute('aria-current');
    }
    url.searchParams.set('theme', theme());
    url.searchParams.set('font', font());
    a.href = url.href;
  }
}
function updatePreferences() {
  themeSwitch.setAttribute('aria-checked', String(theme() === 'dark'));
  themeSwitch.title = `Switch to ${theme() === 'dark' ? 'light' : 'dark'} mode`;
  document.documentElement.dataset.font = font();
  const url = new URL(location.href);
  url.searchParams.set('theme', theme()); url.searchParams.set('font', font());
  history.replaceState(null, '', url);
  updateLinks();
  for (const state of states.values()) {
    // Static fallbacks have both font variants; no WASM download for reading.
    for (const img of state.card.querySelectorAll('.static-preview')) {
      img.src = new URL(`assets/previews/${state.card.dataset.example}-${img.dataset.theme}-${font()}.svg`, root);
    }
    if (state.enabled) schedule(state);
  }
}
themeSwitch.addEventListener('click', () => {
  document.documentElement.dataset.theme = theme() === 'dark' ? 'light' : 'dark';
  updatePreferences();
});
fontSelect.addEventListener('change', updatePreferences);
const preferences = document.querySelector('#preferences');
document.addEventListener('click', event => {
  if (!preferences.contains(event.target)) preferences.open = false;
});
document.addEventListener('keydown', event => {
  if (event.key === 'Escape' && preferences.open) {
    preferences.open = false;
    preferences.querySelector('summary').focus();
  }
});
const menu = document.querySelector('#menu-toggle');
menu.addEventListener('click', () => { const open = menu.getAttribute('aria-expanded') !== 'true'; menu.setAttribute('aria-expanded', open); document.querySelector('#sidebar').classList.toggle('open', open); });

for (const card of cards) {
  const textarea = card.querySelector('textarea');
  const widgets = validateWidgets(JSON.parse(card.dataset.widgets || '[]'));
  const state = { card, widgets, values: widgetDefaults(widgets), source: exampleSource(textarea.value, widgets), original: textarea.value, status: card.querySelector('.example-status'), enabled: false };
  states.set(card, state);
  card.querySelector('details').addEventListener('toggle', event => {
    if (event.target.open && !state.enabled) { state.enabled = true; schedule(state); }
  });
  let debounce;
  async function updateHighlight(source) {
    try {
      highlighter ||= import('./highlight.mjs');
      const html = await (await highlighter).highlight(source);
      if (textarea.value === source) card.querySelector('.highlighted').innerHTML = html; // Shiki escapes source text.
    } catch { status(state, 'Highlighting unavailable; plain source remains editable.', true); }
  }
  function updateExample() {
    state.enabled = true;
    state.source = exampleSource(textarea.value, widgets, state.values);
    clearTimeout(debounce);
    status(state, 'Waiting for changes…');
    debounce = setTimeout(() => {
      updateHighlight(textarea.value);
      schedule(state);
    }, 450);
  }
  textarea.addEventListener('input', updateExample);
  const controls = card.querySelector('.example-controls');
  function syncControls() {
    for (const input of card.querySelectorAll('[data-widget]')) {
      const widget = widgets.find(w => w.name === input.dataset.widget);
      const value = state.values[widget.name];
      if (widget.type === 'switch') input.checked = value === 'true';
      else input.value = widget.type === 'slider' && widget.unit ? value.slice(0, -widget.unit.length) : value;
      if (widget.type === 'slider') input.setAttribute('aria-valuetext', value);
      input.closest('.example-control').querySelector('output').textContent = value;
    }
  }
  if (controls) {
    controls.disabled = false;
    controls.addEventListener('input', event => {
      const input = event.target.closest('[data-widget]');
      if (!input) return;
      const widget = widgets.find(w => w.name === input.dataset.widget);
      state.values[widget.name] = widget.type === 'switch' ? String(input.checked) : input.value + (widget.type === 'slider' ? widget.unit : '');
      syncControls();
      updateExample();
    });
    card.querySelector('[data-reset-widgets]').addEventListener('click', () => {
      state.values = widgetDefaults(widgets);
      syncControls();
      updateExample();
    });
  }
  card.querySelector('[data-run]').addEventListener('click', () => schedule(state));
  card.querySelector('[data-reset]').addEventListener('click', () => { textarea.value = state.original; state.values = widgetDefaults(widgets); syncControls(); updateExample(); });
}
for (const button of document.querySelectorAll('[data-copy]')) {
  button.hidden = false;
  button.addEventListener('click', async () => {
    const card = button.closest('.example,.code-card');
    const source = states.get(card)?.source ?? card.querySelector('code').textContent;
    try { await navigator.clipboard.writeText(source); button.textContent = 'Copied ✓'; }
    catch { button.textContent = 'Select code to copy'; }
    setTimeout(() => { button.textContent = 'Copy code'; }, 2200);
  });
}
for (const heading of document.querySelectorAll('article h2')) {
  const a = document.createElement('a'); a.href = `#${heading.id}`; a.textContent = heading.textContent;
  document.querySelector('#page-toc').append(a);
}

const search = document.querySelector('#search');
const results = document.querySelector('#search-results');
let searchIndex;
search.addEventListener('input', async () => {
  const q = search.value.trim().toLowerCase();
  results.replaceChildren(); results.hidden = !q;
  if (!q) return;
  try {
    searchIndex ||= fetch(new URL('assets/search.json', root), { credentials: 'omit', referrerPolicy: 'no-referrer' }).then(r => { if (!r.ok) throw new Error(); return r.json(); });
    const index = await searchIndex;
    if (q !== search.value.trim().toLowerCase()) return;
    const words = q.split(/\s+/);
    const hits = index.map(page => ({ ...page, score: words.reduce((s,w) => s + (page.title.toLowerCase().includes(w) ? 8 : 0) + (page.text.toLowerCase().includes(w) ? 1 : 0),0) })).filter(p => words.every(w => (p.title+' '+p.text).toLowerCase().includes(w))).sort((a,b) => b.score-a.score).slice(0,10);
    for (const hit of hits) { const a = document.createElement('a'); a.href = new URL(hit.path,root); a.textContent = hit.title; results.append(a); }
    if (!hits.length) { const p = document.createElement('p'); p.textContent = 'No results. Try “rainbow”, “number” or “theme”.'; results.append(p); }
    updateLinks();
  } catch { const p = document.createElement('p'); p.textContent = 'Search could not load. Use the chapter list below.'; results.append(p); searchIndex = undefined; }
});
document.addEventListener('keydown', e => { if (e.key === '/' && !/INPUT|TEXTAREA|SELECT/.test(e.target.tagName)) { e.preventDefault(); if (matchMedia('(max-width:720px)').matches && menu.getAttribute('aria-expanded') !== 'true') menu.click(); search.focus(); } if (e.key === 'Escape') { search.value = ''; results.hidden = true; if (menu.getAttribute('aria-expanded') === 'true') menu.click(); } });
updatePreferences();
