const VERSION_ID = /^(?:v\d+\.\d+\.\d+(?:-[A-Za-z0-9.-]+)?|main|local)$/;

export function isValidVersionId(version) {
  return typeof version === 'string' && VERSION_ID.test(version);
}

export function normalizeVersionsManifest(manifest) {
  if (Array.isArray(manifest?.versions)) {
    const versions = manifest.versions.map(entry => typeof entry === 'string'
      ? { version: entry, label: entry === 'local' ? 'Local' : entry }
      : entry);
    return { defaultVersion: manifest.defaultVersion ?? versions[0]?.version, versions };
  }
  return { defaultVersion: manifest?.defaultVersion, versions: manifest?.versions };
}

function pagePath(url, root) {
  const relative = url.pathname.slice(root.pathname.length);
  return relative || 'index.html';
}

export async function resolveVersionUrl({ currentUrl, currentRoot, deploymentRoot, version, fetchImpl = fetch }) {
  if (!isValidVersionId(version)) throw new TypeError('Invalid documentation version');
  const current = new URL(currentUrl);
  const root = new URL(currentRoot);
  const targetRoot = new URL(version === 'local' ? './' : `${version}/`, deploymentRoot);
  const relativePage = pagePath(current, root);
  const target = new URL(relativePage, targetRoot);
  let matchingPage = false;
  try {
    const response = await fetchImpl(target.href, { method: 'HEAD', credentials: 'omit', referrerPolicy: 'no-referrer' });
    matchingPage = response.ok;
  } catch { /* A failed check uses the version's landing page. */ }
  if (!matchingPage) target.pathname = new URL('index.html', targetRoot).pathname;
  for (const key of ['theme', 'font']) {
    const value = current.searchParams.get(key);
    if (value !== null) target.searchParams.set(key, value);
  }
  if (matchingPage) target.hash = current.hash;
  return target.href;
}

export async function initializeVersionSelector({ selector, pageRoot, fetchImpl = fetch, locationObject = location, documentObject = document } = {}) {
  if (!selector) return;
  try {
    const root = new URL(pageRoot, locationObject.href);
    const versionResponse = await fetchImpl(new URL('assets/version.json', root), { credentials: 'omit', referrerPolicy: 'no-referrer' });
    if (!versionResponse.ok) throw new Error('Version metadata unavailable');
    const metadata = await versionResponse.json();
    if (!isValidVersionId(metadata.version) || typeof metadata.siteRoot !== 'string') throw new Error('Invalid version metadata');

    const deploymentRoot = new URL(metadata.siteRoot, root);
    const manifestResponse = await fetchImpl(new URL('versions.json', deploymentRoot), { credentials: 'omit', referrerPolicy: 'no-referrer' });
    if (!manifestResponse.ok) throw new Error('Version list unavailable');
    const manifest = normalizeVersionsManifest(await manifestResponse.json());
    if (!Array.isArray(manifest.versions)) throw new Error('Invalid version list');
    const versions = manifest.versions.filter(item => item && isValidVersionId(item.version) && typeof item.label === 'string');
    if (!versions.length || !versions.some(item => item.version === metadata.version)) throw new Error('Current version missing from version list');

    selector.replaceChildren();
    for (const item of versions) {
      const option = documentObject.createElement('option');
      option.value = item.version;
      option.textContent = item.label;
      selector.append(option);
    }
    selector.value = metadata.version;
    selector.hidden = false;
    selector.addEventListener('change', async () => {
      try {
        locationObject.assign(await resolveVersionUrl({
          currentUrl: locationObject.href,
          currentRoot: root,
          deploymentRoot,
          version: selector.value,
          fetchImpl,
        }));
      } catch { selector.value = metadata.version; }
    });
  } catch {
    selector.hidden = true;
  }
}
