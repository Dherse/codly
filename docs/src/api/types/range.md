# `codly.range`

Selects an inclusive range of one-indexed source lines for a code block.

## Signature

```typst code
codly.range(start, end: none)
```

`start` is positional and required. `end` is optional and may be passed positionally or by name.

## Parameters

| Parameter | Type | Default / required | Meaning |
| --- | --- | --- | --- |
| `start` | `int` | Required | First source line to display, counting from 1. |
| `end` | `int \| none` | `none` | Last source line to display, inclusive. `none` selects through the end of the block. |

## Behavior

> [!NOTE] Source coordinates
> Range endpoints count source lines from one and include both `start` and
> `end`; displayed numbering offsets do not change them.

> [!TIP] Adjacent ranges merge.
> When several ranges are selected, Codly sorts them and merges overlapping
> or directly adjacent ranges before rendering.

Pass a range to [`codly.new`](../components/new.md)'s `range` field, or pass several ranges to its `ranges` field. These coordinates refer to source lines, independently of displayed line-number offsets. The range is inclusive at both ends; an open range such as [`codly.range(3)`](#signature) continues through the final source line.

The constructor accepts positional arguments ([`codly.range(2, 4)`](#signature)) or named arguments ([`codly.range(start: 2, end: 4)`](#signature)). Its implicit casts accept a one- or two-element array, or a dictionary with `start` and optional `end` keys. For example, `(2, 4)` and `(start: 2, end: 4)` cast to the same value as the constructor. Unknown dictionary keys are rejected. Inputs are type-checked as integers (or `none` for `end`); the range type does not impose a positivity or ordering constraint.

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
