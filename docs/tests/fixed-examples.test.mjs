import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import { spawnSync } from 'node:child_process';

const yamlWidgets = `- type: switch\n  name: enabled\n  label: Enabled\n  default: false\n`;

async function preprocess(content) {
  const root = await fs.mkdtemp('/tmp/codly-fixed-previews-');
  const input = [{root}, {items:[{Chapter:{name:'Fixed examples',path:'guide/fixed.md',content,sub_items:[]}}]}];
  try {
    const result = spawnSync(process.execPath, ['scripts/preprocessor.mjs'], {
      input: JSON.stringify(input), encoding: 'utf8', timeout: 30000,
    });
    return {result, root};
  } catch (error) {
    await fs.rm(root, {recursive:true, force:true});
    throw error;
  }
}

test('fixed and interactive previews keep authored source, cached output, and shared source IDs', async () => {
  const body = '#let answer = 42\n#answer';
  const content = [
    '```typst preview fixed\n' + body + '\n```',
    '```typ preview\n' + body + '\n```',
    '```typst,preview,fixed\n#let other = 7\n#other\n```',
  ].join('\n\n');
  const {result, root} = await preprocess(content);
  try {
    assert.equal(result.status, 0, result.stderr);
    const html = JSON.parse(result.stdout).items[0].Chapter.content;
    const manifest = JSON.parse(await fs.readFile(root + '/src/assets/examples.json', 'utf8'));
    assert.equal(manifest.length, 3);
    // The preprocessor walks fence tokens in reverse when it emits manifests.
    const fixed = manifest.find(example => example.body === body && example.fixed === true);
    const interactive = manifest.find(example => example.body === body && example.fixed === false);
    const commaFixed = manifest.find(example => example.body.includes('other'));
    assert(fixed && interactive && commaFixed);
    assert.deepEqual(Object.keys(fixed).sort(), ['body','chapter','fixed','id','source','widgets'].sort());
    assert.equal(fixed.fixed, true);
    assert.equal(interactive.fixed, false);
    assert.equal(commaFixed.fixed, true);
    assert.equal(fixed.source, body);
    assert.equal(fixed.body, body);
    assert.equal(fixed.widgets.length, 0);
    assert.equal(fixed.id, interactive.id, 'fixed mode must not affect the cached SVG identity');
    for (const example of manifest) {
      assert.match(html, new RegExp(`src="\\.\\./assets/previews/${example.id}\\.svg"`));
    }
    const fixedSection = html.match(/<section class="example example-fixed"[\s\S]*?<\/section>/)?.[0];
    assert(fixedSection, 'fixed preview should use the fixed example section class');
    assert.match(fixedSection, /data-fixed="true"/);
    assert(fixedSection.indexOf('class="highlighted"') < fixedSection.indexOf('class="example-output"'), 'authored source should precede its cached output');
    assert.match(fixedSection, /<button data-copy hidden>Copy code<\/button>/);
    assert.doesNotMatch(fixedSection, /<textarea|<details class="editor"|data-run|data-reset|example-controls|example-status/);
    assert.match(html, /<textarea/,'interactive previews retain their editor');
    assert.match(html, /<details class="editor"/);
  } finally { await fs.rm(root, {recursive:true, force:true}); }
});

test('widget configuration cannot attach to fixed previews and still requires adjacency', async () => {
  const fixed = '```typst preview fixed\n#true\n```';
  const configured = '```yaml widgets\n' + yamlWidgets + '```\n\n' + fixed;
  const fixedResult = await preprocess(configured);
  try {
    assert.notEqual(fixedResult.result.status, 0);
    assert.match(fixedResult.result.stderr, /guide\/fixed\.md:.*fixed previews cannot have widgets/i);
  } finally { await fs.rm(fixedResult.root, {recursive:true, force:true}); }

  const interactive = '```typst preview\n#true\n```';
  const nonAdjacent = '```yaml widgets\n' + yamlWidgets + '```\n\nA paragraph breaks adjacency.\n\n' + interactive;
  const adjacentResult = await preprocess(nonAdjacent);
  try {
    assert.notEqual(adjacentResult.result.status, 0);
    assert.match(adjacentResult.result.stderr, /guide\/fixed\.md:.*immediately precede/);
  } finally { await fs.rm(adjacentResult.root, {recursive:true, force:true}); }
});
