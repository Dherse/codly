import { createHighlighterCore } from 'shiki/core';
import { createOnigurumaEngine } from 'shiki/engine/oniguruma';
import typst from 'shiki/langs/typst.mjs';
import dark from 'shiki/themes/github-dark.mjs';
import light from 'shiki/themes/github-light.mjs';
// Use the same engine as build-time highlighting; bundled WASM loads on edit.
// The Typst import includes its dependent grammars and must be passed as a list.
const highlighter = createHighlighterCore({ themes: [dark, light], langs: typst, engine: createOnigurumaEngine(import('shiki/wasm')) });
export async function highlight(source) {
  return (await highlighter).codeToHtml(source, { lang: 'typst', themes: { light: 'github-light', dark: 'github-dark' }, defaultColor: false });
}
