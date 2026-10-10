# `codly.footer`

Creates the footer element rendered below a [code block](new.md).

## Signature

```typst code
// Create a footer element
codly.footer(
  body,
  repeat: false,
  align: center + horizon,
  inset: auto,
  fill: none,
  stroke: auto
)

// Equivalent set-rule for `codly.footer`
codly.footer-set_(..args)

// Equivalent show rule for `codly.footer`
codly.footer-show_(it => ...)
```

`body` is required and positional; all other fields are named.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `body` | `content \| none` | required | Footer content. |
| `repeat` | `bool \| none` | `false` | Repeat the footer on each page when the code block spans pages. |
| `align` | `alignment \| none` | `center + horizon` | Alignment of the footer content in its cell. |
| `inset` | `length \| dictionary \| auto \| none` | `auto` | Inset around the footer content. |
| `fill` | `paint \| auto \| none` | `none` | Footer cell background. `none` leaves it unfilled; `auto` uses the footer's default. This fill is independent of line and number fills. |
| `stroke` | `stroke \| auto \| none` | `auto` | Stroke around the footer cell. |

## Behavior

> [!NOTE] Footer fill defaults to none
> `fill: auto` resolves to the footer's default (`none`). Set an explicit fill when the footer should have a background; its fill is independent of line and number fills.

Pass this element as the `footer` field of [`codly.new`](new.md). Plain footer content is also accepted there and is wrapped as a footer with its defaults. A [`codly.footer-set_(...)`](#signature) rule supplies defaults, while fields set on an explicit [`codly.footer(...)`](#signature) take precedence. The `repeat` field controls whether the footer appears on continuation pages.

[`codly.footer-show_(callback)`](#signature) applies a show rule to footer elements. The callback receives the element and must return replacement content; for example, `#show: codly.footer-show_(it => [#it])` preserves the footer body. These wrappers follow Typst's scoped set and show rules.

## Example

The footer fill can be changed while previewing:

```yaml widgets
- type: select
  name: footer-fill
  label: Footer fill
  default: luma(240)
  options:
    - label: Light gray
      value: 'luma(240)'
    - label: Pale blue
      value: 'rgb("#e8f0ff")'
    - label: None
      value: 'none'
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```js
  const ready = true;
  ```,
  footer: codly.footer([Generated output], fill: footer-fill, inset: 5pt),
)
````
