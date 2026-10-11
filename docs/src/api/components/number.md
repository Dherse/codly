# `codly.number`

A displayed line number in a Codly code block; `number-set_` configures its style and `number-show_` replaces its rendered content.

## Signature

```typst code
codly.number(number, parent, ..fields)
```

`number` and `parent` are required positional fields; the remaining fields are named. Codly normally creates these elements while rendering [`codly.new`](new.md).

## Fields

{{#arg-table elements.number}}

## Behavior

> [!TIP] Custom content bypasses numbering.
> A `content` value is rendered as-is, while integer values go through
> `numbering`. Use an integer when you want the configured numbering style to
> apply.

An integer is formatted with `numbering`; an array passes its values to the numbering function as separate arguments. A `content` value renders as-is, and `number: none` displays nothing. `number-set_(..fields)` sets scoped fields with `#show:`; `number-show_(it => ...)` replaces the generated number element with the callback's result.

The placement setting applies to the number column for code blocks in scope. Outside placement also positions any configured gutters outside the code.

## Example

```yaml widgets
- type: switch
  name: number-outside
  label: Place numbers outside
  default: false
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.number-set_(placement: if number-outside { "outside" } else { "inside" })

#codly.new(
  ```txt
  first line
  second line
  ```,
)
````
