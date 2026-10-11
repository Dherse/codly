# `codly.language`

Defines the displayed name, color, and optional icon for a language badge in a code block.

## Signature

```typst code
codly.language(
  name: str | content,
  color: paint | none = none,
  icon: str | content | none = none,
)
```

`name` is required and named. Fields expecting this type also accept a string as shorthand for `name`, or a dictionary. Unknown fields are retained.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `name` | `str \| content` | Required | Displayed language name. |
| `color` | `paint \| none` | `none` | Language color; `none` uses the badge's default color. |
| `icon` | `str \| content \| none` | `none` | Optional icon shown beside the name. |

The declaration preserves additional, unknown fields. They can provide language-specific overrides to [`codly.lang`](../components/lang.md) fields, such as `radius` or `fill`.

## Behavior

Use language definitions as values in the `languages` dictionary passed to [`codly.lang-set_`](../components/lang.md#signature). The dictionary key must match the raw block's language tag. The settings apply within the show rule's scope. A definition's `name`, `icon`, and `color` customize the badge; an omitted definition falls back to the raw language tag. A definition's matching [`codly.lang`](../components/lang.md) style fields override the corresponding settings supplied to [`codly.lang-set_`](../components/lang.md#signature).

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.lang-set_(languages: (
  rs: (name: [Rust], color: rgb("b7502a"), icon: "R"),
))
#show raw.where(block: true): codly.new

```rs
fn main() {
    println!("Hello, Rust!");
}
```
````
