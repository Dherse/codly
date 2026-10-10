import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { runInNewContext } from 'node:vm';
import { createEngine } from '../runtime/compiler.mjs';
import { compilerFontFiles } from '../scripts/assets.mjs';
import { highlight } from '../runtime/highlight.mjs';
import { exampleSource, validateWidgets, widgetDefaults } from '../runtime/widgets.mjs';
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

test('all preview sources have matching static SVGs in both themes and fonts',async()=>{
  const examples=JSON.parse(await read('book/assets/examples.json'));
  for(const {id,source,body,widgets,chapter} of examples) {
    const html=await read('book/'+chapter.replace(/\.md$/,'.html'));
    const decode = s => s.replace(/&(?:amp|lt|gt|quot|apos|#\d+|#x[\da-f]+);/gi, entity => ({'&amp;':'&','&lt;':'<','&gt;':'>','&quot;':'"','&apos;':"'"}[entity] ?? String.fromCodePoint(entity[2]==='x'?parseInt(entity.slice(3,-1),16):parseInt(entity.slice(2,-1),10))));
    const textareas=[...html.matchAll(/<textarea[^>]*>([\s\S]*?)<\/textarea>/g)].map(m=>decode(m[1]));
    assert(textareas.includes(body),`Editable source mismatch in ${chapter}`);
    assert.equal(exampleSource(body, widgets), source, `Default bindings mismatch in ${chapter}`);
    const displayed=[...html.matchAll(/<div class="highlighted">\s*<pre[^>]*>\s*<code>([\s\S]*?)<\/code>/g)].map(m=>decode(m[1].replace(/<[^>]*>/g,'')));
    assert(displayed.includes(body),`Displayed example body mismatch in ${chapter}`);
    for(const theme of ['dark','light']) for(const font of ['noto','dejavu']) {
      const svg=await read(`book/assets/previews/${id}-${theme}-${font}.svg`);
      assert(svg.includes('<svg') && svg.includes('<path'),`Missing real SVG paths for ${id}`);
      // typst.ts includes foreignObject text-selection metadata. SVGs are always
      // isolated in img elements, never embedded as active documents or inline DOM.
      assert(!/<script|\son\w+=/i.test(svg),`Executable SVG content: ${id}`);
    }
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
    const dark=await compile(source,'dark','noto');
    const light=await compile(source,'light','dejavu');
    assert(dark.includes('<svg'));assert(light.includes('<svg'));assert.notEqual(dark,light);
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
