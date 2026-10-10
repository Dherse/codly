# `codly.highlighted-line`

Describes one whole line to highlight in [`codly.new`](../components/new.md).

## Signature

```typst code
codly.highlighted-line(line, color: none)
```

`line` is required and positional; `color` is optional and positional or named.

## Fields

| Field | Type | Default / required | Meaning |
| --- | --- | --- | --- |
| `line` | `int` | Required | One-indexed displayed line number to highlight. |
| `color` | `none \| paint` | `none` | Optional paint for this line; `none` uses the next color from [`codly.highlight`](../components/highlight.md). |

## Behavior

> [!NOTE] Uses displayed line numbers
> `line` refers to the number shown in the document, including offsets and numbering changes from skips. A source line with no displayed number cannot be selected this way.

> [!TIP] Explicit colors leave the palette cycle untouched
> A supplied `color` is used directly. Entries with `color: none` take and advance the next [`codly.highlight`](../components/highlight.md) palette color.

The constructor also accepts named fields. The value casts from an integer, a dictionary with `line` and optional `color`, or an array of one or two values in field order. Other values and arrays of other lengths fail to cast. The line number refers to the displayed numbering, including offsets and numbering changes caused by skips; a line with no displayed number cannot be highlighted this way. An explicit color is used directly and does not advance the [`codly.highlight`](../components/highlight.md) palette; entries with `color: none` use and advance that palette in declaration order.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```text
  prepare()
  run()
  cleanup()
  ```,
  highlighted: (codly.highlighted-line(2, yellow.lighten(75%)),),
)
````
