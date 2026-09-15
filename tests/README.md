# Tests

Run the complete suite from the repository root:

```sh
python3 tests/run.py
```

Use Tytanic 0.4.1 (`tt`), Typst 0.15.1, and Python 3, matching CI. The runner
loads the bundled fonts and returns a nonzero status if any check fails.

| Suite | Coverage |
| --- | --- |
| `types` | Public constructors, defaults, positional/named arguments, successful/rejected casts, and nested block options |
| `elements` | Scoped settings, instance overrides, selectors, element hooks, disabled/inline raw, language aliases, headers and footers |
| `callbacks` | Scoped child settings, highlight/language callback inputs, offsets with character highlights |
| `highlight-nesting` | Exact wrapper structure: nested, adjacent, equal, crossing, duplicate, empty and out-of-bounds spans; whitespace, Unicode and styled text |
| `highlight-style` | Global styling, per-highlight overrides, fill callbacks and resolved box styles |
| `highlight-baseline` | Native baseline alignment with padding, tags, explicit shifts and `auto` overrides (#131, PR #132) |
| `language-style` | Per-corner badge radii, per-language overrides and independent name/icon visibility (#129, PR #123) |
| `skip-formatting` | Per-skip arrays, fallback values, duplicate records, smart skips and hidden numbers (#102, PR #103) |
| `github-regressions` | Reported bugs already fixed by the development API: unnumbered highlights, figure alignment, final smart skips, empty blocks and gradient headers |
| `rendering-options` | Range merging, open ranges, explicit skips, smart-skip switches, empty lines, disabled numbering, sparse high-offset fills and contextual font measurement |
| `references`, `reference-offset` | Native forward references, item tags, ordinary figure/heading references, metadata queries and continued numbering |
| `annotations` | Sorted multiline annotations, row spans, custom numbering and native labels with offsets |
| `layout` | Header/footer cell overrides and column spans, gradients/tiling, outside numbers and repeated headers/footers across pages |
| `errors` | Argument validation plus deferred layout, label and query failures |
| `issues`, `number-placement`, `outside-styling`, `single-line` | Existing regression examples migrated to the element API and visual comparisons |

Most new tests assert semantic values directly, or project a few resolved fields
into metadata and query them after layout. Keep callbacks small and capture only
the values they need; avoid retaining a whole block or fixture in a show rule.
The nesting suite checks complete wrapper output so repeated outer highlights
cannot pass merely because the rendered text looks right.

Use small pages with explicit margins and `height: auto` to avoid storing large
blank areas in PNGs. Reserve fixed page heights for pagination tests; choose
only enough width for the code or wrapping behavior under test.

Known Typst 0.15.1 limitation: a repeated grid header can extend above the
clipping region of a breakable block on continuation pages. The pagination
fixture uses explicit `1em` header/footer insets to keep the text visible;
smaller insets can still clip, including in a plain Typst reproduction.

For a focused run:

```sh
tt run types highlight-nesting --font-path docs/fonts
python3 tests/run.py --errors-only
```

Tytanic's `catch` checks immediate diagnostics. Layout can report errors after
that call returns, so `run.py` also compiles each case in `errors/layout.typ` and
checks both failure status and a diagnostic substring. A successful compile or
an unrelated error fails the case.

Visual tests keep reference PNGs in `ref/`. Inspect `out/` and `diff/` before
accepting a rendering change with `tt update TEST --font-path docs/fonts`.
To add visual references to an assertion-only suite, create its `ref/` directory
first, then run `tt update TEST --force --font-path docs/fonts`. Keep other
assertion-only suites without PNGs, and do not raise comparison tolerances to
hide regressions.
