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

{{#arg-table types.indent-guides}}

## Behavior

> [!TIP] Check the inferred indentation step
> `width: auto` chooses the most frequently observed change in leading spaces; ties favor the smaller step, and no observed step falls back to four spaces. Set `width` explicitly when the source uses a known indentation size.

> [!NOTE] Only complete levels get guides
> A guide is drawn for each complete `width`-sized level. Indentation that does not reach the next complete level has no guide.

Set the block-level `indent-guides` field to `true` for defaults, `false` to disable inherited guides for one block, or a configuration to customize them. Interior blank lines continue only the levels shared by the surrounding nonblank lines when `blank-lines` is true; leading and trailing blank lines have no inferred guides.

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
