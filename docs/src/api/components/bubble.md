# `codly.bubble`

A pointed callout bubble rendered next to a source line, with independent defaults for its paint, dimensions, spacing, and pointer.

## Signature

```typst code
// A codly pointed callout bubble.
codly.bubble(
  body,
  gap: 0.5em,
  pointer-align: "center",
  pointer-size: 0.4em,
  pointer-height: auto,
  pointer-width: auto,
  pointer-offset: 0pt,
  align: center,
  fill: luma(245),
  stroke: 0.6pt + luma(80),
  inset: (x: 0.5em, y: 0.3em),
  outset: 0pt,
  radius: 2pt,
  width: auto,
  line: int,
  pointer: int,
  placement: "below"
)
```

[`codly.bubble`](#signature) is the generated element type for pointed callouts. Its `body` is positional; `line` and `pointer` are required named fields when representing the element directly. In normal use, create bubbles by setting `pointer` on a `callouts` entry.

## Fields

{{#arg-table elements.bubble}}

## Behavior

> [!TIP] Bubbles can share a row
> Consecutive bubbles on the same side of a source line share a row when their outlines fit. If they collide, Codly places them in separate lanes in declaration order; adjust `gap` or `width` to control the spacing and wrapping.

The bubble and arrow use one outline and fill. Content wraps at the available width. Negative dimensions, pointer sizes, insets, and outsets are rejected. Styling defaults set on [`codly.bubble`](#signature) are inherited by generated bubbles; explicit [`codly.callout`](callout.md) settings and then entry-level bubble settings take precedence. A callout with `pointer: none` does not produce a bubble.

## Rules

[`codly.bubble-set_(..args)`](#signature) sets styling defaults for generated bubbles. [`codly.bubble-show_(it, ..args)`](#signature) installs a show rule for generated bubbles; its first argument is replacement content or a callback.

## Example: Basic Usage

```yaml widgets
- type: slider
  name: pointer
  label: Pointer position
  default: 17
  min: 0
  max: 26
  step: 1
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.bubble-set_(fill: aqua.lighten(75%), radius: 6pt, width: 125pt)
#codly.new(
  ```js
  let total = subtotal + tax
  ```,
  callouts: ((
    line: 1,
    pointer: pointer,
    body: [The final amount includes tax.],
  ),),
)
````

## Example: Custom Show Rule
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.bubble-show_(it => {
  box(stroke: red, it)
})

#codly.new(
  ```js
  let total = subtotal + tax
  ```,
  callouts: ((
    line: 1,
    pointer: 17,
    body: [The final amount includes tax.],
  ),),
)
````
