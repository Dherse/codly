import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import MarkdownIt from 'markdown-it';
import { expandArgumentTables, parseArgumentSchema } from '../scripts/argument-tables.mjs';

const fixture = `elements:
  new:
    doc: Test element.
    fields:
      body:
        type: 'content'
        doc: Required source.
        required: true
      marker:
        type: 'e.types.option(e.types.array(e.types.union(str, language)))'
        default: 'none'
        doc: A searchable fixture description.
types:
  language:
    doc: Test language.
    fields:
      name:
        type: 'str'
        default: '"Example"'
        doc: Language name.
field-groups: {}
`;

test('preprocessing uses the selected YAML checkout for linked tables and search while preserving widgets', async () => {
  const root = await fs.mkdtemp('/tmp/codly-argument-tables-');
  const codlySource = path.join(root, 'checkout');
  const metadataPath = path.join(codlySource, 'src/args.yaml');
  await fs.mkdir(path.dirname(metadataPath), {recursive: true});
  const content = [
    '# Fixture', '', '{{#arg-table elements.new}}', '',
    '```yaml widgets', '- type: switch', '  name: enabled',
    '  label: Enabled', '  default: true', '```',
    '```typst preview', '#enabled', '```', '',
  ].join('\n');
  const input = [{root}, {items: [{Chapter: {
    name: 'Fixture', path: 'api/components/new.md', content, sub_items: [],
  }}]}];
  const preprocess = () => spawnSync(process.execPath, ['scripts/preprocessor.mjs'], {
    input: JSON.stringify(input), encoding: 'utf8', timeout: 30000,
    env: {...process.env, CODLY_SOURCE: codlySource},
  });
  try {
    await fs.writeFile(metadataPath, fixture);
    const first = preprocess();
    assert.equal(first.status, 0, first.stderr);
    const firstOutput = JSON.parse(first.stdout).items[0].Chapter.content;
    assert.doesNotMatch(firstOutput, /\{\{#arg-table/);
    assert.match(firstOutput, /<table>/);
    assert.match(firstOutput, /<code class="typst-type">/);
    assert.match(firstOutput, /href="\.\.\/types\/language\.html"/);
    assert.match(firstOutput, /A searchable fixture description\./);
    assert.match(firstOutput, /Required/);
    assert.match(firstOutput, /positional/i);
    const search = JSON.parse(await fs.readFile(path.join(root, 'src/assets/search.json'), 'utf8'));
    assert.equal(search[0].path, 'api/components/new.html');
    assert.match(search[0].text, /marker/);
    assert.match(search[0].text, /A searchable fixture description\./);
    assert.match(search[0].text, /array<str \| language>/);
    assert.doesNotMatch(search[0].text, /\{\{#arg-table/);
    const examples = JSON.parse(await fs.readFile(path.join(root, 'src/assets/examples.json'), 'utf8'));
    assert.equal(examples.length, 1);
    assert.equal(examples[0].body, '#enabled');
    assert.match(examples[0].source, /#let enabled = true/);
    assert.equal(examples[0].widgets[0].name, 'enabled');

    await fs.writeFile(metadataPath, fixture
      .replace('e.types.option(e.types.array(e.types.union(str, language)))', 'int')
      .replace("default: 'none'", "default: '7'")
      .replace('A searchable fixture description.', 'Updated from the selected checkout.'));
    const second = preprocess();
    assert.equal(second.status, 0, second.stderr);
    const secondOutput = JSON.parse(second.stdout).items[0].Chapter.content;
    assert.match(secondOutput, /Updated from the selected checkout\./);
    assert.match(secondOutput, /<code>7<\/code>/);
    assert.match(secondOutput, /href="https:\/\/typst\.app\/docs\/reference\/foundations\/int\/"/);
    assert.doesNotMatch(secondOutput, /types\/language\.html|A searchable fixture description/);
    const updatedSearch = JSON.parse(await fs.readFile(path.join(root, 'src/assets/search.json'), 'utf8'));
    assert.match(updatedSearch[0].text, /Updated from the selected checkout\./);
    assert.deepEqual(JSON.parse(await fs.readFile(path.join(root, 'src/assets/examples.json'), 'utf8')), examples);

    await fs.writeFile(metadataPath, fixture.replace('  new:', '  renamed:'));
    const missing = preprocess();
    assert.notEqual(missing.status, 0);
    assert.match(missing.stderr, /api\/components\/new\.md:.*elements\.new/);
  } finally {
    await fs.rm(root, {recursive: true, force: true});
  }
});

test('all public API tables match the runtime declaration field order and argument traits', async () => {
  const codlySource = path.resolve(process.env.CODLY_SOURCE || '..');
  const schema = parseArgumentSchema(await fs.readFile(path.join(codlySource, 'src/args.yaml'), 'utf8'));
  const signatures = JSON.parse(await fs.readFile(path.join(codlySource, 'tests/declarations/signatures.json'), 'utf8'));
  const md = new MarkdownIt();
  let count = 0;
  for (const [directory, kind] of [['components', 'elements'], ['types', 'types']]) {
    const folder = `src/api/${directory}`;
    for (const file of await fs.readdir(folder)) {
      if (!file.endsWith('.md') || file === 'index.md') continue;
      const source = await fs.readFile(path.join(folder, file), 'utf8');
      const name = file.slice(0, -3);
      assert.match(source, new RegExp(`\\{\\{#arg-table ${kind}\\.${name}\\}\\}`));
      const expanded = expandArgumentTables(`{{#arg-table ${kind}.${name}}}`, schema, md, `api/${directory}/${file}`);
      const tokens = md.parse(expanded, {});
      const rows = [];
      let current;
      for (let index = 0; index < tokens.length; index++) {
        if (tokens[index].type === 'tr_open') current = [];
        if (tokens[index].type === 'inline' && tokens[index - 1]?.type === 'td_open') current.push(tokens[index]);
        if (tokens[index].type === 'tr_close' && current.length) rows.push(current);
      }
      const runtime = signatures.declarations.find(declaration =>
        declaration.name === (name === 'new' ? 'codly' : name)
        && declaration.id.startsWith(kind === 'types' ? 't_' : 'e_'));
      assert(runtime, `${kind}.${name}: missing runtime signature`);
      const publicFields = runtime.fields.filter(field => !field[0].startsWith('__'));
      assert.deepEqual(rows.map(row => row[0].children.find(token => token.type === 'code_inline')?.content),
        publicFields.map(field => field[0]), `${kind}.${name}: field order`);
      for (const [index, field] of publicFields.entries()) {
        const defaultCell = rows[index][2].content;
        assert.equal(/required/i.test(defaultCell), field[6], `${kind}.${name}.${field[0]}: required`);
        assert.equal(/positional/i.test(defaultCell), !field[7], `${kind}.${name}.${field[0]}: positional`);
      }
      count++;
    }
  }
  assert.equal(count, 30);
});
