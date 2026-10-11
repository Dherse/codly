# `codly.highlight`

[`codly.highlight`](#signature) renders a styled span over part of a source line in a Codly code block.

## Signature

```typst code
codly.highlight(body, highlight: highlight-config | none = none)
codly.highlight-set_(..args)
codly.highlight-show_(it, ..args)
```

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `body` | `content` \| `none` | Required, positional | Highlighted span content. |
| `highlight` | `highlight-config` \| `none` | `none` | Span metadata supplied by Codly, including source positions and local overrides; see [`codly.highlight-config`](../types/highlight-config.md). |
| `color` | `paint` \| `array<paint>` | Thesis theme's five-color highlight palette | Base paint or cycling palette for highlights. The palette must not be empty. |
| `radius` | `length` \| `none` | `0.32em` | Corner radius of the highlight box. |
| `fill` | `function` \| `none` | `color => color.lighten(80%)` | Transforms the selected highlight paint into the box fill. |
| `baseline` | `length` \| `auto` \| `none` | `0pt` | Baseline shift for the highlight box; `auto` follows the content baseline. |
| `stroke` | `stroke` \| `function` \| `none` | `color => 0.5pt + color` | Box stroke, or a callback that derives it from the selected paint. |
| `inset` | `length` \| `dictionary` \| `none` | `0.32em` | Space between the highlighted content and box edges. A dictionary uses Typst inset sides. |
| `outset` | `length` \| `dictionary` \| `none` | `0em` | Space the highlight box extends outside its layout bounds. |
| `clip` | `bool` \| `none` | `true` | Whether the highlight box clips its content. |

## Behavior

> [!TIP] References need a labelled figure.
> A highlight `label` resolves only when the code block sits inside a labelled figure; Codly discovers the figure label automatically.

> [!NOTE] Source coordinates
> Highlight line numbers are one-indexed. Character offsets are zero-indexed,
> and `end` is exclusive.

> [!WARNING]
> A highlight palette must contain at least one color. An empty array causes
> a compilation error.

Codly emits this element for spans declared in a code block's `highlights` field. Span positions are zero-indexed character offsets, with an exclusive `end`; line numbers are one-indexed. Bounds must be nonnegative; omitted or `none` bounds start at the beginning or extend through the end of the line. See [`codly.highlight-config`](../types/highlight-config.md) for span metadata fields.

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
  ```py
  let answer = 42
  ```,
  highlights: ((line: 1, start: 4, end: 10),),
)
````
