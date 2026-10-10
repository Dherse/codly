# `codly.indent-guides`

Configures optional vertical guides at complete indentation levels in a code block.

## Signature

```typst code
codly.indent-guides(
  enabled: bool = true,
  width: auto | int = auto,
  blank-lines: bool = true,
  rainbow: auto | bool = auto,
  palette: auto | array<color> = auto,
  depth-offset: auto | int = auto,
  color: color = luma(70%),
  thickness: length = 0.5pt,
  x-offset: length = 0pt,
)
```

The fields can also be supplied as a dictionary. A boolean casts to `enabled`.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enabled` | `bool` | `true` | Draws indentation guides when enabled. |
| `width` | `auto` \| `int` | `auto` | Spaces per indentation level. `auto` votes on observed indentation changes. |
| `blank-lines` | `bool` | `true` | Continues shared guide levels across interior blank lines. |
| `rainbow` | `auto` \| `bool` | `auto` | Colors guides by level; `auto` follows whether delimiter rainbow coloring is enabled. |
| `palette` | `auto` \| `array<color>` | `auto` | Nonempty colors for rainbow guides; `auto` shares the delimiter palette. |
| `depth-offset` | `auto` \| `int` | `auto` | Nonnegative palette offset; `auto` shares the delimiter offset. |
| `color` | `color` | `luma(70%)` | Guide color when rainbow coloring is disabled. |
| `thickness` | `length` | `0.5pt` | Positive stroke thickness. |
| `x-offset` | `length` | `0pt` | Horizontal guide shift; positive moves right and negative moves left. Supports `em` lengths. |

## Behavior

> [!TIP] Check the inferred indentation step
> `width: auto` chooses the most frequently observed change in leading spaces; ties favor the smaller step, and no observed step falls back to four spaces. Set `width` explicitly when the source uses a known indentation size.

> [!NOTE] Only complete levels get guides
> A guide is drawn for each complete `width`-sized level. Indentation that does not reach the next complete level has no guide.

Set the block-level `indent-guides` field to `true` to use defaults, to `false` to disable inherited guides for one block, or to a configuration to customize them. `width: auto` infers the step from observed changes in leading spaces; an explicit width sets spaces per level. A level is drawn only for complete indentation steps. Interior blank lines continue only the levels shared by the surrounding nonblank lines when `blank-lines` is true; leading and trailing blank lines have no inferred guides.

With `rainbow: auto`, guides use delimiter rainbow colors when delimiter rainbow is enabled. Explicit `rainbow: true` enables palette coloring; `false` uses `color`. An explicit palette or depth offset overrides values inherited from delimiter rainbow settings. The palette must not be empty, width must be positive or `auto`, depth offset must be nonnegative or `auto`, and thickness must be positive. Invalid field types are rejected by the declared types.

Guides follow source indentation and extend across wrapped visual rows when smart indentation is enabled. `x-offset` shifts all guides horizontally without changing source columns.

## Example: Basic Usage

```yaml widgets
- type: switch
  name: guides-enabled
  label: Show indentation guides
  default: true
- type: select
  name: guide-width
  label: Spaces per level
  default: '4'
  options:
    - label: Two spaces
      value: '2'
    - label: Four spaces
      value: '4'
    - label: Eight spaces
      value: '8'
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```text
  root
      child
          leaf
      sibling
  root
  ```,
  indent-guides: if guides-enabled { (width: guide-width) } else { false },
)
````
