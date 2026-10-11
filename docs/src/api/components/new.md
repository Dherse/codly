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