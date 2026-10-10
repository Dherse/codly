# `codly.skip`

Describes an explicit collapsed gap in a code block; pass it in [`codly.new`](../components/new.md)'s `skips` field.

## Signature

```typst code
codly.skip(position, length: 1)
```

`position` is the required positional argument; `length` is optional and can be supplied positionally or by name.

## Fields

| Field | Type | Default / required | Meaning |
| --- | --- | --- | --- |
| `position` | `int` | Required | Zero-indexed source position where the skip row is inserted. |
| `length` | `int` | `1` | Number of omitted lines represented by the skip; added to subsequent displayed line numbers. |

## Behavior

> [!NOTE] Source coordinates
> `position` is a zero-indexed source position, even when ranges or offsets
> change which lines appear.

> [!TIP] Duplicate positions make one skip row.
> If multiple skips have the same position, Codly uses the first entry's
> `length` to adjust subsequent displayed line numbers.

The constructor accepts [`codly.skip(position, length)`](#signature) or named fields. A dictionary casts using `position` and optional `length`; an array of one or two values casts positionally. Other array lengths and unrelated values fail to cast. The `skips` field sorts entries by position; duplicate records at one position produce one skip row, and only the first record's length affects the numbering offset. Positions refer to source lines even when ranges or offsets affect what is displayed.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```text
  first
  second
  third
  fourth
  ```,
  skips: (codly.skip(2, 4),),
)
````
