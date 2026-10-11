# `codly.smart-skip`

Configures which omitted source-line gaps appear as collapsed skip rows when a code block displays selected ranges.

## Signature

```typst code
codly.smart-skip(
  first: bool | none = none,
  last: bool | none = none,
  rest: bool | none = none,
)
```

All fields are named and optional.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `first` | `bool \| none` | `none` | Include a skip when source lines before the first selected range are omitted. |
| `last` | `bool \| none` | `none` | Include a skip when source lines after the last selected range are omitted. |
| `rest` | `bool \| none` | `none` | Include skips for omitted lines between selected ranges or otherwise in the middle of the block. |

## Behavior

> [!NOTE] Source coordinates
> Automatic skips mark gaps between displayed source ranges; they do not
> change the source-line coordinates used by those ranges.

Pass this value to [`codly.new`](../components/new.md)'s `smart-skip` field. A boolean casts to the same value for all three fields. A dictionary casts to this type: omitted `rest` defaults to `false`, and omitted `first` or `last` inherits `rest`. Thus `(rest: true, first: false)` enables middle skips and trailing skips, while suppressing a leading skip. With all three fields false, no automatic skips are inserted. A skip row is inserted only for a discontinuity in the displayed source lines; its represented length is the number of omitted lines.

## Example: Basic Usage

```yaml widgets
- type: switch
  name: show-middle-gap
  label: Show the omitted middle lines
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```python
  def prepare():
      load_data()
      validate()
      transform()
      save()
      report()
      cleanup()
  ```,
  ranges: ((2, 3), (6, 7)),
  smart-skip: codly.smart-skip(first: false, last: false, rest: show-middle-gap),
)
````
