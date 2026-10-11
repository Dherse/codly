import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import MarkdownIt from 'markdown-it';
import { collapsibles } from '../scripts/collapsibles.mjs';
import { initializeCollapsibles, revealCollapsibleTarget } from '../runtime/collapsibles.mjs';

const md = new MarkdownIt({ html: true });

test('collapsible bodies retain Markdown, tables, links and native accessible disclosure', () => {
  const html = md.render(collapsibles('::: collapse Replace global configuration {#configuration}\n\n**Before** and [API details](api/index.md).\n\n| Old | New |\n| --- | --- |\n| configure | show rule |\n\n- First step\n- Second step\n\n:::'));
  assert.match(html, /<details class="collapsible" id="configuration">/);
  assert.match(html, /<summary><span class="collapsible-title">Replace global configuration<\/span><\/summary>/);
  assert.match(html, /<strong>Before<\/strong>/);
  assert.match(html, /href="api\/index.md"/);
  assert.match(html, /<table>/);
  assert.match(html, /<li>Second step<\/li>/);
  assert(!html.includes(':::'));
  assert(!html.includes(' open'));
});

test('titles are escaped, repeated automatic ids are unique, and nesting can start open', () => {
  const source = '::: collapse A "title" <img src=x> & more\n\n::: collapse-open Nested {#nested}\n\nBody.\n\n:::\n\n:::\n\n::: collapse A "title" <img src=x> & more\n\nSecond.\n\n:::';
  const html = md.render(collapsibles(source));
  assert.match(html, /A &quot;title&quot; &lt;img src=x&gt; &amp; more/);
  assert.match(html, /id="collapse-a-title-img-src-x-more"/);
  assert.match(html, /id="collapse-a-title-img-src-x-more-2"/);
  assert.match(html, /id="nested" open/);
  assert.equal((html.match(/<details /g) || []).length, 3);
  assert.equal((html.match(/<\/details>/g) || []).length, 3);
});

test('markers inside fenced code, indented code, HTML and quoted source stay literal', () => {
  for (const literal of [
    '```markdown\n::: collapse Literal\nBody\n:::\n```\n',
    '~~~~markdown\n::: collapse Literal\n```typst preview\nHello\n```\n:::\n~~~~\n',
    '    ::: collapse Literal\n    Body\n    :::\n',
    '<pre>\n::: collapse Literal\nBody\n:::\n</pre>\n',
    '> ::: collapse Literal\n> Body\n> :::\n',
  ]) assert.equal(collapsibles(literal), literal);
});

test('bad section boundaries, missing titles and invalid or duplicate ids explain the authoring error', () => {
  assert.throws(() => collapsibles(':::\n'), /Line 1: a closing ::: has no matching/);
  assert.throws(() => collapsibles('::: collapse Title\nBody\n'), /Line 1: an unclosed/);
  assert.throws(() => collapsibles('::: collapse\n:::\n'), /needs a title/);
  assert.throws(() => collapsibles('::: collapse Title {#bad id}\n:::\n'), /invalid collapsible id bad id/);
  assert.throws(() => collapsibles('::: collapse First {#same}\n:::\n::: collapse Second {#same}\n:::\n'), /duplicate collapsible id same/);
});

test('preprocessing preserves widgets, highlights, admonitions and Mermaid inside collapsible sections', async () => {
  const temp = await fs.mkdtemp('/tmp/codly-collapsibles-');
  try {
    const source = '# Migration\n\n::: collapse Port this feature {#feature}\n\n> [!TIP] Try it\n> Change the control below.\n\n```typst\n#let old = true\n```\n\n```yaml widgets\n- type: switch\n  name: enabled\n  label: Enabled\n  default: true\n```\n```typst preview\n#if enabled [Hello]\n```\n\n| Field | Type |\n| --- | --- |\n| enabled | `bool` |\n\n```mermaid\nflowchart LR\n  Before --> After\n```\n\n:::\n';
    const input = [{ root: temp }, { items: [{ Chapter: { name: 'Migration', path: 'guides/migration.md', content: source, sub_items: [] } }] }];
    const result = spawnSync(process.execPath, ['scripts/preprocessor.mjs'], { input: JSON.stringify(input), encoding: 'utf8', timeout: 10000 });
    assert.equal(result.status, 0, result.stderr);
    const html = md.render(JSON.parse(result.stdout).items[0].Chapter.content);
    assert.match(html, /<details class="collapsible" id="feature">/);
    assert.match(html, /class="admonition admonition-tip"/);
    assert.match(html, /class="code-card"/);
    assert.match(html, /class="example"/);
    assert.match(html, /data-widget="enabled"/);
    assert.match(html, /class="typst-type"/);
    assert.match(html, /data-mermaid=/);
    assert(!html.includes('yaml widgets'));
    const examples = JSON.parse(await fs.readFile(`${temp}/src/assets/examples.json`, 'utf8'));
    assert.equal(examples.length, 1);
    assert.equal(examples[0].body, '#if enabled [Hello]');
    assert.equal(examples[0].widgets[0].name, 'enabled');
    assert.match(examples[0].source, /#let enabled = true/);
  } finally {
    await fs.rm(temp, { recursive: true, force: true });
  }
});

function section(parent = null) {
  return { open: false, parentElement: parent, closest() { return this; } };
}

test('deep links reveal the target disclosure and all ancestors without closing unrelated sections', () => {
  const outer = section(), inner = section(outer), unrelated = section();
  revealCollapsibleTarget({ closest: () => inner });
  assert(outer.open);
  assert(inner.open);
  assert(!unrelated.open);
  revealCollapsibleTarget(outer);
  revealCollapsibleTarget(null);
});

test('initial fragments, changed fragments and repeated links open collapsed content', () => {
  const disclosure = section();
  let scrolls = 0;
  const target = { closest: () => disclosure, scrollIntoView() { scrolls++; } };
  const listeners = {};
  const win = {
    location: new URL('https://codly.dev/migration.html#feature'),
    addEventListener(name, callback) { listeners[name] = callback; },
    requestAnimationFrame(callback) { callback(); },
  };
  const doc = {
    getElementById(id) { return id === 'feature' ? target : null; },
    addEventListener(name, callback) { listeners[name] = callback; },
  };
  initializeCollapsibles(doc, win);
  assert(disclosure.open);
  assert.equal(scrolls, 1);
  disclosure.open = false;
  listeners.click({ target: { closest: () => ({ href: 'https://codly.dev/migration.html#feature' }) } });
  assert(disclosure.open);
  disclosure.open = false;
  listeners.hashchange();
  assert(disclosure.open);
  assert.equal(scrolls, 2);
  disclosure.open = false;
  listeners.click({ target: { closest: () => ({ href: 'https://elsewhere.dev/migration.html#feature' }) } });
  assert(!disclosure.open);
  win.location.hash = '#%invalid';
  assert.doesNotThrow(() => listeners.hashchange());
});
