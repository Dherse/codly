# `codly.info`

Read the source-line count and last displayed line number recorded for a labeled code block.

## Signature

```typst code
codly.info(target) -> (last-number: int | none, lines: int)
```

## Parameters

| Name | Type | Default | Meaning |
| --- | --- | --- | --- |
| `target` | `label` | required, positional | Label identifying the code block whose metadata to read. |

The returned dictionary has these fields:

| Field | Type | Meaning |
| --- | --- | --- |
| `last-number` | `int` or `none` | Last computed displayed line number, or `none` when the block has no numbered source line. |
| `lines` | `int` | Number of source lines in the block, including lines omitted from its displayed range. |

## Behavior

> [!WARNING] The target label must identify one code block.
> Labels resolving to zero or multiple locations, or to a location with no later Codly block record, cause a compilation error.

> [!NOTE] `lines` counts the full source.
> The count includes lines omitted by `range`; `last-number` reflects the selected range and offset.

Call [`codly.info`](#signature) inside `context`, since it queries document content. The helper reads the first Codly block record after the label's location.

Unnumbered rows do not replace `last-number`. Passing the label as another block's `offset` adds this number to that block's numbering, so numbering can continue across blocks.

## Example: Basic Usage

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```
  first
  second
  ```,
)<first-block>
#codly.new(
  ```
  third
  ```,
  offset: <first-block>,
)<continued-block>

#context[
  First block: #repr(codly.info(<first-block>))
]
````
