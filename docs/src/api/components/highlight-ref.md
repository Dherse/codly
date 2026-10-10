# `codly.highlight-ref`

> [!WARNING] References need a labelled figure.
> To use references to highlight, you must ensure that the Codly code block is contained within a labelled figure. 

[`codly.highlight-ref`](#signature) declares the native reference element emitted for a labelled highlight.

## Signature

```typst code
// Create a highlight reference element
codly.highlight-ref(
  body,
  block: label,
  line: int,
  by: "line" | "item",
  item: content | none = none,
  separator: auto | str | content = auto,
  numbering: auto | function | none = auto
)

// Set default fields for matching highlight references
codly.highlight-ref-set_(..args)

// Install a replacement callback or content for matching highlight references
codly.highlight-ref-show_(it, ..args)
```

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `body` | `content` \| `none` | Required, positional | Reference body supplied by Typst. |
| `block` | `label` | Required, named | Label of the containing code block. |
| `line` | `int` | Required, named | Displayed line number containing the highlight. |
| `item` | `content` \| `none` | `none` | Highlight tag used when `by` is `"item"`. |
| `by` | `"line"` \| `"item"` | Required, named | Whether to show the line number or highlight tag. |
| `separator` | `auto` \| `str` \| `content` \| `none` | `auto` | Text between the block reference and this reference; `auto` uses [`codly.ref`](ref.md) settings. |
| `numbering` | `auto` \| `function` \| `none` | `auto` | Formatter for line references; `auto` uses [`codly.ref`](ref.md) settings. |

## Behavior

Typst emits this element when a native reference targets a label on a highlight. It retains the reference to the containing figure or code block, so native figure numbering and links work. With `by: "line"`, the formatter receives the displayed line number. With `by: "item"`, the tag is shown and `item` must be present. A `none` formatter suppresses the numeric part of line references; item references still show their tag. The default separator and formatter come from [`codly.ref`](ref.md).

[`codly.highlight-ref-set_(..args)`](#signature) sets fields for matching references. [`codly.highlight-ref-show_(it, ..args)`](#signature) installs a replacement callback or content for the matching element; a callback receives the reference element. These wrappers follow the same scoped show-rule model as other Codly elements.

## Example

````typ preview
#import "@preview/codly:2.0.0" as codly

#show: codly.highlight-ref-set_(numbering: numbering.with("H1"))

The marked line is @marked.

#figure(caption: [A labelled highlight])[
  #codly.new(
    ```
    answer = 42
    ```,
    highlights: ((line: 1, start: 0, end: 6, label: <marked>),),
  )
]<listing>
````
