import path from 'node:path';
import { externalLinkIcon } from './links.mjs';

const escape = value => value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
const caches = new WeakMap();

export const typstTypeLinks = Object.fromEntries([
  ['foundations', ['arguments', 'array', 'auto', 'bool', 'bytes', 'content', 'datetime',
    'decimal', 'dictionary', 'duration', 'float', 'function', 'int', 'label', 'module',
    'none', 'path', 'regex', 'selector', 'str', 'symbol', 'type', 'version']],
  ['layout', ['alignment', 'angle', 'direction', 'fraction', 'length', 'ratio']],
  ['visualize', ['color', 'stroke']],
  ['introspection', ['location']],
].flatMap(([section, names]) => names.map(name => [name, `https://typst.app/docs/reference/${section}/${name}/`])));
typstTypeLinks.any = typstTypeLinks.type;
typstTypeLinks.paint = 'https://typst.app/docs/reference/visualize/';

export const codlyTypes = [
  'annotation-config', 'callout-config', 'diff', 'gutter-column', 'highlight-config',
  'highlighted-line', 'indent-guides', 'language', 'rainbow', 'range', 'skip',
  'smart-skip', 'sublang', 'unnumbered-line',
];

export const knownTypes = [...Object.keys(typstTypeLinks).filter(name => name !== 'none' && name !== 'auto'), ...codlyTypes];

export const typeLanguage = {
  name: 'typst-types',
  scopeName: 'source.typst-types',
  patterns: [
    { include: 'source.typst#constants' },
    { include: 'source.typst#keywordConstants' },
    {
      match: `(?<![\\w-])(?:${knownTypes.join('|')})(?![\\w-])`,
      name: 'entity.name.type.primitive.typst',
    },
    { match: '[|<>]', name: 'keyword.operator.typst' },
  ],
};

function highlightType(code, highlighter, chapterPath) {
  if (!caches.has(highlighter)) caches.set(highlighter, new Map());
  const cache = caches.get(highlighter);
  const cacheKey = `${chapterPath}\0${code}`;
  if (cache.has(cacheKey)) return cache.get(cacheKey);
  const { tokens } = highlighter.codeToTokens(code, {
    lang: 'typst-types', themes: { light: 'github-light', dark: 'github-dark' }, defaultColor: false,
    includeExplanation: 'scopeName',
  });
  const spans = tokens.flat().map(token => {
    const style = Object.entries(token.htmlStyle || {}).map(([key, value]) => `${key}:${value}`).join(';');
    const content = token.explanation.map(part => {
      const name = part.content;
      const isType = part.scopes.some(scope => /^(?:entity\.name\.type\.primitive|keyword\.other\.(?:none|auto))\.typst$/.test(scope.scopeName));
      if (!isType) return escape(name);
      if (Object.hasOwn(typstTypeLinks, name)) {
        const label = `${name} (Typst reference, opens in a new tab)`;
        return `<a class="type-link" href="${escape(typstTypeLinks[name])}" target="_blank" rel="noopener noreferrer" aria-label="${escape(label)}" title="${escape(label)}">${escape(name)}${externalLinkIcon}</a>`;
      }
      if (codlyTypes.includes(name)) {
        const href = path.posix.relative(path.posix.dirname(chapterPath), `api/types/${name}.html`);
        return `<a class="type-link" href="${escape(href)}" title="${escape(name)} type definition">${escape(name)}</a>`;
      }
      return escape(name);
    }).join('');
    return `<span class="shiki" style="${escape(style)}">${content}</span>`;
  }).join('');
  const html = `<code class="typst-type">${spans}</code>`;
  cache.set(cacheKey, html);
  return html;
}

export function highlightTypeTables(source, md, highlighter, chapterPath = 'index.md') {
  const tokens = md.parse(source, {});
  const lines = source.split('\n');
  const replacements = [];
  for (let start = 0; start < tokens.length; start++) {
    if (tokens[start].type !== 'table_open') continue;
    const end = tokens.findIndex((token, index) => index > start && token.type === 'table_close');
    const table = tokens.slice(start, end + 1);
    const headers = table.filter((token, index) => token.type === 'inline' && table[index - 1]?.type === 'th_open');
    const typeColumn = headers.findIndex(token => token.content.trim().toLowerCase() === 'type');
    if (typeColumn >= 0) {
      let column = -1;
      for (let index = 0; index < table.length; index++) {
        const token = table[index];
        if (token.type === 'tr_open') column = -1;
        if (token.type === 'td_open') column++;
        if (token.type !== 'inline' || table[index - 1]?.type !== 'td_open' || column !== typeColumn) continue;
        for (const child of token.children || []) if (child.type === 'code_inline') {
          child.type = 'html_inline';
          child.content = highlightType(child.content, highlighter, chapterPath);
        }
      }
      replacements.push({ map: tokens[start].map, html: md.renderer.render(table, md.options, {}) });
    }
    start = end;
  }
  for (const { map, html } of replacements.reverse()) lines.splice(map[0], map[1] - map[0], '\n' + html + '\n');
  return lines.join('\n');
}
