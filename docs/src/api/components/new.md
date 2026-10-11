# `codly.new`

Creates a formatted code block. [`codly.new`](#signature) is an alias of [`codly.codly`](#signature); [`codly.set_`](#behavior), [`codly.show_`](#behavior), and [`codly.selector`](#behavior) target the same element.

## Signature

```typst code
codly.new(body, ..fields)
```

`body` is positional and required. It accepts source text, a path, or content containing raw blocks. Other fields are named. The setters accept named field values; `show_` installs a scoped replacement callback, and `selector` creates a Typst selector for block instances.

## Fields

{{#arg-table elements.new}}

## Behavior

> [!TIP] Figure labels are discovered automatically.
> Label the enclosing figure once. Codly discovers that label automatically,
> so omit the `block-label` argument from `codly.new`.

> [!WARNING] Unlabeled inner figures stop discovery.
> A code block inside an unlabeled nested figure does not inherit an outer
> figure's label. Label the inner figure to enable references to its code.

> [!WARNING] Sublanguages cost performance.
> Each sublang block requires re-parsing and introspection; heavy use slows compilation.

Fields are validated and cast by their declared types. Gutter arrays and functions cast to `gutter-column`; `gutters: auto` includes the ordinary number column when enabled, and custom columns remain when `number-enabled` is false. Custom gutters replace diff's automatic old/new/marker columns. Diff colors may be paints, `none`, `auto` (the ordinary row fill), or callbacks receiving a row with diff information. Explicit highlights take precedence over diff backgrounds.

Ranges select source lines before display. Diff references count displayed patch rows; highlight and callout character positions count code characters without diff markers. Diff context uses new-side syntax, and each hunk or file is highlighted independently.

`#show: codly.set_(..fields)` sets named field defaults in scope. `#show: codly.show_(it => content)` replaces matching blocks with the callback result; return `it` inside the result to retain the block. `#show codly.selector(): it => content` uses a native Typst selector. `selector` accepts `outline`, `outer`, and `meta` boolean options, all defaulting to `false`; these select Elembic representation layers rather than filtering fields.

## Example

```yaml widgets
- type: select
  name: example-language
  label: Language
  default: '"python"'
  options:
    - label: Python
      value: '"python"'
    - label: Rust
      value: '"rust"'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#set raw(lang: example-language)

#codly.new(
  ```
  def greet(name):
      print(f'Hello, {name}!')
  ```,
  file: "greeting.py",
  offset: 10,
)
````

## Example: Automatic Code Blocks

````typst preview
#import "@preview/codly:2.0.0" as codly

#show raw.where(block: true): codly.new

```py
def greet(name):
    print(f'Hello, {name}!')
```
````

## Example: Listing Figures

Wrap a block in a native `figure` to give it a caption and listing number. Codly's raw, string, and path inputs infer `kind: raw`, so the same selector styles captions and builds a listings outline.

> [!TIP] One label for the listing and its lines.
> Label the figure and reference it with `@load-config`. Codly discovers that
> label automatically and creates line references such as `@load-config:2`.

````typst preview fixed
#import "@preview/codly:2.0.0" as codly

#show figure.where(kind: raw): set figure.caption(position: top)

#figure(
  codly.new(
    ```py
    def load_config(path):
        with open(path) as source:
            return source.read()
    ```,
  ),
  caption: [Read the configuration file.],
)<load-config>

@load-config opens the file on @load-config:2.

#outline(target: figure.where(kind: raw), title: [Listings])
````

## Example: Scoped Styling

Use a content block to apply a style to a group of examples. The block setter changes shared block defaults; the line setter changes row appearance. After the closing `]`, subsequent code blocks use the outer defaults again.

````typst preview fixed
#import "@preview/codly:2.0.0" as codly

#[
  #show: codly.set_(radius: 8pt)
  #show: codly.line-set_(
    fill: rgb("#eef5ff"),
    stroke: 0.6pt + rgb("#bdd5ef"),
  )

  #codly.new(
    ```py
    timeout = 30
    retries = 3
    ```,
    file: "settings.py",
  )
]

#codly.new(
  ```py
  connect(timeout=timeout)
  ```,
  file: "client.py",
)
````

## Example: Source Excerpts

Select an inclusive range of source lines without rewriting the code. This example displays source lines 2 through 4, with a filename badge and numbering starting at 1.

> [!NOTE] Selection and displayed numbering are separate.
> [`range`](../types/range.md) always uses the original source line numbers.
> `offset: auto` starts the excerpt at 1; omit it to display 2, 3, and 4 instead.
> Use a label as the offset to [continue another block](../helpers/info.md#example-continue-a-listing).

````typst preview
#import "@preview/codly:2.0.0" as codly

#let source = ```py
import json
def read_settings(path):
    with open(path) as file:
        return json.load(file)
print(read_settings('settings.json'))
```

#codly.new(
  source,
  file: "settings.py",
  range: (2, 4),
  offset: auto,
)
````
