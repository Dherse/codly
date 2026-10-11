# `codly.skip`

Describes an explicit collapsed gap in a code block; pass it in [`codly.new`](../components/new.md)'s `skips` field.

## Signature

```typst code
codly.skip(position, length: 1)
```

`position` is the required positional argument; `length` is optional and can be supplied positionally or by name.

## Fields

{{#arg-table types.skip}}

## Behavior

> [!NOTE] Source coordinates
> `position` is a one-indexed source line, even when ranges or offsets
> change which lines appear. Position `2` inserts the gap before source line 2.

> [!TIP] Duplicate positions make one skip row.
> If multiple skips have the same position, Codly uses the first entry's
> `length` to adjust subsequent displayed line numbers.

The constructor accepts [`codly.skip(position, length)`](#signature) or named fields. A dictionary casts using `position` and optional `length`; an array of one or two values casts positionally. The `skips` field sorts entries by position.

Explicit skips represent lines already omitted from the supplied source. They add a gap row and increase subsequent displayed numbers; they do not remove source lines. Use `range` or `ranges` with `smart-skip` to omit lines that are still present.

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
