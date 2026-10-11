import { parseDocument } from 'yaml';
import { typstTypeLinks } from './type-tables.mjs';

const isMap = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const nativeTypes = new Set([...Object.keys(typstTypeLinks).filter(name => !['paint', 'any'].includes(name)), 'gradient', 'tiling', 'pattern', 'relative']);
// Elembic's known native defaults. Custom types and ordinary unions need an
// explicit default; the build must not invent one when metadata changes.
const nativeDefaults = {
  content: '[]', float: '0.0', stroke: 'stroke()', relative: '0% + 0pt',
  array: '()', dictionary: '(:)', str: '""', bool: 'false', int: '0',
  angle: '0deg', ratio: '0%', length: '0pt', fraction: '0fr',
  duration: 'duration(seconds: 0)', arguments: 'arguments()', bytes: 'bytes(())',
  version: 'version(0, 0, 0)', none: 'none', auto: 'auto',
};

export function parseArgumentSchema(yamlSource) {
  const document = parseDocument(yamlSource, { uniqueKeys: true });
  const problems = [...document.errors, ...document.warnings];
  if (problems.length) throw new Error(`Argument schema YAML: ${problems.map(error => error.message).join('; ')}`);
  const schema = document.toJS({ maxAliasCount: 100 });
  if (!isMap(schema)) throw new Error('Argument schema YAML must be a mapping.');
  for (const kind of ['elements', 'types']) {
    if (!isMap(schema[kind])) throw new Error(`Argument schema YAML needs a ${kind} mapping.`);
    for (const [name, declaration] of Object.entries(schema[kind])) {
      if (!isMap(declaration) || !isMap(declaration.fields)) throw new Error(`Argument schema ${kind}.${name} needs a fields mapping.`);
      validateFields(declaration.fields, `${kind}.${name}`);
      if (declaration['field-groups'] !== undefined && !Array.isArray(declaration['field-groups'])) {
        throw new Error(`Argument schema ${kind}.${name}.field-groups must be an array.`);
      }
    }
  }
  if (schema['field-groups'] !== undefined) {
    if (!isMap(schema['field-groups'])) throw new Error('Argument schema field-groups must be a mapping.');
    for (const [name, fields] of Object.entries(schema['field-groups'])) validateFields(fields, `field-groups.${name}`);
  }
  return schema;
}

function validateFields(fields, location) {
  if (!isMap(fields)) throw new Error(`Argument schema ${location} must be a field mapping.`);
  for (const [name, field] of Object.entries(fields)) {
    if (!isMap(field) || typeof field.type !== 'string' || !field.type.trim()) {
      throw new Error(`Argument schema ${location}.${name} needs a Typst type expression string.`);
    }
    for (const key of ['doc', 'default']) {
      if (field[key] !== undefined && typeof field[key] !== 'string') throw new Error(`Argument schema ${location}.${name}.${key} must be a string.`);
    }
    for (const key of ['required', 'named', 'folds']) {
      if (field[key] !== undefined && typeof field[key] !== 'boolean') throw new Error(`Argument schema ${location}.${name}.${key} must be a boolean.`);
    }
  }
}

// This reads the declarative subset used in args.yaml; it does not execute
// Typst. Unrecognized syntax fails so a new declaration cannot silently drift.
function parseType(source, schema) {
  let cursor = 0;
  const fail = message => { throw new Error(`${message} at character ${cursor + 1} in type expression ${JSON.stringify(source)}.`); };
  const whitespace = () => { while (/\s/.test(source[cursor] || '') && cursor < source.length) cursor++; };
  function expression() {
    whitespace();
    if (source[cursor] === '"') {
      const start = cursor++;
      while (cursor < source.length) {
        const char = source[cursor++];
        if (char === '\\') { if (cursor >= source.length) fail('Unterminated string literal'); cursor++; }
        else if (char === '"') return { kind: 'literal', value: source.slice(start, cursor) };
        else if (char === '\n' || char === '\r') fail('A string literal cannot contain an unescaped newline');
      }
      fail('Unterminated string literal');
    }
    const match = source.slice(cursor).match(/^[A-Za-z][A-Za-z0-9_-]*(?:\.[A-Za-z][A-Za-z0-9_-]*)*/);
    if (!match) fail('Expected a type name or string literal');
    const name = match[0];
    cursor += name.length;
    whitespace();
    if (source[cursor] !== '(') {
      if (name === 'e.types.paint') return { kind: 'name', value: 'paint' };
      if (name === 'e.types.any') return { kind: 'name', value: 'any' };
      if (!nativeTypes.has(name) && !Object.hasOwn(schema.types, name)) fail(`Unknown type ${name}`);
      return { kind: 'name', value: name };
    }
    if (!['e.types.option', 'e.types.union', 'e.types.array', 'e.types.dict'].includes(name)) fail(`Unsupported type constructor ${name}`);
    cursor++;
    const args = [];
    whitespace();
    if (source[cursor] !== ')') {
      for (;;) {
        args.push(expression());
        whitespace();
        if (source[cursor] !== ',') break;
        cursor++;
        whitespace();
        if (source[cursor] === ')') break;
      }
    }
    if (source[cursor] !== ')') fail('Expected a closing parenthesis');
    cursor++;
    if (name === 'e.types.union') {
      if (!args.length) fail('A union needs at least one type');
      return union(args);
    }
    if (args.length !== 1) fail(`${name} needs exactly one type`);
    if (name === 'e.types.option') return union([{ kind: 'name', value: 'none' }, args[0]]);
    return { kind: name === 'e.types.array' ? 'array' : 'dictionary', value: args[0] };
  }
  const type = expression();
  whitespace();
  if (cursor !== source.length) fail('Unexpected syntax');
  return type;
}

function union(types) {
  const members = types.flatMap(type => type.kind === 'union' ? type.value : [type]);
  if (members.some(type => type.kind === 'name' && type.value === 'any')) return { kind: 'name', value: 'any' };
  const unique = new Map();
  for (const type of members) unique.set(JSON.stringify(type), type);
  const values = [...unique.values()];
  return values.length === 1 ? values[0] : { kind: 'union', value: values };
}

function displayType(type) {
  if (type.kind === 'union') return type.value.map(displayType).join(' | ');
  if (['array', 'dictionary'].includes(type.kind)) return `${type.kind}<${displayType(type.value)}>`;
  return type.value;
}

function inferredDefault(type) {
  if (type.kind === 'name') return nativeDefaults[type.value];
  if (type.kind === 'literal') return type.value;
  if (type.kind === 'array') return '()';
  if (type.kind === 'dictionary') return '(:)';
  if (type.kind === 'union' && type.value[0].kind === 'name' && ['none', 'auto'].includes(type.value[0].value)) return type.value[0].value;
  return undefined;
}

function declarationFields(declaration, schema) {
  const original = Object.entries(declaration.fields);
  const fields = [...original];
  for (const group of [...(declaration['field-groups'] || [])].reverse()) {
    if (!isMap(group) || group.name !== 'callout') throw new Error(`Unknown declaration field group ${group?.name || '(missing name)'}.`);
    if (!['entry', 'callout', 'bubble'].includes(group.mode)) throw new Error(`Unknown callout field mode ${group.mode}.`);
    const index = original.findIndex(([name]) => name === group.after);
    if (index < 0) throw new Error(`Missing field-group insertion point ${group.after}.`);
    const definitions = schema['field-groups']?.callout;
    if (!isMap(definitions)) throw new Error('Missing shared callout field definitions.');
    const extra = [];
    for (const [name, definition] of Object.entries(definitions)) {
      const styling = name.startsWith('bubble-') || name.startsWith('pointer-');
      if (group.mode === 'bubble' && !styling) continue;
      const inherits = group.mode === 'entry' || (group.mode === 'callout' && styling);
      extra.push([
        group.mode === 'bubble' && name.startsWith('bubble-') ? name.slice(7) : name,
        inherits ? { ...definition, type: `e.types.union(${definition.type}, auto)`, default: 'auto' } : definition,
      ]);
    }
    fields.splice(index + 1, 0, ...extra);
  }
  const names = fields.map(([name]) => name);
  if (new Set(names).size !== names.length) throw new Error('Shared field groups create duplicate argument names.');
  return fields;
}

// Markdown table splitting happens before inline parsing, even inside code.
function code(value) {
  const text = value.replace(/\r?\n/g, ' ').replaceAll('|', '\\|');
  const longest = Math.max(0, ...(text.match(/`+/g) || []).map(run => run.length));
  const fence = '`'.repeat(longest + 1);
  const padding = text.startsWith('`') || text.endsWith('`') || (text.startsWith(' ') && text.endsWith(' ') && text.trim()) ? ' ' : '';
  return `${fence}${padding}${text}${padding}${fence}`;
}

function plain(value) {
  return value.replace(/\r?\n/g, ' ')
    .replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;')
    .replace(/[\\`*_{}[\]()#+.!|~=-]/g, '\\$&');
}

function defaultCell(field, type) {
  if (field.required) return `Required, ${field.named === true ? 'named' : 'positional'}`;
  let value = field.default ?? inferredDefault(type);
  if (value === undefined) throw new Error('Cannot infer this optional field default; specify an explicit default in the YAML.');
  let result;
  if (value === 'r.palette' || value === 'themes-impl.presets.thesis.at("highlight-colors")') result = 'Built-in palette';
  else if (/^r\.[A-Za-z0-9-]+-scopes$/.test(value)) result = 'Built-in selectors';
  else result = code(value);
  return result + (field.named === false ? ', positional' : '');
}

function table(target, schema) {
  const [kind, name] = target.split('.');
  if (!Object.hasOwn(schema[kind] || {}, name)) throw new Error(`Unknown argument table target ${target}.`);
  const rows = ['| Field | Type | Default / required | Meaning |', '| --- | --- | --- | --- |'];
  for (const [fieldName, field] of declarationFields(schema[kind][name], schema)) {
    if (fieldName.startsWith('__')) continue;
    try {
      const type = parseType(field.type, schema);
      rows.push(`| ${code(fieldName)} | ${code(displayType(type))} | ${defaultCell(field, type)} | ${plain(field.doc || '')} |`);
    } catch (error) { throw new Error(`${target}.${fieldName}: ${error.message}`); }
  }
  return rows.join('\n');
}

export function expandArgumentTables(source, schema, md, chapterPath = 'index.md') {
  const lines = source.split('\n');
  const literal = new Set();
  // HTML needs to remain literal even when the supplied renderer disables HTML.
  const parser = md.options.html ? md : new md.constructor({ ...md.options, html: true });
  for (const token of parser.parse(source, {})) {
    if (!['fence', 'code_block', 'html_block'].includes(token.type) || !token.map) continue;
    for (let line = token.map[0]; line < token.map[1]; line++) literal.add(line);
  }
  return lines.map((line, index) => {
    if (literal.has(index) || !/^ {0,3}\{\{#arg-table\b/.test(line)) return line;
    const context = `${chapterPath}:${index + 1}`;
    const match = line.match(/^ {0,3}\{\{#arg-table[ \t]+((?:elements|types)\.[A-Za-z][A-Za-z0-9_-]*)\}\}[ \t]*$/);
    if (!match) throw new Error(`${context}: malformed argument table directive. Use {{#arg-table elements.name}} or {{#arg-table types.name}} on its own line.`);
    try { return '\n' + table(match[1], schema) + '\n'; }
    catch (error) { throw new Error(`${context}: ${error.message}`); }
  }).join('\n');
}
