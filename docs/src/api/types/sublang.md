# `codly.sublang`

Assigns a syntax-highlighting language to an inclusive range of source lines in a code block.

## Signature

```typst code
codly.sublang(
  start: int,
  end: int,
  lang: str,
)
```

All fields are required and named. The value can also be supplied as a dictionary.

## Fields

{{#arg-table types.sublang}}

## Behavior

> [!NOTE] Source coordinates
> Sublanguage ranges count one-indexed source lines and include both
> endpoints, independent of displayed line-number offsets.

> [!TIP] Highlighting preserves the original lines.
> Codly applies each range's syntax language to its source lines while keeping
> their text and positions in the outer code block.

Pass one or more [`codly.sublang`](#signature) values in the `sublangs` argument to [`codly.new`](../components/new.md). `start` must be positive and `end` at least `start`; invalid ranges raise an error. Lines outside the ranges keep the raw block's language. Ranges may also be supplied as dictionaries with the same three fields.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```sh
  echo before
  fn answer() {
      42
  }
  echo after

  ```,
  sublangs: (
    (start: 2, end: 4, lang: "rs"),
  ),
)
````
