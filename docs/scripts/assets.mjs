import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const asset = name => path.join(root, 'vendor', name);

export const fontFiles = {
  'DejaVuSansMono.ttf': asset('typst-assets/files/fonts/DejaVuSansMono.ttf'),
  'LibertinusSerif-Regular.otf': asset('typst-assets/files/fonts/LibertinusSerif-Regular.otf'),
  'LibertinusSerif-Bold.otf': asset('typst-assets/files/fonts/LibertinusSerif-Bold.otf'),
  'LibertinusSerif-Italic.otf': asset('typst-assets/files/fonts/LibertinusSerif-Italic.otf'),
  'LibertinusSerif-BoldItalic.otf': asset('typst-assets/files/fonts/LibertinusSerif-BoldItalic.otf'),
  'NotoSansMono-Regular.ttf': asset('noto-sans-mono/fonts/ttf/hinted/instance_ttf/NotoSansMono-Regular.ttf'),
  'SourceSans3-Regular.ttf': asset('source-sans/TTF/SourceSans3-Regular.ttf'),
  'FontAwesome.woff2': asset('font-awesome/fonts/fontawesome-webfont.woff2'),
};

export const compilerFontFiles = Object.entries(fontFiles)
  .filter(([name]) => !name.endsWith('.woff2')).map(([, file]) => file);
