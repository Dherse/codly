import { createTypstCompiler } from '@myriaddreamin/typst.ts/compiler';
import { createTypstRenderer } from '@myriaddreamin/typst.ts/renderer';
import { loadFonts, withPackageRegistry, withAccessModel } from '@myriaddreamin/typst.ts/dist/esm/options.init.mjs';

// This explicit registry never downloads packages. Only the bundled Elembic resolves.
export async function createEngine({ compilerWasm, rendererWasm, fonts, files }) {
  const compiler = createTypstCompiler();
  await compiler.init({
    getModule: () => compilerWasm,
    beforeBuild: [
      loadFonts(fonts, { assets: false }),
      withAccessModel({ getMTime: () => undefined, isFile: () => false, getRealPath: () => undefined, readAll: () => undefined }),
      withPackageRegistry({ resolve: spec => spec.namespace === 'preview' && spec.name === 'elembic' && spec.version === '1.1.1' ? '/packages/preview/elembic/1.1.1' : undefined }),
    ],
  });
  for (const [path, source] of Object.entries(files)) {
    if (typeof source === 'string') compiler.addSource(path, source);
    else compiler.mapShadow(path, Uint8Array.from(atob(source.base64), c => c.charCodeAt(0)));
  }
  const renderer = createTypstRenderer();
  await renderer.init({ getModule: () => rendererWasm });
  return async (source, theme = 'dark', font = 'dejavu') => {
    if (source.length > 30000) throw new Error('Keep examples under 30,000 characters.');
    compiler.addSource('/main.typ', files['/setup.typ'] + '\n' + source);
    const compiled = await compiler.compile({ mainFilePath: '/main.typ', inputs: { theme, font }, diagnostics: 'full' });
    if (!compiled.result) throw new Error((compiled.diagnostics || []).map(d => `${d.path || ''}: ${d.message}`).join('\n') || 'Typst could not compile this example.');
    const svg = await renderer.renderSvg({ artifactContent: compiled.result, data_selection: { body: true, defs: true, css: true, js: false } });
    if (svg.length > 8_000_000) throw new Error('Preview is too large; shorten the example.');
    return svg;
  };
}
