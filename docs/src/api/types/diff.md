# `codly.diff`

Configures automatic parsing, syntax highlighting, gutters, and row fills for raw blocks whose language is `diff,<language>`.

## Signature

```typst code
codly.diff(
  enabled: bool = true,
  added-fill: auto | paint | function = rgb("dafbe1"),
  removed-fill: auto | paint | function = rgb("ffebe9"),
  meta-fill: auto | paint | function = rgb("ddf4ff"),
  context-fill: auto | paint | function = auto,
  numbers: bool = true,
  markers: bool = true,
  added-marker: str | content = "+",
  removed-marker: str | content = "−",
  old-offset: int = 0,
  new-offset: int = 0,
)
```

The fields can also be supplied as a dictionary. A boolean casts to `enabled`.

## Fields

| Field | Type | Default | Meaning |
| --- | --- | --- | --- |
| `enabled` | `bool` | `true` | Enables diff processing. |
| `added-fill` | `auto` \| `paint` \| `function` \| `none` | `rgb("dafbe1")` | Fill for added rows. |
| `removed-fill` | `auto` \| `paint` \| `function` \| `none` | `rgb("ffebe9")` | Fill for removed rows. |
| `meta-fill` | `auto` \| `paint` \| `function` \| `none` | `rgb("ddf4ff")` | Fill for patch metadata rows. |
| `context-fill` | `auto` \| `paint` \| `function` \| `none` | `auto` | Fill for unchanged rows; `auto` follows the ordinary row fill. |
| `numbers` | `bool` | `true` | Shows automatic old-side and new-side line-number gutters. |
| `markers` | `bool` | `true` | Shows the automatic added/removed marker gutter. |
| `added-marker` | `str` \| `content` | `"+"` | Marker shown for added rows. |
| `removed-marker` | `str` \| `content` | `"−"` | Marker shown for removed rows. |
| `old-offset` | `int` | `0` | Added to old-side source line numbers. |
| `new-offset` | `int` | `0` | Added to new-side source line numbers. |

## Behavior

> [!TIP] Use the patch language prefix
> Set the raw block language to `diff,<language>`, such as `diff,py`, to enable patch parsing and highlight the changed code as Python.

> [!NOTE] Patch line coordinates
> References and line-based settings use displayed patch-row numbers. Highlight and callout character positions count code after the diff marker is removed.

> [!WARNING] Combined merge diffs are unsupported
> Codly parses unified patches, including multiple files and hunks, but not combined merge diff format.

Codly detects `diff,<language>` when the block-level `diff` setting is `auto` (the default). It removes the `diff,` prefix for syntax highlighting and renders old and new source views separately, so removed code does not affect new-side syntax state. Unified patches may contain multiple files and hunks; each is highlighted independently. Combined merge diffs are unsupported. A non-patch snippet may use ` `, `+`, and `-` prefixes for context, added, and removed rows.

Each fill accepts a paint, `none`, or `auto`; `auto` uses the ordinary row fill. A callback receives the row with a `diff` record containing `kind`, `old`, and `new` line coordinates, as well as the row's usual fields. Explicit highlights take precedence over diff fills. Setting `diff: false` or `diff: none` disables processing; setting it to `true` enables the default configuration. Custom `gutters` replace the automatic old/new/marker columns.

References and line-based settings use displayed patch-row numbers. Character positions for highlights and callouts refer to code after its diff marker is removed.

## Example: Basic Usage

```yaml widgets
- type: switch
  name: diff-enabled
  label: Process the diff
  default: true
```

````typst preview
#import "@preview/codly:2.0.0" as codly

#codly.new(
  ```diff,py
   shared
  -old = 1
  +new = 2
   tail
  ```,
  diff: if diff-enabled { auto } else { false },
)
````
