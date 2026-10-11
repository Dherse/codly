# Annotations and references

Mark expressions, group lines, attach notes, and link to all of them from prose.

## Highlights, annotations, and references

References follow **displayed numbering**: change the offset and the highlight reference moves with it, while the annotation stays attached to the same source lines.

```yaml widgets
- type: select
  name: highlight-palette
  label: Highlight palette
  default: '(blue, purple)'
  options:
    - label: Blue and purple
      value: '(blue, purple)'
    - label: Orange and red
      value: '(orange, red)'
    - label: Green and aqua
      value: '(green, aqua)'
- type: slider
  name: highlight-start
  label: First character (one-based)
  default: 10
  min: 1
  max: 13
  step: 1
- type: slider
  name: highlight-length
  label: Highlight length
  default: 7
  min: 1
  max: 9
  step: 1
- type: slider
  name: line-offset
  label: Displayed line offset
  default: 0
  min: 0
  max: 30
  step: 1
- type: switch
  name: annotation-enabled
  label: Show the annotation
  default: true
- type: slider
  name: annotation-end
  label: Last annotated source line
  default: 3
  min: 2
  max: 4
  step: 1
- type: slider
  name: highlight-radius
  label: Highlight corner radius
  default: 3pt
  unit: pt
  min: 0
  max: 8
  step: 1
- type: select
  name: reference-mode
  label: Reference suffix
  default: '"line"'
  options:
    - label: Displayed line number
      value: '"line"'
    - label: Highlight tag or annotation text
      value: '"item"'
- type: select
  name: highlight-tag
  label: Highlight tag
  default: '"step"'
  options:
    - label: step
      value: '"step"'
    - label: compute
      value: '"compute"'
    - label: result
      value: '"result"'
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.highlight-set_(color: highlight-palette, radius: highlight-radius)
#show: codly.ref-set_(by: reference-mode, sep: " · ")

#figure(caption: [A processing pipeline])[
  #codly.new(
    ```py
    data = load()
    result = compute(data)
    validate(result)
    return result
    ```,
    offset: line-offset,
    highlights: (
      (line: 2 + line-offset, start: highlight-start,
       end: highlight-start + highlight-length - 1,
       tag: highlight-tag, label: <selected-span>),
      (line: 4 + line-offset, start: 8, end: 13),
    ),
    annotations: if annotation-enabled {
      ((start: 2, end: annotation-end,
        content: [Processing], label: <processing>),)
    } else { () },
  )
]<analysis-code>

The selected span is @selected-span.
#if annotation-enabled [The annotated range is @processing.]
The computation starts at #ref(label("analysis-code:" + str(2 + line-offset))).
````

Highlight `line` values use **displayed line numbers**; their `start` and `end` count characters from one and include both endpoints. The default spans select `compute` on line 2 (characters 10–16) and `result` on line 4 (characters 8–13). Annotation ranges use **source line numbers**, starting at one with an inclusive end. The labelled enclosing figure supplies the reference target automatically. Item references use a highlight's `tag` or an annotation's `content`.

See [highlight bounds](../api/types/highlight-config.md), [annotation ranges](../api/types/annotation-config.md), and [reference formatting](../api/components/ref.md).

## Pointed bubbles and plain callouts

Two pointers on one line show how bubbles share a row or move into separate lanes as their preferred width and gap change.

```yaml widgets
- type: select
  name: bubble-placement
  label: Bubble placement
  default: '"below"'
  options:
    - label: Below the source line
      value: '"below"'
    - label: Above the source line
      value: '"above"'
- type: slider
  name: pointer-position
  label: First pointer character
  default: 13
  min: 0
  max: 25
  step: 1
- type: select
  name: pointer-alignment
  label: Bubble alignment around pointer
  default: '"center"'
  options:
    - label: Start
      value: '"start"'
    - label: Center
      value: '"center"'
    - label: End
      value: '"end"'
- type: slider
  name: bubble-width
  label: Preferred bubble width
  default: 100pt
  unit: pt
  min: 55
  max: 145
  step: 5
- type: slider
  name: bubble-gap
  label: Gap between bubbles
  default: 5pt
  unit: pt
  min: 0
  max: 12
  step: 1
- type: select
  name: bubble-style
  label: Bubble paint
  default: '(fill: aqua.lighten(80%), stroke: 0.6pt + teal)'
  options:
    - label: Aqua with teal outline
      value: '(fill: aqua.lighten(80%), stroke: 0.6pt + teal)'
    - label: Yellow with orange outline
      value: '(fill: yellow.lighten(80%), stroke: 0.6pt + orange)'
    - label: White with gray outline
      value: '(fill: white, stroke: 0.6pt + gray)'
- type: slider
  name: bubble-radius
  label: Bubble corner radius
  default: 4pt
  unit: pt
  min: 0
  max: 10
  step: 1
- type: switch
  name: source-indent
  label: Follow source indentation
  default: true
- type: switch
  name: plain-callout-enabled
  label: Show the plain callout
  default: true
```
````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.bubble-set_(
  fill: bubble-style.fill,
  stroke: bubble-style.stroke,
  width: bubble-width,
  gap: bubble-gap,
  radius: bubble-radius,
  pointer-align: pointer-alignment,
)
#show: codly.callout-set_(source-indent: source-indent)

#codly.new(
  ```py
  def invoice(subtotal, tax):
      total = subtotal + tax
      return total
  print(invoice(80, 16))
  ```,
  callouts: (
    (line: 2, pointer: pointer-position, placement: bubble-placement,
     body: [The base amount before tax.]),
    (line: 2, pointer: 24, placement: bubble-placement,
     body: [Tax is added once.]),
  ) + if plain-callout-enabled {
    ((line: 3, body: [The computed total is returned.]),)
  } else { () },
)
````

Callout `line` values use **source lines**, unaffected by numbering offsets. A `pointer` counts source characters from **one**, with `0` anchoring the start; `pointer: none` makes a plain callout. Only plain callouts follow `source-indent`. Bubble width is a preference: Codly keeps each bubble within the available row and wraps its text.

See [callout configuration](../api/types/callout-config.md) and [bubble styles](../api/components/bubble.md). To style selected elements with show rules, continue with [queries and show rules](../api/queries-and-show-rules.md).
