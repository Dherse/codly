import MarkdownIt from 'markdown-it';

const escape = text => text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
const slug = text => text.normalize('NFKD').replace(/\p{M}/gu, '').toLowerCase().replace(/[^\p{L}\p{N}]+/gu, '-').replace(/^-|-$/g, '') || 'section';

// Keep bodies as Markdown: later preprocessing still handles tables, links,
// admonitions, syntax highlighting and editable previews inside each section.
// Author at the start of a line, using ::: collapse Title {#optional-id}.
export function collapsibles(source, md = new MarkdownIt({ html: true })) {
  const lines = source.split('\n');
  const literal = new Set();
  for (const token of md.parse(source, {})) {
    if (!['fence', 'code_block', 'html_block'].includes(token.type) || !token.map) continue;
    for (let line = token.map[0]; line < token.map[1]; line++) literal.add(line);
  }
  const stack = [], ids = new Set(), result = [];
  for (const [index, line] of lines.entries()) {
    if (literal.has(index)) { result.push(line); continue; }
    const opening = line.match(/^ {0,3}::: collapse(-open)?(?:[ \t]+(.*?))?[ \t]*$/);
    if (opening) {
      let title = opening[2] || '';
      const explicit = title.match(/[ \t]+\{#([^}]+)\}$/);
      if (explicit) title = title.slice(0, explicit.index).trimEnd();
      if (!title.trim()) throw new Error(`Line ${index + 1}: a collapsible section needs a title.`);
      if (explicit && !/^[A-Za-z][A-Za-z0-9_.:-]*$/.test(explicit[1])) {
        throw new Error(`Line ${index + 1}: invalid collapsible id ${explicit[1]}. Use a letter followed by letters, digits, hyphens, underscores, periods or colons.`);
      }
      let id = explicit?.[1] || `collapse-${slug(title)}`;
      if (explicit && ids.has(id)) throw new Error(`Line ${index + 1}: duplicate collapsible id ${id}.`);
      if (!explicit) {
        const base = id;
        for (let suffix = 2; ids.has(id); suffix++) id = `${base}-${suffix}`;
      }
      ids.add(id);
      stack.push(index + 1);
      result.push('', `<details class="collapsible" id="${escape(id)}"${opening[1] ? ' open' : ''}>`, `<summary><span class="collapsible-title">${escape(title)}</span></summary>`, '<div class="collapsible-content">', '');
    } else if (/^ {0,3}:::[ \t]*$/.test(line)) {
      if (!stack.length) throw new Error(`Line ${index + 1}: a closing ::: has no matching collapsible section.`);
      stack.pop();
      result.push('', '</div>', '</details>', '');
    } else result.push(line);
  }
  if (stack.length) throw new Error(`Line ${stack.at(-1)}: an unclosed collapsible section needs a closing :::.`);
  return result.join('\n');
}
