import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { createEngine } from '../runtime/compiler.mjs';
import { compilerFontFiles } from '../scripts/assets.mjs';
import { previewConcurrency, renderPreviews } from '../scripts/previews.mjs';

test('preview worker count follows CPU availability, the override, and the number of examples', () => {
  const previous = process.env.CODLY_DOCS_WORKERS;
  delete process.env.CODLY_DOCS_WORKERS;
  try {
    assert.equal(previewConcurrency(20, undefined, 2), 2);
    assert.equal(previewConcurrency(20, undefined, 16), 4);
    assert.equal(previewConcurrency(1, undefined, 16), 1);
    assert.equal(previewConcurrency(0), 0);
    assert.equal(previewConcurrency(20, '8', 2), 8);
    assert.equal(previewConcurrency(3, '8'), 3);
    for (const value of ['', '0', '-1', '1.5', '2x', 'Infinity', ' 2 ', '9007199254740992']) {
      assert.throws(() => previewConcurrency(20, value), /positive integer/);
    }
  } finally {
    if (previous === undefined) delete process.env.CODLY_DOCS_WORKERS;
    else process.env.CODLY_DOCS_WORKERS = previous;
  }
});

test('parallel WASM previews match sequential rendering and report failed examples', { timeout: 30000 }, async () => {
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'codly-preview-pool-'));
  const outputDirectory = path.join(directory, 'parallel');
  const engine = {
    compilerWasm: await fs.readFile('book/assets/compiler.wasm'),
    rendererWasm: await fs.readFile('book/assets/renderer.wasm'),
    fonts: await Promise.all(compilerFontFiles.map(file => fs.readFile(file))),
    files: JSON.parse(await fs.readFile('book/assets/sources.json', 'utf8')),
  };
  const examples = [
    { id: 'first', chapter: 'first.md', source: '#import "@preview/codly:2.0.0" as codly\n#codly.new("FIRST")' },
    { id: 'second', chapter: 'second.md', source: '#import "@preview/codly:2.0.0" as codly\n#codly.new("SECOND\\nthird", annotations: ((start: 1, end: 2, content: [note]),))' },
    { id: 'third', chapter: 'third.md', source: '#import "@preview/codly:2.0.0" as codly\n#codly.new(raw("print(42)", lang: "py", block: true))' },
  ];
  try {
    const compile = await createEngine(engine);
    const expected = new Map();
    for (const example of examples) {
      expected.set(`${example.id}.svg`, await compile(example.source));
    }
    await renderPreviews({
      examples: [{ ...examples[0], source: '#let broken = (' }, ...examples],
      engine, outputDirectory, workers: 2,
    });
    assert.deepEqual((await fs.readdir(outputDirectory)).sort(), [...expected.keys()].sort());
    for (const [filename, svg] of expected) {
      assert.equal(await fs.readFile(path.join(outputDirectory, filename), 'utf8'), svg, filename);
    }
    await assert.rejects(renderPreviews({
      examples: [{ id: 'broken', chapter: 'broken.md', source: '#let broken = (' }, examples[0]],
      engine, outputDirectory: path.join(directory, 'failure'), workers: 2,
    }), /broken\.md:.*(?:expected|unclosed)/s);
    await renderPreviews({ examples: [], engine: {}, outputDirectory: path.join(directory, 'empty'), workers: 0 });
    await assert.rejects(fs.access(path.join(directory, 'empty')), { code: 'ENOENT' });
  } finally {
    await fs.rm(directory, { recursive: true, force: true });
  }
});
