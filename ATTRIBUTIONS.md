# Attributions and third-party licenses

Codly is developed by Sébastien d'Herbais de Thun and contributors, under the
[MIT License](LICENSE).

## Typesetting, elements, and code presentation

| Project | Contribution to Codly | License and source |
| --- | --- | --- |
| [Typst](https://github.com/typst/typst) | Typesetting system on which Codly runs, including native raw text rendering and syntax highlighting. | [Apache-2.0](https://github.com/typst/typst/blob/main/LICENSE); see also Typst's [third-party notices](https://github.com/typst/typst/blob/main/NOTICE). |
| [Elembic](https://github.com/PgBiel/elembic), by PgBiel | Runtime dependency (`@preview/elembic:1.1.1`) providing custom elements, typed fields, and scoped rules. | [MIT OR Apache-2.0](https://github.com/PgBiel/elembic/blob/main/LICENSE), at your option; [MIT text](https://github.com/PgBiel/elembic/blob/main/LICENSE-MIT) and [Apache text](https://github.com/PgBiel/elembic/blob/main/LICENSE-APACHE). |
| [Zebraw](https://github.com/hongjr03/typst-zebraw), by hongjr03 | Related code presentation package acknowledged for ideas and inspiration. | [MIT](https://github.com/typst/packages/blob/main/packages/preview/zebraw/0.6.3/LICENSE). |
| [codly-languages](https://github.com/swaits/typst-collection), by Stephen Waits | Companion language configurations, icons, and colors used in examples and documentation. | [MIT](https://github.com/typst/packages/blob/main/packages/preview/codly-languages/0.1.8/LICENSE). Copyright (c) 2025 Stephen Waits. |

## Theme palettes

The presets in [`src/themes.typ`](src/themes.typ) adapt colors from these
projects.

| Upstream project | Codly preset | License and original notice |
| --- | --- | --- |
| [GitHub VS Code Theme](https://github.com/primer/github-vscode-theme), by Primer | `github-light` | [MIT](https://github.com/primer/github-vscode-theme/blob/main/LICENSE). Copyright (c) 2020 Primer. |
| [Solarized](https://ethanschoonover.com/solarized/), by Ethan Schoonover | `solarized-light` | [MIT](https://github.com/altercation/solarized/blob/master/LICENSE). Copyright (c) 2011 Ethan Schoonover. |
| [Atom One Light Syntax](https://github.com/atom/one-light-syntax), by GitHub | `one-light`; adapted from [`styles/colors.less`](https://github.com/atom/one-light-syntax/blob/master/styles/colors.less) | [MIT](https://github.com/atom/one-light-syntax/blob/master/LICENSE.md). Copyright (c) 2016 GitHub Inc. |
| [Visual Studio Code](https://github.com/microsoft/vscode), by Microsoft and contributors | `dark`; colors from the default dark editor and syntax palette | [MIT](https://github.com/microsoft/vscode/blob/main/LICENSE.txt). Copyright (c) 2015 - present Microsoft Corporation. |

The following MIT permission and warranty notice applies to each of the four
theme palette copyright notices above:

```text
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Bundled fonts and icons

These assets are included for documentation and examples. Their full license
texts and copyright notices are alongside the font files.

| Asset | Author / copyright notice | License included in this repository |
| --- | --- | --- |
| [Source Sans 3](https://github.com/adobe-fonts/source-sans) | Copyright 2010-2020 Adobe, with Reserved Font Name 'Source'. | [SIL Open Font License 1.1](fonts/Source%20Sans%203/LICENSE). |
| [Tabler Icons](https://github.com/tabler/tabler-icons) | Copyright (c) 2020-2024 Paweł Kuna. | [MIT](fonts/Tabler%20Icons/LICENSE). |
| [Noto Color Emoji](https://github.com/googlefonts/noto-emoji) | Copyright 2021 Google Inc. All Rights Reserved. | [SIL Open Font License 1.1](fonts/Noto%20Color%20Emoji/LICENSE). |
