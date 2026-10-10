import MarkdownIt from 'markdown-it';

const labels = { note: 'Note', tip: 'Tip', important: 'Important', warning: 'Warning', caution: 'Caution' };
const paths = {
  note: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-10v1"/>',
  tip: '<path d="M9 18h6m-5 3h4m-5-6a6 6 0 1 1 6 0v3H9z"/>',
  important: '<path d="M21 15a3 3 0 0 1-3 3H8l-5 3V6a3 3 0 0 1 3-3h12a3 3 0 0 1 3 3zM12 7v5m0 2v1"/>',
  warning: '<path d="m12 3 10 18H2zM12 9v5m0 2v1"/>',
  caution: '<path d="m8 2-6 6v8l6 6h8l6-6V8l-6-6zM12 7v6m0 3v1"/>',
};
const escape = text => text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

// Rewrite only parsed blockquotes, so markers in fenced code stay literal.
// Keep the body as Markdown for mdBook's links, tables, and code preprocessing.
export function admonitions(source, md = new MarkdownIt({ html: true })) {
  const lines = source.split('\n');
  const quotes = [];
  let depth = 0;
  for (const token of md.parse(source, {})) {
    if (token.type === 'blockquote_open' && depth++ === 0) quotes.push(token);
    if (token.type === 'blockquote_close') depth--;
  }
  for (const token of quotes.reverse()) {
    const [start, end] = token.map;
    const original = lines.slice(start, end);
    // A list item can also contain a quote; leave its list prefix intact.
    const prefix = original[0].match(/^( {0,3})> ?/);
    if (!prefix) continue;
    const body = original.map(line => line.replace(/^ {0,3}> ?/, ''));
    const marker = body[0].match(/^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\](?:[ \t]+(.+?))?[ \t]*$/i);
    if (!marker) {
      const nested = admonitions(body.join('\n'), md);
      if (nested !== body.join('\n')) {
        lines.splice(start, end - start, ...nested.split('\n').map(line => `${prefix[1]}> ${line}`));
      }
      continue;
    }
    const kind = marker[1].toLowerCase();
    const title = escape(marker[2] || labels[kind]);
    const icon = `<svg class="admonition-icon" viewBox="0 0 24 24" aria-hidden="true" focusable="false">${paths[kind]}</svg>`;
    const content = admonitions(body.slice(1).join('\n'), md);
    const html = `<aside class="admonition admonition-${kind}" role="note" aria-label="${title}">\n<p class="admonition-title">${icon}${title}</p>\n\n${content}\n\n</aside>\n`;
    lines.splice(start, end - start, ...html.split('\n'));
  }
  return lines.join('\n');
}
