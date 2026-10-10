// Preferences live in the URL, never in browser storage.
(() => {
  const params = new URLSearchParams(location.search);
  document.documentElement.dataset.theme = params.get('theme') === 'light' ? 'light' : 'dark';
  document.documentElement.dataset.font = params.get('font') === 'noto' ? 'noto' : 'dejavu';
})();
