# `codly.header`

Creates a configurable header element for a Codly code block.

## Signature

```typst code
// Create a header element
codly.header(
  body,
  repeat: false,
  align: center + horizon,
  inset: auto,
  fill: luma(240),
  stroke: auto
)

// Equivalent set-rule for `codly.header`
codly.header-set_(..fields)

// Equivalent show rule for `codly.header`
codly.header-show_(it => ...)
```

`body` is required and positional; all other fields are named.

## Fields

| Field | Type | Default / required | Meaning |
| --- | --- | --- | --- |
| `body` | `content` \| `none` | Required, positional | Content displayed in the header. |
| `repeat` | `bool` \| `none` | `false` | Repeat the header on later pages when the block breaks across pages. |
| `align` | `alignment` \| `none` | `center + horizon` | Alignment of the header content in its cell. |
| `inset` | `length` \| `dictionary` \| `auto` \| `none` | `auto` | Space around the header content; `auto` leaves the grid-cell default in effect. |
| `fill` | `paint` \| `auto` \| `none` | `luma(240)` | Header cell background. `none` leaves it unfilled; `auto` uses the default header fill. |
| `stroke` | `stroke` \| `auto` \| `none` | `auto` | Stroke around the header cell; `auto` leaves the grid-cell default in effect. |

## Behavior

> [!TIP] Put the filename badge in the header
> `codly.new` places its file badge in the header by default. Supplying a custom header body keeps the badge alongside that body; style the badge separately with [`codly.file-set_(...)`](file.md).

When used by [`codly.new`](new.md), the header cell spans the code block's columns. `repeat` controls the underlying grid header's repetition. Setting `fill` to `auto` resolves to `luma(240)`; the header fill is independent of line and number fills. The block's outer corner radius is configured on [`codly.new`](new.md), not on the header element.

[`codly.header-set_(..fields)`](#signature) sets defaults for headers in scope; [`codly.header-show_(replacement)`](#signature) installs a scoped replacement, whose callback receives the header element as `it`.

## Example

```yaml widgets
- type: select
  name: example-fill
  label: Header fill
  default: 'rgb("#d8eaff")'
  options:
    - label: Pale blue
      value: 'rgb("#d8eaff")'
    - label: Pale green
      value: 'rgb("#d9f5df")'
    - label: No fill
      value: 'none'
- type: slider
  name: example-radius
  label: Block corner radius
  default: 4pt
  unit: pt
  min: 0
  max: 12
  step: 1
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  print('hello')
  ```,
  header: codly.header([*Greeting* · Python], fill: example-fill, inset: 5pt),
  radius: example-radius,
)
````
