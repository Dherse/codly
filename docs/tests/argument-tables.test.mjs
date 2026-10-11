import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import MarkdownIt from 'markdown-it';
import { parseArgumentSchema, expandArgumentTables } from '../scripts/argument-tables.mjs';

const md = new MarkdownIt({ html: true });
const field = (type, defaultValue, extra = {}) => ({ type, ...(defaultValue === undefined ? {} : { default: defaultValue }), doc: 'A field.', ...extra });
const schemaFor = fields => ({ elements: { new: { fields } }, types: {} });
const expand = (schema, target = 'elements.new', parser = md) => expandArgumentTables(`{{#arg-table ${target}}}`, schema, parser, 'api/example.md');

test('tables preserve YAML field order, required and positional traits, and inferred optional defaults', () => {
  const schema = schemaFor({
    body: field('content', undefined, { required: true }),
    named: field('int', undefined, { required: true, named: true }),
    tail: field('e.types.option(int)', undefined, { named: false }),
    count: field('int', undefined),
    __layout: field('unsupported-hidden-type', undefined),
    alias: field('e.types.option(str)', 'none'),
  });
  const source = expand(schema);
  assert.match(source, /\| Field \| Type \| Default \/ required \| Meaning \|/);
  assert.match(source, /`body`.*Required, positional/);
  assert.match(source, /`named`.*Required, named/);
  assert.match(source, /`tail`.*`none`, positional/);
  assert.match(source, /`count`.*`0`/);
  assert(!source.includes('__layout'));
  assert(source.indexOf('`body`') < source.indexOf('`named`'));
  assert(source.indexOf('`count`') < source.indexOf('`alias`'));
  assert.equal(md.render(source).match(/<td>/g).length, 20);
});

test('nested options, unions, arrays, dictionary values, string enums and trailing commas render accurately', () => {
  const schema = schemaFor({
    nested: field('e.types.option(e.types.union(auto, e.types.array(e.types.union(auto, str, auto,)), e.types.dict(e.types.option(language)), auto,))', 'auto'),
    enum: field('e.types.union("above", "below", "above",)', '"below"'),
    paint: field('e.types.option(e.types.union(e.types.paint, function))', 'none'),
    anything: field('e.types.any', 'auto'),
  });
  schema.types.language = { fields: {} };
  const html = md.render(expand(schema));
  assert.match(html, /none \| auto \| array&lt;auto \| str&gt; \| dictionary&lt;none \| language&gt;/);
  assert.match(html, /&quot;above&quot; \| &quot;below&quot;/);
  assert.match(html, /none \| paint \| function/);
  assert.match(html, /<code>any<\/code>/);
  assert.equal(html.match(/<td>/g).length, 16);
});

test('shared entry, callout and bubble fields match declaration filtering, inheritance, naming and insertion order', () => {
  const shared = {
    'source-indent': field('bool', 'false'),
    placement: field('e.types.union("above", "below")', '"below"'),
    'bubble-gap': field('length', '0.5em'),
    pointer: field('e.types.option(int)', 'none'),
    'pointer-size': field('length', '0.4em'),
    'pointer-height': field('e.types.union(length, auto)', 'auto'),
    'bubble-fill': field('e.types.option(e.types.paint)', 'luma(245)'),
  };
  for (const mode of ['entry', 'callout', 'bubble']) {
    const schema = schemaFor({
      body: field('content', undefined, { required: true }),
      stroke: field('e.types.option(stroke)', 'none'),
      final: field('bool', 'true'),
    });
    schema.elements.new['field-groups'] = [{ name: 'callout', after: 'stroke', mode }];
    schema['field-groups'] = { callout: shared };
    const source = expand(schema);
    assert(source.indexOf('`stroke`') < source.indexOf(mode === 'bubble' ? '`gap`' : '`source-indent`'));
    assert(source.indexOf('`final`') > source.indexOf(mode === 'bubble' ? '`fill`' : '`bubble-fill`'));
    if (mode === 'bubble') {
      assert(!source.includes('`source-indent`'));
      assert(!source.includes('`placement`'));
      assert(!source.includes('`pointer`'));
      assert(!source.includes('`bubble-gap`'));
      assert.match(source, /`gap`.*`length`.*`0\.5em`/);
      assert.match(source, /`pointer-size`.*`length`.*`0\.4em`/);
    } else if (mode === 'entry') {
      assert.match(source, /`source-indent`.*`bool \\\| auto`.*`auto`/);
      assert.match(source, /`placement`.*`auto`/);
      assert.match(source, /`pointer`.*`none \\\| int \\\| auto`.*`auto`/);
    } else {
      assert.match(source, /`source-indent`.*`bool`.*`false`/);
      assert.match(source, /`placement`.*`"below"`/);
      assert.match(source, /`pointer`.*`none \\\| int`.*`none`/);
      assert.match(source, /`bubble-gap`.*`length \\\| auto`.*`auto`/);
      assert.match(source, /`bubble-fill`.*`none \\\| paint \\\| auto`.*`auto`/);
    }
    assert.match(source, /`pointer-height`.*`length \\\| auto`/);
    assert(!source.includes('auto \\| auto'));
  }
});

test('unions involving any follow Elembic top-type simplification rather than displaying redundant alternatives', () => {
  const source = expand(schemaFor({
    value: field('e.types.union(int, e.types.any)', 'auto'),
    option: field('e.types.option(e.types.any)', 'none'),
    literal: field('e.types.union("any", int)', '0'),
  }));
  assert.match(source, /`value`.*`any`.*`auto`/);
  assert.match(source, /`option`.*`any`.*`none`/);
  assert.match(source, /`literal`.*`"any" \\\| int`/);
  assert.throws(() => expand(schemaFor({ field: field('e.types.option(e.types.any)', undefined) })), /Cannot infer this optional field default/);
});

test('group errors fail explicitly rather than emitting incomplete or contradictory tables', () => {
  for (const [descriptor, groups, expected] of [
    [{ name: 'missing', mode: 'entry', after: 'body' }, {}, /Unknown declaration field group missing/],
    [{ name: 'callout', mode: 'unknown', after: 'body' }, {}, /Unknown callout field mode unknown/],
    [{ name: 'callout', mode: 'entry', after: 'missing' }, {}, /Missing field-group insertion point missing/],
    [{ name: 'callout', mode: 'entry', after: 'body' }, {}, /Missing shared callout field definitions/],
    [{ name: 'callout', mode: 'entry', after: 'body' }, { callout: { body: field('content', '[]') } }, /duplicate argument names/],
  ]) {
    const schema = schemaFor({ body: field('content', '[]') });
    schema.elements.new['field-groups'] = [descriptor];
    schema['field-groups'] = groups;
    assert.throws(() => expand(schema), expected);
  }
});

test('unsupported type syntax and unknown default inference identify the declaration and chapter', () => {
  for (const type of ['e.types.array()', 'e.types.array(int, str)', 'e.types.union()', 'e.types.wrong(int)', 'Unknown', 'paint', 'any', 'e.types.option(int', 'int + bool', '"unterminated', '"bad\nstring"']) {
    assert.throws(() => expand(schemaFor({ field: field(type, 'none') })), /api\/example\.md:1: elements\.new\.field:/);
  }
  assert.throws(() => expand(schemaFor({ field: field('function', undefined) })), /Cannot infer this optional field default/);
  assert.throws(() => expand(schemaFor({ field: field('e.types.union(int, bool)', undefined) })), /Cannot infer this optional field default/);
  const custom = schemaFor({ field: field('language', undefined) });
  custom.types.language = { fields: {} };
  assert.throws(() => expand(custom), /Cannot infer this optional field default/);
});

test('private built-in defaults are named without leaking implementation references and functions remain authored expressions', () => {
  const source = expand(schemaFor({
    palette: field('e.types.array(color)', 'r.palette'),
    colors: field('e.types.array(e.types.paint)', 'themes-impl.presets.thesis.at("highlight-colors")'),
    code: field('str', 'r.code-scopes'),
    ignore: field('str', 'r.ignore-scopes'),
    callback: field('function', '(color) => 0.5pt + color'),
    empty: field('dictionary', '(:)'),
  }));
  assert.equal(source.match(/Built-in palette/g).length, 2);
  assert.equal(source.match(/Built-in selectors/g).length, 2);
  assert(!source.includes('r.palette'));
  assert(!source.includes('themes-impl'));
  assert(!source.includes('r.code-scopes'));
  assert.match(source, /`\(color\) => 0\.5pt \+ color`/);
  assert.match(source, /`\(:\)`/);
});

test('schema parsing rejects duplicate YAML, malformed YAML, non-string Typst expressions and invalid traits', () => {
  const prefix = 'elements:\n  new:\n    fields:\n';
  assert.throws(() => parseArgumentSchema(prefix + '      field:\n        type: int\n        type: bool\ntypes: {}'), /Map keys must be unique/);
  assert.throws(() => parseArgumentSchema('elements: ['), /Argument schema YAML/);
  assert.throws(() => parseArgumentSchema('elements: !unknown {}\ntypes: {}'), /Argument schema YAML:.*Unresolved tag/s);
  assert.throws(() => parseArgumentSchema('[]'), /must be a mapping/);
  assert.throws(() => parseArgumentSchema('elements: {}'), /needs a types mapping/);
  assert.throws(() => parseArgumentSchema('elements:\n  new: {}\ntypes: {}'), /needs a fields mapping/);
  assert.throws(() => parseArgumentSchema(prefix + '      field:\n        type: int\n        default: 0\ntypes: {}'), /default must be a string/);
  assert.throws(() => parseArgumentSchema(prefix + '      field:\n        type: int\n        required: "true"\ntypes: {}'), /required must be a boolean/);
});

test('unknown and malformed directives explain their location and expected authoring syntax', () => {
  const schema = schemaFor({ body: field('content', '[]') });
  assert.throws(() => expandArgumentTables('# Example\n\n{{#arg-table types.missing}}', schema, md, 'api/page.md'), /api\/page\.md:3: Unknown argument table target types\.missing/);
  for (const marker of ['{{#arg-table}}', '{{#arg-table new}}', '{{#arg-table elements.new.extra}}', '{{#arg-table elements.new}} trailing', '{{#arg-table elements.new}']) {
    assert.throws(() => expandArgumentTables(marker, schema, md, 'guides/author.md'), /guides\/author\.md:1: malformed argument table directive/);
  }
  assert.equal(expandArgumentTables('An inline {{#arg-table elements.new}} example.', schema, md), 'An inline {{#arg-table elements.new}} example.');
});

test('literal fenced, indented, quoted and raw HTML directive examples remain untouched', () => {
  const schema = schemaFor({ body: field('content', '[]') });
  for (const literal of [
    '```markdown\n{{#arg-table elements.new}}\n```\n',
    '~~~markdown\n{{#arg-table missing}}\n~~~\n',
    '    {{#arg-table elements.new}}\n',
    '> {{#arg-table elements.new}}\n',
    '<pre>\n{{#arg-table elements.new}}\n</pre>\n',
    '<script>\n{{#arg-table missing}}\n</script>\n',
    '<!--\n{{#arg-table missing}}\n-->\n',
  ]) {
    assert.equal(expandArgumentTables(literal, schema, md), literal);
    assert.equal(expandArgumentTables(literal, schema, new MarkdownIt()), literal);
  }
});

test('plain descriptions and authored defaults containing pipes, backticks, HTML and Markdown render as safe table content', () => {
  const doc = 'A | B `code` <img src=x onerror=alert(1)> & **text** [link](bad)\nnext.';
  const defaultValue = '"a|b`<script>"';
  const schema = schemaFor({ field: field('str', defaultValue, { doc }) });
  const html = md.render(expand(schema));
  assert.equal((html.match(/<td>/g) || []).length, 4);
  assert.match(html, /A \| B `code` &lt;img src=x onerror=alert\(1\)&gt; &amp; \*\*text\*\* \[link\]\(bad\) next\./);
  assert.match(html, /<code>&quot;a\|b`&lt;script&gt;&quot;<\/code>/);
  assert(!html.includes('<img'));
  assert(!html.includes('<script>'));
  assert(!html.includes('<strong>'));
  assert(!html.includes('<a '));
});

test('table code defaults preserve odd and even backslashes before pipes, repeated backticks and surrounding whitespace', () => {
  const values = [
    ...Array.from({ length: 7 }, (_, count) => `"a${'\\'.repeat(count)}|b"`),
    '`tick`', '``both``', 'a```b', ' padded ', ' `literal` ', ' leading', 'trailing ', '   ',
  ];
  for (const value of values) {
    const source = expand(schemaFor({ field: field('str', value) }));
    const tokens = md.parse(source, {});
    const inlineCode = tokens.filter(token => token.type === 'inline')
      .flatMap(token => token.children || []).filter(token => token.type === 'code_inline');
    assert.equal(inlineCode.at(-1).content, value, JSON.stringify(value));
    assert.equal((md.render(source).match(/<td>/g) || []).length, 4, JSON.stringify(value));
  }
});

test('all checked-in declarations generate complete tables, including hidden-field filtering and expanded shared groups', async () => {
  const schema = parseArgumentSchema(await fs.readFile(new URL('../../src/args.yaml', import.meta.url), 'utf8'));
  for (const kind of ['elements', 'types']) {
    for (const name of Object.keys(schema[kind])) {
      const html = md.render(expand(schema, `${kind}.${name}`));
      assert(html.includes('<table>'), `${kind}.${name}`);
      assert(!html.includes('<code>__'), `${kind}.${name} exposes an internal field`);
      assert(!html.includes('e.types.'), `${kind}.${name} exposes declaration syntax`);
    }
  }
  assert.match(expand(schema, 'types.highlight-config'), /`depth`.*`none`/);
  assert.match(expand(schema, 'elements.new'), /`alias`/);
});
