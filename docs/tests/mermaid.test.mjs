import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { spawn } from 'node:child_process';
import { runInNewContext } from 'node:vm';

test('Mermaid fences preserve readable source and do not create Typst previews', async () => {
  const temporary = await fs.mkdtemp('/tmp/codly-mermaid-');
  const source = 'flowchart LR\n  accTitle: Transform code\n  A["<raw>"] --> B["Codly & layout"]';
  try {
    const input = [{ root: temporary }, { items: [{ Chapter: {
      name: 'Internals', path: 'api/internals.md', content: `\`\`\`mermaid\n${source}\n\`\`\`\n`, sub_items: [],
    } }] }];
    const run = await new Promise((resolve, reject) => {
      const child = spawn(process.execPath, ['scripts/preprocessor.mjs'], { timeout: 30000 });
      let stdout = '', stderr = '';
      child.stdout.setEncoding('utf8').on('data', data => { stdout += data; });
      child.stderr.setEncoding('utf8').on('data', data => { stderr += data; });
      child.on('error', reject);
      child.on('close', status => resolve({ status, stdout, stderr }));
      child.stdin.end(JSON.stringify(input));
    });
    assert.equal(run.status, 0, run.stderr);
    const html = JSON.parse(run.stdout).items[0].Chapter.content;
    assert.match(html, /<figure class="mermaid-diagram" data-mermaid="diagram-[\da-f]+">/);
    assert.match(html, /<div class="mermaid-output" role="region" aria-label="Diagram" tabindex="0" hidden><\/div>/);
    assert.match(html, /<details class="mermaid-source" open>/);
    assert(html.includes('A[&quot;&lt;raw&gt;&quot;] --&gt; B[&quot;Codly &amp; layout&quot;]'));
    assert.deepEqual(JSON.parse(await fs.readFile(`${temporary}/src/assets/examples.json`, 'utf8')), []);
  } finally {
    await fs.rm(temporary, { recursive: true, force: true });
  }
});

async function diagramRuntime({ fail = false } = {}) {
  const root = { dataset: { theme: 'light' } };
  const details = { open: true };
  const variables = {};
  const image = { attributes: {}, viewBox: { baseVal: { width: 800 } }, style: { setProperty(name, value) { variables[name] = value; } }, setAttribute(name, value) { this.attributes[name] = value; }, hasAttribute(name) { return name in this.attributes; } };
  const output = { hidden: true, querySelector: () => image };
  const code = { textContent: 'flowchart LR\nA --> B' };
  const figure = { dataset: { mermaid: 'example' }, querySelector: selector => ({ '.mermaid-source': details, '.mermaid-source code': code, '.mermaid-output': output })[selector] };
  const configurations = [];
  let observer;
  const mermaid = {
    initialize(configuration) { configurations.push(configuration); },
    async render() { if (fail) throw new Error('Invalid diagram'); return { svg: '<svg></svg>' }; },
  };
  const source = (await fs.readFile('runtime/diagrams.mjs', 'utf8')).replace(/^import .*;\n/gm, '').replace('export function', 'function');
  const context = {
    mermaid,
    document: { documentElement: root },
    getComputedStyle: () => ({ getPropertyValue: property => `${root.dataset.theme}:${property}` }),
    MutationObserver: class { constructor(callback) { observer = callback; } observe() {} },
  };
  runInNewContext(source, context);
  await context.initializeDiagrams([figure]);
  return { root, details, output, image, variables, configurations, update: () => observer() };
}

test('diagrams follow the current theme and retain a reader-opened source panel', async () => {
  const runtime = await diagramRuntime();
  assert.equal(runtime.output.hidden, false);
  assert.equal(runtime.details.open, false);
  assert.equal(runtime.image.attributes.role, 'img');
  assert.equal(runtime.variables['--diagram-width'], '640px');
  assert.equal(runtime.configurations[0].securityLevel, 'strict');
  runtime.details.open = true;
  runtime.root.dataset.theme = 'dark';
  await runtime.update();
  const dark = runtime.configurations.at(-1);
  assert.equal(dark.themeVariables.darkMode, true);
  assert.equal(dark.themeVariables.primaryTextColor, 'dark:--text');
  assert.equal(runtime.details.open, true);
});

test('a failed diagram leaves the original source readable', async () => {
  const runtime = await diagramRuntime({ fail: true });
  assert.equal(runtime.output.hidden, true);
  assert.equal(runtime.details.open, true);
});
