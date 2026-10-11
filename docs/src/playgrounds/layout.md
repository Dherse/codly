# Layout and excerpts

Tune a code block for the space around it, then select parts of a larger file without losing their source coordinates.

## Fit long lines

Reduce the width to compare ordinary wrapping with smart indentation; the wrap marker appears on continuation lines when smart indentation is enabled.

Row inset adds space around each line; block padding adds space around the whole block. Moving numbers outside places them beside the code border.

```yaml widgets
- type: select
  name: layout-theme
  label: Theme
  default: '"github-light"'
  options:
    - label: GitHub Light
      value: '"github-light"'
    - label: Dark
      value: '"dark"'
    - label: Clean
      value: '"clean"'
- type: slider
  name: layout-width
  label: Block width
  default: '100%'
  min: 55
  max: 100
  step: 5
  unit: '%'
- type: slider
  name: layout-size
  label: Code size
  default: '9pt'
  min: 7
  max: 12
  step: 1
  unit: pt
- type: slider
  name: layout-radius
  label: Corner radius
  default: '4pt'
  min: 0
  max: 12
  step: 1
  unit: pt
- type: slider
  name: layout-inset
  label: Row inset
  default: '3pt'
  min: 2
  max: 8
  step: 1
  unit: pt
- type: slider
  name: layout-padding
  label: Block padding
  default: '0pt'
  min: 0
  max: 12
  step: 1
  unit: pt
- type: switch
  name: layout-numbers
  label: Show line numbers
  default: true
- type: switch
  name: layout-outside
  label: Numbers outside the block
  default: false
- type: switch
  name: layout-smart-indent
  label: Smart indentation
  default: true
- type: switch
  name: layout-wrap-marker
  label: Show wrap marker
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.theme(layout-theme, block: (text: (size: layout-size)))
#show: codly.line-set_(inset: layout-inset)
#show: codly.number-set_(
  placement: if layout-outside { "outside" } else { "inside" },
)

#codly.new(
  ```py
  def send_digest(address, updates):
      if updates:
          subject = "Your weekly project updates are ready to read"
          send_email(address, subject=subject, body=format_updates(updates))
      return {"recipient": address, "delivered": bool(updates)}
  ```,
  file: "digest.py",
  width: layout-width,
  radius: layout-radius,
  padding: layout-padding,
  number-enabled: layout-numbers,
  smart-indent: layout-smart-indent,
  wrap-marker: if layout-wrap-marker { [↪] } else { none },
)
````

See [`codly.new`](../api/components/new.md) for block fields and [`codly.theme`](../api/helpers/theme.md) for styling individual components.

## Show an excerpt with a review gutter

The review marks belong to source lines 2, 4, and 7; they stay attached when the excerpt or numbering offset changes.

```yaml widgets
- type: select
  name: excerpt-ranges
  label: Source selection
  default: none
  options:
    - label: Whole file
      value: none
    - label: Function body (2–7)
      value: '((2, 7),)'
    - label: Two excerpts (2–4 and 7–8)
      value: '((2, 4), (7, 8))'
- type: slider
  name: excerpt-offset
  label: Numbering offset
  default: '0'
  min: 0
  max: 100
  step: 10
- type: switch
  name: excerpt-numbers
  label: Show line numbers
  default: true
- type: switch
  name: excerpt-review
  label: Show review gutter
  default: true
- type: slider
  name: excerpt-gutter-width
  label: Review gutter width
  default: '18pt'
  min: 12
  max: 30
  step: 2
  unit: pt
- type: switch
  name: excerpt-smart-skip
  label: Show omitted-line markers
  default: true
- type: select
  name: excerpt-fills
  label: Row backgrounds
  default: '(rgb("f6f8fa"), white)'
  options:
    - label: Alternating
      value: '(rgb("f6f8fa"), white)'
    - label: Solid
      value: 'rgb("f6f8fa")'
    - label: No fill
      value: none
- type: switch
  name: excerpt-guides
  label: Show indentation guides
  default: true
- type: select
  name: excerpt-guide-width
  label: Spaces per guide level
  default: '4'
  options:
    - label: Infer from source
      value: auto
    - label: Two spaces
      value: '2'
    - label: Four spaces
      value: '4'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.theme("github-light", block: (text: (size: 9pt)))
#show: codly.line-set_(fill: excerpt-fills)

#codly.new(
  ```py
  def visible_names(records):
      names = []
      for record in records:
          if record["active"]:
              name = record["name"].strip()
              names.append(name)
      return sorted(names)
  print(visible_names(records))
  ```,
  file: "names.py",
  ranges: excerpt-ranges,
  offset: excerpt-offset,
  number-enabled: excerpt-numbers,
  smart-skip: excerpt-smart-skip,
  indent-guides: if excerpt-guides {
    (width: excerpt-guide-width)
  } else { false },
  gutters: if excerpt-review {
    (auto, codly.gutter-column(
      values: (none, "?", none, "!", none, none, "✓", none),
      width: excerpt-gutter-width,
      align: center,
      text: (fill: rgb("8250df")),
    ))
  } else { auto },
)
````

> [!NOTE] Source lines and displayed numbers differ.
> `ranges` and gutter arrays use original source lines. `offset` changes displayed numbers; it does not move the selected lines or review marks.

See [`codly.range`](../api/types/range.md), [`codly.smart-skip`](../api/types/smart-skip.md), and [`codly.gutter-column`](../api/types/gutter-column.md) for the selection and gutter rules. Continue with [annotations and references](annotations.md) to attach explanations to those lines.
