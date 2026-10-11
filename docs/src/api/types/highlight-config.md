# `codly.highlight-config`

Describes one character-level highlight on a source line in a Codly code block. See [`codly.new`](../components/new.md) for the block's `highlights` field.

## Signature

```typst code
codly.highlight-config(line, start: none, end: none, fill: none, tag: none, inset: none, baseline: none, clip: none, outset: none, radius: none, label: none, stroke: none, depth: none)
```

`line` is the required positional field; every other field is named. A dictionary with a `line` key can also be cast to this type.

## Fields

{{#arg-table types.highlight-config}}

## Behavior

> [!NOTE] Source coordinates
> `line` is a one-indexed displayed line number, including any offset.
> `start` and `end` are one-indexed character positions, and `end` is inclusive.

> [!WARNING] References need a labelled figure
> To reference a highlight, give it a `label` and place its code block inside a labelled figure.

The constructor and dictionary cast normalize omitted or `none` bounds to `start: 0` and an end bound covering the rest of the line. Explicit bounds must be nonnegative; `line` must be positive. Character positions start at one and include both endpoints; `start: 0` is accepted as a line-start alias. Equal positive bounds select one character. Bounds count the source text after Typst removes the raw block's common indentation and, for diffs, after the row's diff marker is removed. Grapheme clusters and whitespace runs remain whole when a boundary falls inside them.

A `fill` paint is used directly and does not consume a palette entry; a callback receives the next palette paint. Highlights using `none` also consume the next palette entry. An empty configured palette is invalid. Local style fields override the corresponding [`codly.highlight`](../components/highlight.md) settings when provided.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```js
  let answer = 42
  ```,
  highlights: (codly.highlight-config(1, start: 5, end: 10, fill: yellow.lighten(65%), tag: "value"),),
)
````
