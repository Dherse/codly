# `codly.file`

Creates the filename badge used beside a code block or in its header or footer.

## Signature

```typst code
// Create a filename badge
codly.file(
  body: str | content,
  fill: paint | none = luma(240),
  stroke: stroke | none = 0.5pt + luma(160),
  inset: length | dictionary = (x: 0.4em, y: 0.2em),
  radius: length | dictionary = 2pt,
)

// Equivalent set-rule for `codly.file`
codly.file-set_(..args)

// Equivalent show rule for `codly.file`
codly.file-show_(it => ...)
```

`body` is required and may be supplied positionally; it is the displayed filename or filename content. The remaining fields are named. [`codly.new`](new.md) documents how code blocks derive and place this badge.

[`codly.file-set_(..args)`](#signature) sets badge defaults in scope; [`codly.file-show_(it => ...)`](#signature) replaces each rendered badge with the callback's result.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `body` | `str \| content` | Required, positional | Displayed filename. |
| `fill` | `paint \| none` | `luma(240)` | Badge background; `none` removes the fill. |
| `stroke` | `stroke \| none` | `0.5pt + luma(160)` | Badge border; `none` removes the border. |
| `inset` | `length \| dictionary` | `(x: 0.4em, y: 0.2em)` | Inner padding around the filename. A length applies uniformly; a dictionary can set axes independently. |
| `radius` | `length \| dictionary` | `2pt` | Corner radius. A length applies uniformly; a dictionary can set corners individually. |

## Behavior

> [!TIP] Pass a path to `codly.new`
> When the code input is a path, [`codly.new`](new.md) reads the file, derives the badge text from its basename, and uses its extension as the language when `lang` is omitted. Set `file` or `lang` explicitly to override those defaults.

The badge is a box using `fill`, `stroke`, `inset`, and `radius` around `body`; `inset` and `radius` accept either one length or a dictionary.

## Example

```yaml widgets
- type: slider
  name: example-radius
  label: Corner radius
  default: 4pt
  unit: pt
  min: 0
  max: 12
  step: 1
- type: select
  name: fill
  label: Badge fill
  default: 'rgb("#d8eaff")'
  options:
    - label: Pale blue
      value: 'rgb("#d8eaff")'
    - label: Pale green
      value: 'rgb("#d9f5df")'
    - label: No fill
      value: 'none'
```

```typst preview
#import "@preview/codly:2.0.0" as codly

#codly.file("src/main.typ", radius: example-radius, fill: fill)
```
