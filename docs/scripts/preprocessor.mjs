import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import MarkdownIt from 'markdown-it';
import { createHighlighter } from 'shiki';
import { exampleSource } from '../runtime/widgets.mjs';
import { parseWidgets, renderWidgets } from './widgets.mjs';
import { highlightTypeTables, typeLanguage } from './type-tables.mjs';
import { typstCodeLanguage } from './typst-code.mjs';
import { admonitions } from './admonitions.mjs';
import { collapsibles } from './collapsibles.mjs';
import { mermaidFence } from './mermaid.mjs';
if (process.argv[2] === 'supports') process.exit(process.argv[3] === 'html' ? 0 : 1);
const [context, book] = JSON.parse(fs.readFileSync(0, 'utf8'));
const highlighter = await createHighlighter({ themes: ['github-dark','github-light'], langs: ['typst',typstCodeLanguage,typeLanguage,'rust','python','yaml','bash','toml','json','markdown'] });
const md = new MarkdownIt();
const escape = s => s.replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;').replaceAll('"','&quot;');
const index = [], examples = [];
function visit(items) {
  for (const item of items) if (item.Chapter) {
    const chapter = item.Chapter;
    const source = chapter.content;
    index.push({ title: chapter.name, path: chapter.path.replace(/\.md$/,'.html'), text: source.replace(/<[^>]*>/g,' ').replace(/[#`*]/g,'').slice(0,50000) });
    let expanded;
    try { expanded = collapsibles(source); }
    catch (error) { throw new Error(`${chapter.path}: ${error.message}`); }
    const highlightedTypes = highlightTypeTables(admonitions(expanded), md, highlighter, chapter.path);
    const lines = highlightedTypes.split('\n');
    const tokens = md.parse(highlightedTypes, {}).filter(t => t.type === 'fence');
    const configs = new Map();
    const widgetFences = new Set();
    for (const [i, token] of tokens.entries()) {
      if (!/^(?:yaml|yml) widgets$/.test(token.info.trim())) continue;
      const next = tokens[i + 1];
      const [nextLanguage, ...nextFlags] = next?.info.trim().split(/[ ,]+/) || [];
      if (!next || !/^(?:typst|typ)$/.test(nextLanguage) || !nextFlags.includes('preview') || lines.slice(token.map[1], next.map[0]).join('\n').trim()) {
        throw new Error(`${chapter.path}: a yaml widgets fence must immediately precede a typst preview fence.`);
      }
      try { configs.set(next, parseWidgets(token.content)); }
      catch (error) { throw new Error(`${chapter.path}: ${error.message}`); }
      widgetFences.add(token);
    }
    for (const token of tokens.reverse()) {
      if (widgetFences.has(token)) { lines.splice(token.map[0], token.map[1] - token.map[0], ''); continue; }
      const [requested, ...flags] = token.info.trim().split(/[ ,]+/);
      if (requested === 'mermaid') {
        if (flags.length) throw new Error(`${chapter.path}: mermaid fences do not accept flags.`);
        const id = createHash('sha256').update(chapter.path + ':' + token.map[0]).digest('hex').slice(0,16);
        lines.splice(token.map[0], token.map[1] - token.map[0], '\n' + mermaidFence(token.content.trimEnd(), id) + '\n');
        continue;
      }
      const lang = ({typ:'typst',sh:'bash',py:'python',rs:'rust'})[requested] || requested || 'text';
      const known = highlighter.getLoadedLanguages().includes(lang) || lang === 'text';
      if (!known) throw new Error(`${chapter.path}: unsupported syntax language ${lang}. Add it to scripts/preprocessor.mjs.`);
      const body = token.content.trimEnd();
      const codeMode = lang === 'typst' && flags.includes('code');
      const fixed = flags.includes('fixed');
      if (fixed && !flags.includes('preview')) throw new Error(`${chapter.path}: fixed requires a typst preview fence.`);
      const widgets = configs.get(token) || [];
      const code = exampleSource(body, widgets);
      const highlighted = highlighter.codeToHtml(body, { lang: codeMode ? 'typst-code' : lang, themes: { light:'github-light',dark:'github-dark' }, defaultColor: false });
      let html;
      if (flags.includes('preview')) {
        if (lang !== 'typst') throw new Error('Only Typst fences support preview.');
        if (fixed && configs.has(token)) throw new Error(`${chapter.path}: fixed previews cannot have widgets. Put the default values in the example source.`);
        const id = createHash('sha256').update(code + JSON.stringify(widgets)).digest('hex').slice(0,16);
        examples.push({ id, source: code, body, widgets, fixed, chapter: chapter.path });
        const relative = '../'.repeat(chapter.path.split('/').length-1);
        const editor = fixed ? "" : `<details class="editor"><summary>Edit &amp; run on your device</summary><label for="edit-${id}-${token.map[0]}">Editable Typst source</label><textarea id="edit-${id}-${token.map[0]}" spellcheck="false" autocomplete="off" autocapitalize="off" maxlength="30000">${escape(body).replaceAll("\n","&#10;")}</textarea><p class="hint">${widgets.length ? "The controls supply the example variables. Their definitions are hidden here; Copy code includes the current values and your edits." : "The highlighted source and output update after you stop typing. Copy code includes your edits."}</p><button data-run>Run</button> <button data-reset>Reset example</button></details>`;
        html = `<section class="example${fixed ? " example-fixed" : ""}" data-example="${id}" ${fixed ? 'data-fixed="true"' : `data-widgets="${escape(JSON.stringify(widgets))}"`} aria-label="Typst example">${fixed ? "" : renderWidgets(widgets, `${id}-${token.map[0]}`)}<div class="example-body"><div class="example-source"><div class="example-toolbar"><strong><span aria-hidden="true">&lt;/&gt;</span> Typst source</strong><div class="toolbar-buttons"><button data-copy hidden>Copy code</button></div></div><div class="highlighted">${highlighted}</div>${editor}</div><div class="example-output"><div class="preview-toolbar"><span class="preview-label">OUTPUT</span>${fixed ? "" : '<span class="example-status" role="status">Pre-rendered default</span>'}</div><div class="preview"><img class="static-preview" src="${relative}assets/previews/${id}.svg" alt="Rendered output of the Typst example" loading="lazy"></div></div></div></section>`;
      } else html = `<div class="code-card"><div class="code-toolbar"><span>${escape(codeMode ? 'typst code' : lang)}</span><button data-copy hidden>Copy code</button></div>${highlighted}</div>`;
      lines.splice(token.map[0],token.map[1]-token.map[0], '\n'+html+'\n');
    }
    chapter.content = lines.join('\n');
    visit(chapter.sub_items);
  }
}
visit(book.items || book.sections);
fs.mkdirSync(path.join(context.root,'src/assets'),{recursive:true});
fs.writeFileSync(path.join(context.root,'src/assets/search.json'), JSON.stringify(index));
fs.writeFileSync(path.join(context.root,'src/assets/examples.json'), JSON.stringify(examples));
process.stdout.write(JSON.stringify(book));
