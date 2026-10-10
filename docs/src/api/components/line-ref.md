# `codly.line-ref`

> [!WARNING] References need a labelled figure.
> Put the code block inside a labelled figure to enable line references.
> Codly detects that figure label automatically, so omit the `block-label`
> argument from `codly.new`.

Formats native Typst references to displayed lines in labeled Codly code blocks.

## Signature

```typst code
codly.line-ref(body, block: label, number: int, suffix: none, separator: auto, numbering: auto)
codly.line-ref-set_(..args)
codly.line-ref-show_(it, ..args)
```

[`codly.line-ref`](#signature) is a generated element definition; Codly creates it for line targets, so user code normally refers to those targets with `@block:line` rather than constructing the element. `line-ref-set_(...)` applies field defaults to generated line references in the current scope. `line-ref-show_(it)` installs a show rule; its first argument is the replacement callback or content, not field overrides.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `body` | `content` \| `none` | required | Internal reference body supplied by Typst. |
| `block` | `label` | required, named | Label of the containing code block. |
| `number` | `int` | required, named | Displayed line number. |
| `suffix` | `content` \| `none` | `none` | Optional suffix attached to the displayed line number. |
| `separator` | `auto` \| `str` \| `content` \| `none` | `auto` | Content between the native block reference and line number; `auto` uses [`codly.ref`](ref.md) settings. |
| `numbering` | `auto` \| `function` \| `none` | `auto` | Formats the displayed line number; `auto` uses [`codly.ref`](ref.md) settings, while `none` leaves only the native block reference. |

## Behavior

The constructor is exported, but references are normally generated from native reference syntax. The element has no custom casts and cannot itself carry a label. Its fields are checked against the declared types; `block` and `number` are named required fields on the generated element. Codly generates line targets for labeled blocks, and `@block:line` references the block figure followed by the line formatter. The number is the displayed line number, including the block's numbering behavior, rather than a character position in the source.

`separator: auto` and `numbering: auto` inherit [`codly.ref`](ref.md)'s `sep` and `numbering` settings. Explicit fields set through `line-ref-set_` override those shared defaults for line references in scope. A numbering function receives the displayed line number. `line-ref-show_` lets a show rule replace or wrap the generated reference; its callback receives the element.

See [`codly.ref`](ref.md) for shared reference defaults.

## Example

This self-contained example labels a code block and refers to its second displayed line. The local set rule changes the separator and line-number format:

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.line-ref-set_(separator: " line ", numbering: n => [L#n])

#figure(caption: [A small code block])[
  #codly.new(
    ```
    first line
    second line
    ```,
  )
]<example>

The reference points to line two of the block: @example:2.
````
