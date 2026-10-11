import { createEngine } from './compiler.mjs';

// Restrict all worker fetches before initializing third-party code. No credentials,
// referrers, remote registries, telemetry or requests derived from example text.
const nativeFetch = self.fetch.bind(self);
self.fetch = (input, init = {}) => {
  const url = new URL(typeof input === 'string' ? input : input.url || input, self.location.href);
  if (url.origin !== self.location.origin) throw new Error('External requests are disabled.');
  return nativeFetch(url, { ...init, credentials: 'omit', referrerPolicy: 'no-referrer' });
};
const asset = name => new URL(name, self.location.href).href;
let engine;
let chain = Promise.resolve();
async function loadCompilerAssets() {
  const manifestUrl = asset('compiler-assets.json');
  const response = await fetch(manifestUrl);
  if (!response.ok) throw new Error('Could not load compiler assets.');
  const manifest = await response.json();
  const resolve = name => new URL(name, manifestUrl).href;
  return {
    compilerWasm: resolve(manifest.compilerWasm), rendererWasm: resolve(manifest.rendererWasm),
    fonts: manifest.fonts.map(resolve),
  };
}
self.onmessage = ({ data: { id, source } }) => {
  chain = chain.then(async () => {
    try {
      engine ||= (async () => createEngine({
        ...await loadCompilerAssets(),
        files: await fetch(asset('sources.json')).then(r => { if (!r.ok) throw new Error('Could not load bundled Codly.'); return r.json(); }),
      }))();
      const svg = await (await engine)(source);
      self.postMessage({ id, svg });
    } catch (error) {
      self.postMessage({ id, error: String(error.message || error) });
    }
  });
};
