# Diffs and mixed languages

Highlight changes in a patch, and embedded code inside another language.

## Review a Python change

This patch replaces a positional result with named fields. Old and new code get independent syntax passes, so removed delimiters or multiline strings do not disturb the highlighting of added code. The custom gutter shows patch-row coordinates and replaces the automatic old/new/marker columns.

```yaml widgets
- type: switch
  name: patch-enabled
  label: Process the patch
  default: true
- type: switch
  name: patch-numbers
  label: Old and new numbers
  default: true
- type: switch
  name: patch-markers
  label: Added and removed markers
  default: true
- type: select
  name: patch-colors
  label: Change colors
  default: '(added: rgb("dafbe1"), removed: rgb("ffebe9"), meta: rgb("ddf4ff"))'
  options:
    - label: Green and red
      value: '(added: rgb("dafbe1"), removed: rgb("ffebe9"), meta: rgb("ddf4ff"))'
    - label: Blue and orange
      value: '(added: rgb("dbeafe"), removed: rgb("ffedd5"), meta: rgb("f1f5f9"))'
    - label: No background
      value: '(added: none, removed: none, meta: none)'
- type: slider
  name: patch-old-offset
  label: Old number offset
  default: '0'
  min: 0
  max: 100
  step: 10
- type: slider
  name: patch-new-offset
  label: New number offset
  default: '0'
  min: 0
  max: 100
  step: 10
- type: switch
  name: patch-custom-gutter
  label: Custom patch-row gutter
  default: false
- type: switch
  name: patch-rainbow
  label: Color nested delimiters
  default: true
- type: slider
  name: patch-width
  label: Block width
  default: '100%'
  min: 55
  max: 100
  step: 5
  unit: '%'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```diff-py
  @@ -20,3 +20,6 @@
   def summarize(values):
  -    totals = [sum(values), len(values)]
  -    return totals
  +    totals = {
  +        "sum": sum(values),
  +        "count": len(values),
  +    }
  +    return totals
  ```,
  diff: if patch-enabled {
    (
      numbers: patch-numbers,
      markers: patch-markers,
      added-fill: patch-colors.added,
      removed-fill: patch-colors.removed,
      meta-fill: patch-colors.meta,
      old-offset: patch-old-offset,
      new-offset: patch-new-offset,
    )
  } else { false },
  gutters: if patch-custom-gutter {
    (codly.gutter-column(
      values: row => if row.source-line != none {
        "R" + str(row.source-line)
      },
      align: right,
      text: (fill: gray),
    ),)
  } else { auto },
  rainbow: patch-rainbow,
  width: patch-width,
)
````

Both `diff-py` and `diff,py` are valid Codly language tags. The hyphenated fence also works in Typst 0.15; on versions without comma support in fences, use `raw(source, block: true, lang: "diff,py")`.

See [`codly.diff`](../api/types/diff.md) for patch coordinates and [`codly.gutter-column`](../api/types/gutter-column.md) for custom columns.

## Highlight Python inside a shell script

The shell launches Python through a heredoc, so lines 3–10 need Python highlighting inside a shell block. Without the sublanguage, the shell grammar treats that region as a string.

Each sublanguage has its own delimiter stack. Rainbow coloring skips delimiters in strings and comments, and indentation guides follow leading spaces.

```yaml widgets
- type: switch
  name: embedded-enabled
  label: Highlight embedded code
  default: true
- type: select
  name: embedded-language
  label: Embedded language
  default: '"py"'
  options:
    - label: Python
      value: '"py"'
    - label: Plain text
      value: '"text"'
- type: switch
  name: syntax-rainbow
  label: Color nested delimiters
  default: true
- type: select
  name: syntax-palette
  label: Delimiter and guide palette
  default: '(rgb("d73a49"), rgb("005cc5"), rgb("22863a"))'
  options:
    - label: Red, blue, green
      value: '(rgb("d73a49"), rgb("005cc5"), rgb("22863a"))'
    - label: Purple, teal, orange
      value: '(rgb("7c3aed"), rgb("0f766e"), rgb("c2410c"))'
    - label: One blue
      value: '(rgb("005cc5"),)'
- type: slider
  name: syntax-depth-offset
  label: Starting palette index
  default: '0'
  min: 0
  max: 4
  step: 1
- type: switch
  name: syntax-guides
  label: Show indentation guides
  default: true
- type: select
  name: syntax-indent-width
  label: Spaces per guide level
  default: '4'
  options:
    - label: Infer from source
      value: auto
    - label: Two spaces
      value: '2'
    - label: Four spaces
      value: '4'
- type: switch
  name: syntax-numbers
  label: Show line numbers
  default: true
- type: slider
  name: syntax-width
  label: Block width
  default: '100%'
  min: 55
  max: 100
  step: 5
  unit: '%'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```sh
  #!/usr/bin/env bash
  python3 - <<'PY'
  def summarize(values):
      stats = {
          "sum": sum(values),
          "count": len(values),
      }
      return {"stats": stats, "items": list(values)}

  print(summarize([2, 4, 8]))
  PY
  echo "Report ready"
  ```,
  sublangs: if embedded-enabled {
    (codly.sublang(start: 3, end: 10, lang: embedded-language),)
  } else { () },
  rainbow: (
    enabled: syntax-rainbow,
    palette: syntax-palette,
    depth-offset: syntax-depth-offset,
  ),
  indent-guides: (
    enabled: syntax-guides,
    width: syntax-indent-width,
  ),
  number-enabled: syntax-numbers,
  width: syntax-width,
)
````

Sublanguage ranges count original source lines, starting at 1. If you insert lines above the Python section, update `start` and `end` in the editor.

See [`codly.sublang`](../api/types/sublang.md), [`codly.rainbow`](../api/types/rainbow.md), and [`codly.indent-guides`](../api/types/indent-guides.md) for the individual options, or [Internals](../api/internals.md) for the rendering pipeline.
