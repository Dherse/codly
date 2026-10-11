# `codly.highlight`

[`codly.highlight`](#signature) renders a styled span over part of a source line in a Codly code block.

## Signature

```typst code
codly.highlight(body, highlight: highlight-config | none = none)
codly.highlight-set_(..args)
codly.highlight-show_(it, ..args)
```

## Fields

{{#arg-table elements.highlight}}

## Behavior

> [!TIP] References need a labelled figure.
> A highlight `label` resolves only when the code block sits inside a labelled figure; Codly discovers the figure label automatically.

> [!NOTE] Source coordinates
> Highlight `line` values use displayed line numbers. Character bounds are
> one-indexed, and `end` is inclusive.

> [!WARNING]
> A highlight palette must contain at least one color. An empty array causes
> a compilation error.

Codly emits this element for spans declared in a code block's `highlights` field. Character positions start at one and include both endpoints. Explicit bounds must be nonnegative; `start: 0` is also accepted for the beginning of the line. Omitted or `none` bounds start at the beginning or extend through the end of the line. See [`codly.highlight-config`](../types/highlight-config.md) for span metadata fields.

Each code block has an independent highlight-paint cycle, separate from whole-line highlighting. A scalar `color` repeats for every span; an array cycles in declaration order. An explicit paint in the span metadata uses that paint without advancing the cycle, while its callback receives the next palette paint. The element's `fill` and `stroke` callbacks receive that resolved span paint. Per-span `radius`, `clip`, `inset`, `outset`, `baseline`, and `stroke` settings override the corresponding element fields when present.

[`codly.highlight-set_(..args)`](#signature) sets fields for matching highlight elements in scope; [`codly.highlight-show_(it, ..args)`](#signature) installs replacement content or a callback receiving the highlight element.

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
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.highlight-set_(radius: example-radius)

#codly.new(
  ```js
  let answer = 42
  ```,
  highlights: ((line: 1, start: 5, end: 10),),
)
````
