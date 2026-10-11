# Migrating from 1.3.0 and 1.3.1 to 2.0

Version 2 replaces state-changing configuration calls with explicit code elements and scoped show rules. Most data structures carry over unchanged; styling moves to the component that owns it.

This guide covers both 1.3.0 and 1.3.1, whose configuration APIs are identical. Where 1.3.1 behavior differs — nested highlights, local highlight overrides, icon spacing, reference and grid fixes — the relevant section says so.

Each section shows the old code, its replacement, and an editable 2.0 example. The 1.3 snippets are for comparison only; widget controls and source edits apply to the new example, and **Copy code** captures both.

| If your document uses… | Start here |
| --- | --- |
| `codly-init`, `codly(...)`, or `local(...)` | [Initialization](#initialization) and [scoped settings](#scoped-settings) |
| Enable/disable helpers | [Conversion boundaries](#enable-and-disable) |
| `inset`, `stroke`, `fill`, or `zebra-fill` | [Geometry and typography](#migration-typography-and-spacing) and [row fills](#migration-row-fills) |
| `languages`, `lang-*`, or `lang-format` | [Language definitions](#migration-language-definitions) and [formatters](#migration-language-formatters) |
| Headers, footers, or filename presentation | [Headers and footers](#migration-headers-and-footers) and [filenames](#migration-filename-badges) |
| Ranges, skips, or continued numbering | [Ranges](#migration-ranges), [explicit skips](#migration-explicit-skips), and [offsets](#migration-offset) |
| Number formatting or hidden numbers | [Number styling and visibility](#migration-numbers) |
| Highlights or annotations | [Whole-line highlights](#migration-whole-line-highlights), [character spans](#migration-span-highlights), and [annotations](#migration-annotations) |
| References or internal queries | [References](#migration-references) and [custom rules and queries](#custom-rules-and-queries) |

::: collapse Update imports and initialize automatic conversion {#initialization}

In 1.3, `codly-init` installed the raw-block show rules and figure handling. The `codly` function then changed configuration; it did not take a code block as its positional body.

**Before — 1.3.0 or 1.3.1:**

```typst
#import "@preview/codly:1.3.1": *
#show: codly-init
#codly(number-format: numbering.with("1."))
```

**After — 2.0:** import the namespace, set defaults with show rules, and register `codly.new` as the raw-block converter. `codly.new(body, ..fields)` constructs a block; the exported `codly.codly` is an alias of this constructor, not the old configuration function.

```yaml widgets
- type: switch
  name: setup-numbers
  label: Show line numbers
  default: true
- type: select
  name: setup-numbering
  label: Number format
  default: '"1."'
  options:
    - label: Plain
      value: '"1"'
    - label: With a dot
      value: '"1."'
    - label: In parentheses
      value: '"(1)"'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.set_(number-enabled: setup-numbers)
#show: codly.number-set_(numbering: setup-numbering)
#show raw.where(block: true): codly.new

```py
def greet(name):
    return f"Hello, {name}!"
print(greet("reader"))
```
````

The selector only converts block raw content; inline raw keeps Typst's ordinary rendering. If you build every listing with an explicit `#codly.new(...)`, omit the converter rule entirely.

Codly 2.0 requires Typst 0.15 or newer. These examples import `@preview/codly:2.0.0`; when working from a checkout, import `"codly.typ"` or a locally installed `"@local/codly:2.0.0"` instead.

See [`codly.new`](api/components/new.md) for accepted bodies and fields.

:::

::: collapse Replace configuration state with scoped defaults and explicit blocks {#scoped-settings}

In 1.3, `#codly(...)` mutated state for the raw blocks that followed. `local(...)` applied temporary overrides, with `nested: true` to merge an enclosing `local` configuration. Block-specific settings — ranges, offsets, skips, highlights, annotations, headers, footers — were reset after each block.

**Before:**

````typst
#import "@preview/codly:1.3.1": *
#show: codly-init
#codly(radius: 2pt)

#local(radius: 8pt, nested: true)[
  ```py
  special = True
  ```
]

```py
ordinary = True
```
````

**After:** place `#show: codly.set_(...)` in the scope whose blocks should inherit it. Component setters work the same way. An explicit argument on `codly.new` overrides that block's scoped default. Nested scopes inherit outer rules without a `nested` flag.

```yaml widgets
- type: slider
  name: scope-outer-radius
  label: Outer corner radius
  default: 2pt
  unit: pt
  min: 0
  max: 12
  step: 1
- type: slider
  name: scope-inner-radius
  label: Inner corner radius
  default: 8pt
  unit: pt
  min: 0
  max: 12
  step: 1
- type: slider
  name: scope-padding
  label: First block padding
  default: 3pt
  unit: pt
  min: 0
  max: 8
  step: 1
- type: switch
  name: scope-first-numbers
  label: First block numbers
  default: false
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.theme("github-light")
#show: codly.set_(radius: scope-outer-radius)

#{
  show: codly.set_(radius: scope-inner-radius)
  codly.new(
    ```py
    special = True
    ```,
    padding: scope-padding,
    number-enabled: scope-first-numbers,
  )
}

#codly.new(
  ```py
  ordinary = True
  ```,
)
````

Scoped defaults apply to every matching element that follows in the scope; they are not consumed by the next block. Pass one-off data (ranges, skips, highlights, annotations) directly to `codly.new`, and keep shared defaults in show rules. Reusing a labelled highlight across blocks creates duplicate labels.

There is no `codly-reset` equivalent: end the scope to restore the enclosing configuration. To reset presentation inside a scope, apply a theme or explicit component defaults — but note that a theme does not clear block data such as ranges or annotations.

`#set codly.new(...)` is not an Elembic set rule. Use `#show: codly.set_(...)` for block defaults and the component setters (`codly.line-set_`, `codly.lang-set_`, …) for component fields.

:::

::: collapse Keep existing block behavior options {#retained-block-options}

Several familiar fields stay on the block. Move them from `#codly(...)` or `local(...)` to the corresponding `codly.new(..., field: value)` call; use `codly.set_` only when the value should apply throughout a scope.

| Field retained from 1.3 | What it controls |
| --- | --- |
| `aliases` | Maps an authored language key to a syntax-highlighting language. Language badge definitions still belong to `codly.lang`. |
| `smart-indent` | Keeps continuation lines aligned with source indentation. |
| `skip-last-empty` | Omits the final empty source line when enabled. |
| `breakable` | Allows the code block to split across pages. Header/footer repetition requires a breakable block. |

If a 1.3 field accepted a zero-argument function as a lazy value, call it yourself and pass the result; 2.0 fields expect concrete values.

The example also uses two new 2.0 controls, `width` and `wrap-marker`; the marker only appears when smart indentation is enabled.

```yaml widgets
- type: switch
  name: retained-alias
  label: Resolve the custom Python alias
  default: true
- type: switch
  name: retained-smart-indent
  label: Smart indentation
  default: true
- type: switch
  name: retained-skip-empty
  label: Omit the final empty line
  default: true
- type: slider
  name: retained-width
  label: Block width
  default: 100%
  unit: '%'
  min: 55
  max: 100
  step: 5
- type: switch
  name: retained-wrap-marker
  label: Show wrap markers
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.theme("github-light", block: (text: (size: 9pt)))
#show: codly.lang-set_(languages: (example-python: "Python"))

#codly.new(
  ```example-python
  def notify(address, updates):
      if updates:
          send_email(address, subject="Your project updates", body=format_updates(updates))

  ```,
  aliases: if retained-alias { (example-python: "py") } else { (:) },
  smart-indent: retained-smart-indent,
  skip-last-empty: retained-skip-empty,
  width: retained-width,
  wrap-marker: if retained-wrap-marker { [↪] } else { none },
)
````

When checking a migrated wrapped listing, compare indentation as well as row counts: a wrapped continuation is still part of its source line. The [headers and footers](#migration-headers-and-footers) example uses a finite page height if you need to check pagination.

:::

::: collapse Port enable and disable helpers to conversion boundaries {#enable-and-disable}

The 1.3 helpers `codly-enable`, `codly-disable`, `no-codly`, and `yes-codly` controlled the state checked by `codly-init`. The 2.0 constructor has no `enabled` field: calling it means that you want a Codly block.

**Before:**

````typst
#import "@preview/codly:1.3.1": *
#show: codly-init
#codly-disable()
```text
Ordinary raw text
```
#codly-enable()
```py
print("formatted")
```
````

**After:** choose where conversion happens. For occasional listings, leave raw blocks alone and call `codly.new` explicitly. For automatic conversion, write one routing rule that returns the original raw element for excluded blocks — here, everything tagged `text`:

```yaml widgets
- type: switch
  name: conversion-enabled
  label: Convert code blocks
  default: true
- type: switch
  name: conversion-exclude-text
  label: Keep text blocks ordinary
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show raw.where(block: true): it => {
  if conversion-enabled and not (
    conversion-exclude-text and it.lang == "text"
  ) {
    codly.new(it)
  } else {
    it
  }
}

```py
print("formatted")
```

```text
An ordinary text block
```
````

Adjust the predicate to your own exclusion policy, or place the converter inside a local scope so raw blocks outside it stay ordinary.

> [!IMPORTANT] Keep the bypass in the routing rule.
> A later `show raw.where(block: true): it => it` does not reliably undo an earlier converter — the element still passes through the older rule. Port `no-codly` wrappers by extending the converter's exclusion policy or by scoping the converter itself.

> [!TIP] Disable Codly with a label
> Tag a raw block with a label such as `<native>` and test it in the routing rule to opt individual blocks out (or in):
>
> ````typst preview
> #import "@preview/codly:2.0.0" as codly
> 
> #show raw.where(block: true): it => {
>   if "label" in it.fields() and it.label == <native> {
>     it
>   } else {
>     codly.new(it)
>   }
> }
>
> ```py
> print("native")
> ``` <native>
> 
> ```py
> print("formatted")
> ```
> ````

:::

::: collapse Typography, row spacing, and the code border {#migration-typography-and-spacing}

**Move presentation to its component; keep geometry on the block.** Version 1 combined row inset, border, and outer radius in a single configuration call. Version 2 separates them:

| Version 1 | Version 2 |
| --- | --- |
| `inset: ...` | `#show: codly.line-set_(inset: ...)` |
| `stroke: ...` | `#show: codly.line-set_(stroke: ...)` |
| `radius: ...` | `codly.new(..., radius: ...)`, or scoped `codly.set_` |
| Native raw/text typography | Native rules, or the `text` dictionary of a theme section |

Neither 1.3 release had a Codly-specific `font` option. Native text rules still apply; for Codly-only typography, use a theme's `block.text` dictionary, or `number.text`, `lang.text`, `header.text`, and `footer.text` for individual components. Place narrower rules after the theme so they take precedence.

Version 1:

```typst
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)
#codly(inset: 4pt, stroke: 1pt + luma(180), radius: 6pt)
```

The new `padding` field adds space at the **block edges**, independent of row inset — do not port `inset` to `padding`. Version 2 also adds `leading`, `gutter`, `column-gutter`, and `row-gutter` on the block; `leading` sets vertical row spacing, replacing the vertical components of the old inset. These are new controls, not renames.

```yaml widgets
- type: select
  name: migration-code-font
  label: Code font
  default: '"DejaVu Sans Mono"'
  options:
    - label: DejaVu Sans Mono
      value: '"DejaVu Sans Mono"'
    - label: Noto Sans Mono
      value: '"Noto Sans Mono"'
- type: slider
  name: migration-code-size
  label: Code size
  default: 9pt
  unit: pt
  min: 7
  max: 12
  step: 1
- type: slider
  name: migration-row-inset
  label: Row inset
  default: 4pt
  unit: pt
  min: 1
  max: 8
  step: 1
- type: slider
  name: migration-edge-padding
  label: Block edge padding
  default: 0pt
  unit: pt
  min: 0
  max: 10
  step: 1
- type: slider
  name: migration-block-radius
  label: Outer corner radius
  default: 6pt
  unit: pt
  min: 0
  max: 12
  step: 1
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.theme(
  "thesis",
  block: (text: (font: migration-code-font, size: migration-code-size)),
  lang: (text: (font: "Source Sans 3", size: 9pt)),
)
#show: codly.line-set_(inset: migration-row-inset, stroke: 1pt + luma(180))

#codly.new(
  ```py
  def greet(name):
      return f"Welcome back, {name}!"
  print(greet("Ada"))
  ```,
  radius: migration-block-radius,
  padding: migration-edge-padding,
)
````

If a 1.3.0 document depended on document-wide `grid` or `grid.cell` rules leaking into Codly (1.3.1 already isolated its grid), re-check the layout; version 2 exposes the supported presentation changes as component fields instead.

See [`codly.line`](api/components/line.md), [`codly.new`](api/components/new.md), and [themes](api/helpers/theme.md).

:::

::: collapse Background fills, zebra striping, and fill callbacks {#migration-row-fills}

**Replace the two old background settings with one row fill.** `zebra-fill` is removed. `codly.line` accepts a single paint, `none`, a nonempty palette, or a callback.

Version 1:

```typst
#codly(fill: white, zebra-fill: luma(240))
```

Version 2's matching alternating configuration is:

```typst
#show: codly.line-set_(fill: (luma(240), white))
```

The order matters: entry 0 paints displayed row 0, entry 1 paints row 1. An old `zebra-fill: none` becomes a scalar `fill: <old fill>`; an empty palette is invalid. `fill: auto` restores the default alternating pattern.

**Displayed rows are not source lines.** Palette indexing counts generated skip rows, callout rows, and header/footer rows. Headers and footers have their own backgrounds but still advance the index, so a header shifts the stripe of the first code line. For striping by source-line parity, use the callback's `source-line` field instead.

The callback receives one row dictionary:

| Field | Meaning |
| --- | --- |
| `index` | Zero-based position among displayed rows, including generated rows. |
| `kind` | `"code"`, `"skip"`, or `"callout"` for callback rows. |
| `source-line` | One-based source line for code/callout rows; `none` for skips. |
| `number` | Displayed line number after offsets/skips; `none` for unnumbered/generated rows. |

Headers and footers never call this function. Whole-line highlights and enabled diff backgrounds take precedence over the row fill.

Note the changed callback contract: 1.3 accepted zero-argument lazy values such as `fill: () => color`, but the 2.0 fill callback is a row formatter. Write `fill: row => ...`, or evaluate the old helper yourself (`fill: helper()`). Other component callbacks keep their own contracts — do not rewrite them all to take a row.

```yaml widgets
- type: select
  name: migration-stripe-mode
  label: Fill selection
  default: '"displayed"'
  options:
    - label: Displayed row palette
      value: '"displayed"'
    - label: Source line parity
      value: '"source"'
    - label: Solid background
      value: '"solid"'
- type: select
  name: migration-stripe-paint
  label: Stripe paint
  default: 'luma(240)'
  options:
    - label: Pale gray
      value: 'luma(240)'
    - label: Pale blue
      value: 'rgb("e2edff")'
    - label: Pale green
      value: 'rgb("e5f5e9")'
- type: switch
  name: migration-fill-header
  label: Include a header
  default: false
- type: switch
  name: migration-fill-excerpt
  label: Select two source ranges
  default: false
- type: switch
  name: migration-fill-numbers
  label: Show line numbers
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.line-set_(fill:
  if migration-stripe-mode == "displayed" {
    (migration-stripe-paint, white)
  } else if migration-stripe-mode == "source" {
    row => {
      if row.kind != "code" { return luma(250) }
      if calc.rem(row.source-line, 2) == 1 { migration-stripe-paint }
      else { white }
    }
  } else { migration-stripe-paint }
)
#show: codly.header-set_(fill: luma(220), inset: 4pt)

#codly.new(
  ```py
  def total(prices):
      subtotal = sum(prices)
      tax = subtotal * 0.2
      return subtotal + tax
  print(total([10, 20]))
  ```,
  header: if migration-fill-header { [Pricing example] } else { none },
  ranges: if migration-fill-excerpt { ((1, 2), (4, 5)) } else { none },
  smart-skip: true,
  number-enabled: migration-fill-numbers,
)
````

The number gutter follows each row's background by default. Set `codly.number-set_(fill: ...)` when you want an independent gutter paint.

See [`codly.line`](api/components/line.md).

:::

::: collapse Language definitions, icons, and badge settings {#migration-language-definitions}

**Move language presentation from the block configuration to `codly.lang`.** Existing dictionaries carry over, including definitions from `codly-languages`:

```typst
// Version 1
#codly(
  languages: (py: (name: [Python], color: blue, icon: "🐍")),
  display-name: true,
  display-icon: true,
  lang-radius: 4pt,
)

// Version 2
#show: codly.lang-set_(
  languages: (py: (name: [Python], color: blue, icon: "🐍")),
  display-name: true,
  display-icon: true,
  radius: 4pt,
)
```

The `lang-` prefix is gone: `inset`, `outset`, `radius`, `fill`, and `stroke` are set directly on `codly.lang`. `languages`, `default-color`, `display-name`, and `display-icon` stay on this setter; `aliases` stays on the block, since it selects the syntax-highlighting language rather than badge presentation.

Every definition must now have a `name`. For an old icon-only definition, add `name: []`. A plain string (`py: "Python"`) is still shorthand for a definition with that name, but unlike the 1.3 shortcut it respects `display-name: false`.

Badge `fill` and `stroke` callbacks still receive `(name: ..., icon: ..., color: ...)`, with the language color as base paint. One split to watch: in 1.3, `default-color` also colored uncolored **span highlights**. In 2.0, `codly.lang-set_(default-color: ...)` covers badges only; use `codly.highlight-set_(color: ...)` for highlights.

1.3.1 added automatic spacing between icon and name — remove any manual `h(0.2em)` left in older icon definitions.

```yaml widgets
- type: switch
  name: migration-badge-name
  label: Display the language name
  default: true
- type: switch
  name: migration-badge-icon
  label: Display the language icon
  default: true
- type: select
  name: migration-badge-color
  label: Language color
  default: 'rgb("3476a8")'
  options:
    - label: Blue
      value: 'rgb("3476a8")'
    - label: Green
      value: 'rgb("2a7f62")'
    - label: Purple
      value: 'rgb("7655a3")'
- type: slider
  name: migration-badge-radius
  label: Badge radius
  default: 4pt
  unit: pt
  min: 0
  max: 10
  step: 1
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.lang-set_(
  languages: (py: (name: [Python], color: migration-badge-color, icon: "🐍")),
  display-name: migration-badge-name,
  display-icon: migration-badge-icon,
  radius: migration-badge-radius,
  fill: lang => lang.color.lighten(85%),
  stroke: lang => 0.5pt + lang.color,
)

#codly.new(
  ```py
  def greet(name):
      return f"Hello, {name}!"
  print(greet("Ada"))
  ```,
)
````

Per-language definitions can now also override `display-name`, `display-icon`, `fill`, `stroke`, `inset`, and `radius` for their matching badge. `outset`, `align`, and `default-color` belong to the shared badge settings instead.

See [`codly.lang`](api/components/lang.md) and [`codly.language`](api/types/language.md).

:::

::: collapse Custom language formatters and the new show-rule callback {#migration-language-formatters}

**Replace `lang-format` with a show rule.** The old formatter received three positional values: the resolved display **name**, icon, and color — despite the old documentation's wording, the first was not always the raw language key, and the color was positional too.

Version 1:

```typst
#codly(lang-format: (name, icon, color) => {
  box(inset: 3pt, fill: color.lighten(85%), [#icon #name])
})
```

The 2.0 replacement is a show rule on `codly.lang`: its callback receives the generated language **element**, whose body is the raw key such as `"py"`. Read its effective settings with `codly.e.fields(it)` — always Codly's own `codly.e` export, so element identities match.

The example adapts an old three-argument formatter. Because the show rule replaces the built-in badge renderer, it must resolve the definition, display flags, and color fallback itself; the component's `fill`, `stroke`, `inset`, and `radius` no longer apply automatically.

```yaml widgets
- type: switch
  name: migration-custom-badge
  label: Use the custom formatter
  default: true
- type: switch
  name: migration-custom-name
  label: Display the name
  default: true
- type: switch
  name: migration-custom-icon
  label: Display the icon
  default: true
- type: slider
  name: migration-custom-inset
  label: Custom badge inset
  default: 3pt
  unit: pt
  min: 1
  max: 8
  step: 1
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.lang-set_(
  languages: (py: (name: [Python], icon: "🐍", color: rgb("3476a8"))),
  display-name: migration-custom-name,
  display-icon: migration-custom-icon,
)

#let old-formatter(name, icon, color) = {
  if name == [] and icon == [] { return [] }
  box(inset: migration-custom-inset, fill: color.lighten(85%),
    [#icon #strong(name)])
}

#show: codly.lang-show_(it => {
  if not migration-custom-badge { return it }
  let fields = codly.e.fields(it)
  let def = if fields.languages == none { (:) } else {
    fields.languages.at(fields.body, default: (:))
  }
  let name = if def.at("display-name", default: fields.display-name) {
    def.at("name", default: fields.body)
  } else { [] }
  let icon = if def.at("display-icon", default: fields.display-icon) {
    def.at("icon", default: [])
  } else { [] }
  old-formatter(
    name,
    if icon == none { [] } else { icon },
    def.at("color", default: fields.default-color),
  )
})

#codly.new(
  ```py
  message = "Hello, Ada!"
  print(message)
  ```,
)
````

For old `lang-format: none`, use `lang-position: none` on `codly.new` or `codly.set_` to disable badge placement; for `lang-format: auto`, remove the custom show rule. A formatter that wants the raw language key can use `fields.body` directly.

See [queries and show rules](api/queries-and-show-rules.md).

:::

::: collapse Filename badges and source-file input {#migration-filename-badges}

**Use the explicit `file` field.** Although the 1.3 signatures listed `filename` and `filename-separator`, they were never implemented. Treat filename display as new in 2.0.

```typst
#codly.new(source, file: "example.py")
```

Filename badges are their own `codly.file` component, styled with `codly.file-set_` independently of `codly.lang`. `file-position: top + left` puts the badge in a header, `bottom + left` in a footer, `left` beside the first code row, and `none` hides it. Explicit positions reserve space so the badge never overlaps code.

`codly.new(path("example.py"))` reads a file from disk, infers the language from its extension, and uses the basename as filename (`file: none` hides it, `lang` overrides inference). A string argument is source text, not a path to read. For an authored raw block, pass `file` explicitly, as below.

```yaml widgets
- type: select
  name: migration-file-placement
  label: Filename placement
  default: 'top + left'
  options:
    - label: Header left
      value: 'top + left'
    - label: Footer left
      value: 'bottom + left'
    - label: Beside the first line
      value: 'left'
    - label: Hidden
      value: 'none'
- type: select
  name: migration-file-fill
  label: Filename badge fill
  default: 'luma(240)'
  options:
    - label: Pale gray
      value: 'luma(240)'
    - label: Pale blue
      value: 'rgb("e2edff")'
    - label: Transparent
      value: 'none'
- type: slider
  name: migration-file-radius
  label: Filename badge radius
  default: 2pt
  unit: pt
  min: 0
  max: 8
  step: 1
- type: switch
  name: migration-file-language
  label: Display the language badge
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.file-set_(
  fill: migration-file-fill,
  radius: migration-file-radius,
  stroke: 0.5pt + luma(160),
)

#codly.new(
  ```py
  def greet(name):
      return f"Hello, {name}!"
  print(greet("Ada"))
  ```,
  file: "greeting.py",
  file-position: migration-file-placement,
  lang-position: if migration-file-language { auto } else { none },
)
````

There is no `filename-separator` field. For bespoke composition, put styled content in a header/footer body or replace `codly.file` through `codly.file-show_`.

See [`codly.file`](api/components/file.md) and [`codly.new`](api/components/new.md).

:::

::: collapse Headers, footers, repetition, and body transforms {#migration-headers-and-footers}

**Keep the content on the block and move its cell settings to the header/footer component.** Plain content still works: `codly.new(source, header: [Title], footer: [Note])`. Use `codly.header` and `codly.footer` for a local style, or their setters for defaults shared by all blocks in scope.

| Version 1 | Version 2 |
| --- | --- |
| `header-repeat: true` | `codly.header-set_(repeat: true)` or `codly.header(body, repeat: true)` |
| `footer-repeat: true` | The equivalent `codly.footer` setting |
| `header-cell-args: (align: ..., fill: ..., inset: ..., stroke: ...)` | Those fields directly on `codly.header` or its setter |
| `footer-cell-args: (...)` | Those fields directly on `codly.footer` or its setter |
| `header-transform: transform` | `codly.header-show_(it => transform(codly.e.fields(it).body))` |
| `footer-transform: transform` | The equivalent `codly.footer-show_` rule |

Version 1:

```typst
#codly(
  header: [Retry example],
  header-repeat: true,
  header-cell-args: (align: left, inset: 4pt),
  header-transform: body => strong(body),
  footer: [Network helper],
)
```

There is no `cell-args` escape hatch in 2.0: Codly manages cell spans and positions, so `x`, `y`, `rowspan`, `colspan`, and cell-level pagination settings have no equivalent. Use the component fields for appearance and the block's `breakable` field for pagination. If old code modified the grid topology, redesign that composition instead of copying the dictionary.

**The transform receives a different value.** The 1.3 transform took your authored body content; the 2.0 show rule receives an element — get the body via `codly.e.fields(it).body`. That body may include Codly's generated language or filename badges, which a whole-body transform will restyle too. To transform only your title, apply it before construction: `header: codly.header(transform([Title]))`. Header and footer fills are independent of row striping; `fill: auto` selects the component default (pale gray for a header, none for a footer).

```yaml widgets
- type: select
  name: migration-header-transform
  label: What receives bold styling
  default: '"title"'
  options:
    - label: Only the authored title
      value: '"title"'
    - label: The generated header body
      value: '"body"'
- type: select
  name: migration-header-fill
  label: Header fill
  default: 'rgb("e2edff")'
  options:
    - label: Pale blue
      value: 'rgb("e2edff")'
    - label: Pale green
      value: 'rgb("e5f5e9")'
    - label: No fill
      value: 'none'
- type: slider
  name: migration-header-inset
  label: Header inset
  default: 4pt
  unit: pt
  min: 1
  max: 8
  step: 1
- type: switch
  name: migration-header-repeat
  label: Repeat header on later pages
  default: true
- type: switch
  name: migration-footer-repeat
  label: Repeat footer on earlier pages
  default: true
- type: switch
  name: migration-footer-visible
  label: Include a footer
  default: true
- type: slider
  name: migration-page-height
  label: Page height
  default: 200pt
  unit: pt
  min: 140
  max: 260
  step: 20
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#set page(height: migration-page-height)
#set text(size: 9pt)

#show: codly.header-set_(
  repeat: migration-header-repeat,
  align: left + horizon,
  fill: migration-header-fill,
  inset: migration-header-inset,
)
#show: codly.footer-set_(
  repeat: migration-footer-repeat,
  align: left + horizon,
  inset: 3pt,
  fill: luma(250),
)

#show: codly.header-show_(it => {
  if migration-header-transform == "body" {
    strong(codly.e.fields(it).body)
  } else { it }
})

#let title = [Retry example]
#codly.new(
  ```py
  def fetch(url, attempts=3):
      for attempt in range(attempts):
          try:
              response = request(url)
          except ConnectionError:
              log("Connection failed")
              continue
          if response.ok:
              return response
          log("Will retry")
      raise RuntimeError("Retry limit reached")

  def main():
      response = fetch("/api/messages")
      print(response.text)

  if __name__ == "__main__":
      main()
  ```,
  header: codly.header(
    if migration-header-transform == "title" { strong(title) } else { title }
  ),
  footer: if migration-footer-visible { codly.footer([Network helper]) } else { none },
  file: "network.py",
)
````

Repetition only matters when a breakable block actually crosses a page boundary — the example uses a small page height to demonstrate. A repeated header appears on later pages; a repeated footer also appears on pages before the last. Keep the block breakable when porting a repeating layout.

See [`codly.header`](api/components/header.md), [`codly.footer`](api/components/footer.md), and [queries and show rules](api/queries-and-show-rules.md).

:::

::: collapse Select source ranges and collapse the gaps {#migration-ranges}

**Keep the source coordinates; move the selection onto the code element.** `range` selects one inclusive source-line interval, `ranges` several; source lines start at 1. `offset` changes the displayed numbers without changing which lines are selected.

```typst code
// 1.3.0 / 1.3.1: settings for the next raw block.
#codly(ranges: ((2, 3), (6, 7)), smart-skip: true)
```

Pass those values to `codly.new(...)`, or use `#show: codly.set_(...)` to share them within a scope. The removed `#codly-range(2, end: 4)` helper becomes `range: (2, 4)`. Tuples still cast to `codly.range`, so the explicit constructor is optional:

```typst code
// Equivalent selections in 2.0:
ranges: ((2, 3), (6, 7))
ranges: (codly.range(2, 3), codly.range(6, 7))
// Open-ended selection:
range: codly.range(3) // source line 3 through the end
```

**Use either `range` or `ranges`, not both.** 1.3 let `ranges` win when both were present; 2.0 rejects the combination, including a value inherited from an outer scope. A single tuple `(2, 3)` belongs in `range`; `ranges` takes an array such as `((2, 3),)`.

`smart-skip` is still a boolean or a dictionary. `true` marks every omitted region; `(rest: true, first: false, last: false)` marks only the gaps between selections, with `first` and `last` inheriting `rest` (default `false`) when omitted. Automatic skip rows mark omitted source lines but add no numbering shift beyond the missing lines themselves.

```yaml widgets
- type: select
  name: migration-ranges
  label: Source selection
  default: '((2, 3), (6, 7))'
  options:
    - label: Two intervals
      value: '((2, 3), (6, 7))'
    - label: Middle interval
      value: '((3, 6),)'
    - label: All source lines
      value: none
- type: switch
  name: migration-gap-first
  label: Mark the leading gap
  default: false
- type: switch
  name: migration-gap-middle
  label: Mark middle gaps
  default: true
- type: switch
  name: migration-gap-last
  label: Mark the trailing gap
  default: false
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  def process(records):
      load(records)
      validate(records)
      normalize(records)
      sort(records)
      save(records)
      report(records)
  process(records)
  ```,
  ranges: migration-ranges,
  smart-skip: (
    first: migration-gap-first,
    rest: migration-gap-middle,
    last: migration-gap-last,
  ),
)
````

See [range](api/types/range.md) and [smart-skip](api/types/smart-skip.md).

:::

::: collapse Port explicit skips without moving their insertion point {#migration-explicit-skips}

**Keep each existing `(position, length)` pair unchanged.** The old `#codly-skip(position, length)` helper appended a skip to the next block's state. In 2.0, supply that record in `skips`, optionally using `codly.skip(position, length)`.

```typst code
// 1.3.0 / 1.3.1:
#codly-skip(2, 8)
// Or: #codly(skips: ((2, 8),))
```

```typst code
// 2.0, inside codly.new(...):
skips: (codly.skip(2, 8),)
// Equivalent: skips: ((2, 8),)
```

The insertion point is the source line **before which** the gap row appears: position `2` puts the skip before source line 2, in both 1.3 and 2.0. Older descriptions of these positions as zero-indexed did not match the renderer — keep your working positions unchanged.

An explicit skip represents lines **already absent from the source**. Its `length` shifts subsequent displayed numbers but removes nothing: three source lines with `skips: ((2, 8),)` display as `1`, a skip marker, `10`, `11`. To hide lines that are still in the source, use `range`/`ranges` with `smart-skip` instead.

`skip-line` and `skip-number` still set the code and number cells of the gap row, and existing content values port directly. In 2.0, an array supplies different content for successive explicit skips; automatic gaps use the fallback marker. Keep the number column enabled to see `skip-number`.

```yaml widgets
- type: slider
  name: migration-skip-position
  label: Insert before source line
  default: '2'
  min: 1
  max: 3
  step: 1
- type: slider
  name: migration-skip-length
  label: Omitted line count
  default: '8'
  min: 1
  max: 20
  step: 1
- type: switch
  name: migration-skip-custom
  label: Explain the gap in its row
  default: true
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  prepare()
  process()
  finish()
  ```,
  skips: (codly.skip(migration-skip-position, migration-skip-length),),
  skip-line: if migration-skip-custom {
    align(center)[… #migration-skip-length omitted lines …]
  } else { [⋯] },
  skip-number: [⋯],
)
````

See [skip](api/types/skip.md).

:::

::: collapse Replace offset-from with the unified offset field {#migration-offset}

**`offset` now takes a number, `auto`, or a label.** The numeric form keeps its old meaning: add that number to the displayed line numbers. `#codly-offset(offset: 20)` becomes a field on `codly.new(...)` or a scoped `#show: codly.set_(offset: 20)`.

```typst code
// 1.3.0 / 1.3.1:
#codly(offset: 20)
// Continue another block:
#codly(offset-from: <first-part>)
// Continue it with an additional shift:
#codly(offset-from: <first-part>, offset: 3)
```

```typst code
// 2.0, inside codly.new(...):
offset: 20
offset: <first-part>
// Or start the first selected source line at 1:
offset: auto
```

For continuation, label the previous block (or its enclosing figure): `offset: <first-part>` continues from that block's **last displayed number**, accounting for its own offsets, selections, explicit skips, and unnumbered lines. Because the offset is relative to the predecessor, an excerpt beginning at source line 2 starts two above the predecessor's last number; to continue seamlessly, subtract `first-source-line - 1` from `codly.info(<first-part>).last-number` in context. An empty predecessor contributes zero. Never make two blocks continue each other.

If the old document combines `offset-from` with an additional numeric shift, resolve that number explicitly in context:

````typst
#context {
  let info = codly.info(<first-part>)
  let last = if info.last-number == none { 0 } else { info.last-number }
  codly.new(
    ```
    next line
    ```,
    offset: last + 3,
  )
}
````

`offset: auto` starts an excerpt at 1. It anchors to the first selected source line that exists and keeps the gaps between disjoint intervals — it does not compress separate excerpts into a consecutive sequence.

Offsets affect displayed numbers, line-reference labels, and highlight `line` coordinates. Source-indexed constructs — ranges, annotation intervals, callouts, gutter arrays — keep their source coordinates. A scoped offset now applies to every matching block in the scope; it is no longer a next-block value that resets after rendering.

```yaml widgets
- type: select
  name: migration-offset-mode
  label: Second block numbering
  default: '<first-part>'
  options:
    - label: Continue the first block
      value: '<first-part>'
    - label: Preserve source numbers
      value: '0'
    - label: Start the excerpt at one
      value: auto
    - label: Add ten
      value: '10'
- type: switch
  name: migration-offset-excerpt
  label: Show only source lines two and three
  default: true
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  prepare()
  load()
  ```,
)<first-part>

#codly.new(
  ```py
  validate()
  process()
  finish()
  ```,
  range: if migration-offset-excerpt { (2, 3) } else { none },
  offset: migration-offset-mode,
)
````

See [`codly.new`](api/components/new.md) and [`codly.info`](api/helpers/info.md).

:::

::: collapse Separate number styling from number visibility {#migration-numbers}

**Move number formatting onto `codly.number`; use `number-enabled` to hide the column.** In 1.3, `number-format: none` disabled line numbers. In 2.0, `codly.number`'s `numbering` accepts a native numbering pattern or callback, while the block's `number-enabled` field controls whether Codly generates its automatic number gutter.

```typst code
// 1.3.0 / 1.3.1:
#codly(
  number-format: numbering.with("I."),
  number-align: right + horizon,
  number-placement: "outside",
)
// To hide numbers: #codly(number-format: none)
```

```typst code
// 2.0:
#show: codly.number-set_(
  numbering: "I.",
  align: right + horizon,
  placement: "outside",
)
// For one block: codly.new(..., number-enabled: false)
```

Callbacks still receive the numeric value, so `(n) => [L#n]` ports directly as `numbering: (n) => [L#n]`. Do not confuse this with `number-show_`, whose callback receives the generated element — read its integer with `codly.e.fields(it).number`. Use a set rule for formatting and a show rule to replace the rendered number element.

`placement` still accepts `"inside"` and `"outside"`; outside placement moves custom gutter columns along with the automatic number column. `number-enabled: false` removes only the automatic column — independent custom gutters remain.

**Leaving individual lines unnumbered is new in 2.0**, not a renamed 1.3 argument. `unnumbered: (2,)` skips numbering for source line 2 while keeping subsequent numbers contiguous; `codly.unnumbered-line(2, [→])` supplies custom content for that cell. Unnumbered lines use the special reference labels covered in [references](#migration-references).

```yaml widgets
- type: select
  name: migration-number-format
  label: Number format
  default: '"1"'
  options:
    - label: Decimal
      value: '"1"'
    - label: Roman
      value: '"I."'
    - label: Custom callback
      value: '(n) => [L#n]'
- type: switch
  name: migration-number-enabled
  label: Generate the number column
  default: true
- type: switch
  name: migration-number-outside
  label: Put gutters outside
  default: false
- type: switch
  name: migration-number-unnumbered
  label: Leave the comment unnumbered
  default: false
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.number-set_(
  numbering: migration-number-format,
  align: right + horizon,
  placement: if migration-number-outside { "outside" } else { "inside" },
)

#codly.new(
  ```py
  prepare()
  # Explain the next step.
  process()
  finish()
  ```,
  number-enabled: migration-number-enabled,
  unnumbered: if migration-number-unnumbered { (2,) } else { () },
)
````

See [number](api/components/number.md) and [unnumbered-line](api/types/unnumbered-line.md).

:::

::: collapse Rename whole-line highlights and preserve their colors {#migration-whole-line-highlights}

**Rename `highlighted-lines` to `highlighted`.** Existing integer entries and `(line, paint)` pairs still work through casts to `codly.highlighted-line`. These are different from the character spans in `highlights`, whose field name is unchanged.

```typst code
// 1.3.0 / 1.3.1:
#codly(
  highlighted-lines: (2, (4, green.lighten(80%))),
  highlighted-default-color: yellow.lighten(80%),
)
```

```typst code
// 2.0:
#show: codly.highlight-set_(color: yellow, fill: color => color.lighten(80%))
// Inside codly.new(...):
highlighted: (2, (4, green.lighten(80%)))
// Equivalent explicit entries:
highlighted: (
  codly.highlighted-line(2),
  codly.highlighted-line(4, green.lighten(80%)),
)
```

`highlighted-default-color` becomes the `color` and `fill` settings of `codly.highlight`: `color` chooses the base paint and the `fill` callback derives the row background from it. To keep an already-computed paint exactly, pass it in each highlighted-line entry, or use `fill: color => color` with that paint as `color`.

**The line coordinate is the displayed number, in both 1.3 and 2.0.** If an offset shows source line 2 as number 12, target `12`. Explicit skips and unnumbered lines shift the mapping, and a source line with no displayed number cannot be targeted by `highlighted` at all — use row styling or a custom gutter there.

A palette array cycles through entries that lack an explicit paint; explicit paints do not advance the cycle. Whole-line and span highlights have separate cycles per block but share the configured palette. 1.3 kept `highlighted-default-color` (rows) and `default-color` (spans) independent — to preserve different colors, pin row paints explicitly in `highlighted` and set span defaults with `highlight-set_`.

```yaml widgets
- type: slider
  name: migration-whole-offset
  label: Displayed numbering offset
  default: '0'
  min: 0
  max: 20
  step: 10
- type: select
  name: migration-whole-palette
  label: Default highlight palette
  default: '(yellow, blue)'
  options:
    - label: Yellow and blue
      value: '(yellow, blue)'
    - label: Orange and green
      value: '(orange, green)'
- type: switch
  name: migration-whole-explicit
  label: Give line four an explicit green fill
  default: true
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.highlight-set_(
  color: migration-whole-palette,
  fill: color => color.lighten(80%),
)

#codly.new(
  ```py
  prepare()
  validate()
  process()
  finish()
  ```,
  offset: migration-whole-offset,
  highlighted: (
    2 + migration-whole-offset,
    if migration-whole-explicit {
      (4 + migration-whole-offset, green.lighten(80%))
    } else { 4 + migration-whole-offset },
  ),
)
````

See [highlighted-line](api/types/highlighted-line.md) and [highlight](api/components/highlight.md).

:::

::: collapse Port character highlights, including 1.3.1 local overrides {#migration-span-highlights}

**Keep `highlights` and its dictionaries; move shared styling onto `codly.highlight`.** Character coordinates still start at zero, and `end` remains exclusive. Omitted or `none` `start` means the beginning of the line; omitted or `none` `end` means its end. The `line` coordinate uses displayed numbering, including offsets and explicit skips, in both versions.

```typst code
// 1.3.0 / 1.3.1:
#codly(
  highlight-radius: 3pt,
  highlight-inset: 1pt,
  highlight-fill: color => color.lighten(80%),
  highlights: ((line: 2, start: 11, end: 14, fill: orange),),
)
```

```typst code
// 2.0:
#show: codly.highlight-set_(
  radius: 3pt,
  inset: 1pt,
  fill: color => color.lighten(80%),
)
// Inside codly.new(...):
highlights: (codly.highlight-config(2, start: 11, end: 14, fill: orange),)
```

`highlight-stroke`, `highlight-outset`, and `highlight-clip` move the same way: drop the prefix and pass them to `highlight-set_`. Note the two roles of `fill`: a span entry's `fill` picks its base paint, while the component's `fill` callback transforms that paint into the box background.

**1.3.1's local overrides carry over.** Per-highlight `inset`, `baseline`, `outset`, `clip`, and `radius` — and the nested-highlight fixes — still override component defaults in 2.0, which additionally allows per-span `stroke` and a `depth` field to control stacking order. On 1.3.0 these local overrides did not work; port the shared settings first, then add exceptions.

One default changed: `baseline` used to derive from the bottom highlight inset; it now defaults to `0pt` (`auto` follows the content baseline). Set it explicitly if you relied on the old positioning. Bounds must stay nonnegative and `end` must follow `start`.

```yaml widgets
- type: slider
  name: migration-span-offset
  label: Displayed numbering offset
  default: '0'
  min: 0
  max: 20
  step: 10
- type: switch
  name: migration-span-nested
  label: Add a surrounding highlight
  default: true
- type: switch
  name: migration-span-local
  label: Override the inner span radius
  default: true
- type: slider
  name: migration-span-radius
  label: Inner span corner radius
  default: 3pt
  unit: pt
  min: 0
  max: 6
  step: 1
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.highlight-set_(radius: 0pt, inset: 1pt)

#codly.new(
  ```py
  def clamp(value):
      return max(0, min(value, 100))
  ```,
  offset: migration-span-offset,
  highlights: (
    ..if migration-span-nested {
      ((line: 2 + migration-span-offset, start: 4, fill: blue),)
    } else { () },
    (
      line: 2 + migration-span-offset,
      start: 11,
      end: 14,
      fill: orange,
      radius: if migration-span-local { migration-span-radius } else { none },
    ),
  ),
)
````

See [highlight-config](api/types/highlight-config.md) and [highlight](api/components/highlight.md).

:::

::: collapse Port annotation ranges and their numbering {#migration-annotations}

**Keep the source-line ranges and attach numbering to the annotation configuration.** `annotations` remains an array of dictionaries with `start`, optional `end`, optional `content`, and optional `label`. Dictionaries cast to `codly.annotation-config`, so you can port them before adopting the explicit constructor.

```typst code
// 1.3.0 / 1.3.1:
#codly(
  annotation-format: numbering.with("(a)"),
  annotations: ((start: 2, end: 4, content: [body]),),
)
```

```typst code
// 2.0, inside codly.new(...):
annotations: ((
  start: 2, end: 4, content: [body],
  numbering: numbering.with("(a)"),
),)
// Or: codly.annotation-config(2, end: 4, content: [body],
//   numbering: numbering.with("(a)"))
```

The global `annotation-format` field is gone; set `numbering` on each annotation, repeating the same callback for a shared format. `numbering: none` hides the number but keeps the content and brace. `end: none` still means a one-line annotation, not “through the end”.

Both endpoints are **one-indexed source lines**, and `end` is inclusive; offsets change displayed numbers without moving the brace. Ranges must be positive, ordered, and non-overlapping. When selecting excerpts, include the annotation's starting line — an annotation that starts outside the excerpt is dropped, not re-anchored at the excerpt boundary.

`content` is ordinary Typst content; rotated labels still work. 2.0 sizes braces from the measured rows, including wrapped code, so re-check the output after changing width or pagination. A labelled annotation still needs a labelled enclosing figure, as shown in [references](#migration-references).

To replace the brace entirely, use `annotation-show_`: read `body`, `height`, `num`, `numbering`, and the hidden `label` content with `codly.e.fields(it)`, and keep that resolved `label` content in your replacement so references keep their anchor.

```yaml widgets
- type: slider
  name: migration-annotation-start
  label: First source line
  default: '2'
  min: 1
  max: 3
  step: 1
- type: slider
  name: migration-annotation-end
  label: Last source line
  default: '4'
  min: 3
  max: 4
  step: 1
- type: switch
  name: migration-annotation-number
  label: Show the annotation number
  default: true
- type: switch
  name: migration-annotation-rotate
  label: Rotate its text
  default: true
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  def process():
      load()
      compute()
      save()
  process()
  ```,
  annotations: ((
    start: migration-annotation-start,
    end: migration-annotation-end,
    content: if migration-annotation-rotate {
      rotate(-90deg, reflow: true)[body]
    } else { [body] },
    numbering: if migration-annotation-number {
      numbering.with("(a)")
    } else { none },
  ),),
)
````

See [annotation-config](api/types/annotation-config.md) and [annotation](api/components/annotation.md).

:::

::: collapse Keep native references and move their formatting rules {#migration-references}

**Your existing `@block:2`, `@highlight-label`, and `@annotation-label` references can stay.** Keep a label on the enclosing figure; `codly.new` discovers it automatically, so you do not need to repeat it as `block-label`. Item labels still belong on their highlight or annotation configuration.

```typst code
// 1.3.0 / 1.3.1:
#codly(
  reference-by: "item",
  reference-sep: " — ",
  reference-number-format: numbering.with("I"),
)
```

```typst code
// 2.0:
#show: codly.ref-set_(
  by: "item",
  sep: " — ",
  numbering: numbering.with("I"),
)
```

Line labels are built from the **displayed integer**, before the visual numbering pattern: a block with Roman numbering still uses `@block:2`, not `@block:II`. If an offset shows source line 2 as number 12, the label becomes `@block:12` — keep references and highlight coordinates consistent with that mapping.

`by: "line"` refers to highlights and annotations by displayed line; `by: "item"` uses a highlight's `tag`, which must exist. **Annotation item references changed: they now use the annotation's `content` instead of its formatted number.** If you relied on a suffix like `(a)`, switch to displayed-line references or override the generated `codly.annotation-ref`:

```typst code
#show: codly.annotation-ref-show_(it => {
  let fields = codly.e.fields(it)
  [#ref(fields.block) — (a)]
})
```

Hiding the annotation number does not hide its item content.

For unnumbered source lines, use labels such as `@block:l2p1`: `l2` is the preceding displayed number and `p1` counts consecutive unnumbered lines after it. Numbered lines keep the normal `@block:2` form.

Each reference kind is now its own generated element — `codly.line-ref`, `codly.highlight-ref`, and `codly.annotation-ref` — with its own `*-set_` and `*-show_` wrappers; `ref-set_` supplies the shared defaults. In a show callback, read the containing `block` label and the number/item fields with `codly.e.fields(it)`, and return `ref(fields.block)` to keep the figure reference's normal formatting.

```yaml widgets
- type: select
  name: migration-ref-mode
  label: Highlight and annotation references
  default: '"line"'
  options:
    - label: Displayed line number
      value: '"line"'
    - label: Item tag or content
      value: '"item"'
- type: select
  name: migration-ref-separator
  label: Reference separator
  default: '" — "'
  options:
    - label: Dash
      value: '" — "'
    - label: Colon
      value: '":"'
    - label: Line wording
      value: '" line "'
- type: select
  name: migration-ref-numbering
  label: Reference number format
  default: 'numbering.with("1")'
  options:
    - label: Decimal
      value: 'numbering.with("1")'
    - label: Roman
      value: 'numbering.with("I")'
    - label: Figure reference only
      value: none
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.ref-set_(
  by: migration-ref-mode,
  sep: migration-ref-separator,
  numbering: migration-ref-numbering,
)

#figure(caption: [A migrated code block])[
  #codly.new(
    ```py
    def process():
        result = compute()
        return result
    ```,
    highlights: ((
      line: 2,
      start: 4,
      end: 10,
      tag: [value],
      label: <migration-value>,
    ),),
    annotations: ((
      start: 2,
      end: 3,
      content: [body],
      label: <migration-body>,
    ),),
  )
]<migration-code>

Line: @migration-code:2. \
Highlight: @migration-value. \
Annotation: @migration-body.
````

See [reference settings](api/components/ref.md), [line-ref](api/components/line-ref.md), [highlight-ref](api/components/highlight-ref.md), and [annotation-ref](api/components/annotation-ref.md).

:::

::: collapse Port lazy settings, custom show rules, and queries {#custom-rules-and-queries}

Many 1.3 settings accepted a zero-argument function as a lazy value, e.g. `#codly(radius: () => chosen-radius)`. In 2.0, each field declares its accepted types: a radius takes a length, so pass `chosen-radius` directly. Genuine callbacks keep their documented contracts — a number formatter receives a number, a highlight paint transformer a resolved paint, a row-fill callback a row dictionary. Do not mechanically rewrite every old function-valued setting.

To decorate or replace a generated element, install a `*-show_` callback. It receives an Elembic element; read its resolved fields with **`codly.e.fields(it)`**, always using Codly's own `codly.e` export so element identities match. The rule below decorates one number while keeping the normal renderer:

```yaml widgets
- type: slider
  name: custom-number
  label: Decorated number
  default: 2
  min: 1
  max: 3
  step: 1
- type: select
  name: custom-accent
  label: Decoration color
  default: purple
  options:
    - label: Purple
      value: purple
    - label: Red
      value: red
    - label: Teal
      value: teal
- type: switch
  name: custom-bold
  label: Bold decoration
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.number-show_(it => {
  let fields = codly.e.fields(it)
  if fields.number == custom-number {
    text(
      fill: custom-accent,
      weight: if custom-bold { "bold" } else { "regular" },
      it,
    )
  } else { it }
})

#codly.new(
  ```py
  data = load()
  result = compute(data)
  save(result)
  ```,
)

#context {
  let blocks = codly.e.query(codly.new, before: here())
  [Blocks before this paragraph: #blocks.len().]
}
````

Returning `it` (possibly wrapped) keeps the built-in renderer, including its formatting and anchors; returning fresh content replaces it. Constructing the same component inside its own show rule re-triggers the rule.

Scripts that inspected `state("codly-...")`, internal figures, or nested `.body.children` relied on 1.3 implementation details and must be rewritten. Use `codly.e.query` for element instances, `codly.e.fields` for fields, `codly.e.get` for scoped defaults, and [`codly.info`](api/helpers/info.md) for a labelled block's source-line count and last displayed number. Query inside `context`, and never make an element's existence depend on a query that counts that same element.

Native selectors such as `codly.selector()` work in show rules, but their default representation layers can match intermediate renderings, so they are not interchangeable with `codly.e.query` for counting instances. Constrain introspection to the elements and locations you need.

Continue with [queries and show rules](api/queries-and-show-rules.md) for filtering and replacement examples, or [internals](api/internals.md) for the rendering stages.

:::