import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import { createEngine } from '../runtime/compiler.mjs';
import { fontFiles, compilerFontFiles } from '../scripts/assets.mjs';

const families = [
  {
    name: 'DejaVu Sans Mono',
    regular: 'DejaVuSansMono.ttf',
    bold: 'DejaVuSansMono-Bold.ttf',
    italic: 'DejaVuSansMono-Oblique.ttf',
    boldItalic: 'DejaVuSansMono-BoldOblique.ttf',
  },
  {
    name: 'Noto Sans Mono',
    regular: 'NotoSansMono-Regular.ttf',
    bold: 'NotoSansMono-Bold.ttf',
  },
  {
    name: 'Source Sans 3',
    regular: 'SourceSans3-Regular.ttf',
    bold: 'SourceSans3-Bold.ttf',
    italic: 'SourceSans3-It.ttf',
    boldItalic: 'SourceSans3-BoldIt.ttf',
  },
];
const styles = {
  regular: { weight: 'regular', style: 'normal', numericWeight: 400 },
  bold: { weight: 'bold', style: 'normal', numericWeight: 700 },
  italic: { weight: 'regular', style: 'italic', numericWeight: 400 },
  boldItalic: { weight: 'bold', style: 'italic', numericWeight: 700 },
};

// Read the font's actual weight and slant, rather than trusting its filename.
function table(bytes, name) {
  for (let index = 0; index < bytes.readUInt16BE(4); index++) {
    const entry = 12 + index * 16;
    if (bytes.toString('ascii', entry, entry + 4) === name) {
      const offset = bytes.readUInt32BE(entry + 8);
      return bytes.subarray(offset, offset + bytes.readUInt32BE(entry + 12));
    }
  }
  assert.fail(`Missing ${name} font table`);
}

test('static previews and the live manifest bundle genuine regular, bold, and italic faces', async () => {
  const manifest = JSON.parse(await fs.readFile('book/assets/compiler-assets.json', 'utf8'));
  assert.deepEqual(manifest.fonts.map(file => path.basename(file)).sort(),
    compilerFontFiles.map(file => path.basename(file)).sort());

  for (const family of families) {
    for (const [styleName, style] of Object.entries(styles)) {
      const filename = family[styleName];
      if (!filename) continue; // Noto Sans Mono has no italic family.
      assert(fontFiles[filename], `${family.name} needs its ${styleName} face`);
      assert(manifest.fonts.includes(`fonts/${filename}`), `${filename} missing from live compiler`);
      const source = await fs.readFile(fontFiles[filename]);
      assert.equal(table(source, 'OS/2').readUInt16BE(4), style.numericWeight, filename);
      assert.equal(table(source, 'post').readInt32BE(4) !== 0, style.style === 'italic', filename);
      assert.deepEqual(await fs.readFile(`book/assets/fonts/${filename}`), source, filename);
    }
  }
});

function glyphOutlines(svg) {
  const paths = [...svg.matchAll(/<path\b[^>]*\bclass="outline_glyph"[^>]*\bd="([^"]+)"/g)]
    .map(match => match[1]);
  assert(paths.length >= 3, 'The sample must render real outlines for H, n, and 0');
  return paths;
}

const sample = (family, { weight, style }) =>
  `#set text(font: "${family.name}", size: 20pt, weight: "${weight}", style: "${style}")\nHn0`;

test('WASM previews select real bold and italic glyphs rather than reusing or synthesizing regular outlines', { timeout: 30000 }, async () => {
  const manifest = JSON.parse(await fs.readFile('book/assets/compiler-assets.json', 'utf8'));
  const options = {
    compilerWasm: await fs.readFile('book/assets/compiler.wasm'),
    rendererWasm: await fs.readFile('book/assets/renderer.wasm'),
    files: JSON.parse(await fs.readFile('book/assets/sources.json', 'utf8')),
  };
  const compile = await createEngine({
    ...options,
    fonts: await Promise.all(manifest.fonts.map(file => fs.readFile(`book/assets/${file}`))),
  });
  const regular = new Map();
  for (const family of families) {
    regular.set(family.name, glyphOutlines(await compile(sample(family, styles.regular))));
  }

  for (const [styleName, style] of Object.entries(styles)) {
    if (styleName === 'regular') continue;
    const supportedFamilies = families.filter(family => family[styleName]);
    // With only the requested faces installed, the reference cannot choose a
    // regular face. Comparing paths also excludes SVG IDs and layout metadata.
    const reference = await createEngine({
      ...options,
      fonts: await Promise.all(supportedFamilies.map(family => fs.readFile(fontFiles[family[styleName]]))),
    });
    for (const family of supportedFamilies) {
      const actual = glyphOutlines(await compile(sample(family, style)));
      assert.notDeepEqual(actual, regular.get(family.name), `${family.name} ${styleName} must change glyph geometry`);
      assert.deepEqual(actual, glyphOutlines(await reference(sample(family, style))),
        `${family.name} ${styleName} must use the genuine vendor face`);
    }
  }
});
