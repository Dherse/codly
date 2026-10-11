# `codly.annotation-config`

Describes an annotation attached to one or more one-indexed source lines in a code block.

## Signature

```typst code
codly.annotation-config(start, end: none, content: none, label: none, numbering: n => [#n])
```

## Parameters

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `start` | `int` | required | First source line covered by the annotation; must be greater than zero. |
| `end` | `int \| none` | `none` | Last covered line. `none` is normalized to `start`; otherwise it must be positive and at least `start`. |
| `content` | `content \| none` | `none` | Showable content displayed beside the annotation; `none` leaves only its number. |
| `label` | `label \| none` | `none` | Label for referencing this annotation when its code block is inside a figure. |
| `numbering` | `function \| none` | `n => [#n]` | Function formatting the annotation number. Set to `none` to hide the number. |

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
