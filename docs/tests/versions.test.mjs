import test from 'node:test';
import assert from 'node:assert/strict';
import { initializeVersionSelector, isValidVersionId, normalizeVersionsManifest, resolveVersionUrl } from '../runtime/versions.mjs';

function selectorFixture() {
  return {
    hidden: true, value: '', options: [], listeners: {},
    replaceChildren() { this.options = []; },
    append(option) { this.options.push(option); },
    addEventListener(name, callback) { this.listeners[name] = callback; },
  };
}

function documentFixture() {
  return { createElement: tag => ({ tag, value: '', textContent: '' }) };
}

test('version IDs reject paths and accept published versions', () => {
  for (const version of ['v2.0.0', 'v2.1.0-rc.1', 'main', 'local']) assert.equal(isValidVersionId(version), true);
  for (const version of ['../main', '/main', 'v2.0', 'latest', '']) assert.equal(isValidVersionId(version), false);
});

test('local string manifests normalize to a labeled local version', () => {
  assert.deepEqual(normalizeVersionsManifest({ versions: ['local'] }), {
    defaultVersion: 'local', versions: [{ version: 'local', label: 'Local' }],
  });
});

test('version navigation keeps a matching chapter, preferences, and fragment', async () => {
  const target = await resolveVersionUrl({
    currentUrl: 'https://example.test/codly/v2.0.0/guide/setup.html?theme=light&font=noto&other=drop#install',
    currentRoot: 'https://example.test/codly/v2.0.0/',
    deploymentRoot: 'https://example.test/codly/',
    version: 'main',
    fetchImpl: async (url, options) => {
      assert.equal(options.method, 'HEAD');
      assert.equal(url, 'https://example.test/codly/main/guide/setup.html');
      return { ok: true };
    },
  });
  assert.equal(target, 'https://example.test/codly/main/guide/setup.html?theme=light&font=noto#install');
});

test('missing chapters fall back to the target index and drop the fragment', async () => {
  const target = await resolveVersionUrl({
    currentUrl: 'https://example.test/codly/v2.0.0/old/chapter.html?theme=dark#section',
    currentRoot: 'https://example.test/codly/v2.0.0/',
    deploymentRoot: 'https://example.test/codly/',
    version: 'main',
    fetchImpl: async () => ({ ok: false }),
  });
  assert.equal(target, 'https://example.test/codly/main/index.html?theme=dark');
});

test('invalid versions never reach the navigation probe', async () => {
  let called = false;
  await assert.rejects(resolveVersionUrl({
    currentUrl: 'https://example.test/codly/', currentRoot: 'https://example.test/codly/',
    deploymentRoot: 'https://example.test/codly/', version: '../main', fetchImpl: async () => { called = true; },
  }), /Invalid documentation version/);
  assert.equal(called, false);
});

test('nested version pages load deployment metadata and safely populate the selector', async () => {
  const selector = selectorFixture();
  const requested = [];
  const responses = new Map([
    ['https://example.test/codly/main/assets/version.json', { version: 'main', siteRoot: '../' }],
    ['https://example.test/codly/versions.json', { defaultVersion: 'v2.0.0', versions: [
      { version: 'v2.0.0', label: 'v2.0.0' }, { version: 'main', label: '<b>main</b> (nightly)' },
    ] }],
  ]);
  await initializeVersionSelector({
    selector, pageRoot: '../', locationObject: { href: 'https://example.test/codly/main/guide/setup.html' },
    documentObject: documentFixture(),
    fetchImpl: async url => {
      requested.push(String(url));
      const data = responses.get(String(url));
      return { ok: Boolean(data), json: async () => data };
    },
  });
  assert.deepEqual(requested, [...responses.keys()]);
  assert.equal(selector.hidden, false);
  assert.equal(selector.value, 'main');
  assert.deepEqual(selector.options.map(({ value, textContent }) => [value, textContent]), [
    ['v2.0.0', 'v2.0.0'], ['main', '<b>main</b> (nightly)'],
  ]);
});

test('latest root metadata uses its own root manifest and hides selector on fetch failure', async () => {
  const selector = selectorFixture();
  const requested = [];
  await initializeVersionSelector({
    selector, pageRoot: './', locationObject: { href: 'https://example.test/codly/index.html' },
    documentObject: documentFixture(),
    fetchImpl: async url => {
      requested.push(String(url));
      if (String(url) === 'https://example.test/codly/assets/version.json') {
        return { ok: true, json: async () => ({ version: 'v2.0.0', siteRoot: './' }) };
      }
      return { ok: true, json: async () => ({ defaultVersion: 'v2.0.0', versions: [{ version: 'v2.0.0', label: 'v2.0.0' }] }) };
    },
  });
  assert.deepEqual(requested, ['https://example.test/codly/assets/version.json', 'https://example.test/codly/versions.json']);
  assert.equal(selector.hidden, false);

  const unavailable = selectorFixture();
  await initializeVersionSelector({
    selector: unavailable, pageRoot: './', locationObject: { href: 'https://example.test/codly/' },
    documentObject: documentFixture(), fetchImpl: async () => { throw new Error('offline'); },
  });
  assert.equal(unavailable.hidden, true);
});
