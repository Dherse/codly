# `codly.range`

Selects an inclusive range of one-indexed source lines for a code block.

## Signature

```typst code
codly.range(start, end: none)
```

`start` is positional and required. `end` is optional and may be passed positionally or by name.

## Parameters

{{#arg-table types.range}}

## Behavior

> [!NOTE] Source coordinates
> Range endpoints count source lines from one and include both `start` and
> `end`; displayed numbering offsets do not change them.

> [!TIP] Adjacent ranges merge.
> When several ranges are selected, Codly sorts them and merges overlapping
> or directly adjacent ranges before rendering.

Pass a range to [`codly.new`](../components/new.md)'s `range` field, or pass several ranges to its `ranges` field. An open range such as [`codly.range(3)`](#signature) continues through the final source line.

The constructor accepts positional arguments ([`codly.range(2, 4)`](#signature)) or named arguments ([`codly.range(start: 2, end: 4)`](#signature)). Implicit casts accept a one- or two-element array or a dictionary with `start` and optional `end` keys; unknown dictionary keys are rejected. Bounds are type-checked as integers (or `none` for `end`), with no positivity or ordering constraint.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```
  prepare()
  validate()
  transform()
  save()
  ```,
  range: codly.range(2, 3),
)
````
