import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { runInNewContext } from 'node:vm';
import { createEngine } from '../runtime/compiler.mjs';
import { fontFiles, compilerFontFiles } from '../scripts/assets.mjs';
import { highlight } from '../runtime/highlight.mjs';
import { exampleSource, validateWidgets, widgetDefaults } from '../runtime/widgets.mjs';
import { createHighlighter } from 'shiki';
import { codlyTypes, highlightTypeTables, knownTypes, typeLanguage, typstTypeLinks } from '../scripts/type-tables.mjs';
import MarkdownIt from 'markdown-it';
import { configureLinks, externalLinkIcon } from '../scripts/links.mjs';
import { typstCodeLanguage } from '../scripts/typst-code.mjs';
const read = f => fs.readFile(f,'utf8');
async function walk(dir) { const files=[]; for(const e of await fs.readdir(dir,{withFileTypes:true})) { const f=path.join(dir,e.name); files.push(...(e.isDirectory()?await walk(f):[f])); } return files; }

test('fresh light and dark visits use the native code font, and explicit choices survive navigation', async () => {
  const script = await read('runtime/preferences.js');
  for (const [search, theme, font] of [
    ['', 'dark', 'dejavu'], ['?theme=light', 'light', 'dejavu'],
    ['?theme=light&font=noto', 'light', 'noto'], ['?theme=dark&font=dejavu', 'dark', 'dejavu'],
    ['?theme=unknown&font=unknown', 'dark', 'dejavu'],
  ]) {
    const dataset = {};
    runInNewContext(script, { location: { search }, document: { documentElement: { dataset } }, URLSearchParams });
    assert.deepEqual(dataset, { theme, font });
  }
});

test('Typst source exposes token colors for both CSS themes', async () => {
  const source = '#import "codly.typ" as codly\n#let count = 42\n// A comment\n#codly.new(raw("hello", block: true))';
  const html = await highlight(source);
  const tokens = [...html.matchAll(/<span style="([^"]+)">/g)];
  assert(tokens.length > 10, 'Expected highlighted syntax tokens');
  for (const [, style] of tokens) {
    assert.match(style, /--shiki-light:#[\da-f]+/i);
    assert.match(style, /--shiki-dark:#[\da-f]+/i);
  }
  for (const theme of ['light', 'dark']) {
    const colors = new Set(tokens.map(([, style]) => style.match(new RegExp(`--shiki-${theme}:(#[\\da-f]+)`, 'i'))[1]));
    assert(colors.size >= 3, `${theme} syntax should have distinct token colors`);
  }
});

test('Typst code fences highlight like expressions inside a code block without displaying the wrapper', async () => {
  const highlighter = await createHighlighter({ themes: ['github-light', 'github-dark'], langs: ['typst', typstCodeLanguage] });
  const temp = await fs.mkdtemp('/tmp/codly-code-mode-');
  const source = 'codly.highlight(body, highlight: none)\ncodly.number(number: int, label: "line", fill: rgb("aabbcc"))';
  try {
    const options = { themes: { light: 'github-light', dark: 'github-dark' }, defaultColor: false };
    const summarize = lines => lines.flat().map(({content, htmlStyle}) => ({content, htmlStyle}));
    const code = highlighter.codeToTokens(source, { ...options, lang: 'typst-code' });
    const wrapped = highlighter.codeToTokens(`#{\n${source}\n}`, { ...options, lang: 'typst' });
    assert.deepEqual(summarize(code.tokens), summarize(wrapped.tokens.slice(1, -1)));
    for (const theme of ['light', 'dark']) {
      assert(new Set(code.tokens.flat().map(t => t.htmlStyle[`--shiki-${theme}`])).size >= 3);
    }
    const input = [{root:temp},{items:[{Chapter:{name:'Signature',path:'signature.md',content:`\`\`\`typst code\n${source}\n\`\`\`\n`,sub_items:[]}}]}];
    const run = spawnSync(process.execPath, ['scripts/preprocessor.mjs'], {input:JSON.stringify(input),encoding:'utf8',timeout:5000});
    assert.equal(run.status,0,run.stderr);
    const html = JSON.parse(run.stdout).items[0].Chapter.content;
    assert(html.includes('<span>typst code</span>'));
    const highlighted = html.match(/<code>([\s\S]*?)<\/code>/)[1];
    assert.equal(highlighted.replace(/<[^>]*>/g, '').replaceAll('&quot;', '"'), source);
    assert(highlighted.includes('--shiki-light:'));
    assert(highlighted.includes('--shiki-dark:'));
  } finally {
    highlighter.dispose();
    await fs.rm(temp,{recursive:true,force:true});
  }
});

test('all published HTML assets and internal page links resolve under a project subpath',async()=>{
  for(const file of (await walk('book')).filter(f=>f.endsWith('.html'))) {
    const html=await read(file);
    for(const m of html.matchAll(/(?:src|href)="([^"#]+)(?:#[^"]*)?"/g)) {
      const href=m[1].replaceAll('&amp;','&');
      if(/^(?:https?:|data:|blob:|mailto:)/.test(href)) continue;
      assert(!href.startsWith('/'),`${file}: root-relative URL breaks project Pages: ${href}`);
      const target=path.resolve(path.dirname(file),decodeURIComponent(href.split(/[?#]/)[0]));
      assert(target.startsWith(path.resolve('book')+path.sep),`Escaping book: ${target}`);
      await assert.doesNotReject(fs.access(target),`${file} → ${href}`);
    }
  }
});

test('external link decoration preserves markup and internal navigation and is idempotent', () => {
  const source = '<a href="https://typst.app/docs/" rel="nofollow" target="_self"><em>Typst</em></a>'
    + "<a href='//github.com/Dherse/codly'>GitHub</a>"
    + '<a href="http://example.test/">HTTP</a>'
    + '<a href="../types/range.html" target="_blank">Local</a>'
    + '<a href="#fields" target="_blank">Fields</a>'
    + '<a href="https://typst.app/docs/">Existing' + externalLinkIcon + '</a>'
    + '<code>&lt;a href="https://example.test/"&gt;</code>';
  const html = configureLinks(source);
  assert.equal(configureLinks(html),html);
  const links = [...html.matchAll(/<a\b([^>]+)>([\s\S]*?)<\/a>/g)];
  assert.equal(links.length,6);
  for (const [, attributes, content] of links) {
    if (/href=["'](?:https?:)?\/\//.test(attributes)) {
      assert(attributes.includes('target="_blank"'));
      assert.match(attributes, /rel="[^"]*noopener/);
      assert.match(attributes, /rel="[^"]*noreferrer/);
      assert.equal((content.match(/class="external-link-icon"/g) || []).length,1);
    } else {
      assert(!attributes.includes('target='));
      assert(!content.includes('external-link-icon'));
    }
  }
  assert(html.includes('rel="nofollow noopener noreferrer"'));
  assert(html.includes('<em>Typst</em>'));
  assert(html.endsWith('<code>&lt;a href="https://example.test/"&gt;</code>'));
});

test('every published external link opens a new tab with one icon and internal links stay in this tab',async()=>{
  let external = 0;
  for (const file of (await walk('book')).filter(f => f.endsWith('.html'))) {
    for (const [, attributes, content] of (await read(file)).matchAll(/<a\b([^>]+)>([\s\S]*?)<\/a>/g)) {
      if (/href="(?:https?:)?\/\//.test(attributes)) {
        external++;
        assert(attributes.includes('target="_blank"'), `External link in ${file}`);
        assert.match(attributes, /rel="[^"]*noopener/);
        assert.match(attributes, /rel="[^"]*noreferrer/);
        assert.equal((content.match(/class="external-link-icon"/g) || []).length,1, `Icon in ${file}`);
      } else {
        assert(!/target="_blank"/.test(attributes), `Internal link in ${file}`);
        assert(!content.includes('external-link-icon'), `Internal icon in ${file}`);
      }
    }
  }
  assert(external > 0, 'Expected to verify external links');
});

test('generated runtime has no storage APIs or external script/style embeds',async()=>{
  for(const file of (await walk('book')).filter(f=>/\.(js|html)$/.test(f))) {
    const text=await read(file);
    if(file.endsWith('.js')) assert(!/\b(?:localStorage|sessionStorage|indexedDB|serviceWorker)\b|document\.cookie/.test(text),`Storage API in ${file}`);
    if(file.endsWith('.html')) {
      assert(!/<script(?![^>]*\bsrc=)[\s>]/i.test(text),`Inline script in ${file}`);
      assert(!/<(?:script|link|iframe|img)[^>]+(?:src|href)="https?:/i.test(text),`External embedded asset in ${file}`);
      assert(!/<(?:object|embed|iframe)[\s>]/i.test(text),`Active embedded document in ${file}`);
      assert(text.includes("connect-src 'self'"));
      assert(text.includes('name="referrer" content="no-referrer"'));
    }
  }
});

test('all preview sources have one safe static SVG',async()=>{
  const examples=JSON.parse(await read('book/assets/examples.json'));
  const ids=[...new Set(examples.map(({id})=>id))].sort();
  assert.deepEqual((await fs.readdir('book/assets/previews')).sort(),ids.map(id=>`${id}.svg`));
  const byChapter=new Map();
  for(const {chapter} of examples) byChapter.set(chapter,(byChapter.get(chapter)||0)+1);
  for(const [chapter,count] of byChapter) {
    const html=await read('book/'+chapter.replace(/\.md$/,'.html'));
    assert.equal([...html.matchAll(/<img\b[^>]*class="static-preview"/g)].length,count,`Static preview image count in ${chapter}`);
  }
  for(const {id,source,body,widgets,fixed,chapter} of examples) {
    const html=await read('book/'+chapter.replace(/\.md$/,'.html'));
    const decode = s => s.replace(/&(?:amp|lt|gt|quot|apos|#\d+|#x[\da-f]+);/gi, entity => ({'&amp;':'&','&lt;':'<','&gt;':'>','&quot;':'"','&apos;':"'"}[entity] ?? String.fromCodePoint(entity[2]==='x'?parseInt(entity.slice(3,-1),16):parseInt(entity.slice(2,-1),10))));
    const textareas=[...html.matchAll(/<textarea[^>]*>([\s\S]*?)<\/textarea>/g)].map(m=>decode(m[1]));
    if (!fixed) assert(textareas.includes(body),`Editable source mismatch in ${chapter}`);
    assert.equal(exampleSource(body, widgets), source, `Default bindings mismatch in ${chapter}`);
    const displayed=[...html.matchAll(/<div class="highlighted">\s*<pre[^>]*>\s*<code>([\s\S]*?)<\/code>/g)].map(m=>decode(m[1].replace(/<[^>]*>/g,'')));
    assert(displayed.includes(body),`Displayed example body mismatch in ${chapter}`);
    const svg=await read(`book/assets/previews/${id}.svg`);
    assert(svg.includes('<svg') && svg.includes('<path'),`Missing real SVG paths for ${id}`);
    // typst.ts includes foreignObject text-selection metadata. SVGs are always
    // isolated in img elements, never embedded as active documents or inline DOM.
    assert(!/<script|\son\w+=/i.test(svg),`Executable SVG content: ${id}`);
  }
});

test('embedded Codly runtime matches the source checkout', async () => {
  const sources = JSON.parse(await read('book/assets/sources.json'));
  const source = path.resolve(process.env.CODLY_SOURCE || '..');
  for (const file of [path.join(source, 'codly.typ'), path.join(source, 'typst.toml'), ...await walk(path.join(source, 'src'))]) {
    const name = '/' + path.relative(source, file).split(path.sep).join('/');
    const bytes = await fs.readFile(file);
    if (/\.(typ|json|toml)$/.test(file)) assert.equal(sources[name], bytes.toString('utf8'), name);
    else if (/\.(png|svg|jpg)$/.test(file)) assert.equal(sources[name]?.base64, bytes.toString('base64'), name);
  }
});

test('the live editor loads the same fonts as static previews, including color emoji', async () => {
  const script = (await read('runtime/worker.mjs')).replace("import { createEngine } from './compiler.mjs';", '');
  const manifest = JSON.parse(await read('book/assets/compiler-assets.json'));
  let options;
  let done;
  const completed = new Promise(resolve => { done = resolve; });
  const self = {
    location: { href: 'https://docs.example/assets/worker.js', origin: 'https://docs.example' },
    fetch: async url => ({ ok: true, json: async () => String(url).endsWith('/compiler-assets.json') ? manifest : {} }),
    postMessage: done,
  };
  runInNewContext(script, {
    self, URL,
    fetch: (...args) => self.fetch(...args),
    createEngine: async args => { options = args; return async () => '<svg/>'; },
  });
  self.onmessage({ data: { id: 1, source: '🐱' } });
  assert.equal((await completed).svg, '<svg/>');
  assert.deepEqual(Array.from(options.fonts, url => path.basename(url)).sort(), compilerFontFiles.map(file => path.basename(file)).sort());
  assert(options.fonts.some(url => url.endsWith('/fonts/NotoColorEmoji-Regular.ttf')));
  assert.equal(options.compilerWasm, 'https://docs.example/assets/compiler.wasm');
  assert.deepEqual(await fs.readFile('book/assets/fonts/NotoColorEmoji-Regular.ttf'), await fs.readFile(fontFiles['NotoColorEmoji-Regular.ttf']));
  assert((await read('book/assets/THIRD_PARTY_NOTICES.txt')).includes('===== Noto Color Emoji ====='));
});

test('the worker resolves shared compiler assets under a project subpath and reuses its engine', async () => {
  const script = (await read('runtime/worker.mjs')).replace("import { createEngine } from './compiler.mjs';", '');
  for (const location of ['https://docs.example/codly/main/assets/worker.js', 'https://docs.example/codly/assets/worker.js']) {
    const prefix = location.includes('/main/') ? '../../' : '../';
    const manifest = { compilerWasm: `${prefix}_typst/compiler.wasm`, rendererWasm: `${prefix}_typst/renderer.wasm`, fonts: [`${prefix}_typst/font.ttf`] };
    const requests = [];
    let engines = 0;
    let done;
    const self = {
      location: { href: location, origin: 'https://docs.example' },
      fetch: async (url, options) => {
        requests.push(String(url));
        assert.equal(options.credentials, 'omit');
        return { ok: true, json: async () => String(url).endsWith('/compiler-assets.json') ? manifest : {} };
      },
      postMessage: result => done(result),
    };
    runInNewContext(script, { self, URL, fetch: (...args) => self.fetch(...args), createEngine: async options => {
      engines++;
      assert.equal(options.compilerWasm, 'https://docs.example/codly/_typst/compiler.wasm');
      assert.equal(options.rendererWasm, 'https://docs.example/codly/_typst/renderer.wasm');
      assert.deepEqual(Array.from(options.fonts), ['https://docs.example/codly/_typst/font.ttf']);
      return async () => '<svg/>';
    } });
    for (const id of [1, 2]) {
      const completed = new Promise(resolve => { done = resolve; });
      self.onmessage({ data: { id, source: 'example' } });
      assert.equal((await completed).svg, '<svg/>');
    }
    assert.equal(engines, 1);
    assert.equal(requests.filter(url => url.endsWith('/compiler-assets.json')).length, 1);
  }
});

test('authored docs and gallery examples rely on automatic figure labels', async () => {
  const md = new MarkdownIt();
  for (const file of (await walk('src')).filter(file => file.endsWith('.md'))) {
    for (const token of md.parse(await read(file), {})) {
      if (token.type !== 'fence' || !/^(?:typst|typ)(?:[ ,]|$)/.test(token.info.trim())) continue;
      assert(!/\bblock-label\s*:/.test(token.content), `${file}: label the enclosing figure instead of setting block-label`);
      assert(!/\bcodly\.new\s*\(\s*"/.test(token.content), `${file}: use a fenced code block instead of a string input`);
      assert(!/\braw\s*\(\s*"/.test(token.content), `${file}: use a fenced code block instead of a literal raw call`);
    }
  }
  for (const file of (await walk('../examples')).filter(file => file.endsWith('.typ'))) {
    assert(!/\bblock-label\s*:/.test(await read(file)), `${file}: label the enclosing figure instead of setting block-label`);
  }
});

test('fence extraction escapes hostile HTML and handles nested Markdown fences',async()=>{
  const source='#import "codly.typ" as codly\n\n</textarea><script>alert(1)</script>\n';
  const input=[{root:process.cwd()},{items:[{Chapter:{name:'Fixture',path:'test.md',content:'```typst preview\n'+source+'```\n',sub_items:[]}}]}];
  // Use a temporary root so fixture manifests cannot replace the real build assets.
  const temp=await fs.mkdtemp('/tmp/codly-preprocess-'); input[0].root=temp;
  try {
    const run=spawnSync(process.execPath,['scripts/preprocessor.mjs'],{input:JSON.stringify(input),encoding:'utf8',timeout:5000});
    assert.equal(run.status,0,run.stderr);
    const html=JSON.parse(run.stdout).items[0].Chapter.content;
    assert(!html.includes('<script>alert'));
    assert(html.includes('&lt;/textarea&gt;&lt;script&gt;'));
    assert.equal((html.match(/<textarea /g)||[]).length,1);
  } finally { await fs.rm(temp,{recursive:true,force:true}); }
});

test('documented type expressions highlight native and Codly types, including nested unions', async () => {
  const highlighter = await createHighlighter({ themes: ['github-light', 'github-dark'], langs: ['typst', typeLanguage] });
  try {
    const options = { themes: { light: 'github-light', dark: 'github-dark' }, defaultColor: false };
    const native = highlighter.codeToTokens('#(length)', { ...options, lang: 'typst' }).tokens[0].find(t => t.content === 'length');
    const tokenize = source => highlighter.codeToTokens(source, { ...options, lang: 'typst-types' }).tokens.flat();
    for (const name of knownTypes) {
      const tokens = tokenize(`array<${name} | none> | "${name}" | unknown-${name}`);
      const named = tokens.find(t => t.content === name);
      assert(named, `Expected a type token for ${name}`);
      assert.deepEqual(named.htmlStyle, native.htmlStyle, `${name} should use Typst type colors`);
      assert.equal(tokens.filter(t => t.content === name).length, name === 'array' ? 2 : 1, 'Quoted values and unknown names should not match the type registry');
      assert.equal(tokens.map(t => t.content).join(''), `array<${name} | none> | "${name}" | unknown-${name}`);
    }
  } finally { highlighter.dispose(); }
});

test('parameter type cells use inline Typst colors without changing other table cells', async () => {
  const temp=await fs.mkdtemp('/tmp/codly-type-tables-');
  const content='| Parameter | Type | Default | Meaning |\n| --- | --- | --- | --- |\n| `width` | `length \\| dictionary` | `4pt` | A `length`. |\n\n| Feature | Value |\n| --- | --- |\n| Size | `length` |\n';
  const input=[{root:temp},{items:[{Chapter:{name:'Types',path:'types.md',content,sub_items:[]}}]}];
  try {
    const run=spawnSync(process.execPath,['scripts/preprocessor.mjs'],{input:JSON.stringify(input),encoding:'utf8',timeout:5000});
    assert.equal(run.status,0,run.stderr);
    const html=JSON.parse(run.stdout).items[0].Chapter.content;
    const typeCell=html.match(/<td><code class="typst-type">([\s\S]*?)<\/code><\/td>/)?.[1];
    assert(typeCell, 'Expected an inline highlighted type cell');
    assert.match(typeCell, /--shiki-light:#[\da-f]+;--shiki-dark:#[\da-f]+/i);
    assert.equal(typeCell.replace(/<[^>]*>/g,''), 'length | dictionary');
    assert(html.includes('<td><code>width</code></td>'));
    assert(html.includes('<td><code>4pt</code></td>'));
    assert(html.includes('<td>A <code>length</code>.</td>'));
    assert(html.includes('| Size | `length` |'), 'Tables without a Type column should stay Markdown');
    assert(!/<pre|<textarea/.test(html), 'Inline types must not become code cards');
  } finally { await fs.rm(temp,{recursive:true,force:true}); }
});

test('type links use official references or relative local definitions without linking quoted values', async () => {
  const highlighter = await createHighlighter({ themes: ['github-light', 'github-dark'], langs: ['typst', typeLanguage] });
  const md = new MarkdownIt();
  const expression = `${knownTypes.join(' \\| ')} \\| none \\| auto \\| array<range \\| none> \\| "range" \\| unknown-range`;
  const source = `| Parameter | Type |\n| --- | --- |\n| value | \`${expression}\` |\n`;
  try {
    for (const chapter of ['index.md', 'api/index.md', 'api/components/new.md', 'api/types/range.md']) {
      const html = highlightTypeTables(source, md, highlighter, chapter);
      const links = [...html.matchAll(/<a class="type-link" ([^>]+)>([\s\S]*?)<\/a>/g)];
      for (const [name, href] of Object.entries(typstTypeLinks)) {
        const link = links.find(([, , content]) => content.startsWith(`${name}<svg`));
        assert(link, `Expected official link for ${name}`);
        assert(link[1].includes(`href="${href}"`));
        assert(link[1].includes('target="_blank"'));
        assert(link[1].includes('rel="noopener noreferrer"'));
        assert(link[1].includes('opens in a new tab'));
        assert(link[2].includes('aria-hidden="true"'));
      }
      for (const name of codlyTypes) {
        const local = links.filter(([, , content]) => content === name);
        assert.equal(local.length, name === 'range' ? 2 : 1, 'Quoted and unknown values should not link');
        for (const [, attributes, content] of local) {
          const href = attributes.match(/href="([^"]+)"/)[1];
          assert.equal(path.posix.normalize(path.posix.join(path.posix.dirname(chapter), href)), `api/types/${name}.html`);
          assert(!attributes.includes('target='));
          assert(!content.includes('<svg'));
        }
      }
    }
    assert.equal(typstTypeLinks.path, 'https://typst.app/docs/reference/foundations/path/');
    assert.equal(typstTypeLinks.location, 'https://typst.app/docs/reference/introspection/location/');
  } finally { highlighter.dispose(); }
});

test('actual WASM compiles offline, rejects missing packages, and recovers from errors', {timeout:30000},async()=>{
  const previousFetch=globalThis.fetch;
  let requests=0;
  globalThis.fetch=()=>{requests++;throw new Error('Unexpected network request');};
  try {
    const files=JSON.parse(await read('book/assets/sources.json'));
    const compile=await createEngine({
      compilerWasm:await fs.readFile('book/assets/compiler.wasm'),rendererWasm:await fs.readFile('book/assets/renderer.wasm'),
      fonts:await Promise.all(compilerFontFiles.map(file => fs.readFile(file))),
      files,
    });
    await assert.rejects(compile('#let x = ('),/expected|unclosed/);
    await assert.rejects(compile('#import "@preview/cetz:0.3.4": *'),/package|denied|resolve|found/);
    const source='#import "codly.typ" as codly\n#codly.new(raw("café → λ", block:true))';
    const previewSource=`#import "codly.typ" as codly
#context {
  assert.eq(page.fill, white)
  assert.eq(text.font, "libertinus serif")
  assert.eq(text.fill, black)
}
#codly.e.get(get => { assert.eq(get(codly.line).fill, (luma(240), none)) })
#codly.file("src/main.typ")`;
    const baseline=await compile(source);
    assert(baseline.includes('<svg'));
    for (const emojiSource of [
      '🐱 🌸 💖 🦊 🧁',
      ['#import "codly.typ" as codly', '#codly.new(', '  ```py', '  # 🐱 🌸 💖 🦊 🧁', '  ```', ')'].join('\n'),
    ]) {
      const svg = await compile(emojiSource);
      const glyphs = [...svg.matchAll(/data:image\/svg\+xml;base64,([A-Za-z0-9+/=]+)/g)];
      assert.equal(glyphs.length, 5, 'Each emoji must render a color glyph in text and code');
      for (const [, encoded] of glyphs) {
        const glyph = Buffer.from(encoded, 'base64').toString('utf8');
        assert.match(glyph, /<path\b/);
        assert(new Set(glyph.match(/fill="rgb\([^)]+\)"/g)).size > 1, 'Emoji glyphs must retain their colors');
      }
    }
    for (const [theme,font] of [['light','noto'],['dark','dejavu'],['light','dejavu']]) {
      assert.equal(await compile(source,theme,font),baseline,'Theme and font preferences must not affect preview output');
    }
    await compile(previewSource);
    await compile(`#import "codly.typ" as codly
#show: codly.theme("github-light")
#set text(font: "Libertinus Serif", fill: rgb("123456"))
#context { assert.eq(text.font, "libertinus serif"); assert.eq(text.fill, rgb("123456")) }
#codly.e.get(get => { assert.eq(get(codly.line).fill, white) })
#show: codly.line-show_(it => context { assert.eq(text.fill, rgb("1f2328")); it })
#codly.new("Explicit theme")`,'dark','noto');
    const packageSource=source.replace('import "codly.typ"', 'import "@preview/codly:2.0.0"');
    assert.equal(await compile(packageSource,'dark','noto'),baseline,'Published imports should compile identically to local imports');
    for (const imports of [
      '#import "@preview/codly:2.0.0" as snippet\n#snippet.new("hello")',
      '#import "@preview/codly:2.0.0": new\n#new("hello")',
      '#import "@preview/codly:2.0.0": new as code-block\n#code-block("hello")',
      '#import "@preview/codly:2.0.0" as first\n#import "@preview/codly:2.0.0" as second\n#first.new("first")\n#second.new("second")',
    ]) {
      const local=imports.replaceAll('import "@preview/codly:2.0.0"','import "codly.typ"');
      assert.equal(await compile(imports),await compile(local),'Import aliases and selective imports should remain unchanged');
    }
    await compile('#let package = "@preview/codly:2.0.0"\n#assert(package == "@preview/codly:2.0.0")');
    await assert.rejects(compile('#import "@preview/codly:2.0.1" as codly'),/package|denied|resolve|found/);
    const referenced=await compile('#import "codly.typ" as codly\n#figure(caption: [Example])[#codly.new("first\\nsecond", block-label: <example>)]<example>\nSee @example:2.');
    assert(referenced.includes('pseudo-link'), 'Expected rendered reference links');
    assert(!/<script|\son\w+=/i.test(referenced), 'Reference previews must have no executable handlers');
    const annotated=`#import "@preview/codly:2.0.0" as codly
#codly.new(
  raw("prepare()\\nresult = compute()\\nprint(result)\\ncleanup()", lang: "py", block: true),
  annotations: ((start: 2, end: 4, content: [Computes and displays the result]),),
)
#context {
  for height in (60pt, 120pt) {
    let brace = codly.annotation([], [], height: height, numbering: none)
    assert(measure(brace).height >= height * 0.7,
      message: "Annotation brace must stretch to its requested height")
  }
}`;
    assert((await compile(annotated)).includes('<svg'));
    const body='#import "codly.typ" as codly\n#show: codly.line-set_(fill: stripe)\n#codly.new(raw("let a = 1;\\nlet b = 2;", lang: "rust", block: true), radius: corner-radius)';
    const widgetConfig=[
      {type:'slider',name:'corner-radius',label:'Corner radius',default:'4pt',unit:'pt',min:0,max:20,step:0.5},
      {type:'select',name:'stripe',label:'Row fill',default:'rgb("aabbcc")',options:[
        {label:'Blue',value:'rgb("aabbcc")'},{label:'Green',value:'rgb("78edb1")'},{label:'None',value:'none'},
      ]},
    ];
    const widgets=validateWidgets(widgetConfig);
    const defaults=widgetDefaults(widgets);
    const changed={...defaults, 'corner-radius':'12.5pt', stripe:'rgb("78edb1")'};
    const assertions='\n#assert(corner-radius == 12.5pt)\n#assert(stripe == rgb("78edb1"))';
    const defaultSvg=await compile(exampleSource(body, widgets));
    const changedSvg=await compile(exampleSource(body + assertions, widgets, changed));
    assert.notEqual(defaultSvg, changedSvg, 'Control changes must change rendered output');
    const noStripes=await compile(exampleSource(body+'\n#assert(stripe == none)', widgets, {...defaults,stripe:'none'}));
    assert.notEqual(defaultSvg, noStripes);
    assert.equal(await compile(exampleSource(body, widgets)),defaultSvg,'Reset must reproduce default output');
    // Select values are arbitrary expressions, not strings interpreted in JS.
    const expressions=validateWidgets([{type:'select',name:'choice',label:'Choice',default:'(length: 3pt, tint: rgb("abcdef"))',options:[{label:'Compound',value:'(length: 3pt, tint: rgb("abcdef"))'},{label:'Invalid',value:'unknown-widget-value'}]}]);
    await compile(exampleSource('#assert(choice.length == 3pt)\n#assert(choice.tint == rgb("abcdef"))',expressions));
    await assert.rejects(compile(exampleSource('Hello',expressions,{choice:'unknown-widget-value'})),/unknown variable/);
    await compile(exampleSource('Hello',expressions));
    const runtimeFixture='#import "codly.typ" as codly\n#codly.new(raw("let a = 1;\\nlet b = 2;", lang: "rust", block: true))';
    assert((await compile(runtimeFixture, 'light', 'dejavu')).includes('<svg'));
    assert((await compile(runtimeFixture, 'dark', 'dejavu')).includes('<svg'));
    assert.equal(requests,0,'Compiler attempted a request with all assets supplied');
    await assert.rejects(compile('x'.repeat(30001)),/30,000/);
  } finally { globalThis.fetch=previousFetch; }
});
