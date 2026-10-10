import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import MarkdownIt from 'markdown-it';
import { admonitions } from '../scripts/admonitions.mjs';

const md = new MarkdownIt({ html: true });

test('all five boxes render Markdown with accessible labels and decorative icons', () => {
  for (const kind of ['NOTE', 'TIP', 'IMPORTANT', 'WARNING', 'CAUTION']) {
    const html = md.render(admonitions(`> [!${kind}]\n> **Bold** and [a link](example.md).\n>\n> - First\n> - Second\n`));
    assert.match(html, new RegExp(`class="admonition admonition-${kind.toLowerCase()}"`));
    assert.match(html, /role="note" aria-label="[A-Z][a-z]+"/);
    assert.match(html, /aria-hidden="true" focusable="false"/);
    assert.match(html, /<strong>Bold<\/strong>/);
    assert.match(html, /<a href="example.md">a link<\/a>/);
    assert.match(html, /<li>First<\/li>/);
    assert(!html.includes(`[!${kind}]`));
  }
});

test('custom titles are escaped and literal markers and ordinary quotes stay unchanged', () => {
  const source = '> [!WARNING] A "title" <img src=x> & more\n> Body\n';
  assert.match(admonitions(source), /aria-label="A &quot;title&quot; &lt;img src=x&gt; &amp; more"/);
  for (const literal of [
    '> An ordinary quote.\n> Continued.\n',
    '> [!UNKNOWN]\n> Future marker\n',
    '> Mention [!TIP] within a sentence.\n',
    '```markdown\n> [!WARNING]\n> Example syntax\n```\n',
    '    > [!WARNING]\n    > Indented example\n',
  ]) assert.equal(admonitions(literal), literal);
});

test('nested boxes, ordinary nested quotes, and lazy continuations retain their content', () => {
  const source = '> [!NOTE]\n> Parent.\n>\n> > [!TIP]\n> > Nested tip.\n>\n> > Ordinary nested quote.\n>\n> Final paragraph.\n\n> [!CAUTION]\nLazy continuation.\n';
  const html = md.render(admonitions(source));
  assert.equal((html.match(/<aside /g) || []).length, 3);
  assert.equal((html.match(/<\/aside>/g) || []).length, 3);
  assert.match(html, /<blockquote>\n<p>Ordinary nested quote\.<\/p>/);
  assert.match(html, /<p>Final paragraph\.<\/p>/);
  assert.match(html, /<p>Lazy continuation\.<\/p>/);
});

test('preprocessing keeps syntax highlighting and interactive previews inside boxes', async () => {
  const temp = await fs.mkdtemp('/tmp/codly-admonitions-');
  try {
    const source = '> [!TIP] Interactive example\n> Try **this**:\n>\n> ```yaml widgets\n> - type: switch\n>   name: enabled\n>   label: Enabled\n>   default: true\n> ```\n> ```typst preview\n> #if enabled [Hello]\n> ```\n\n> [!WARNING]\n> ```typst\n> #let palette = ()\n> ```\n';
    const input = [{ root: temp }, { items: [{ Chapter: { name: 'Boxes', path: 'boxes.md', content: source, sub_items: [] } }] }];
    const result = spawnSync(process.execPath, ['scripts/preprocessor.mjs'], { input: JSON.stringify(input), encoding: 'utf8', timeout: 10000 });
    assert.equal(result.status, 0, result.stderr);
    const output = JSON.parse(result.stdout).items[0].Chapter.content;
    const html = md.render(output);
    assert.match(html, /admonition-tip/);
    assert.match(html, /<strong>this<\/strong>/);
    assert.match(html, /class="example"/);
    assert.match(html, /class="code-card"/);
    assert.match(html, /--shiki-light:/);
    assert(!html.includes('```'));
    const examples = JSON.parse(await fs.readFile(`${temp}/src/assets/examples.json`, 'utf8'));
    assert.equal(examples.length, 1);
    assert.equal(examples[0].body, '#if enabled [Hello]');
    assert.equal(examples[0].widgets[0].name, 'enabled');
  } finally {
    await fs.rm(temp, { recursive: true, force: true });
  }
});
