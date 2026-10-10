import fs from 'node:fs/promises';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';
import { createEngine } from '../runtime/compiler.mjs';
import { fontFiles, compilerFontFiles } from './assets.mjs';
const root = fileURLToPath(new URL('../',import.meta.url));
process.chdir(root);
process.env.PATH = `${root}/.tools/node/bin:${root}/.tools:${process.env.PATH}`;
const codlySource = path.resolve(process.env.CODLY_SOURCE || '..');
await fs.rm('book', {recursive: true, force: true});
const assets = 'src/assets';
await fs.rm(assets,{recursive:true,force:true});
await fs.mkdir(`${assets}/previews`,{recursive:true});
await fs.mkdir(`${assets}/fonts`, {recursive: true});
for (const [name, file] of Object.entries(fontFiles)) await fs.copyFile(file, `${assets}/fonts/${name}`);
await fs.writeFile(`${assets}/version.json`, JSON.stringify({version: 'local', siteRoot: './'}));
await fs.copyFile('runtime/preferences.js',`${assets}/preferences.js`);
await fs.writeFile(`${assets}/icon.svg`,'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" rx="14" fill="#111925"/><path d="m23 20-13 12 13 12m18-24 13 12-13 12m-7-27-6 30" fill="none" stroke="#78edb1" stroke-width="4"/></svg>');
const compilerWasm = await fs.readFile('node_modules/@myriaddreamin/typst-ts-web-compiler/pkg/typst_ts_web_compiler_bg.wasm');
const rendererWasm = await fs.readFile('node_modules/@myriaddreamin/typst-ts-renderer/pkg/typst_ts_renderer_bg.wasm');
await fs.writeFile(`${assets}/compiler.wasm`, compilerWasm);
await fs.writeFile(`${assets}/renderer.wasm`, rendererWasm);
const files = {};
async function addTree(directory,virtualRoot) {
  for (const entry of await fs.readdir(directory,{withFileTypes:true})) {
    if (entry.isDirectory()) await addTree(path.join(directory,entry.name),`${virtualRoot}/${entry.name}`);
    else if (/\.(typ|json|toml|tmTheme)$/.test(entry.name)) files[`${virtualRoot}/${entry.name}`] = await fs.readFile(path.join(directory,entry.name),'utf8');
    else if (/\.(png|svg|jpg)$/.test(entry.name)) files[`${virtualRoot}/${entry.name}`] = { base64: (await fs.readFile(path.join(directory,entry.name))).toString('base64') };
  }
}
await addTree(path.join(codlySource, 'src'), '/src');
for (const name of ['codly.typ', 'typst.toml']) files[`/${name}`] = await fs.readFile(path.join(codlySource, name), 'utf8');
await addTree('vendor/elembic/src','/packages/preview/elembic/1.1.1/src');
files['/packages/preview/elembic/1.1.1/typst.toml'] = await fs.readFile('vendor/elembic/typst.toml', 'utf8');
await addTree('typst','');
await fs.writeFile(`${assets}/sources.json`,JSON.stringify(files));
const notices = ['THIRD-PARTY NOTICES\nBundled source, runtime dependencies and fonts.\n'];
async function collectNotices(dir) {
  for (const entry of await fs.readdir(dir,{withFileTypes:true})) {
    const file=path.join(dir,entry.name);
    if(entry.isDirectory()) await collectNotices(file);
    else if(/license|notice|copyright/i.test(entry.name) && !/\.(?:js|mjs|ts|map)$/.test(entry.name)) notices.push(`\n===== ${file} =====\n${await fs.readFile(file,'utf8')}`);
  }
}
await collectNotices('vendor');
notices.push('\nFont Awesome 4.7.0 by Dave Gandy; Copyright (c) 2016 Dave Gandy.\nFont license: SIL Open Font License 1.1.\n' + await fs.readFile('vendor/noto-sans-mono/LICENSE', 'utf8'));
notices.push(await fs.readFile(path.join(codlySource, 'LICENSE'), 'utf8'));
await collectNotices('node_modules');
await fs.writeFile(`${assets}/THIRD_PARTY_NOTICES.txt`,notices.join('\n'));
await build({entryPoints:{docs:'runtime/docs.mjs',worker:'runtime/worker.mjs',highlight:'runtime/highlight.mjs'},bundle:true,splitting:true,format:'esm',platform:'browser',target:'es2022',outdir:assets,minify:true,legalComments:'linked',metafile:true}).then(async result => { await fs.mkdir('.cache',{recursive:true}); await fs.writeFile('.cache/bundle-meta.json',JSON.stringify(result.metafile)); });
console.log('Building Markdown and highlighting…');
execFileSync('.tools/mdbook',['build'],{stdio:'inherit'});
const examples = JSON.parse(await fs.readFile(`${assets}/examples.json`,'utf8'));
const fonts = await Promise.all(compilerFontFiles.map(file => fs.readFile(file)));
const compile = await createEngine({compilerWasm,rendererWasm,fonts,files});
const unique = [...new Map(examples.map(e=>[e.id,e])).values()];
console.log(`Rendering ${unique.length} examples in two themes and two fonts with the actual WASM engine…`);
for (const example of unique) for (const theme of ['dark','light']) for (const font of ['noto','dejavu']) {
  try { await fs.writeFile(`${assets}/previews/${example.id}-${theme}-${font}.svg`,await compile(example.source,theme,font)); }
  catch (error) { throw new Error(`${example.chapter} (${theme}/${font}): ${error.message}`); }
}
await fs.cp(assets,'book/assets',{recursive:true});
await fs.copyFile('theme/docs.css','book/docs.css');
await fs.writeFile('book/.nojekyll','');
await fs.writeFile('book/versions.json', JSON.stringify({defaultVersion: 'local', versions: ['local']}));
// mdBook 0.5's toc helper emits book-root paths for its own toc.js to resolve.
// Resolve them at build time instead so our navigation also works without JS.
async function fixNavigation(dir) {
  for (const entry of await fs.readdir(dir,{withFileTypes:true})) {
    const file=path.join(dir,entry.name);
    if(entry.isDirectory()) await fixNavigation(file);
    else if(entry.name.endsWith('.html')) {
      const prefix=path.relative(path.dirname(file),'book').split(path.sep).join('/');
      let html=await fs.readFile(file,'utf8');
      html=html.replace(/(<nav aria-label="Documentation">)([\s\S]*?)(<\/nav>)/,(_,start,nav,end)=>start+nav.replace(/href="(?!https?:|#)([^"]+)"/g,(_,href)=>`href="${prefix ? prefix+'/' : ''}${href}"`)+end);
      await fs.writeFile(file,html);
    }
  }
}
await fixNavigation('book');
// The custom template does not use the stock mdBook runtime. Remove the unused
// files too, so the published artifact contains no dormant storage scripts.
for (const name of ['book.js','searcher.js','searchindex.js','searchindex.json','elasticlunr.min.js','mark.min.js','highlight.js','clipboard.min.js','toc.js','toc.html','print.html']) await fs.rm(`book/${name}`,{force:true});
console.log('Built book/ — ready for static hosting.');
