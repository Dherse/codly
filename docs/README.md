# Documentation site

From the repository root:

```sh
just docs-setup
just docs-dev          # http://127.0.0.1:8001
just docs-check
just docs-build        # output: docs/book/
just docs-serve
just docs-site         # assemble docs/.site/ with version navigation
just docs-serve-site
just docs-deploy       # dispatch the Pages workflow on main; requires gh login
```

Add pages under `src/` and list them in `src/SUMMARY.md`.
Builds use Codly directly from the parent checkout.
Each example has one pre-rendered image with a white page and Typst's default
fonts. Theme and font preferences affect only the documentation UI.
Noto Color Emoji is bundled for color emojis in code and ordinary example text,
including static previews and the live editor. Emoji fallback works automatically;
use `#set text(font: "Noto Color Emoji")` to select it explicitly.
Published versions share content-hashed compiler, renderer, and font URLs under
`_typst/`, allowing the browser's HTTP cache to reuse identical downloads across
the landing page, releases, and main. Changed bytes get a new URL; existing files
remain available for archived versions. Standalone `book/` builds use local assets.
This uses ordinary HTTP caching, with no cookies or JavaScript-managed persistent
storage. Cache retention and revalidation depend on the browser and hosting headers.
Static previews render in parallel using up to four workers, limited by available
CPUs. Set `CODLY_DOCS_WORKERS` to a positive integer to override the pool size,
for example `CODLY_DOCS_WORKERS=2 just docs-build`.
Third-party runtime and font assets are pinned submodules; `just docs-setup`
initializes them. For a fresh clone, use `git clone --recurse-submodules`.

Use `typst preview` fences for editable examples. Add `fixed` for a full-width
example with highlighted code above its pre-rendered SVG:

`````markdown
````typst preview fixed
#import "@preview/codly:2.0.0" as codly
#codly.new[
```rust
let answer = 42;
```
]
````
`````

Fixed examples support copying, with no editor or live rendering. Put defaults
directly in their source; `yaml widgets` is reserved for interactive examples.

## Deployment

The source workflow publishes generated files to the `gh-pages` branch of
[Dherse/codly.github.io](https://github.com/Dherse/codly.github.io).

1. Create a fine-grained personal access token restricted to `Dherse/codly.github.io`,
   with **Contents: Read and write**.
2. In `Dherse/codly`, add it as the Actions secret `DOCS_DEPLOY_TOKEN`.
3. Merge the workflow into `main`. Its push publishes the first build; use
   `just docs-deploy` to run it manually.
4. After `gh-pages` exists, in `Dherse/codly.github.io` select
   **Settings → Pages → Source → Deploy from a branch → gh-pages → /(root)**.

The default Pages URL is `https://dherse.github.io/codly.github.io/`.
This is a project site because the repository owner is `Dherse`.
All site links are relative, so a later custom domain needs no URL rewrite.

`site.json` configures `customDomain` as `codly.dherse.dev`. Site assembly writes
the root `CNAME` on every deployment, restoring it if a previous build deleted it.
Without `customDomain`, assembly preserves the hosting branch's existing `CNAME`.
Archived releases cannot overwrite the hosting domain. Set the same domain in
the hosting repository's **Settings → Pages → Custom domain**.

Main pushes update `/main/`. The release workflow builds `/vX.Y.Z/` after validation.
Missing release tags from `initialVersion` onward are also backfilled automatically.
The hosting branch retains published versions across deployments.

`site.json` sets the default version. `"latest"` opens the highest published stable
release; replace it with a tag such as `"v2.0.0"` to pin the landing site.
`initialVersion` seeds the first release from main only when its package version
matches and no archive exists. The actual release tag rebuilds that snapshot.

To backfill an existing tag, run **Deploy documentation** with `release_ref` set
to that tag. Tags without the site scaffold use the current scaffold and their
own Codly source. Later tags use their own documentation and runtime.

## Notes, tips, and warnings

Use a blockquote with a marker on its first line:

```markdown
> [!WARNING]
> A highlight palette must contain at least one color.

> [!TIP] Choosing a palette
> Use **five colors** for a repeating cycle. Links, lists, and code fences
> work inside the box; prefix each line with `>`.
```

The supported markers are `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`,
and `[!CAUTION]`. An optional title after the marker replaces the default
heading. Ordinary blockquotes and markers inside code fences stay unchanged.
The boxes render at build time and work without JavaScript in both themes.

## Diagrams

Use `mermaid` fences with an accessible title and description:

```mermaid
flowchart TD
    accTitle: Code block pipeline
    accDescr: Source code becomes highlighted lines and then a Codly layout.
    Source --> Highlighting --> Layout
```

Mermaid loads from the local build only on pages containing diagrams and follows
the current light or dark theme. Diagram source remains available when JavaScript
is disabled or rendering fails. Wide diagrams scroll inside their own panel.
