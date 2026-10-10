# `codly.define-theme`

Build a reusable theme dictionary by inheriting a built-in preset or another theme, then applying named token and element-setting overrides.

## Signature

```typst code
codly.define-theme(base: "thesis", ..overrides)
```

`base` is named and defaults to `"thesis"`; overrides are named arguments. Positional arguments are not accepted.

## Parameters

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `base` | `str` or `dictionary` | `"thesis"` | A preset name or an existing theme dictionary. The built-in names are `thesis`, `dark`, `clean`, `github-light`, `solarized-light`, and `one-light`. |
| `foreground` | `paint` or `auto` | inherited | Text color for code; `auto` follows the surrounding text. |
| `muted` | `paint` or `auto` | inherited | Muted text color, including line numbers; `auto` follows the resolved foreground. |
| `fill` | `auto`, `paint` or `none`, array of paints or `none`, or function | inherited | Source-line fill. An array cycles by displayed row; a function receives a row dictionary with `index`, `kind`, `source-line`, and `number`. |
| `accent` | `paint` | inherited | Main accent, including the language badge's default color and (unless explicitly overridden) the first highlight color. |
| `stroke` | `stroke` | inherited | Default outline for code elements. |
| `radius` | `length` | inherited | Default corner radius. |
| `inset` | `length` or `dictionary` | inherited | Default code-line inset. |
| `header-fill`, `footer-fill`, `bubble-fill` | `paint` or `none` | inherited | Backgrounds for the header, footer, and callout bubbles. |
| `syntax` | `auto`, `str`, `path`, or `bytes` | inherited | TextMate plist theme for raw-code syntax highlighting. |
| `highlight-fill` | `function` | inherited | Callback receiving a highlight color and returning its fill. |
| `highlight-colors` | `paint` or nonempty array of paints | inherited | Default highlight color, or a palette cycled by highlights. |
| `language-colors` | `bool` | inherited | Whether language badges use their language-specific colors. |
| `block`, `line`, `number`, `lang`, `file`, `header`, `footer`, `highlight`, `callout`, `bubble`, `annotation` | `dictionary` | inherited | Overrides settable fields on the corresponding Codly element. The `text` entry in a section is a dictionary of native Typst text settings. |

All defaults are inherited from the selected base. Token names and section names are the complete supported top-level keys. Within a section, use fields supported by the corresponding Codly element. The `fill` callback's row dictionary uses a zero-based displayed-row `index`; `kind` is `code`, `skip`, or `callout`, while `source-line` and `number` are `none` for generated rows or numbers that are not displayed.

## Behavior

> [!NOTE] Accent also updates the first highlight color.
> If you override `accent` without supplying `highlight-colors`, the new accent replaces the first inherited highlight color. An explicit palette takes precedence.

> [!WARNING] Highlight palettes cannot be empty.
> Passing `highlight-colors: ()` causes a compilation error.

The result is a complete dictionary, not a show rule. It starts with the `thesis` defaults, merges a preset or dictionary base, then merges the named overrides. Section dictionaries merge one level deep, so separate fields such as `header: (fill: red)` and `header: (align: left)` can be combined when deriving a theme. Values inside those fields, including callbacks and nested dictionaries, are replaced as complete values.

An unknown preset or top-level key raises an error. Every section override must be a dictionary.

Pass the returned dictionary to [`codly.theme`](../helpers/theme.md) to render with it. Theme rules are scoped: explicit element fields and later local set rules can override theme values. Section `text` settings are applied as text settings to text within that element.

## Example: Basic Usage

```yaml widgets
- type: select
  name: accent
  label: Accent
  default: 'rgb("ef6c00")'
  options:
    - label: Orange
      value: 'rgb("ef6c00")'
    - label: Blue
      value: 'rgb("1565c0")'
    - label: Green
      value: 'rgb("2e7d32")'
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#let custom = codly.define-theme(
  base: "thesis",
  accent: accent,
  header: (fill: accent.lighten(80%), align: left),
)
#show: codly.theme(custom)

#codly.new(
  ```py
  return answer
  ```,
  header: [Custom theme],
  highlights: ((line: 1),),
)
````
