# `codly.annotation-config`

Describes an annotation attached to one or more one-indexed source lines in a code block.

## Signature

```typst code
codly.annotation-config(start, end: none, content: none, label: none, numbering: numbering.with("(1)"))
```

## Parameters

{{#arg-table types.annotation-config}}

## Behavior

> [!NOTE] Source coordinates
> `start` and `end` are one-indexed source lines, and `end` is inclusive. Displayed line-number offsets do not change the covered source lines.

> [!WARNING] References need a labelled figure
> To reference an annotation, give it a `label` and place its code block inside a labelled figure. Codly discovers the figure label automatically.

> [!WARNING] Annotation ranges cannot overlap.
> Two annotations cannot cover the same source line. Because `end` is
> inclusive, the next annotation must start after the previous one's end.

The positional `start` argument is required. The constructor also accepts a dictionary with a `start` key. Dictionary and constructor inputs are type-checked, then normalized: a missing or `none` `end` becomes `start`, and missing `content` becomes `none`. `start` and a supplied `end` must be positive, and `end` must not precede `start`.

Annotations are passed in the code block's `annotations` array.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```py
  prepare()
  result = compute()
  print(result)
  cleanup()
  ```,
  annotations: (
    codly.annotation-config(
      2,
      end: 3,
      content: [These lines compute and display the result.],
    ),
  ),
)
````
