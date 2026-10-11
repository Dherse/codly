# `codly.annotation`

[`codly.annotation`](#signature) is the generated brace element displayed beside an annotated source-line range in a Codly code block.

## Signature

```typst code
// Create a new annotation.
codly.annotation(body, ..fields)

// Equivalent set-rule for an annotation.
codly.annotation-set_(..args)

// Override the show-rule for an annotation.
codly.annotation-show_(it, ..args)
```

Codly creates this element while rendering [`codly.new`](new.md) and supplies its fields. `body` is the required positional content field; the remaining fields are named.

## Fields

{{#arg-table elements.annotation}}

## Behavior

> [!TIP] References need a labelled figure.
> An annotation `label` resolves only when the code block sits inside a labelled figure; Codly discovers the figure label automatically.

> [!NOTE] Source coordinates
> Annotation ranges count one-indexed source lines, and `end` is inclusive.

Codly emits one annotation element for a configured line range. Range endpoints are one-indexed source-line positions, independent of displayed line-number offsets; annotation ranges cannot overlap. Use [`codly.annotation-config`](../types/annotation-config.md) to configure a range.

[`codly.annotation-set_(..args)`](#signature) sets fields on generated annotations in scope; [`codly.annotation-show_(it, ..args)`](#signature) installs replacement content or a callback receiving the generated element.

## Example: Basic Usage

```yaml widgets
- type: switch
  name: show-annotation-number
  label: Show annotation number
  default: true
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  prepare()
  result = compute()
  print(result)
  cleanup()
  ```,
  annotations: ((
    start: 2,
    end: 4,
    content: [Computes and displays the result],
    numbering: if show-annotation-number { n => [(#n)] } else { none },
  ),),
)
````
