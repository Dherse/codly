# `codly.sublang-block`

> [!WARNING] Sublang blocks cost performance.
> Each sublang block requires re-parsing and introspection; heavy use slows compilation.

The generated element that holds one syntax-highlighted language range inside a Codly code block.

## Signature

```typst code
codly.sublang-block(body, idx)
```

Codly creates this element while rendering [`codly.new`](new.md). In normal use, configure language ranges with the block's `sublangs` field and [`codly.sublang`](../types/sublang.md), rather than constructing this element directly. Both required fields are positional in the generated element constructor.

## Fields

{{#arg-table elements.sublang-block}}

## Behavior

> [!NOTE] Range indexes follow declaration order.
> `idx` is zero-based within one code block's `sublangs` array; it does not
> identify a source line or language key.

For each configured sublanguage range, Codly creates a raw block with that range's language and stores it in `body`. Its display keeps the syntax highlighting while attaching per-line metadata so the block renderer can reuse it.

## Example

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```sh
  > cat test.rs
  fn main() {
      println!("hello");
  }
  > exit

  ```,
  sublangs: ((start: 2, end: 4, lang: "rs"),),
)
````
