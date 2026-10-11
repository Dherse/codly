# `codly.callout`

A row attached to a source line in a Codly code block; it can be plain text or a pointed bubble.

## Signature

```typst code
// Create a new callout.
codly.callout(
  body,
  line: int,
  align: auto,
  breakable: auto,
  inset: auto,
  fill: auto,
  stroke: auto,
  source-indent: false,
  placement: "below",

  // Parameters for the bubble if any.
  bubble-gap: auto,
  bubble-align: auto,
  bubble-fill: auto,
  bubble-stroke: auto,
  bubble-inset: auto,
  bubble-outset: auto,
  bubble-radius: auto,
  bubble-width: auto,
  
  // Parameters for the bubble's pointer if used.
  pointer: none,
  pointer-align: auto,
  pointer-size: auto,
  pointer-height: auto,
  pointer-width: auto,
  pointer-offset: auto,
)
```

`body` is positional. `line` is required and named. Normally, callouts are created by entries in the `callouts` field; see [`codly.callout-config`](../types/callout-config.md).

## Fields

{{#arg-table elements.callout}}

## Behavior

> [!TIP] Plain callouts can follow source indentation
> Set `source-indent: true` to align a plain callout with the source indentation while preserving the gutter columns. Pointed callouts stay anchored to their source character.

Callout lines are source-line coordinates, unaffected by displayed line-number offsets. Pointer positions count characters in the source line, with zero denoting its start; the pointer follows the rendered character when code wraps. Negative pointers, dimensions, insets, outsets, and gaps are rejected. A bubble's body and arrow share one fill and outline, and bubble text wraps to its available width.

Unspecified or `auto` bubble styling inherits from [`codly.bubble`](bubble.md), after explicit [`codly.callout`](#signature) styling. Entry values in `callouts` take precedence over the element's set-rule values. Explicit `none` disables bubble fill or stroke; `pointer: none` keeps a callout plain.

[`codly.callout-set_(..args)`](#signature) sets defaults for callout cells and bubbles; [`codly.callout-show_(it, ..args)`](#signature) installs a show rule taking replacement content or a callback such as `it => [#it]`. Bubble-specific defaults and show rules are documented on [`codly.bubble`](bubble.md).

## Example

```yaml widgets
- type: switch
  name: source-indent
  label: Align plain callout to source indentation
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#show: codly.callout-set_(source-indent: source-indent)
#codly.new(
  ```py
  if ready:
    start()
  ```,
  callouts: (
    (line: 1, body: [Plain callout aligned with the source.]),
    (line: 2, pointer: 3, body: [Pointing at `start`.]),
  ),
)
````
