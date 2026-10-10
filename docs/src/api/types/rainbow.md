# `codly.rainbow`

Configures syntax-aware coloring for matching code delimiters by nesting depth.

## Signature

```typst code
codly.rainbow(
  enabled: bool = true,
  palette: array<color> = (...),
  pairs: array<"()" | "[]" | "{}"> = ("()", "[]", "{}"),
  depth-offset: int = 0,
  unmatched: color | none = none,
  code-scopes: str = ...,
  ignore-scopes: str = ...,
)
```

The value can also be a dictionary with these fields, or a boolean that sets `enabled`.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enabled` | `bool` | `true` | Enables delimiter coloring. |
| `palette` | `array<color>` | Built-in palette | Colors cycled by nesting depth; must not be empty. |
| `pairs` | array of `"()"` \| `"[]"` \| `"{}"` | `("()", "[]", "{}")` | Delimiter pairs recognized for nesting. |
| `depth-offset` | `int` | `0` | Adds an offset to the nesting depth before choosing a palette color; must be nonnegative. |
| `unmatched` | `color` \| `none` | `none` | Color for unmatched delimiters; `none` leaves their syntax color unchanged. |
| `code-scopes` | `str` | Built-in selectors | Syntax scope selectors classified as code by the rainbow pass. |
| `ignore-scopes` | `str` | Built-in selectors | Syntax scope selectors excluded from delimiter coloring, such as strings and comments. |

## Behavior

> [!WARNING] The palette must be nonempty.
> An empty `palette` or a negative `depth-offset` causes a compilation error.

> [!TIP] Adjust scopes for unusual grammars.
> `code-scopes` and `ignore-scopes` replace the built-in selectors. Customize
> them when a language classifies delimiters differently from the defaults.

Set `rainbow` on [`codly.new`](../components/new.md) or in [`codly.set_`](../components/new.md#behavior) to configure blocks in that scope. `true` enables the defaults and `false` disables the pass. Delimiters are colored according to nesting depth, cycling through `palette`; `depth-offset` shifts the starting color. Only pairs listed in `pairs` contribute to nesting. Unclosed openers and unmatched closers use `unmatched` when it is a color; otherwise they retain their syntax highlighting.

The pass uses syntax scopes to find code and ignore literals and comments. `code-scopes` and `ignore-scopes` replace the built-in selector strings, so customize them when a language's grammar classifies delimiters differently. Sublanguage regions are processed with their own nesting stack.

## Example: Basic Usage

```yaml widgets
- type: switch
  name: rainbow-enabled
  label: Color delimiters
  default: true
- type: select
  name: rainbow-pairs
  label: Delimiter pairs
  default: '("()", "[]", "{}")'
  options:
    - label: All pairs
      value: '("()", "[]", "{}")'
    - label: Braces only
      value: '("{}",)'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```rs
  fn main() {
      let items = [1, 2, 3];
      println!("{}", items[0]);
  }
  ```,
  rainbow: if rainbow-enabled {
    (palette: (rgb("#d73a49"), rgb("#005cc5"), rgb("#22863a")), pairs: rainbow-pairs)
  } else {
    false
  },
)
````
